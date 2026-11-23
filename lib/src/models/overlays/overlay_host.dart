part of 'index.dart';

/// Renders the overlays shown with `showSnackbar` and `showDialog` next to
/// its [child], so they keep the theme and `Scaffold` context of the place
/// they are shown from.
///
/// `NakiApp` and `Scaffold` include one; the closest one shows the overlay.
class OverlayHost extends StatefulComponent {
  /// The content the overlays are shown next to.
  final Component child;

  /// Creates an [OverlayHost] around [child].
  const OverlayHost({super.key, required this.child});

  /// The closest [OverlayHostState] above [context], if any.
  static OverlayHostState? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<_OverlayHostScope>()?.state;

  @override
  State<OverlayHost> createState() => OverlayHostState();

  static List<StyleRule> get styles => OverlayModelStyles.overlayHost;
}

class OverlayHostState extends State<OverlayHost> {
  final _entries = <int, Component>{};
  int _nextId = 0;

  /// Shows [overlay] until [controller] closes, then removes it
  /// once its [exitDuration] exit animation has played.
  ///
  /// [onClosed] runs once, as soon as [controller] closes.
  void show(
    Component overlay, {
    required OverlayController controller,
    Duration exitDuration = const Duration(milliseconds: 200),
    VoidCallback? onClosed,
  }) {
    final id = _nextId++;

    void listener() {
      if (controller.isOpen) return;
      controller.removeListener(listener);
      onClosed?.call();
      Future.delayed(exitDuration, () {
        if (mounted) setState(() => _entries.remove(id));
      });
    }

    controller.addListener(listener);

    setState(() {
      _entries[id] = OverlayEntryScope(
        key: ValueKey('naki-overlay-$id'),
        controller: controller,
        child: Builder(builder: (_) => overlay),
      );
    });
  }

  @override
  Component build(BuildContext context) {
    return _OverlayHostScope(
      state: this,
      child: NakiFragment([
        component.child,

        // portal for overlays injected via OverlayScope
        const OverlayRegion(),

        // portal for overlays injected via show* functions
        if (_entries.isNotEmpty)
          .element(
            tag: 'naki-overlayhost',
            children: _entries.values.toList(),
          ),
      ]),
    );
  }
}

class _OverlayHostScope extends InheritedComponent {
  final OverlayHostState state;

  const _OverlayHostScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_OverlayHostScope oldComponent) =>
      state != oldComponent.state;
}
