// Refraction maths adapted from Liquid-Glass (https://github.com/zakisheriff/Liquid-Glass),
// MIT License, Copyright (c) 2026 Zaki Sheriff. See NOTICE.

import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:jaspr/jaspr.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart'
    show
        Blob,
        CanvasRenderingContext2D,
        Event,
        FileReader,
        HTMLCanvasElement,
        ImageData,
        window;

/// The optics of a liquid glass shape.
///
/// Linear ramps run across the whole box under a neutral core feathered
/// about twice the [bezel] deep, so a short bar bends across most of its
/// height. The left and right ends pull in content from past the edge, the
/// top and bottom from inside.
class RefractionShape {
  /// Width of the curved rim in pixels. The neutral core is inset by it.
  final double bezel;

  /// The deepest shift in pixels.
  final double thickness;

  const RefractionShape({required this.bezel, required this.thickness});
}

/// A displacement map and shape mask baked for one glass shape.
class RefractionField {
  /// Width of the baked images in samples.
  final int pixelWidth;

  /// Height of the baked images in samples.
  final int pixelHeight;

  /// Width of the filtered area in CSS pixels.
  final double width;

  /// Height of the filtered area in CSS pixels.
  final double height;

  /// RGBA displacement map. Red and green encode the horizontal and vertical
  /// shift around a neutral 128.
  final Uint8ClampedList map;

  /// RGBA mask with the exact rounded-rect alpha of the shape.
  final Uint8ClampedList mask;

  /// `feDisplacementMap` scale in CSS pixels.
  final double scale;

  /// Largest shift in CSS pixels anywhere in the map.
  final double maxShift;

  const RefractionField({
    required this.pixelWidth,
    required this.pixelHeight,
    required this.width,
    required this.height,
    required this.map,
    required this.mask,
    required this.scale,
    required this.maxShift,
  });
}

