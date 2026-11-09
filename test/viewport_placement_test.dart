import 'package:naki_ui/src/utilities/enums.dart';
import 'package:naki_ui/src/utilities/helpers.dart';
import 'package:test/test.dart';

void main() {
  group('isToolbarHidden', () {
    bool hidden({
      num page = 874,
      num small = 660,
      num large = 874,
      num scale = 1,
    }) => isToolbarHidden(
      pageHeight: page,
      smallHeight: small,
      largeHeight: large,
      scale: scale,
    );

    test('when the page fills the largest viewport', () {
      expect(hidden(), isTrue);
      expect(hidden(page: 377, small: 296, large: 377), isTrue);
    });

    test('not with the toolbar showing or the keyboard open', () {
      expect(hidden(page: 660), isFalse);
      expect(hidden(page: 296, small: 296, large: 402), isFalse);
    });

    test('not in a Home Screen web app', () {
      expect(hidden(small: 874), isFalse);
    });

    test('not during pinch zoom', () {
      expect(hidden(scale: 2), isFalse);
    });
  });

  group('hiddenViewportInset', () {
    int inset({
      bool hidden = true,
      num page = 874,
      num inner = 768,
      num offset = 106,
    }) => hiddenViewportInset(
      hidden: hidden,
      pageHeight: page,
      innerHeight: inner,
      offsetTop: offset,
    );

    test('is the strip above the viewport with the toolbar hidden', () {
      expect(inset(), 106);
      expect(inset(page: 377, inner: 296, offset: 81), 81);
    });

    test('is 0 once the page is scrolled back into view', () {
      expect(inset(offset: 0), 0);
    });

    test('is 0 with the toolbar showing', () {
      expect(inset(hidden: false), 0);
    });
  });

  group('hiddenToolbarBottomInset', () {
    int inset({
      bool hidden = true,
      bool iPhone = true,
      num width = 402,
      num height = 874,
      bool landscape = false,
    }) => hiddenToolbarBottomInset(
      hidden: hidden,
      iPhone: iPhone,
      screenWidth: width,
      screenHeight: height,
      landscape: landscape,
    );

    test('is the home indicator with the toolbar hidden', () {
      expect(inset(), 34);
      expect(inset(landscape: true), 20);
    });

    test('is 0 while the toolbar is showing', () {
      expect(inset(hidden: false), 0);
    });

    test('is 0 on iPhones with a home button', () {
      expect(inset(width: 375, height: 667), 0);
    });

    test('is 0 off iPhone', () {
      expect(inset(iPhone: false), 0);
    });
  });

  group('placePicker', () {
    ({bool above, double? top, double? maxHeight}) place({
      required double height,
      required double anchorTop,
      required double anchorBottom,
    }) => placePicker(
      height: height,
      anchorTop: anchorTop,
      anchorBottom: anchorBottom,
      safeTop: 100,
      safeBottom: 700,
      gap: 10,
    );

    test('stays below the anchor when it fits there', () {
      final placement = place(height: 300, anchorTop: 150, anchorBottom: 200);

      expect(placement.above, isFalse);
      expect(placement.top, isNull);
      expect(placement.maxHeight, isNull);
    });

    test('flips above only when it fits there', () {
      final placement = place(height: 300, anchorTop: 500, anchorBottom: 550);

      expect(placement.above, isTrue);
      expect(placement.top, isNull);
    });

    test('never flips over the app bar', () {
      final placement = place(height: 420, anchorTop: 380, anchorBottom: 430);

      expect(placement.above, isFalse);
      expect(placement.top, 280);
      expect(placement.maxHeight, isNull);
    });

    test('caps a picker taller than the safe band', () {
      final placement = place(height: 900, anchorTop: 380, anchorBottom: 430);

      expect(placement.top, 100);
      expect(placement.maxHeight, 600);
    });
  });

  group('placePopover', () {
    const safe = (top: 100.0, right: 394.0, bottom: 640.0, left: 8.0);
    const gap = 8.0;

    ({double shiftX, double shiftY, double? maxHeight}) place(
      PopoverPosition position, {
      required ({double top, double right, double bottom, double left}) popover,
      required ({double top, double right, double bottom, double left}) anchor,
    }) => placePopover(
      position: position,
      popover: popover,
      anchor: anchor,
      safe: safe,
      gap: gap,
    );

    test('leaves a popover that already fits where it is', () {
      final placed = place(
        .bottomLeft,
        popover: (top: 308, right: 200, bottom: 408, left: 100),
        anchor: (top: 260, right: 200, bottom: 300, left: 100),
      );

      expect(placed.shiftX, 0);
      expect(placed.shiftY, 0);
      expect(placed.maxHeight, isNull);
    });

    test('flips above when only that side fits', () {
      final placed = place(
        .bottomLeft,
        popover: (top: 608, right: 200, bottom: 708, left: 100),
        anchor: (top: 560, right: 200, bottom: 600, left: 100),
      );

      // bottom lands gap above the anchor
      expect(708 + placed.shiftY, 560 - gap);
    });

    test('keeps a top popover above while both sides fit', () {
      final placed = place(
        .top,
        popover: (top: 292, right: 200, bottom: 392, left: 100),
        anchor: (top: 400, right: 200, bottom: 440, left: 100),
      );

      expect(placed.shiftY, 0);
    });

    test('flips a top popover below the app bar', () {
      final placed = place(
        .top,
        popover: (top: 12, right: 200, bottom: 112, left: 100),
        anchor: (top: 120, right: 200, bottom: 160, left: 100),
      );

      expect(12 + placed.shiftY, 160 + gap);
    });

    test('slides off the side insets without leaving its side', () {
      final placed = place(
        .bottom,
        popover: (top: 308, right: 460, bottom: 408, left: 260),
        anchor: (top: 260, right: 400, bottom: 300, left: 320),
      );

      expect(460 + placed.shiftX, safe.right);
      expect(placed.shiftY, 0);
    });

    test('flips a left popover to the right of a trigger at the edge', () {
      final placed = place(
        .left,
        popover: (top: 280, right: 12, bottom: 320, left: -188),
        anchor: (top: 280, right: 100, bottom: 320, left: 20),
      );

      expect(-188 + placed.shiftX, 100 + gap);
      expect(placed.shiftY, 0);
    });

    test('slides a right popover down out from under the app bar', () {
      final placed = place(
        .right,
        popover: (top: 60, right: 300, bottom: 140, left: 128),
        anchor: (top: 80, right: 120, bottom: 120, left: 20),
      );

      expect(60 + placed.shiftY, safe.top);
      expect(placed.shiftX, 0);
    });

    test('covers its trigger when neither side fits', () {
      final placed = place(
        .bottomLeft,
        popover: (top: 408, right: 200, bottom: 808, left: 100),
        anchor: (top: 360, right: 200, bottom: 400, left: 100),
      );

      expect(408 + placed.shiftY, 240);
      expect(808 + placed.shiftY, safe.bottom);
    });

    test('caps a popover taller than the safe band', () {
      final vertical = place(
        .bottomLeft,
        popover: (top: 308, right: 200, bottom: 1108, left: 100),
        anchor: (top: 260, right: 200, bottom: 300, left: 100),
      );
      final horizontal = place(
        .right,
        popover: (top: 0, right: 300, bottom: 800, left: 128),
        anchor: (top: 260, right: 120, bottom: 300, left: 20),
      );

      expect(vertical.maxHeight, safe.bottom - safe.top);
      expect(horizontal.maxHeight, safe.bottom - safe.top);
      expect(0 + horizontal.shiftY, safe.top);
    });
  });
}
