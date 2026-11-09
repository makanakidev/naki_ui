// Overlays and the bottom bar only rebuild on the web, so these tests run in a
// browser: dart test -p chrome test/glass_test.dart
@TestOn('browser')
library;

import 'package:jaspr/dom.dart' show Color;
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/src/styles/css.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

web.HTMLElement _element(String selector) =>
    web.document.querySelector(selector)! as web.HTMLElement;

const _cardGlassColor = '--naki-card-glass-color';

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  group('Card.glass', () {
    testClient('uses the glass variant', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Card.glass(child: NakiText('Glass')),
        ),
      );
      await _settle();

      expect(
        _element('.naki-card').classList.contains('naki-card--glass'),
        isTrue,
      );
    });

    testClient('color tints the glass instead of covering it', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Card.glass(
            color: Color('#ff0000'),
            child: NakiText('Glass'),
          ),
        ),
      );
      await _settle();

      final card = _element('.naki-card');

      expect(card.style.getPropertyValue(_cardGlassColor), '#ff0000');
      expect(card.style.backgroundColor, isEmpty);
    });

    testClient('other variants keep a plain background', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Card(
            color: Color('#ff0000'),
            child: NakiText('Solid'),
          ),
        ),
      );
      await _settle();

      final card = _element('.naki-card');

      expect(card.style.getPropertyValue(_cardGlassColor), isEmpty);
      expect(card.style.backgroundColor, isNotEmpty);
    });
  });

  group('Dialog glass', () {
    Future<void> pumpDialog(ClientTester tester, {required bool glass}) async {
      final controller = OverlayController();

      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Scaffold(
            body: Dialog(controller: controller, glass: glass, title: 'Hi'),
          ),
        ),
      );
      await _settle();

      controller.open();
      await _settle();
    }

    testClient('adds the glass class', (tester) async {
      await pumpDialog(tester, glass: true);

      expect(
        _element('.naki-dialog').classList.contains('dialog-glass'),
        isTrue,
      );
    });

    testClient('is off by default', (tester) async {
      await pumpDialog(tester, glass: false);

      expect(
        _element('.naki-dialog').classList.contains('dialog-glass'),
        isFalse,
      );
    });
  });

  testClient('Popover styles content that is itself a wrapper', (tester) async {
    tester.pumpComponent(
      NakiThemeProvider(
        builder: (_) => const Popover(
          position: PopoverPosition.bottomLeft,
          content: Padding(
            padding: EdgeInsets.all(Dim.px(12)),
            child: NakiText('Details'),
          ),
          child: NakiText('Open'),
        ),
      ),
    );
    await _settle();

    expect(_element('.naki-popover-content').textContent, 'Details');
  });

  group('Dialog glass barrier', () {
    test('animates its color, not its opacity', () {
      // opacity below 1 would hide the page from the glass during the fade
      final backdrop = Css.nakiDialogStyle['glass-backdrop']!;
      final exit = Css.nakiDialogStyle['glass-backdrop-exit']!;

      expect(backdrop['animation'], contains('nakiDialogBarrierIn'));
      expect(exit['animation'], contains('nakiDialogBarrierOut'));
    });
  });

  group('glass theme values', () {
    test('default to the bottom navbar tint and a softer dark rim', () {
      const light = LightThemeData();
      const dark = DarkThemeData();

      expect(light.glassTint.value, '15%');
      expect(dark.glassTint.value, '30%');
      expect(light.glassRim.value, '100%');
      expect(dark.glassRim.value, '40%');
      expect(light.glassBlur.value, '16px');
      expect(light.bottomNavbarGlassRefractionValue, 100);
    });

    test('card and dialog glass tint matches the frosted navbar', () {
      const light = LightThemeData();
      const dark = DarkThemeData();

      expect(light.glassTint.value, light.bottomNavbarGlassTint.value);
      expect(dark.glassTint.value, dark.bottomNavbarGlassTint.value);
    });

    test('come from ComponentScheme', () {
      const theme = LightThemeData(
        component: ComponentScheme(
          glassTint: 30,
          glassRim: 50,
          glassBlur: Dim.px(8),
          bottomNavbarGlassRefraction: 0,
        ),
      );

      expect(theme.glassTint.value, '30%');
      expect(theme.glassRim.value, '50%');
      expect(theme.glassBlur.value, '8px');
      expect(theme.bottomNavbarGlassRefractionValue, 0);
    });
  });
}
