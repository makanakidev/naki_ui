@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/src/theme/tokens.dart';
import 'package:naki_ui/theme.dart';

void main() {
  group('Theme data & schemes', () {
    test('LightThemeData and DarkThemeData expose expected color schemes', () {
      const light = LightThemeData();
      const dark = DarkThemeData();

      expect(light.colorScheme, 'light');
      expect(dark.colorScheme, 'dark');
    });

    test(
      'ColorSeed overrides primary color and supports copyWith/equality',
      () {
        const base = ColorSeed(primary: Color('#0f766e'));
        final updated = base.copyWith(secondary: const Color('#14b8a6'));
        const light = LightThemeData(colorSeed: base);

        expect(light.primaryColorValue, '#0f766e');
        expect(updated.primary, const Color('#0f766e'));
        expect(updated.secondary, const Color('#14b8a6'));
        expect(base == base.copyWith(), isTrue);
        expect(base == updated, isFalse);
      },
    );

    test('scheme copyWith and value equality behave consistently', () {
      const spacing = SpacingScheme(paddingSm: Dim.px(8));
      expect(spacing == spacing.copyWith(), isTrue);
      expect(spacing == spacing.copyWith(paddingMd: const Dim.px(16)), isFalse);

      const radius = RadiusScheme(radiusMd: Dim.px(10));
      expect(radius == radius.copyWith(), isTrue);
      expect(radius == radius.copyWith(radiusLg: const Dim.px(20)), isFalse);

      const borders = BorderScheme(borderWidth: Dim.px(1));
      expect(borders == borders.copyWith(), isTrue);
      expect(
        borders == borders.copyWith(focusBorderWidth: const Dim.px(2)),
        isFalse,
      );

      const elevation = ElevationScheme(shadowColor: Color('#000000'));
      expect(elevation == elevation.copyWith(), isTrue);
      expect(
        elevation == elevation.copyWith(smallShadowColor: const Color('#111')),
        isFalse,
      );

      const calendar = CalendarScheme(cellSize: Dim.px(36));
      expect(calendar == calendar.copyWith(), isTrue);
      expect(
        calendar == calendar.copyWith(dateFontSize: const Dim.px(13)),
        isFalse,
      );
    });

    test('custom styles map is merged into theme variables', () {
      const light = LightThemeData(styles: {'--custom-gap': '12px'});
      expect(light.variables['--custom-gap'], '12px');
    });

    test('ThemeConfig provides sensible defaults', () {
      const config = ThemeConfig();
      expect(config.initialMode, ThemeMode.system);
      expect(config.cacheThemeMode, isFalse);
      expect(config.styles, isEmpty);
      expect(ThemeConfig.defaultStyles, isNotEmpty);
    });
  });

  group('NakiThemeProvider', () {
    testComponents('propagates mode, brightness, and custom tokens', (
      tester,
    ) async {
      Brightness? activeBrightness;
      ThemeMode? activeMode;
      Tokens? activeTokens;

      tester.pumpComponent(
        NakiThemeProvider.fromConfig(
          configuration: const ThemeConfig(
            initialMode: ThemeMode.dark,
            darkThemeData: DarkThemeData(
              colorSeed: ColorSeed(primary: Color('#22d3ee')),
            ),
          ),
          builder: (context) {
            activeBrightness = NakiThemeProvider.brightnessOf(context);
            activeMode = NakiThemeProvider.modeOf(context);
            activeTokens = NakiThemeProvider.tokensOf(context);
            return const div([]);
          },
        ),
      );
      await tester.pump();

      expect(activeBrightness, Brightness.dark);
      expect(activeMode, ThemeMode.dark);
      expect(activeTokens, isNotNull);
      expect(activeTokens!.primaryColorValue, '#22d3ee');
    });

    test('new spacing, radius, elevation, and component tokens customize cleanly', () {
      const light = LightThemeData(
        spacing: SpacingScheme(paddingXs: Dim.px(6), marginXs: Dim.px(6)),
        radius: RadiusScheme(radiusXs: Dim.px(3), radiusFull: Dim.px(50)),
        elevation: ElevationScheme(
          cardShadow: '0 2px 4px rgba(0,0,0,0.2)',
          appbarShadow: 'none',
        ),
        component: ComponentScheme(
          disabledOpacity: 0.45,
          barrierBlur: Dim.px(12),
          appbarGlassBlur: Dim.px(16),
          spinnerGlassBlur: Dim.px(10),
          bottomSheetHandleColor: Color('#334155'),
        ),
      );

      expect(light.variables['--naki-padding-xs'], '6px');
      expect(light.variables['--naki-margin-xs'], '6px');
      expect(light.variables['--naki-radius-xs'], '3px');
      expect(light.variables['--naki-radius-full'], '50px');
      expect(light.variables['--naki-card-shadow'], '0 2px 4px rgba(0,0,0,0.2)');
      expect(light.variables['--naki-appbar-shadow'], 'none');
      expect(light.variables['--naki-disabled-opacity'], '0.45');
      expect(light.variables['--naki-barrier-blur'], '12px');
      expect(light.variables['--naki-appbar-glass-blur'], '16px');
      expect(light.variables['--naki-spinner-glass-blur'], '10px');
      expect(light.variables['--naki-bottom-sheet-handle-color'], '#334155');
    });
  });
}
