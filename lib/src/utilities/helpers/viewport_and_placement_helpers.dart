part of 'index.dart';

/// The heights of `100svh` and `100lvh`, in pixels.
({double small, double large}) viewportUnitHeights() {
  double measure(String height) {
    final probe = document.createElement('div') as HTMLElement;
    probe.style.cssText =
        'position:fixed;visibility:hidden;pointer-events:none;height:$height';
    document.body?.append(probe);

    final measured = probe.getBoundingClientRect().height;
    probe.remove();
    return measured;
  }

  return (small: measure('100svh'), large: measure('100lvh'));
}

/// Whether Safari's toolbar is hidden.
///
/// The page then fills the largest viewport, while it fills the smallest one
/// with the toolbar showing or the on-screen keyboard open. A Home Screen web
/// app has only one viewport size, and `env()` covers it. Pinch zoom changes
/// the [scale].
bool isToolbarHidden({
  required num pageHeight,
  required num smallHeight,
  required num largeHeight,
  required num scale,
}) {
  final zoomed = (scale - 1).abs() > 0.01;
  return !zoomed && pageHeight > smallHeight && pageHeight >= largeHeight - 0.5;
}

/// Height of the page hidden above the visible viewport, in pixels.
///
/// With its toolbar [hidden], Safari lays the page out taller than what it
/// shows and leaves the rest under the status bar and address bar, while
/// `env(safe-area-inset-top)` stays `0`.
int hiddenViewportInset({
  required bool hidden,
  required num pageHeight,
  required num innerHeight,
  required num offsetTop,
}) {
  if (!hidden) return 0;

  return max(0, min(offsetTop, pageHeight - innerHeight)).round();
}

/// Height of the iPhone home indicator while Safari's toolbar is [hidden].
///
/// The page reaches the bottom of the screen in that state, yet
/// `env(safe-area-inset-bottom)` stays `0` and nothing else reports the
/// indicator, so its height is the system value. Only iPhones without a home
/// button, which are taller than 2:1, have one.
int hiddenToolbarBottomInset({
  required bool hidden,
  required bool iPhone,
  required num screenWidth,
  required num screenHeight,
  required bool landscape,
}) {
  final shortSide = min(screenWidth, screenHeight);
  final longSide = max(screenWidth, screenHeight);
  if (!hidden || !iPhone || longSide < shortSide * 2) return 0;

  return landscape ? 20 : 34;
}

/// Where an open picker of [height] goes between [safeTop] and [safeBottom].
///
/// It stays [gap] below or above its anchor when it fits there, trying above
/// first when [preferAbove] is set. Otherwise [top] overrides that, covering
/// the anchor, and [maxHeight] caps a picker taller than the safe band.
({bool above, double? top, double? maxHeight}) placePicker({
  required double height,
  required double anchorTop,
  required double anchorBottom,
  required double safeTop,
  required double safeBottom,
  required double gap,
  bool preferAbove = false,
}) {
  final fitsBelow = height <= safeBottom - anchorBottom - gap;
  final fitsAbove = height <= anchorTop - safeTop - gap;

  if (fitsAbove && (preferAbove || !fitsBelow)) {
    return (above: true, top: null, maxHeight: null);
  }

  if (fitsBelow) return (above: false, top: null, maxHeight: null);

  final visible = min(height, safeBottom - safeTop);
  final lowestTop = max(safeTop, safeBottom - visible);

  return (
    above: false,
    top: (anchorBottom + gap).clamp(safeTop, lowestTop),
    maxHeight: height > visible ? visible : null,
  );
}

