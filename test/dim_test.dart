import 'package:naki_ui/theme.dart';
import 'package:test/test.dart';

void main() {
  group('Dim.important', () {
    test('adds the declaration to any dimension', () {
      expect(const Dim.px(500).important.cssText, '500px !important');
      expect(const Dim.percent(50).important.cssText, '50% !important');
      expect(Dim.auto.important.cssText, 'auto !important');
      expect(Dim.zero.important.cssText, '0 !important');
      expect(
        const Dim.raw('calc(100% - 48px)').important.cssText,
        'calc(100% - 48px) !important',
      );
      expect(
        const Dim.variable('--gap', defaultValue: '8px').important.cssText,
        'var(--gap, 8px) !important',
      );
    });

    test('leaves the original dimension unchanged', () {
      const dim = Dim.px(500);

      expect(dim.important.isImportant, isTrue);
      expect(dim.isImportant, isFalse);
      expect(dim.cssText, '500px');
    });

    test('returns the same instance when already important', () {
      final dim = const Dim.px(500).important;

      expect(identical(dim.important, dim), isTrue);
    });

    test('is part of equality', () {
      expect(const Dim.px(500).important, isNot(const Dim.px(500)));
      expect(const Dim.px(500).important, const Dim.px(500).important);
      expect(
        const Dim(500, unit: 'px', important: true),
        const Dim.px(500).important,
      );
    });

    test('survives copyWith and arithmetic', () {
      final dim = const Dim.px(10).important;

      expect(dim.copyWith(value: 20).cssText, '20px !important');
      expect((dim + const Dim.px(5)).cssText, '15px !important');
      expect((dim - const Dim.px(5)).cssText, '5px !important');
      expect((dim * 2).cssText, '20px !important');
      expect((dim / 2).cssText, '5px !important');
      expect(dim.copyWith(important: false).cssText, '10px');
    });
  });

  test('named constructors stay constant and keep their units', () {
    const dims = <(Dim, String)>[
      (Dim.px(1), '1px'),
      (Dim.percent(1), '1%'),
      (Dim.em(1), '1em'),
      (Dim.rem(1), '1rem'),
      (Dim.vw(1), '1vw'),
      (Dim.vh(1), '1vh'),
      (Dim.vmin(1), '1vmin'),
      (Dim.vmax(1), '1vmax'),
      (Dim.dvh(1), '1dvh'),
      (Dim.dvw(1), '1dvw'),
      (Dim.svh(1), '1svh'),
      (Dim.svw(1), '1svw'),
      (Dim.lvh(1), '1lvh'),
      (Dim.lvw(1), '1lvw'),
      (Dim.deg(1), '1deg'),
      (Dim.rad(1), '1rad'),
      (Dim.grad(1), '1grad'),
      (Dim.maxContent, 'max-content'),
      (Dim.minContent, 'min-content'),
      (Dim.fitContent, 'fit-content'),
      (Dim.zero, '0'),
      (Dim.inherit, 'inherit'),
      (Dim.auto, 'auto'),
      (Dim.normal, 'normal'),
      (Dim.raw('calc(1px)'), 'calc(1px)'),
      (Dim.variable('--gap'), 'var(--gap)'),
    ];

    for (final (dim, css) in dims) {
      expect(dim.cssText, css);
    }
  });
}
