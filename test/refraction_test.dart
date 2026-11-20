// The refraction maths is pure Dart, so these tests run on the VM.
@TestOn('vm')
library;

import 'dart:math' as math;

import 'package:naki_ui/src/utilities/refraction.dart';
import 'package:test/test.dart';

/// Red and green of the map pixel nearest CSS point ([x], [y]).
(int, int) _shiftAt(RefractionField field, double x, double y) {
  final px = (x / field.width * field.pixelWidth).floor();
  final py = (y / field.height * field.pixelHeight).floor();
  final o = (py * field.pixelWidth + px) * 4;
  return (field.map[o], field.map[o + 1]);
}

/// Decoded vertical shift in CSS pixels at ([x], [y]).
double _dyAt(RefractionField field, double x, double y) {
  final (_, g) = _shiftAt(field, x, y);
  return (g - 127.5) / 127.5 * field.maxShift;
}

int _alphaAt(RefractionField field, double x, double y) {
  final px = (x / field.width * field.pixelWidth).floor();
  final py = (y / field.height * field.pixelHeight).floor();
  return field.mask[(py * field.pixelWidth + px) * 4 + 3];
}

void main() {
  // The liquid glass bar's own shape.
  const glass = RefractionShape(bezel: 12, thickness: 13);
  final bar = bakeRefractionField(
    width: 360,
    height: 64,
    radius: 32,
    shape: glass,
  );

  /// Decoded shift in CSS pixels at ([x], [y]).
  (double, double) shiftPx(double x, double y) {
    final (r, g) = _shiftAt(bar, x, y);
    return (
      (r - 127.5) / 127.5 * bar.maxShift,
      (g - 127.5) / 127.5 * bar.maxShift,
    );
  }

  test('scale spans the largest shift both ways', () {
    expect(bar.scale, closeTo(bar.maxShift * 2, 1e-9));
  });

  test('masks the centre in and the corners out', () {
    expect(_alphaAt(bar, 180, 32), 255);
    expect(_alphaAt(bar, 0.5, 0.5), 0);
    expect(_alphaAt(bar, 359.5, 63.5), 0);
  });

  test('pulls toward the ends and from inside at top and bottom', () {
    // The top rim peaks near the 13px of the original map.
    expect(_dyAt(bar, 180, 0.5), inInclusiveRange(11, 13.5));
    final (left, _) = shiftPx(8, 32);
    final (right, _) = shiftPx(352, 32);
    final (_, top) = shiftPx(180, 0.5);
    final (_, bottom) = shiftPx(180, 63.5);
    // The ends read from further out, toward the edge.
    expect(left, lessThan(-5));
    expect(right, greaterThan(5));
    // The top reads from below and the bottom from above.
    expect(top, greaterThan(11));
    expect(bottom, lessThan(-11));
  });

  test('keeps samples clear of the pill edge', () {
    // Past the rounded ends lie the corners of the bounding box, where the
    // bar's own drop shadow sits: sampling them smears grey streaks.
    final step = bar.maxShift / 127.5;
    for (var y = 0; y < bar.pixelHeight; y++) {
      for (var x = 0; x < bar.pixelWidth; x++) {
        final o = (y * bar.pixelWidth + x) * 4;
        // Pixels the mask hides need not bend at all.
        if (_pillOutside(x + 0.5, y + 0.5) > 1) continue;
        final sx = x + 0.5 + (bar.map[o] - 127.5) * step;
        final sy = y + 0.5 + (bar.map[o + 1] - 127.5) * step;
        // Clear of the anti-aliased edge ring, give or take one map step.
        expect(
          _pillOutside(sx, sy),
          lessThanOrEqualTo(-1.5 + step * 1.5),
          reason: '($x, $y)',
        );
      }
    }
  });

  test('reaches deep into a short bar', () {
    final (_, y) = shiftPx(180, 12);
    expect(y, greaterThan(2));
  });

  test('leaves the centre all but still', () {
    final (x, y) = shiftPx(180, 32);
    expect(x.abs(), lessThan(0.6));
    expect(y.abs(), lessThan(0.6));
  });

  test('thinner glass bends less', () {
    final thin = bakeRefractionField(
      width: 360,
      height: 64,
      radius: 32,
      shape: const RefractionShape(bezel: 12, thickness: 6.5),
    );
    expect(_dyAt(thin, 180, 10), closeTo(_dyAt(bar, 180, 10) / 2, 0.2));
  });

  test('bakes an empty shape without NaN', () {
    final empty = bakeRefractionField(
      width: 0,
      height: 0,
      radius: 0,
      shape: glass,
    );
    expect(empty.scale.isFinite, isTrue);
    expect(empty.map.length, 4);
  });

  test('keeps large bakes near a million samples', () {
    final sheet = bakeRefractionField(
      width: 1600,
      height: 1200,
      radius: 24,
      shape: glass,
      density: 2,
    );
    expect(
      sheet.pixelWidth * sheet.pixelHeight,
      lessThanOrEqualTo(1000000 * 1.01),
    );
    expect(sheet.map.length, sheet.pixelWidth * sheet.pixelHeight * 4);
  });
}

/// Distance outside the 360×64 test bar's pill, in CSS pixels.
double _pillOutside(double x, double y) {
  final ox = math.max((x - 180).abs() - 148, 0.0);
  final oy = (y - 32).abs();
  return math.sqrt(ox * ox + oy * oy) - 32;
}
