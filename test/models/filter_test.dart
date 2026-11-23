import 'package:naki_ui/theme.dart';
import 'package:test/test.dart';

void main() {
  group('Filter cascading architecture', () {
    test('builds combined CSS from cascaded apply methods', () {
      final filter = Filter()
        ..applyBlur(10)
        ..applyBrightness(50)
        ..applyContrast(50)
        ..applyGrayscale(50)
        ..applyHueRotate(50)
        ..applyInvert(const Dim(1.5))
        ..applyOpacity(const Dim(0.5))
        ..applySaturation(const Dim.percent(50))
        ..applySepia(const Dim(0.5))
        ..applyRaw('drop-shadow(0 4px 8px rgba(0, 0, 0, 0.25))');

      const expected =
          'blur(10px) brightness(50%) contrast(50%) grayscale(50%) '
          'hue-rotate(50deg) invert(1.5) opacity(0.5) saturate(50%) sepia(0.5) '
          'drop-shadow(0 4px 8px rgba(0, 0, 0, 0.25))';

      expect(filter.cssText, expected);
      expect(filter.props, {
        'backdrop-filter': expected,
        '-webkit-backdrop-filter': expected,
      });
    });

    test('clamps out-of-range values and supports clear()', () {
      final filter = Filter()
        ..applyBlur(-5)
        ..applyBrightness(150)
        ..applyContrast(250)
        ..applyGrayscale(-10)
        ..applyHueRotate(500);

      expect(
        filter.cssText,
        'blur(0px) brightness(100%) contrast(100%) grayscale(0%) hue-rotate(360deg)',
      );

      filter.clear();
      expect(filter.cssText, isEmpty);
      expect(filter.props, {
        'backdrop-filter': '',
        '-webkit-backdrop-filter': '',
      });
    });

    test('presets remain intact', () {
      expect(
        Filter.frostedGlass.cssText,
        'blur(3px) brightness(50%) contrast(50%) grayscale(50%) '
        'hue-rotate(50deg) invert(1.5) opacity(0.5) saturate(50%) sepia(0.5)',
      );
      expect(Filter.dramaticOverlay.cssText, 'contrast(100%) grayscale(100%)');
      expect(Filter.dimBlur.cssText, 'blur(10px) opacity(0.5)');
    });
  });

  group('Standalone Filter subclasses', () {
    test('each subclass is a const Filter overriding cssText and props', () {
      const filters = <(Filter, String)>[
        (BlurFilter(10), 'blur(10px)'),
        (BrightnessFilter(50), 'brightness(50%)'),
        (ContrastFilter(75), 'contrast(75%)'),
        (GrayscaleFilter(25), 'grayscale(25%)'),
        (HueRotateFilter(180), 'hue-rotate(180deg)'),
        (InvertFilter(80), 'invert(80%)'),
        (OpacityFilter(50), 'opacity(50%)'),
        (SaturationFilter(140), 'saturate(140%)'),
        (SepiaFilter(60), 'sepia(60%)'),
        (
          RawFilter('drop-shadow(0 4px 8px #000)'),
          'drop-shadow(0 4px 8px #000)',
        ),
      ];

      for (final (filter, expectedCss) in filters) {
        expect(filter, isA<Filter>());
        expect(filter.cssText, expectedCss);
        expect(filter.props, {
          'backdrop-filter': expectedCss,
          '-webkit-backdrop-filter': expectedCss,
        });
      }
    });

    test('default constructors produce valid CSS defaults', () {
      expect(const BlurFilter().cssText, 'blur(0px)');
      expect(const BrightnessFilter().cssText, 'brightness(100%)');
      expect(const ContrastFilter().cssText, 'contrast(100%)');
      expect(const GrayscaleFilter().cssText, 'grayscale(0%)');
      expect(const HueRotateFilter().cssText, 'hue-rotate(0deg)');
      expect(const InvertFilter().cssText, 'invert(0%)');
      expect(const OpacityFilter().cssText, 'opacity(100%)');
      expect(const SaturationFilter().cssText, 'saturate(100%)');
      expect(const SepiaFilter().cssText, 'sepia(0%)');
    });

    test('clamps numeric subclasses and preserves value equality', () {
      expect(const BlurFilter(200), const BlurFilter(100));
      expect(const BlurFilter(-10), const BlurFilter(0));
      expect(const BrightnessFilter(200), const BrightnessFilter(100));
      expect(const ContrastFilter(-5), const ContrastFilter(0));
      expect(const GrayscaleFilter(150), const GrayscaleFilter(100));
      expect(const HueRotateFilter(400), const HueRotateFilter(360));
      expect(const InvertFilter(150), const InvertFilter(100));
      expect(const OpacityFilter(-10), const OpacityFilter(0));
      expect(const SaturationFilter(-10), const SaturationFilter(0));
      expect(const SaturationFilter(150).cssText, 'saturate(150%)');
      expect(const SepiaFilter(150), const SepiaFilter(100));
      expect(const BlurFilter(10), isNot(const BlurFilter(20)));
      expect(const BlurFilter(10), isNot(const BrightnessFilter(10)));
      expect(const RawFilter('a'), const RawFilter('a'));
      expect(const RawFilter('a'), isNot(const RawFilter('b')));
    });

    test(
      'mutating methods throw UnsupportedError on standalone subclasses',
      () {
        expect(
          () => const BlurFilter(10).applyBrightness(50),
          throwsUnsupportedError,
        );
        expect(() => const BlurFilter(10).clear(), throwsUnsupportedError);
      },
    );
  });

  group('Filter.and()', () {
    test('combines standalone subclasses without mutating inputs', () {
      const blur = BlurFilter(10);
      const brightness = BrightnessFilter(50);
      const contrast = ContrastFilter(80);

      final combined = blur.and(brightness).and(contrast);

      expect(combined.cssText, 'blur(10px) brightness(50%) contrast(80%)');
      expect(combined.props, {
        'backdrop-filter': 'blur(10px) brightness(50%) contrast(80%)',
        '-webkit-backdrop-filter': 'blur(10px) brightness(50%) contrast(80%)',
      });
      expect(blur.cssText, 'blur(10px)');
      expect(brightness.cssText, 'brightness(50%)');
    });

    test('works with empty Filter, cascaded Filter, and presets', () {
      final fromEmpty = Filter().and(const BlurFilter(8));
      expect(fromEmpty.cssText, 'blur(8px)');

      final withEmpty = const BlurFilter(8).and(Filter());
      expect(withEmpty.cssText, 'blur(8px)');

      final cascaded = (Filter()..applyBlur(10)).and(
        const BrightnessFilter(50),
      );
      expect(
        cascaded,
        Filter()
          ..applyBlur(10)
          ..applyBrightness(50),
      );

      final withTrailingCascade = const BlurFilter(10).and(
        const BrightnessFilter(50),
      )..applyContrast(50);
      expect(
        withTrailingCascade.cssText,
        'blur(10px) brightness(50%) contrast(50%)',
      );

      final presetSnapshot = Filter.dimBlur.cssText;
      final extendedPreset = Filter.dimBlur.and(const BrightnessFilter(80));
      expect(Filter.dimBlur.cssText, presetSnapshot);
      expect(extendedPreset.cssText, 'blur(10px) opacity(0.5) brightness(80%)');
    });
  });
}
