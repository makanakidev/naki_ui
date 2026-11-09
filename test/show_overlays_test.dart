@TestOn('browser')
library;

import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle([int ms = 80]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

web.Element? _query(String selector) => web.document.querySelector(selector);

/// A Scaffold whose body hands its context to [onContext].
Component _shell(void Function(BuildContext) onContext) => Scaffold(
  body: Builder(
    builder: (context) {
      onContext(context);
      return const NakiText('body');
    },
  ),
);

void main() {
  group('showDialog', () {
    testClient('completes with the closeDialog result', (tester) async {
      late BuildContext shell;
      late BuildContext dialog;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showDialog<String>(
        context: shell,
        builder: (context) {
          dialog = context;
          return const Dialog(title: 'Hello');
        },
      );
      await _settle();

      expect(_query('naki-dialog'), isNotNull);

      closeDialog(dialog, 'ok');

      expect(await result, 'ok');

      await _settle(400);
      expect(_query('naki-dialog'), isNull);
    });

    testClient('completes with null when dismissed', (tester) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showDialog<bool>(
        context: shell,
        builder: (_) => const Dialog(title: 'Hi', barrierDismissible: true),
      );
      await _settle();

      (_query('naki-dialog')! as web.HTMLElement).click();

      expect(await result, isNull);
    });
  });

  group('showModalBottomSheet', () {
    testClient('completes with the closeModalBottomSheet result', (
      tester,
    ) async {
      late BuildContext shell;
      late BuildContext sheet;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showModalBottomSheet<String>(
        context: shell,
        builder: (context) {
          sheet = context;
          return const NakiText('Options');
        },
      );
      await _settle();

      expect(_query('naki-bottomsheet')?.textContent, contains('Options'));

      closeModalBottomSheet(sheet, 'mail');

      expect(await result, 'mail');

      await _settle(400);
      expect(_query('naki-bottomsheet'), isNull);
    });

    testClient('completes with null when dismissed', (tester) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showModalBottomSheet<String>(
        context: shell,
        builder: (_) => const NakiText('Options'),
      );
      await _settle();

      (_query('naki-bottomsheet')! as web.HTMLElement).click();

      expect(await result, isNull);
    });
  });

  group('showSnackbar', () {
    testClient('shows it until closeSnackbar', (tester) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      showSnackbar(shell, const Snackbar(content: NakiText('Saved')));
      await _settle();

      expect(_query('naki-snackbar')?.textContent, contains('Saved'));

      closeSnackbar();
      await _settle(400);

      expect(_query('naki-snackbar'), isNull);
    });

    testClient('clears the app bar of a Scaffold inside NakiApp', (
      tester,
    ) async {
      late BuildContext page;
      tester.pumpComponent(
        NakiApp(
          home: Scaffold(
            appBar: const AppBar(title: NakiText('Title')),
            body: Builder(
              builder: (context) {
                page = context;
                return const NakiText('body');
              },
            ),
          ),
        ),
      );
      await _settle();

      showSnackbar(
        page,
        const Snackbar(
          position: SnackbarPosition.top,
          content: NakiText('Saved'),
        ),
      );
      await _settle();

      final snackbar = _query('naki-snackbar')! as web.HTMLElement;
      expect(
        snackbar.style.getPropertyValue('--naki-snackbar-offset-y'),
        contains('appbar'),
      );
    });

    testClient('replaces the snackbar already open', (tester) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      showSnackbar(shell, const Snackbar(content: NakiText('First')));
      await _settle();
      showSnackbar(shell, const Snackbar(content: NakiText('Second')));
      await _settle(400);

      final snackbars = web.document.querySelectorAll('naki-snackbar');
      expect(snackbars.length, 1);
      expect(snackbars.item(0)!.textContent, contains('Second'));
    });
  });
}
