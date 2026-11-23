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
        title: 'Hello',
        actions: (context) {
          dialog = context;
          return const [];
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
        title: 'Hi',
        barrierDismissible: true,
      );
      await _settle();

      (_query('naki-dialog')! as web.HTMLElement).click();

      expect(await result, isNull);
    });
  });

  group('showCustomDialog', () {
    testClient('shows custom dialog builder and resolves with result', (
      tester,
    ) async {
      late BuildContext shell;
      late BuildContext dialog;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showCustomDialog<String>(
        context: shell,
        builder: (context) {
          dialog = context;
          return const Dialog(title: 'Custom');
        },
      );
      await _settle();

      expect(_query('naki-dialog')?.textContent, contains('Custom'));

      closeDialog(dialog, 'custom-ok');

      expect(await result, 'custom-ok');

      await _settle(400);
      expect(_query('naki-dialog'), isNull);
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

    testClient('replaces back-to-back synchronous showSnackbar calls', (
      tester,
    ) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      showSnackbar(shell, const Snackbar(content: NakiText('First')));
      showSnackbar(shell, const Snackbar(content: NakiText('Second')));
      await _settle(400);

      final snackbars = web.document.querySelectorAll('naki-snackbar');
      expect(snackbars.length, 1);
      expect(snackbars.item(0)!.textContent, contains('Second'));
    });

    testClient('mounting open Snackbar closes prior open Snackbar post-build', (
      tester,
    ) async {
      final first = OverlayController(isOpen: true);
      final second = OverlayController(isOpen: true);

      tester.pumpComponent(
        Scaffold(
          body: Column(
            children: [
              Snackbar(controller: first, content: const NakiText('First')),
              Snackbar(controller: second, content: const NakiText('Second')),
            ],
          ),
        ),
      );
      await _settle(400);

      expect(first.isOpen, isFalse);
      expect(second.isOpen, isTrue);

      final snackbars = web.document.querySelectorAll('naki-snackbar');
      expect(snackbars.length, 1);
      expect(snackbars.item(0)!.textContent, contains('Second'));
    });
  });

  group('Navigator.pop overlay integration', () {
    testClient('Navigator.pop completes showDialog with typed result', (
      tester,
    ) async {
      late BuildContext shell;
      late BuildContext dialog;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final result = showDialog<String>(
        context: shell,
        title: 'Pop Dialog',
        builder: (context) {
          dialog = context;
          return const NakiText('Pop Dialog');
        },
      );
      await _settle();

      Navigator.pop(dialog, 'popped-ok');

      expect(await result, 'popped-ok');
      await _settle(400);
      expect(_query('naki-dialog'), isNull);
    });

    testClient(
      'Navigator.pop completes showModalBottomSheet with typed result',
      (tester) async {
        late BuildContext shell;
        late BuildContext sheet;
        tester.pumpComponent(_shell((context) => shell = context));
        await _settle();

        final result = showModalBottomSheet<int>(
          context: shell,
          builder: (context) {
            sheet = context;
            return const NakiText('Sheet');
          },
        );
        await _settle();

        Navigator.pop(sheet, 99);

        expect(await result, 99);
        await _settle(400);
        expect(_query('naki-bottomsheet'), isNull);
      },
    );
  });

  group('showDatePicker & showTimePicker', () {
    testClient('showDatePicker renders calendar grid and resolves via Ok', (
      tester,
    ) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final future = showDatePicker(
        context: shell,
        initialDate: DateTime(2026, 6, 15),
        firstDate: DateTime(2026, 1, 1),
        lastDate: DateTime(2026, 12, 31),
      );
      await _settle();

      expect(_query('naki-dialog'), isNotNull);
      expect(_query('.naki-date-picker'), isNotNull);

      final dayButton = _query('.naki-calendar-date[aria-pressed="true"]');
      expect(dayButton, isNotNull);

      final okButton =
          web.document
                  .querySelectorAll(
                    '.naki-calendar-footer .naki-calendar-action',
                  )
                  .item(2)
              as web.HTMLElement;
      okButton.click();

      expect(await future, DateTime(2026, 6, 15));
      await _settle(400);
      expect(_query('naki-dialog'), isNull);
    });

    testClient('showDatePicker resolves null on Cancel', (tester) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final future = showDatePicker(
        context: shell,
        initialDate: DateTime(2026, 6, 15),
      );
      await _settle();

      final cancelButton =
          web.document
                  .querySelectorAll(
                    '.naki-calendar-footer .naki-calendar-action',
                  )
                  .item(1)
              as web.HTMLElement;
      cancelButton.click();

      expect(await future, isNull);
    });

    testClient('showDateRangePicker resolves selected range on Ok', (
      tester,
    ) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final future = showDateRangePicker(
        context: shell,
        initialDateRange: [DateTime(2026, 6, 10), DateTime(2026, 6, 12)],
        firstDate: DateTime(2026, 1, 1),
        lastDate: DateTime(2026, 12, 31),
      );
      await _settle();

      final okButton =
          web.document
                  .querySelectorAll(
                    '.naki-calendar-footer .naki-calendar-action',
                  )
                  .item(2)
              as web.HTMLElement;
      okButton.click();

      final result = await future;
      expect(result, [
        DateTime(2026, 6, 10),
        DateTime(2026, 6, 11),
        DateTime(2026, 6, 12),
      ]);
    });

    testClient('showTimePicker renders time steppers and resolves via Ok', (
      tester,
    ) async {
      late BuildContext shell;
      tester.pumpComponent(_shell((context) => shell = context));
      await _settle();

      final initial = DateTime(2026, 6, 15, 14, 30);
      final future = showTimePicker(context: shell, initialTime: initial);
      await _settle();

      expect(_query('.naki-time-picker'), isNotNull);

      final okButton =
          web.document
                  .querySelectorAll(
                    '.naki-calendar-footer .naki-calendar-action',
                  )
                  .item(2)
              as web.HTMLElement;
      okButton.click();

      expect(await future, initial);
    });
  });
}