/// Bakes the displacement field of a [width] by [height] rounded rect with
/// corner [radius] through [shape].
///
/// [density] is samples per CSS pixel. It drops until the bake holds at most
/// about a million samples.
RefractionField bakeRefractionField({
  required double width,
  required double height,
  required double radius,
  required RefractionShape shape,
  double density = 1,
}) {
  final w = width;
  final h = height;
  final r = radius.clamp(0, math.min(width, height) / 2).toDouble();

  // The field is smooth but the rim is a hairline: below about one sample per
  // CSS pixel it breaks into dots, so big glass stays near full resolution.
  var d = density.clamp(0.35, 2).toDouble();
  while (w * h * d * d > 1000000 && d > 0.35) {
    d *= 0.85;
  }
  final cw = math.max(1, (w * d).ceil());
  final ch = math.max(1, (h * d).ceil());

  final dx = Float32List(cw * ch);
  final dy = Float32List(cw * ch);
  final inside = Float32List(cw * ch);
  var maxShift = 0.0001;

  final hw = width / 2;
  final hh = height / 2;
  final sample = 1 / d;

  // Samples stay clear of the shape's edge. Past it a backdrop filter reads
  // the corners of the bounding box, where the glass's own drop shadow sits,
  // and the outermost pixel ring is anti-aliased into that shadow. Stopping
  // samples dead at one ring would repeat it across the rim as streaks, so
  // samples ease toward a margin instead and nearby content is squeezed
  // smoothly. Pixels outside the shape are masked away, but they ease inside
  // too: the browser may blend neighbouring map pixels, and a neutral pixel
  // beside a strongly bent one would blend into a weak shift that reads the
  // shadow.
  (double, double) keepInside(double x, double y, double sx, double sy) {
    final (cx, cy) = _easeInside(x + sx, y + sy, hw, hh, r);
    return (cx - x, cy - y);
  }

  // A neutral core inset by the bezel, feathered by a Gaussian of half the
  // bezel and 97% opaque, over ramps that run across the whole box.
  final coreRadius = math.max(0.0, r - shape.bezel);
  final coreHalfWidth = math.max(0.0, hw - shape.bezel);
  final coreHalfHeight = math.max(0.0, hh - shape.bezel);
  final feather = math.max(shape.bezel / 2, 0.5);
  final depth = 2 * shape.thickness;

  for (var y = 0; y < ch; y++) {
    for (var x = 0; x < cw; x++) {
      final i = y * cw + x;
      final px = ((x + 0.5) * w) / cw - w / 2;
      final py = ((y + 0.5) * h) / ch - h / 2;

      final dist = _insideRoundedRect(px, py, hw, hh, r);
      final coverage = (dist / sample + 0.5).clamp(0.0, 1.0);
      final core =
          0.97 *
          _gaussianCdf(
            _insideRoundedRect(
                  px,
                  py,
                  coreHalfWidth,
                  coreHalfHeight,
                  coreRadius,
                ) /
                feather,
          );
      // Red runs from full at the left edge to none at the right, green
      // from none at the top to full at the bottom.
      // A shape with no width or height has nothing to ramp across.
      final rampX = width > 0 ? 1 - (px + hw) / width : 0.5;
      final rampY = height > 0 ? (py + hh) / height : 0.5;
      final (vx, vy) = keepInside(
        px,
        py,
        -depth * (core * 0.5 + (1 - core) * coverage * rampX - 0.5),
        -depth * (core * 0.5 + (1 - core) * coverage * rampY - 0.5),
      );
      dx[i] = vx;
      dy[i] = vy;
      maxShift = math.max(maxShift, math.max(vx.abs(), vy.abs()));
      inside[i] = coverage;
    }
  }

  final map = _filled(cw * ch, 128, 128, 128, 255);
  final mask = _filled(cw * ch, 255, 255, 255, 255);
  for (var i = 0; i < cw * ch; i++) {
    final o = i * 4;
    map[o] = (127.5 + (dx[i] / maxShift) * 127.5).round();
    map[o + 1] = (127.5 + (dy[i] / maxShift) * 127.5).round();
    mask[o + 3] = (inside[i] * 255).round();
  }

  return RefractionField(
    pixelWidth: cw,
    pixelHeight: ch,
    width: w,
    height: h,
    map: map,
    mask: mask,
    scale: maxShift * 2,
    maxShift: maxShift,
  );
}

/// Signed distance from ([px], [py]) to a rounded rect centred on the origin,
/// positive inside.
double _insideRoundedRect(
  double px,
  double py,
  double halfWidth,
  double halfHeight,
  double radius,
) {
  final qx = px.abs() - (halfWidth - radius);
  final qy = py.abs() - (halfHeight - radius);
  final ox = math.max(qx, 0.0);
  final oy = math.max(qy, 0.0);
  return radius -
      (math.sqrt(ox * ox + oy * oy) + math.min(math.max(qx, qy), 0.0));
}

/// Clear distance kept between a sample and the shape's edge, in pixels.
const _edgeMargin = 1.5;

/// Width of the band over which samples ease toward [_edgeMargin].
const _edgeEase = 3.0;

/// Moves ([x], [y]) inward along the edge normal of a rounded rect centred on
/// the origin, so it ends at least [_edgeMargin] inside.
///
/// Points deeper than `_edgeMargin + _edgeEase` stay put. Closer or outside,
/// the depth eases exponentially toward the margin, matching the untouched
/// depth and slope where the band begins, so order along the normal is kept.
(double, double) _easeInside(
  double x,
  double y,
  double halfWidth,
  double halfHeight,
  double radius,
) {
  final depth = _insideRoundedRect(x, y, halfWidth, halfHeight, radius);
  const start = _edgeMargin + _edgeEase;
  // A shape too small for the margin is left alone.
  if (depth >= start || math.min(halfWidth, halfHeight) <= start) {
    return (x, y);
  }
  final eased = _edgeMargin + _edgeEase * math.exp((depth - start) / _edgeEase);

  // Outward normal of the rounded rect at (x, y).
  final qx = x.abs() - (halfWidth - radius);
  final qy = y.abs() - (halfHeight - radius);
  double nx;
  double ny;
  if (qx > 0 && qy > 0) {
    final len = math.sqrt(qx * qx + qy * qy);
    nx = qx / len * (x < 0 ? -1 : 1);
    ny = qy / len * (y < 0 ? -1 : 1);
  } else if (qx > qy) {
    nx = x < 0 ? -1 : 1;
    ny = 0;
  } else {
    nx = 0;
    ny = y < 0 ? -1 : 1;
  }
  final inward = eased - depth;
  return (x - nx * inward, y - ny * inward);
}

