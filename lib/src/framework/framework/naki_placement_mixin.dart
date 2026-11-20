part of 'index.dart';

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
