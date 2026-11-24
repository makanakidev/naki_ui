part of 'index.dart';

/// Manages an imperative stack of [NakiRoute]s alongside
/// `jaspr_router` and overlay scopes (`showDialog`,
/// `showModalBottomSheet`, `showDatePicker`,
/// `showTimePicker`, etc.).
///
/// Mounted automatically by `NakiApp` and also usable standalone.
class Navigator extends StatefulComponent {
  /// Root component shown when no imperative routes are pushed.
  final Component? home;

  /// Initial named route pushed on mount when specified.
  final String? initialRoute;

  /// Named route builders used by [pushNamed] and [initialRoute].
  final Map<String, ComponentBuilder>? routes;

  /// Fallback route factory invoked when [routes]
  /// does not contain a name.
  final NakiRouteFactory? onGenerateRoute;

  /// Fallback route factory invoked when
  /// [onGenerateRoute] returns `null`.
  final NakiRouteFactory? onUnknownRoute;

  /// Optional key pointing to a descendant `jaspr_router`
  /// [RouterState] so [Navigator.pushNamed] and
  /// [Navigator.pop] bridge cleanly with URL routing.
  final GlobalStateKey<RouterState>? routerKey;

  /// Creates a [Navigator].
  const Navigator({
    super.key,
    this.home,
    this.initialRoute,
    this.routes,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.routerKey,
  });

  /// Returns a [NakiRoutePredicate] that stops
  /// at a route named [name].
  static NakiRoutePredicate withName(String name) =>
      (route) => route.settings.name == name;

  /// Returns the [NavigatorState] enclosing [context],
  /// throwing a [StateError] if no [Navigator] exists.
  static NavigatorState of(
    BuildContext context, {
    bool rootNavigator = false,
  }) {
    final state = maybeOf(context, rootNavigator: rootNavigator);

    if (state == null) {
      throw StateError(
        'Navigator.of() called with a context that does not contain a '
        'Navigator. Wrap your app in NakiApp or Navigator.',
      );
    }

    return state;
  }

  /// Returns the nearest enclosing [NavigatorState],
  /// or `null` if none.
  static NavigatorState? maybeOf(
    BuildContext context, {
    bool rootNavigator = false,
  }) {
    var current =
        context
            .dependOnInheritedComponentOfExactType<_NavigatorScope>()
            ?.state ??
        context.findAncestorStateOfType<NavigatorState>();

    if (!rootNavigator) return current;

    while (current?._parentNavigator != null) {
      current = current!._parentNavigator;
    }

    return current;
  }

  /// Pushes [route] onto the navigator enclosing [context].
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    NakiRoute<T> route,
  ) => of(context).push<T>(route);

  /// Pushes a named route onto the navigator enclosing [context].
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) => of(context).pushNamed<T>(routeName, arguments: arguments);

  /// Replaces the current route with [newRoute], completing
  /// it with [result].
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    NakiRoute<T> newRoute, {
    TO? result,
  }) => of(context).pushReplacement<T, TO>(newRoute, result: result);

  /// Replaces the current route with a named route, completing
  /// the old route with [result].
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) => of(context).pushReplacementNamed<T, TO>(
    routeName,
    result: result,
    arguments: arguments,
  );

  /// Pushes [newRoute] and removes prior routes until [predicate]
  /// returns true.
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    NakiRoute<T> newRoute,
    NakiRoutePredicate predicate,
  ) => of(context).pushAndRemoveUntil<T>(newRoute, predicate);

  /// Pushes a named route and removes prior routes until [predicate]
  /// returns true.
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String newRouteName,
    NakiRoutePredicate predicate, {
    Object? arguments,
  }) => of(context).pushNamedAndRemoveUntil<T>(
    newRouteName,
    predicate,
    arguments: arguments,
  );

  /// Pops the current overlay (when [context] is inside an active overlay)
  /// or the top-most route on the navigator stack, passing optional
  /// [result].
  ///
  /// When neither an active overlay nor an imperative [NakiRoute] can be
  /// popped and a `jaspr_router` [RouterState] is present, delegates to
  /// `RouterState.back()`.
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    final overlayController = OverlayEntryScope.maybeOf(context);

    if (overlayController != null) {
      if (overlayController is OverlayResultController) {
        overlayController.closeWith(result);
      } else {
        overlayController.close();
      }
      return;
    }

    final navigator = maybeOf(context);
    if (navigator != null && navigator.canPop()) {
      navigator.pop<T>(result);
      return;
    }

    final router = _findRouterState(context, navigator);
    if (router != null) {
      router.back();
      return;
    }

    if (navigator == null || !navigator.canPop()) {
      throw StateError(
        'Navigator.pop() called with a context that has neither an active '
        'overlay nor an enclosing Navigator.',
      );
    }
  }

  /// Attempts to close an enclosing overlay or pop a route,
  /// returning whether anything was popped.
  static Future<bool> maybePop<T extends Object?>(
    BuildContext context, [
    T? result,
  ]) async {
    if (OverlayEntryScope.maybeOf(context) != null) {
      pop<T>(context, result);
      return true;
    }

    final navigator = maybeOf(context);
    if (navigator == null) return false;

    return navigator.maybePop<T>(result);
  }

  /// Whether [pop] would close an overlay or pop an imperative route.
  static bool canPop(BuildContext context) {
    if (OverlayEntryScope.maybeOf(context) != null) return true;
    return maybeOf(context)?.canPop() ?? false;
  }

  /// Repeatedly pops imperative routes until [predicate] returns `true`.
  static void popUntil(BuildContext context, NakiRoutePredicate predicate) =>
      of(context).popUntil(predicate);

  static RouterState? _findRouterState(
    BuildContext context,
    NavigatorState? navigator,
  ) =>
      navigator?.component.routerKey?.currentState ??
      context.findAncestorStateOfType<RouterState>();

  @override
  State<Navigator> createState() => NavigatorState();

  static List<StyleRule> get styles => NavigatorStyles.rules;
}

class _NavigatorScope extends InheritedComponent {
  final NavigatorState state;
  final int _generation;

  const _NavigatorScope({
    required this.state,
    required int generation,
    required super.child,
  }) : _generation = generation;

  @override
  bool updateShouldNotify(covariant _NavigatorScope oldComponent) =>
      oldComponent.state != state || oldComponent._generation != _generation;
}
