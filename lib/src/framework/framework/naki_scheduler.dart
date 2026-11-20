part of 'index.dart';

/// Shared scheduling logic injected into elements
/// created by `NakiStatelessMixin`.
mixin _NakiScheduler on BuildableElement {
  VoidCallback? _cleanup;
  bool _unmounted = false;

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
    _unmounted = true;
    _cleanup?.call();
    _cleanup = null;
    super.unmount();
  }

  void _schedule([Component? newComponent]) {
    final target = newComponent ?? component;

    if (target is NakiStatelessMixin) {
      onComponentRendered(() async {
        if (_unmounted) return;

        _cleanup?.call();
        _cleanup = null;

        final nState = target;
        final result = await nState.afterRender(this);
        if (result is! VoidCallback) return;

        if (_unmounted) {
          result();
          return;
        }

        _cleanup = result;
      });
    }
  }
}

class _NakiStatelessElement extends StatelessElement with _NakiScheduler {
  _NakiStatelessElement(super.component);
}
