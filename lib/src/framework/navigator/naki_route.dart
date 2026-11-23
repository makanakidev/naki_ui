part of 'index.dart';

/// Abstraction for an imperative route managed by a [Navigator].
abstract class NakiRoute<T> {
  /// Metadata describing this route.
  final NakiRouteSettings settings;

  final Completer<T?> _popCompleter = Completer<T?>();
  NavigatorState? _navigator;
  bool _isActive = false;

  /// Creates a route with optional [settings].
  NakiRoute({this.settings = const NakiRouteSettings()});

  /// The [NavigatorState] currently hosting this route, if any.
  NavigatorState? get navigator => _navigator;

  /// Whether this route is currently in a navigator history stack.
  bool get isActive => _isActive;

  /// Whether this route is the top-most active route on its [navigator].
  bool get isCurrent => _navigator?._currentRoute == this;

  /// Whether the route state should remain mounted while
  /// covered by another route.
  bool get maintainState => true;

  /// Completes when this route is popped, with the pop result (if any).
  Future<T?> get completed => _popCompleter.future;

  /// Alias for [completed], matching Flutter's `Route.popped`.
  Future<T?> get popped => _popCompleter.future;

  /// Returns the closest enclosing [NakiRoute] typed as [T],
  /// or `null` if none.
  static NakiRoute<T>? of<T extends Object?>(BuildContext context) {
    final route = context
        .dependOnInheritedComponentOfExactType<_NakiRouteScope>()
        ?.route;
    return route is NakiRoute<T> ? route : null;
  }

  /// Returns the closest enclosing [NakiRoute], or `null` if none.
  static NakiRoute<dynamic>? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<_NakiRouteScope>()?.route;

  /// Builds the component subtree displayed for this route.
  Component buildPage(BuildContext context);

  /// Called when this route is inserted into a [Navigator].
  void didPush() {
    _isActive = true;
  }

  /// Called when this route replaces [oldRoute] in a [Navigator].
  void didReplace(NakiRoute<dynamic>? oldRoute) {
    _isActive = true;
  }

  /// Called when this route is popped with [result].
  void didPop(T? result) {
    _isActive = false;
    if (!_popCompleter.isCompleted) {
      _popCompleter.complete(result);
    }
  }

  /// Called on the newly uncovered route when [nextRoute] is popped.
  void didPopNext(NakiRoute<dynamic> nextRoute) {}

  /// Releases resources associated with this route.
  void dispose() {
    _isActive = false;
    if (!_popCompleter.isCompleted) {
      _popCompleter.complete(null);
    }
    _navigator = null;
  }

  void _completePop(Object? result) {
    if (result == null) {
      didPop(null);
    } else if (result is T) {
      didPop(result as T);
    } else {
      throw ArgumentError.value(
        result,
        'result',
        'Expected $T? when popping route ${settings.name ?? T}',
      );
    }
  }
}

/// A [NakiRoute] that builds its page content using a [ComponentBuilder].
class NakiPageRoute<T> extends NakiRoute<T> {
  /// Builder invoked to construct the route's page content.
  final ComponentBuilder builder;

  @override
  final bool maintainState;

  /// Creates a page route using [builder].
  NakiPageRoute({
    required this.builder,
    super.settings = const NakiRouteSettings(),
    this.maintainState = true,
  });

  @override
  Component buildPage(BuildContext context) => _NakiRouteScope(
    route: this,
    child: Builder(builder: builder),
  );
}

class _NakiRouteScope extends InheritedComponent {
  final NakiRoute<dynamic> route;

  const _NakiRouteScope({required this.route, required super.child});

  @override
  bool updateShouldNotify(covariant _NakiRouteScope oldComponent) =>
      oldComponent.route != route;
}
