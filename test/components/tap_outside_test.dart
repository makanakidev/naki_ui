@TestOn('browser')
library;

import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 80));

void _tapOutside() => web.document.body!.dispatchEvent(
  web.PointerEvent('pointerup', web.PointerEventInit(bubbles: true)),
);

web.Element? _query(String selector) => web.document.querySelector(selector);

void main() {
  group('Dropdown', () {
    Future<void> open(ClientTester tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Dropdown<int>(
            id: 'number',
            options: const [DropdownItem(label: 'One', value: 1)],
            onSelected: (_) {},
          ),
        ),
      );
      await _settle();

      (_query('.naki-dropdown-trigger')! as web.HTMLElement).click();
      await _settle();
    }

    testClient('closes on a tap outside', (tester) async {
      await open(tester);

      expect(_query('naki-dropdown[open]'), isNotNull);

      _tapOutside();
      await _settle();

      expect(_query('naki-dropdown[open]'), isNull);
    });

    testClient('stays open on a tap inside', (tester) async {
      await open(tester);

      _query('.naki-dropdown-menu')!.dispatchEvent(
        web.PointerEvent('pointerup', web.PointerEventInit(bubbles: true)),
      );
      await _settle();

      expect(_query('naki-dropdown[open]'), isNotNull);
    });
  });

  testClient('Autocomplete closes on a tap outside', (tester) async {
    tester.pumpComponent(
      NakiThemeProvider(
        builder: (_) => AutoCompleteField(
          id: 'fruit',
          options: const ['Apple', 'Apricot'],
          onSelected: (_) {},
        ),
      ),
    );
    await _settle();

    final input = _query('naki-autocomplete input')! as web.HTMLInputElement..value = 'Ap';
    input.dispatchEvent(web.Event('input', web.EventInit(bubbles: true)));
    await Future<void>.delayed(const Duration(milliseconds: 250));

    expect(_query('.naki-autocomplete-option'), isNotNull);

    _tapOutside();
    await _settle();

    expect(_query('.naki-autocomplete-option'), isNull);
  });
}
