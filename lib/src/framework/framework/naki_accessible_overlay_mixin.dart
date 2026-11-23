part of 'index.dart';

/// Mixin on `State` for modal overlays: moves focus into the
/// overlay, traps `Tab`, closes on `Escape` while top-most in
/// [NakiOverlayStack], and hands focus back when it closes.
///
/// Attach [overlaySurfaceKey] to the overlay's surface and call
/// [syncOverlayAccessibility] from `build` with its open state.
mixin NakiAccessibleOverlayMixin<T extends StatefulComponent> on State<T> {
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;
  HTMLElement? _previousFocus;
  bool _requestedOpen = false;

  /// Key for the overlay's surface, which holds focus
  /// and the `Tab` trap.
  final overlaySurfaceKey = GlobalNodeKey<HTMLElement>();

  /// Starts or stops managing focus as [open] changes;
  /// [close] runs on `Escape`.
  void syncOverlayAccessibility(bool open, VoidCallback close) {
    if (_requestedOpen == open) return;

    _requestedOpen = open;

    // capture the trigger before the overlay renders and
    // autofocus moves focus
    if (open && kIsWeb) _previousFocus = document.activeElement as HTMLElement?;

    onComponentRendered(() {
      if (!mounted) return;

      if (open) {
        _activateOverlay(close);
      } else {
        _deactivateOverlay();
      }
    });
  }

  List<HTMLElement> _focusableElements(HTMLElement surface) {
    final nodes = surface.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), '
      'select:not([disabled]), textarea:not([disabled]), '
      '[tabindex]:not([tabindex="-1"])',
    );

    final elements = <HTMLElement>[];

    for (var index = 0; index < nodes.length; index++) {
      final node = nodes.item(index) as HTMLElement?;
      if (node != null) elements.add(node);
    }

    return elements;
  }

  void _activateOverlay(VoidCallback close) {
    final surface = overlaySurfaceKey.currentNode;
    if (surface == null) return;

    NakiOverlayStack.push(this);

    final focusable = _focusableElements(surface);
    (focusable.isNotEmpty ? focusable.first : surface).focus();

    _keyboardSubscription?.cancel();
    _keyboardSubscription = EventStreamProviders.keyDownEvent
        .forTarget(document)
        .listen((event) {
          // only the top-most overlay handles keyboard
          // dismissal and trapping
          if (!NakiOverlayStack.isTop(this)) return;

          if (event.key == 'Escape') {
            event.preventDefault();
            event.stopPropagation();
            close();
            return;
          }

          if (event.key != 'Tab') return;

          final currentFocusable = _focusableElements(surface);
          if (currentFocusable.isEmpty) {
            event.preventDefault();
            surface.focus();
            return;
          }

          final first = currentFocusable.first;
          final last = currentFocusable.last;
          final active = document.activeElement;

          if (event.shiftKey &&
              (active == first || !surface.contains(active))) {
            event.preventDefault();
            last.focus();
          } else if (!event.shiftKey &&
              (active == last || !surface.contains(active))) {
            event.preventDefault();
            first.focus();
          }
        });
  }

  void _deactivateOverlay() {
    NakiOverlayStack.remove(this);
    _keyboardSubscription?.cancel();
    _keyboardSubscription = null;
    _previousFocus?.focus();
    _previousFocus = null;
    _requestedOpen = false;
  }

  @override
  void dispose() {
    _deactivateOverlay();
    super.dispose();
  }
}
