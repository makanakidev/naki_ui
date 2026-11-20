part of 'index.dart';

/// Mixin on `StatelessComponent` that provides post-render
/// rendering callback hooks (client-side only).
///
/// **Usage:**
/// ```dart
/// class MyComp extends StatelessComponent with NakiStatelessMixin {
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
mixin NakiStatelessMixin on StatelessComponent {
  /// This method is called only once after the component is built and
  /// the browser has rendered it. Does nothing on server rendering.
  ///
  /// Override to perform actions after the component has fully painted.
  ///
  /// Can return a cleanup function to be executed when
  /// the component is unmounted.
  FutureOr<VoidCallback?> afterRender(BuildContext context) => null;

  @override
  Element createElement() {
    final self = this;
    return _NakiStatelessElement(self);
  }
}
