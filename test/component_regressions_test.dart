import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

void main() {
  group('text selection', () {
    test('TextStyle sets user-select for Safari too', () {
      expect(
        const TextStyle().props,
        containsPair('-webkit-user-select', 'none'),
      );
      expect(const TextStyle().props, containsPair('user-select', 'none'));
      expect(
        const TextStyle(selectable: true).props,
        containsPair('-webkit-user-select', 'text'),
      );
    });
  });

  group('application and theme regressions', () {
    test('NakiApp accepts its documented default location', () {
      expect(() => NakiApp(home: const div([])), returnsNormally);
    });

    testComponents('NakiApp resolves base path and asset URLs properly', (
      tester,
    ) async {
      tester.pumpComponent(
        NakiApp(
          basePath: '/naki_ui',
          favicon: 'assets/favicon.png',
          seo: const SEO(
            url: 'https://makanakidev.github.io/naki_ui',
            logo: 'assets/logo.png',
          ),
          home: const div([]),
        ),
      );
      await tester.pump();

      expect(
        find.byComponentPredicate(
          (c) =>
              c is DomComponent &&
              c.tag == 'base' &&
              c.attributes?['href'] == '/naki_ui/',
          description: 'base href tag',
        ),
        findsOneComponent,
      );

      expect(
        find.byComponentPredicate(
          (c) =>
              c is DomComponent &&
              c.tag == 'link' &&
              c.attributes?['rel'] == 'icon' &&
              c.attributes?['href'] == 'assets/favicon.png',
          description: 'favicon link tag',
        ),
        findsOneComponent,
      );

      expect(
        find.byComponentPredicate(
          (c) =>
              c is DomComponent &&
              c.tag == 'meta' &&
              c.attributes?['property'] == 'og:image' &&
              c.attributes?['content'] ==
                  'https://makanakidev.github.io/naki_ui/assets/logo.png',
          description: 'og:image meta tag',
        ),
        findsOneComponent,
      );
    });

    test('ThemeConfig instances are isolated', () {
      const light = LightThemeData(
        colorSeed: ColorSeed(primary: Color('#123456')),
      );
      const dark = DarkThemeData(
        colorSeed: ColorSeed(primary: Color('#abcdef')),
      );

      const first = ThemeConfig(
        initialMode: ThemeMode.light,
        lightThemeData: light,
      );
      const second = ThemeConfig(
        initialMode: ThemeMode.dark,
        darkThemeData: dark,
      );

      expect(identical(first, second), isFalse);
      expect(first.initialMode, ThemeMode.light);
      expect(second.initialMode, ThemeMode.dark);
      expect(first.lightThemeData, same(light));
      expect(second.darkThemeData, same(dark));
    });
  });

  group('component semantics regressions', () {
    testComponents('form buttons expose native reset and submit behavior', (
      tester,
    ) async {
      tester.pumpComponent(
        div([
          Button.text('Reset', resetForm: true),
          Button.text('Submit', type: ButtonType.submit),
        ]),
      );
      await tester.pump();

      expect(
        find.byComponentPredicate(
          (component) =>
              component is DomComponent &&
              component.tag == 'button' &&
              component.attributes?['type'] == 'reset',
          description: 'native reset button',
        ),
        findsOneComponent,
      );

      expect(
        find.byComponentPredicate(
          (component) =>
              component is DomComponent &&
              component.tag == 'button' &&
              component.attributes?['type'] == 'submit',
          description: 'native submit button',
        ),
        findsOneComponent,
      );
    });

    testComponents('interactive cards expose keyboard activation', (
      tester,
    ) async {
      tester.pumpComponent(Card(child: const NakiText('Open'), onTap: () {}));
      await tester.pump();

      expect(
        find.byComponentPredicate(
          (component) =>
              component is DomComponent &&
              component.tag == 'naki-card' &&
              component.attributes?['role'] == 'button' &&
              component.attributes?['tabindex'] == '0' &&
              component.events?.containsKey('click') == true &&
              component.events?.containsKey('keydown') == true,
          description: 'keyboard-operable card',
        ),
        findsOneComponent,
      );
    });

    testComponents('autocomplete binds keyboard handling to its text field', (
      tester,
    ) async {
      tester.pumpComponent(
        AutoCompleteField(
          id: 'fruit',
          options: const ['Apple', 'Banana'],
          onSelected: (_) {},
        ),
      );

      await tester.pump();

      expect(
        find.byComponentPredicate(
          (component) =>
              component is TextField &&
              component.events?.onKeyDown != null &&
              component.attributes?['role'] == 'combobox',
          description: 'autocomplete input with keyboard events',
        ),
        findsOneComponent,
      );
    });
  });
}
