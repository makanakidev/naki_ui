// Reads computed styles, so these tests run in a browser:
// dart test -p chrome test/spinner_test.dart
@TestOn('browser')
library;

import 'package:jaspr/dom.dart' show Color;
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

web.HTMLElement get _spinner =>
    web.document.querySelector('.naki-spinner')! as web.HTMLElement;

String get _type => _spinner.getAttribute('data-type')!;

void main() {
  void pumpSpinner(ClientTester tester, Spinner spinner) {
    tester.pumpComponent(NakiThemeProvider(builder: (_) => spinner));
  }

  group('Spinner', () {
    testClient('glass works without a surface color', (tester) async {
      pumpSpinner(tester, const Spinner.glass());

      expect(_type, 'glass');
      expect(
        _spinner.style.getPropertyValue('--naki-spinner-surface-color'),
        isEmpty,
      );
    });

    testClient('glass applies a custom surface color', (tester) async {
      pumpSpinner(
        tester,
        const Spinner.glass(surfaceColor: Color('#ffffff')),
      );

      expect(_type, 'glass');
      expect(
        _spinner.style.getPropertyValue('--naki-spinner-surface-color'),
        'rgb(from #ffffff r g b / 0.4)',
      );
    });

    testClient('surfaceColor keeps enabling glass', (tester) async {
      pumpSpinner(tester, const Spinner(surfaceColor: Color('#ffffff')));

      expect(_type, 'glass');
    });

    testClient('other spinners are not glass', (tester) async {
      pumpSpinner(tester, const Spinner());

      expect(_type, 'rounded');
    });
  });
}