/// Share of a unit Gaussian below [x]: how opaque a blurred edge is [x]
/// standard deviations inside it.
double _gaussianCdf(double x) {
  // Abramowitz and Stegun 7.1.26, accurate to about 1.5e-7.
  final z = x.abs() / math.sqrt2;
  final t = 1 / (1 + 0.3275911 * z);
  final poly =
      t *
      (0.254829592 +
          t *
              (-0.284496736 +
                  t * (1.421413741 + t * (-1.453152027 + t * 1.061405429))));
  final erf = 1 - poly * math.exp(-z * z);
  return 0.5 * (1 + (x < 0 ? -erf : erf));
}

/// An RGBA buffer of [pixels] pixels, all set to one colour.
Uint8ClampedList _filled(int pixels, int r, int g, int b, int a) {
  final bytes = Uint8ClampedList(pixels * 4);
  final word = Uint8List.fromList([r, g, b, a]).buffer.asUint32List()[0];
  bytes.buffer
      .asUint32List(bytes.offsetInBytes, pixels)
      .fillRange(0, pixels, word);
  return bytes;
}

/// A baked refraction, ready for [RefractionFilter].
class BakedRefraction {
  /// PNG data URL of the displacement map.
  final String map;

  /// PNG data URL of the shape mask.
  final String mask;

  /// Width of the filtered area in CSS pixels.
  final double width;

  /// Height of the filtered area in CSS pixels.
  final double height;

  /// `feDisplacementMap` scale in CSS pixels.
  final double scale;

  const BakedRefraction({
    required this.map,
    required this.mask,
    required this.width,
    required this.height,
    required this.scale,
  });
}

final _cache = <String, Future<BakedRefraction>>{};

/// Bakes [shape] for a [width] by [height] rounded rect with corner [radius]
/// and encodes it to PNG data URLs. Browser only.
///
/// Identical shapes share one bake. Bakes run one at a time in short slices,
/// so a page full of glass doesn't hold up the main thread.
Future<BakedRefraction> bakeRefraction({
  required double width,
  required double height,
  required double radius,
  required RefractionShape shape,
}) {
  final w = width.roundToDouble();
  final h = height.roundToDouble();
  final r = math.min(radius, math.min(w, h) / 2);
  final key = [
    w,
    h,
    (r * 2).round() / 2,
    shape.bezel,
    shape.thickness,
  ].join('|');

  return _cache[key] ??= _BakeQueue.run(() async {
    final field = bakeRefractionField(
      width: w,
      height: h,
      radius: r,
      shape: shape,
      density: math.min(window.devicePixelRatio, 2),
    );
    final [map, mask] = await Future.wait([
      _encode(field.pixelWidth, field.pixelHeight, field.map),
      _encode(field.pixelWidth, field.pixelHeight, field.mask),
    ]);
    return BakedRefraction(
      map: map,
      mask: mask,
      width: field.width,
      height: field.height,
      scale: field.scale,
    );
  });
}

