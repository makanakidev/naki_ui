part of 'index.dart';

/// State for a [Navigator] managing an imperative stack of [NakiRoute]s.
class NavigatorState extends State<Navigator> {
  final List<NakiRoute<dynamic>> _history = [];

  int _generation = 0;
  NavigatorState? _parentNavigator;

  NakiRoute<dynamic>? get _currentRoute =>
      _history.isEmpty ? null : _history.last;

  int get _minRouteCount => component.home != null ? 0 : 1;

  RouterState? get _router =>
      component.routerKey?.currentState ??
      context.findAncestorStateOfType<RouterState>();

  @override
  void initState() {
    super.initState();

    final initial = component.initialRoute;
    if (initial != null) {
      final route = _resolveRoute<dynamic>(NakiRouteSettings(name: initial));
      if (route != null) {
        route._navigator = this;
        route.didPush();
        _history.add(route);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentNavigator = context
        .dependOnInheritedComponentOfExactType<_NavigatorScope>()
        ?.state;
  }

  @override
  void dispose() {
    for (final route in _history) route.dispose();
    _history.clear();
    super.dispose();
  }

  /// Whether there is at least one route that can be popped
  /// off this navigator.
  bool canPop() => _history.length > _minRouteCount;

  /// Pushes [route] onto this navigator's stack.
  Future<T?> push<T extends Object?>(NakiRoute<T> route) {
    assert(route._navigator == null, 'Cannot push a route twice.');

    setState(() {
      route._navigator = this;
      route.didPush();
      _history.add(route);
      _generation++;
    });

    return route.completed;
  }

  /// Resolves and pushes a named route onto this navigator's stack.
  ///
  /// Falls back to `jaspr_router`'s [RouterState.push] when no
  /// matching route is registered on this [Navigator] and a
  /// router is attached.
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    final settings = NakiRouteSettings(name: routeName, arguments: arguments);
    final route = _resolveRoute<T>(settings, fallbackToUnknown: false);
    if (route != null) return push<T>(route);

    final router = _router;
    if (router != null) {
      router.push(routeName, extra: arguments);
      return Future<T?>.value(null);
    }

    final unknown = component.onUnknownRoute?.call(settings);
    if (unknown != null) return push<T>(unknown as NakiRoute<T>);

    throw StateError('No route found for "$routeName".');
  }

  /// Replaces the current route with [newRoute], completing
  /// the replaced route with [result].
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    NakiRoute<T> newRoute, {
    TO? result,
  }) {
    assert(newRoute._navigator == null, 'Cannot push a route twice.');

    setState(() {
      NakiRoute<dynamic>? oldRoute;

      if (_history.isNotEmpty) {
        oldRoute = _history.removeLast();
        oldRoute._completePop(result);
        oldRoute.dispose();
      }

      newRoute._navigator = this;
      newRoute.didReplace(oldRoute);
      _history.add(newRoute);
      _generation++;
    });

    return newRoute.completed;
  }

  /// Resolves and replaces the current route with [routeName].
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    final settings = NakiRouteSettings(name: routeName, arguments: arguments);
    final route = _resolveRoute<T>(settings, fallbackToUnknown: false);
    if (route != null) return pushReplacement<T, TO>(route, result: result);

    final router = _router;
    if (router != null) {
      router.replace(routeName, extra: arguments);
      return Future<T?>.value(null);
    }

    final unknown = component.onUnknownRoute?.call(settings);
    if (unknown != null) {
      return pushReplacement<T, TO>(unknown as NakiRoute<T>, result: result);
    }

    throw StateError('No route found for "$routeName".');
  }

  /// Pushes [newRoute] and pops preceding routes until
  /// [predicate] returns `true`.
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    NakiRoute<T> newRoute,
    NakiRoutePredicate predicate,
  ) {
    assert(newRoute._navigator == null, 'Cannot push a route twice.');

    setState(() {
      while (_history.isNotEmpty && !predicate(_history.last)) {
        final removed = _history.removeLast();
        removed.dispose();
      }

      newRoute._navigator = this;
      newRoute.didPush();
      _history.add(newRoute);
      _generation++;
    });

    return newRoute.completed;
  }

  /// Resolves [newRouteName], pushes it, and removes preceding
  /// routes until [predicate] returns `true`.
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    NakiRoutePredicate predicate, {
    Object? arguments,
  }) {
    final settings = NakiRouteSettings(
      name: newRouteName,
      arguments: arguments,
    );

    final route = _resolveRoute<T>(settings);
    if (route == null) {
      throw StateError('No route found for "$newRouteName".');
    }

    return pushAndRemoveUntil<T>(route, predicate);
  }

  /// Pops the top-most imperative route, completing its
  /// future with [result].
  void pop<T extends Object?>([T? result]) {
    if (!canPop()) {
      final router = _router;
      if (router != null) {
        router.back();
        return;
      }

      throw StateError('Cannot pop the root route of Navigator.');
    }

    setState(() {
      final popped = _history.removeLast();
      popped._completePop(result);
      popped.dispose();

      if (_history.isNotEmpty) {
        _history.last.didPopNext(popped);
      }

      _generation++;
    });
  }

  /// Pops the top-most route if [canPop] is `true`.
  Future<bool> maybePop<T extends Object?>([T? result]) async {
    if (!canPop()) return false;
    pop<T>(result);
    return true;
  }

  /// Pops routes from the stack until [predicate] returns `true`
  /// for the top route (or until reaching the root [home]).
  void popUntil(NakiRoutePredicate predicate) {
    if (_history.isEmpty) return;

    setState(() {
      while (_history.length > _minRouteCount && !predicate(_history.last)) {
        final popped = _history.removeLast();
        popped._completePop(null);
        popped.dispose();
      }
      _generation++;
    });
  }

  NakiRoute<T>? _resolveRoute<T>(
    NakiRouteSettings settings, {
    bool fallbackToUnknown = true,
  }) {
    final name = settings.name;
    final builder = name != null && component.routes != null
        ? component.routes![name]
        : null;

    if (builder != null) {
      return NakiPageRoute<T>(builder: builder, settings: settings);
    }

    final generated = component.onGenerateRoute?.call(settings);
    if (generated != null) return generated as NakiRoute<T>;

    if (fallbackToUnknown) {
      final unknown = component.onUnknownRoute?.call(settings);
      if (unknown != null) return unknown as NakiRoute<T>;
    }

    return null;
  }

  @override
  Component build(BuildContext context) {
    final List<Component> _routes = [
      for (var i = 0; i < _history.length; i++)
        if (i == _history.length - 1)
          .wrapElement(
            key: ValueKey(_history[i]),
            attributes: {'data-index': '$i'},
            child: _history[i].buildPage(context),
          )
        else if (_history[i].maintainState)
          .wrapElement(
            key: ValueKey(_history[i]),
            attributes: {'data-index': '$i'},
            classes: 'hide',
            child: _history[i].buildPage(context),
          ),
    ];

    if (Navigator.maybeOf(context) == null) {
      _routes.insert(0, const RawText('<!--@navigator-routes-->'));
      _routes.add(const RawText('<!--/@navigator-routes-->'));
    }

    final stack = NakiFragment(
      [
        if (component.home != null)
          .wrapElement(
            key: ValueKey(this),
            classes: _history.isEmpty ? null : 'hide',
            attributes: {'navigator-home': ''},
            child: component.home!,
          ),

        if (_history.isNotEmpty) ..._routes,
      ],
    );

    return _NavigatorScope(
      state: this,
      generation: _generation,
      child: OverlayHost.maybeOf(context) != null
          ? stack
          : OverlayHost(child: stack),
    );
  }
}
