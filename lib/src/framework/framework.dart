import 'dart:async';
import 'package:jaspr/jaspr.dart';

import '../utilities/helpers.dart' show onComponentRendered;

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
      if (result is VoidCallback) _cleanup = result;
    });
  }

  @override
  void dispose() {
    _cleanup?.call();
    _cleanup = null;
    super.dispose();
  }
}

/// Shared scheduling logic injected into elements
/// created by `NakiStatelessMixin`.
mixin _NakiScheduler on BuildableElement {
  VoidCallback? _cleanup;

  @override
  void didMount() {
    super.didMount();
    _schedule();
  }

  @override
  void update(Component newComponent) {
    super.update(newComponent);
    _schedule(newComponent);
  }

  @override
  void unmount() {
    _cleanup?.call();
    _cleanup = null;
    super.unmount();
  }

  void _schedule([Component? newComponent]) {
    final target = newComponent ?? component;

    if (target is NakiStatelessMixin) {
      onComponentRendered(() async {
        _cleanup?.call();
        _cleanup = null;

        final nState = target;
        final result = await nState.afterRender(this);

        if (result is VoidCallback) _cleanup = result;
      });
    }
  }
}

class _NakiStatelessElement extends StatelessElement with _NakiScheduler {
  _NakiStatelessElement(super.component);
}
