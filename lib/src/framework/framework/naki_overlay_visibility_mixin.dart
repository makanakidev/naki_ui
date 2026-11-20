part of 'index.dart';

/// Shared open / exit-animation state machine for overlays.
///
/// Exit state is owned by Dart and rendered through attributes, so reopening
/// during an exit animation cancels it instead of leaving a stale
/// `data-exiting` attribute on a reused DOM node.
mixin NakiOverlayVisibilityMixin<T extends StatefulComponent> on State<T> {
  bool _visible = false;
  bool _exiting = false;

  Timer? _exitTimer;

  /// Duration of the exit animation (matches the CSS keyframes).
  Duration get exitDuration;

  /// Whether the overlay is rendered, including while it animates out.
  bool get isVisible => _visible;

  /// Whether the overlay is open and not animating out.
  bool get isInteractive => _visible && !_exiting;

  /// Attributes applied to animated elements while exiting.
  Map<String, String> get exitAttributes =>
      _exiting ? const {'data-exiting': 'true', 'inert': ''} : const {};

  /// Updates visibility; pass `rebuild: false` from lifecycle methods that
  /// are already followed by a build.
  void syncVisibility(bool open, {bool rebuild = true}) {
    void update(VoidCallback fn) => rebuild ? setState(fn) : fn();

    if (open) {
      _exitTimer?.cancel();
      _exitTimer = null;

      if (_visible && !_exiting) return;

      update(() {
        _visible = true;
        _exiting = false;
      });

      return;
    }

    if (!_visible || _exiting) return;

    // nothing to animate on the server
    if (!kIsWeb) {
      _visible = false;
      return;
    }

    update(() => _exiting = true);

    _exitTimer = Timer(exitDuration, () {
      _exitTimer = null;

      setState(() {
        _visible = false;
        _exiting = false;
      });
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    super.dispose();
  }
}
