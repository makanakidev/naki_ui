import 'dart:async';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart'
    show
        Event,
        EventStreamProviders,
        HTMLElement,
        KeyboardEvent,
        document,
        window;

import '../styles/text_style.dart';
import '../utilities/helpers.dart'
    show listenTapOutside, onComponentRendered, overlayBounds;

import 'overlay_stack.dart';

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

/// Mixin on `State` that keeps an anchored overlay inside the safe areas and
/// the Scaffold's bars.
///
/// Give the overlay [placementKey], spread [placement] into its inline styles
/// and call [place] after it opens. The overlay is anchored to its parent.
/// [place] then measures it and keeps doing so while the viewport changes,
/// until [stopPlacing].
///
/// **Usage:**
/// ```dart
/// class _MyOverlayState extends State<MyOverlay> with NakiPlacementMixin {
///   @override
///   Map<String, String> computePlacement(overlay, anchor, bounds) => {
///     'translate': '0 ${bounds.top - overlay.getBoundingClientRect().top}px',
///   };
///
///   @override
///   Component build(BuildContext context) => div(
///     key: placementKey,
///     styles: Styles(raw: placement),
///     const [],
///   );
/// }
/// ```
mixin NakiPlacementMixin<T extends StatefulComponent> on State<T> {
  /// Key of the overlay being placed.
  final placementKey = GlobalNodeKey<HTMLElement>();

  /// Inline styles that place the overlay, kept here so rebuilds don't lose
  /// them.
  Map<String, String> get placement => _placement;
  Map<String, String> _placement = const {};

  StreamSubscription<Event>? _resizeSubscription;
  StreamSubscription<Event>? _tapSubscription;
  int _placedWidth = 0;

  /// Returns the inline styles that keep [overlay] inside [bounds].
  ///
  /// [overlay] is measured without any earlier placement, so it sits where
  /// its own styles put it.
  Map<String, String> computePlacement(
    HTMLElement overlay,
    HTMLElement anchor,
    ({double top, double right, double bottom, double left}) bounds,
  );

  /// Called when a tap lands outside the placed overlay and its anchor.
  void onTapOutside(Event event) {}

  /// Places the overlay now and again whenever the viewport's width changes.
  ///
  /// Scrolling doesn't place it again: it's a child of its anchor, so it
  /// scrolls with it wherever it was put. Neither does a height change, which
  /// is only a browser toolbar or the keyboard moving.
  void place() {
    final overlay = placementKey.currentNode;
    final anchor = overlay?.parentElement as HTMLElement?;
    if (overlay == null || anchor == null) return;

    final style = overlay.style;
    for (final name in _placement.keys) style.removeProperty(name);

    _placement = computePlacement(overlay, anchor, overlayBounds());
    _placement.forEach((name, value) => style.setProperty(name, value));

    _placedWidth = window.innerWidth;
    _resizeSubscription ??= EventStreamProviders.resizeEvent
        .forTarget(window)
        .listen((_) {
          if (window.innerWidth != _placedWidth) place();
        });

    _tapSubscription ??= listenTapOutside(
      () => placementKey.currentNode?.parentElement,
      onTapOutside,
    );
  }

  /// Stops following the viewport. [placement] stays, so an overlay that is
  /// still fading out doesn't move.
  void stopPlacing() {
    _resizeSubscription?.cancel();
    _resizeSubscription = null;
    _tapSubscription?.cancel();
    _tapSubscription = null;
  }

  @override
  void dispose() {
    stopPlacing();
    super.dispose();
  }
}

/// Mixin on `State` for modal overlays: moves focus into the overlay, traps
/// `Tab`, closes on `Escape` while top-most in [NakiOverlayStack], and hands
/// focus back when it closes.
///
/// Attach [overlaySurfaceKey] to the overlay's surface and call
/// [syncOverlayAccessibility] from `build` with its open state.
mixin NakiAccessibleOverlayMixin<T extends StatefulComponent> on State<T> {
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;
  HTMLElement? _previousFocus;
  bool _requestedOpen = false;

  /// Key for the overlay's surface, which holds focus and the `Tab` trap.
  final overlaySurfaceKey = GlobalNodeKey<HTMLElement>();

  /// Starts or stops managing focus as [open] changes; [close] runs on
  /// `Escape`.
  void syncOverlayAccessibility(bool open, VoidCallback close) {
    if (_requestedOpen == open) return;

    _requestedOpen = open;

    // capture the trigger before the overlay renders and autofocus moves focus
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

/// Mixin on Naki text components.
mixin NakiTextScope on StatelessComponent {
  /// Style applied to the text.
  TextStyle? get style;

  /// Additional CSS classes applied to the text.
  String? get classes;

  /// Additional HTML attributes applied to the text.
  Map<String, String>? get attributes;
}

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
