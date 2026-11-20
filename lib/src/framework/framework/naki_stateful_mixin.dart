part of 'index.dart';

/// Mixin on `State` that provides post-render rendering callback hooks
/// (client-side only).
///
/// ### Example
/// ```dart
/// class MyComp extends StatefulComponent {
///   @override
///   State<MyComp> createState() => _MyCompState();
/// }
///
/// class _MyCompState extends State<MyComp> with NakiStatefulMixin {
///   @override
///   FutureOr<VoidCallback?> afterRender(BuildContext context) {
///     print('rendered!');
///     return () => print('cleanup!');
///   }
///
///   @override
///   Component build(BuildContext context) => ...;
/// }
/// ```
mixin NakiStatefulMixin<T extends StatefulComponent> on State<T> {
  VoidCallback? _cleanup;

  /// This method is called only once after the component is built and
  /// the browser has rendered it. Does nothing on server rendering.
  ///
  /// Override to perform actions after the component has fully painted.
  ///
  /// Can return a cleanup function to be executed when
  /// the component is unmounted.
  FutureOr<VoidCallback?> afterRender(BuildContext context) => null;

  @override
  void initState() {
    super.initState();
    refreshAfterRender();
  }

  /// Re-runs [afterRender], first disposing the previous render hook.
  ///
  /// Stateful components should call this from [didUpdateComponent] when a
  /// DOM-bound dependency such as a controller changes.
  void refreshAfterRender() {
    onComponentRendered(() async {
      if (!mounted) return;

      _cleanup?.call();
      _cleanup = null;

      final result = await afterRender(context);
      if (result is! VoidCallback) return;

      if (!mounted) {
        result();
        return;
      }

      _cleanup = result;
    });
  }

  @override
  void dispose() {
    _cleanup?.call();
    _cleanup = null;
    super.dispose();
  }
}