/// How far an open popover moves to stay inside [safe], in pixels.
///
/// [popover] is where its [position] put it against [anchor]. It flips to the
/// opposite side when only that side fits, and otherwise moves as little as
/// it takes, covering the anchor if it has to. [maxHeight] caps a popover
/// taller than the safe band.
({double shiftX, double shiftY, double? maxHeight}) placePopover({
  required PopoverPosition position,
  required ({double top, double right, double bottom, double left}) popover,
  required ({double top, double right, double bottom, double left}) anchor,
  required ({double top, double right, double bottom, double left}) safe,
  required double gap,
}) {
  final vertical =
      position != PopoverPosition.left && position != PopoverPosition.right;
  final before = switch (position) {
    PopoverPosition.top ||
    PopoverPosition.topLeft ||
    PopoverPosition.topRight ||
    PopoverPosition.left => true,
    _ => false,
  };

  // the side it opens towards, then the axis it slides along
  final start = vertical ? popover.top : popover.left;
  final size = vertical
      ? popover.bottom - popover.top
      : popover.right - popover.left;

  final side = placePicker(
    height: size,
    anchorTop: vertical ? anchor.top : anchor.left,
    anchorBottom: vertical ? anchor.bottom : anchor.right,
    safeTop: vertical ? safe.top : safe.left,
    safeBottom: vertical ? safe.bottom : safe.right,
    gap: gap,
    preferAbove: before,
  );

  final anchorStart = vertical ? anchor.top : anchor.left;
  final anchorEnd = vertical ? anchor.bottom : anchor.right;
  final stays = side.top == null && side.above == before;
  final target =
      side.top ?? (side.above ? anchorStart - gap - size : anchorEnd + gap);
  final sideShift = stays ? 0.0 : target - start;

  double slide(double from, double to, double safeFrom, double safeTo) {
    if (to - from > safeTo - safeFrom || from < safeFrom)
      return safeFrom - from;
    return to > safeTo ? safeTo - to : 0;
  }

  final slideShift = vertical
      ? slide(popover.left, popover.right, safe.left, safe.right)
      : slide(popover.top, popover.bottom, safe.top, safe.bottom);

  final band = safe.bottom - safe.top;
  final height = popover.bottom - popover.top;

  return (
    shiftX: vertical ? slideShift : sideShift,
    shiftY: vertical ? sideShift : slideShift,
    maxHeight: vertical ? side.maxHeight : (height > band ? band : null),
  );
}

/// The edges of [element], in viewport coordinates.
({double top, double right, double bottom, double left}) elementEdges(
  Element element,
) {
  final rect = element.getBoundingClientRect();
  return (
    top: rect.top.toDouble(),
    right: rect.right.toDouble(),
    bottom: rect.bottom.toDouble(),
    left: rect.left.toDouble(),
  );
}

/// The band anchored overlays stay in, in viewport coordinates: inside the
/// safe areas and the Scaffold's bars, [margin] away from all of them.
({double top, double right, double bottom, double left}) overlayBounds({
  double margin = 8,
}) {
  final safeArea = safeAreaInsets();

  final viewportWidth =
      (document.documentElement?.clientWidth ?? window.innerWidth).toDouble();
  final viewportHeight = window.innerHeight.toDouble();

  final appBarBottom = getVisibleElement(
    '.naki-appbar-wrapper .naki-appbar',
  )?.getBoundingClientRect().bottom.toDouble();

  final bottomBarTop = getVisibleElement(
    '.naki-navbar-wrapper .naki-bottombar',
  )?.getBoundingClientRect().top.toDouble();

  return (
    top: max(safeArea.top, appBarBottom ?? 0.0) + margin,
    right: viewportWidth - safeArea.right - margin,
    bottom:
        min(viewportHeight - safeArea.bottom, bottomBarTop ?? viewportHeight) -
        margin,
    left: safeArea.left + margin,
  );
}

/// The insets the page can't draw content in, in pixels.
///
/// The top one is only `env(safe-area-inset-top)`: what [hiddenViewportInset]
/// measures is above the viewport, so it doesn't reach into these coordinates.
({double top, double right, double bottom, double left}) safeAreaInsets() {
  if (kIsServer) return (top: 0, right: 0, bottom: 0, left: 0);

  final probe = document.createElement('div') as HTMLElement;
  probe.style.cssText =
      'position:fixed;visibility:hidden;pointer-events:none;padding:'
      'env(safe-area-inset-top,0px) ${Css.safeAreaRight} '
      '${Css.safeAreaBottom} ${Css.safeAreaLeft}';
  document.body?.append(probe);

  final style = window.getComputedStyle(probe);
  double read(String side) =>
      double.tryParse(
        style.getPropertyValue('padding-$side').replaceAll('px', ''),
      ) ??
      0;

  final insets = (
    top: read('top'),
    right: read('right'),
    bottom: read('bottom'),
    left: read('left'),
  );

  probe.remove();

  return insets;
}

/// Returns a visible HTML element that matches the selector.
///
/// When `deepSearch` is true, it returns the last visible element.
/// When `deepSearch` is false, it returns the first visible element.
HTMLElement? getVisibleElement(String selector, {bool deepSearch = false}) {
  if (kIsServer) return null;

  final nodes = document.querySelectorAll(selector);
  if (nodes.length == 0) return null;

  HTMLElement? target;

  for (int i = 0; i < nodes.length; i++) {
    final e = nodes.item(i) as HTMLElement;
    final styles = window.getComputedStyle(e);

    // skip if hidden by CSS
    if (styles.display == 'none' ||
        styles.visibility == 'hidden' ||
        styles.opacity == '0') {
      continue;
    }

    // skip if not rendered
    if (e.getClientRects().length == 0) continue;

    target = e;

    if (!deepSearch) break;
  }

  return target;
}