/// Encodes RGBA [pixels] to a PNG data URL.
///
/// `toBlob` copies the pixels at once and encodes in the background, unlike
/// `toDataURL`, which holds up the page for tens of milliseconds per image.
Future<String> _encode(int width, int height, Uint8ClampedList pixels) {
  final canvas = HTMLCanvasElement()
    ..width = width
    ..height = height;
  final context = canvas.getContext('2d')! as CanvasRenderingContext2D;
  context.putImageData(ImageData(pixels.toJS, width, height.toJS), 0, 0);

  final done = Completer<String>();
  void fallback() {
    if (!done.isCompleted) done.complete(canvas.toDataURL());
  }

  canvas.toBlob(
    (Blob? blob) {
      if (blob == null) return fallback();
      final reader = FileReader();
      reader.onload = (Event _) {
        final result = reader.result;
        if (result.isA<JSString>()) {
          done.complete((result! as JSString).toDart);
        } else {
          fallback();
        }
      }.toJS;
      reader.onerror = (Event _) {
        fallback();
      }.toJS;
      reader.readAsDataURL(blob);
    }.toJS,
  );
  return done.future;
}

/// Runs bakes one after another, each in its own event-loop slice.
abstract final class _BakeQueue {
  static final _jobs = Queue<void Function()>();
  static var _running = false;

  static Future<T> run<T>(Future<T> Function() job) {
    final result = Completer<T>();
    _jobs.add(() => result.complete(Future.sync(job)));
    _pump();
    return result.future;
  }

  static void _pump() {
    if (_running) return;
    _running = true;

    void slice() {
      // Run bakes until about 8ms are spent, always at least one.
      final watch = Stopwatch()..start();
      do {
        _jobs.removeFirst()();
      } while (_jobs.isNotEmpty && watch.elapsedMilliseconds < 8);

      if (_jobs.isEmpty) {
        _running = false;
      } else {
        Timer.run(slice);
      }
    }

    Timer.run(slice);
  }
}

/// An SVG `<filter>` that bends content with a [BakedRefraction].
///
/// Render it inside an `<svg>` and point `backdrop-filter: url(#id)` at it.
/// Only Chromium runs an SVG filter there.
class RefractionFilter extends StatelessComponent {
  /// The filter's element id.
  final String id;

  /// The baked maps and scale.
  final BakedRefraction baked;

  /// Gaussian blur in CSS pixels applied after the bend.
  final double blur;

  /// Multiplies the baked bend without baking again. Below 1 every sample
  /// still lands inside the shape, which is convex, so the rim stays clean.
  final double strength;

  const RefractionFilter({
    required this.id,
    required this.baked,
    this.blur = 0,
    this.strength = 1,
    super.key,
  });

  @override
  Component build(BuildContext context) {
    final area = {
      'x': '0',
      'y': '0',
      'width': _n(baked.width),
      'height': _n(baked.height),
    };

    Component primitive(String tag, Map<String, String> attributes) =>
        .element(tag: tag, attributes: attributes);

    return .element(
      tag: 'filter',
      attributes: {
        'id': id,
        ...area,
        'filterUnits': 'userSpaceOnUse',
        'primitiveUnits': 'userSpaceOnUse',
        'color-interpolation-filters': 'sRGB',
      },
      children: [
        primitive('feImage', {
          'href': baked.map,
          ...area,
          'preserveAspectRatio': 'none',
          'result': 'field',
        }),
        primitive('feDisplacementMap', {
          'in': 'SourceGraphic',
          'in2': 'field',
          'scale': _n(baked.scale * strength),
          'xChannelSelector': 'R',
          'yChannelSelector': 'G',
          'result': 'bent',
        }),

        if (blur > 0)
          primitive('feGaussianBlur', {
            'in': 'bent',
            'stdDeviation': _n(blur),
            'result': 'bent',
          }),

        // The filter's output is a rectangle: bent light sampled past the rim
        // must not leak into the corners.
        primitive('feImage', {
          'href': baked.mask,
          ...area,
          'preserveAspectRatio': 'none',
          'result': 'shape',
        }),
        primitive('feComposite', {
          'in': 'bent',
          'in2': 'shape',
          'operator': 'in',
        }),
      ],
    );
  }
}

/// Formats [value] for an SVG attribute without trailing zeros.
String _n(double value) {
  final text = value.toStringAsFixed(6);
  return text.contains('.') ? text.replaceFirst(RegExp(r'\.?0+$'), '') : text;
}
