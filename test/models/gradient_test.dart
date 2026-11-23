import 'package:jaspr/dom.dart' show Color, Colors;
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/theme.dart';
import 'package:test/test.dart';

void main() {
  group('Gradient cascading architecture', () {
    test('builds combined CSS from cascaded apply methods', () {
      final gradient = Gradient()
        ..applyLinear(
          colors: const [Color('#3b82f6'), Colors.purple],
          direction: LinearGradientDirection.toRight,
          stops: const [Dim.px(20), Dim.percent(80)],
        )
        ..applyRadial(
          colors: const [Colors.red, Color('#feb47b')],
          shape: Shape.circle,
          position: RadialGradientPosition.center,
        )
        ..applyConic(
          colors: const [Color('#ff0000'), Color('#00ff00')],
          angle: 45,
          position: ConicGradientPosition.center,
        )
        ..applyRaw('linear-gradient(red, blue)');

      const expected =
          'linear-gradient(to right, #3b82f6 20px, purple 80%), '
          'radial-gradient(circle at center, red, #feb47b), '
          'conic-gradient(from 45.0deg at center, #ff0000, #00ff00), '
          'linear-gradient(red, blue)';

      expect(gradient.cssText, expected);
      expect(gradient.props, {'background-image': expected});
    });

    test('supports repeating gradients and clear()', () {
      final gradient = Gradient()
        ..applyRepeatingLinear(
          colors: const [Color('#000000'), Color('#ffffff')],
          angle: 405,
          stops: const [Dim.px(0), Dim.px(20)],
        )
        ..applyRepeatingRadial(
          colors: const [Color('#ff0000'), Color('#0000ff')],
          shape: Shape.circle,
          position: RadialGradientPosition.center,
          stops: const [Dim.px(0), Dim.px(15)],
        )
        ..applyRepeatingConic(
          colors: const [Color('#ff0000'), Color('#00ff00')],
          angle: 0,
          position: ConicGradientPosition.center,
          stops: const [Dim.deg(0), Dim.deg(20)],
        );

      expect(
        gradient.cssText,
        'repeating-linear-gradient(45.0deg, #000000 0px, #ffffff 20px), '
        'repeating-radial-gradient(circle at center, #ff0000 0px, #0000ff 15px), '
        'repeating-conic-gradient(from 0.0deg at center, #ff0000 0deg, #00ff00 20deg)',
      );

      gradient.clear();
      expect(gradient.cssText, isEmpty);
      expect(gradient.props, {'background-image': ''});
    });

    test('presets remain intact', () {
      expect(
        Gradient.sunset.cssText,
        'linear-gradient(135.0deg, #ff7e5f, #feb47b)',
      );
      expect(
        Gradient.oceanBreeze.cssText,
        'linear-gradient(to right, #2b5876, #4e4376)',
      );
      expect(
        Gradient.lush.cssText,
        'linear-gradient(to right, #56ab2f, #a8e063)',
      );
      expect(
        Gradient.purpleHaze.cssText,
        'linear-gradient(to right, #7303c0, #ec38bc, #fdeff9)',
      );
    });
  });

  group('Standalone Gradient subclasses', () {
    test('each subclass is a const Gradient overriding cssText and props', () {
      const gradients = <(Gradient, String)>[
        (
          LinearGradient(
            colors: [Color('#3b82f6'), Color('#8b5cf6')],
            direction: LinearGradientDirection.toBottomRight,
          ),
          'linear-gradient(to bottom right, #3b82f6, #8b5cf6)',
        ),
        (
          RadialGradient(
            colors: [Color('#f59e0b'), Color('#ef4444')],
            shape: Shape.circle,
            position: RadialGradientPosition.center,
          ),
          'radial-gradient(circle at center, #f59e0b, #ef4444)',
        ),
        (
          ConicGradient(
            colors: [Color('#ff0000'), Color('#00ff00'), Color('#0000ff')],
            angle: 45,
            position: ConicGradientPosition.center,
          ),
          'conic-gradient(from 45.0deg at center, #ff0000, #00ff00, #0000ff)',
        ),
        (
          RepeatingLinearGradient(
            colors: [Color('#000000'), Color('#ffffff')],
            angle: 45,
            stops: [Dim.px(0), Dim.px(20)],
          ),
          'repeating-linear-gradient(45.0deg, #000000 0px, #ffffff 20px)',
        ),
        (
          RepeatingRadialGradient(
            colors: [Color('#ff0000'), Color('#0000ff')],
            shape: Shape.ellipse,
            stops: [Dim.px(0), Dim.px(15)],
          ),
          'repeating-radial-gradient(ellipse, #ff0000 0px, #0000ff 15px)',
        ),
        (
          RepeatingConicGradient(
            colors: [Color('#ff0000'), Color('#00ff00')],
            position: ConicGradientPosition.topLeft,
            stops: [Dim.deg(0), Dim.deg(20)],
          ),
          'repeating-conic-gradient(at top left, #ff0000 0deg, #00ff00 20deg)',
        ),
        (
          RawGradient('linear-gradient(to top, #000, #fff)'),
          'linear-gradient(to top, #000, #fff)',
        ),
      ];

      for (final (gradient, expectedCss) in gradients) {
        expect(gradient, isA<Gradient>());
        expect(gradient.cssText, expectedCss);
        expect(gradient.props, {'background-image': expectedCss});
      }
    });

    test('preserves value equality across subclasses', () {
      const a = LinearGradient(
        colors: [Color('#000'), Color('#fff')],
        angle: 90,
      );
      const b = LinearGradient(
        colors: [Color('#000'), Color('#fff')],
        angle: 90,
      );
      const c = RepeatingLinearGradient(
        colors: [Color('#000'), Color('#fff')],
        angle: 90,
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(const RawGradient('a'), const RawGradient('a'));
      expect(const RawGradient('a'), isNot(const RawGradient('b')));
    });

    test(
      'mutating methods throw UnsupportedError on standalone subclasses',
      () {
        const linear = LinearGradient(colors: [Color('#000'), Color('#fff')]);
        expect(
          () =>
              linear.applyLinear(colors: const [Color('#111'), Color('#222')]),
          throwsUnsupportedError,
        );
        expect(() => linear.clear(), throwsUnsupportedError);
      },
    );
  });

  group('Gradient.and()', () {
    test('combines standalone subclasses without mutating inputs', () {
      const linear = LinearGradient(
        colors: [Color('#3b82f6'), Color('#8b5cf6')],
        direction: LinearGradientDirection.toRight,
      );
      const radial = RadialGradient(
        colors: [Color('#f59e0b'), Colors.transparent],
        shape: Shape.circle,
      );

      final combined = linear.and(radial);
      const expected =
          'linear-gradient(to right, #3b82f6, #8b5cf6), '
          'radial-gradient(circle, #f59e0b, transparent)';

      expect(combined.cssText, expected);
      expect(combined.props, {'background-image': expected});
      expect(
        linear.cssText,
        'linear-gradient(to right, #3b82f6, #8b5cf6)',
      );
      expect(radial.cssText, 'radial-gradient(circle, #f59e0b, transparent)');
    });

    test('works with empty Gradient, cascaded Gradient, and presets', () {
      const linear = LinearGradient(
        colors: [Color('#000'), Color('#fff')],
        angle: 90,
      );
      expect(Gradient().and(linear).cssText, linear.cssText);
      expect(linear.and(Gradient()).cssText, linear.cssText);

      final cascaded = (Gradient()..applyRaw('a')).and(const RawGradient('b'));
      expect(
        cascaded,
        Gradient()
          ..applyRaw('a')
          ..applyRaw('b'),
      );

      final withTrailingCascade = const RawGradient('a').and(
        const RawGradient('b'),
      )..applyRaw('c');
      expect(withTrailingCascade.cssText, 'a, b, c');

      final presetSnapshot = Gradient.sunset.cssText;
      final extendedPreset = Gradient.sunset.and(const RawGradient('overlay'));
      expect(Gradient.sunset.cssText, presetSnapshot);
      expect(extendedPreset.cssText, '$presetSnapshot, overlay');
    });
  });
}
