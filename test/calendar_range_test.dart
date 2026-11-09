// Calendar relies on browser APIs and only rebuilds on the web, so these tests
// run in a browser: dart test -p chrome test/calendar_range_test.dart
@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

web.HTMLElement _element(String selector) =>
    web.document.querySelector(selector)! as web.HTMLElement;

String get _trigger => _element('.default_trigger').textContent!.trim();

web.HTMLElement _day(int year, int month, int day) =>
    _element('[id\$="_day_${year}_${month}_$day"]');

List<int> get _selectedDays {
  final nodes = web.document.querySelectorAll(
    '.naki-calendar-date[aria-pressed="true"]',
  );

  return [
    for (var index = 0; index < nodes.length; index++)
      int.parse(nodes.item(index)!.textContent!.trim()),
  ];
}

web.HTMLButtonElement _action(String text) {
  final nodes = web.document.querySelectorAll('.naki-calendar-action');

  for (var index = 0; index < nodes.length; index++) {
    final node = nodes.item(index)! as web.HTMLButtonElement;
    if (node.textContent!.trim() == text) return node;
  }

  throw StateError('No "$text" action');
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

Future<void> _click(web.HTMLElement element) async {
  element.click();
  await _settle();
}

/// A finger lifting off the page, away from the calendar and its trigger.
Future<void> _tapOutside() async {
  web.document.body!.dispatchEvent(
    web.PointerEvent('pointerup', web.PointerEventInit(bubbles: true)),
  );
  await _settle();
}

Future<void> _open() => _click(_element('.default_trigger'));

Future<void> _pick(int year, int month, int day) =>
    _click(_day(year, month, day));

/// Rebuilds with a new `minimum`, as `DateTime.now()` does in a parent's build.
class _MovingMinimum extends StatefulComponent {
  const _MovingMinimum();

  static VoidCallback rebuild = () {};

  @override
  State<_MovingMinimum> createState() => _MovingMinimumState();
}

class _MovingMinimumState extends State<_MovingMinimum> {
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _MovingMinimum.rebuild = () => setState(() => _seconds++);
  }

  @override
  Component build(BuildContext context) => Calendar(
    id: 'day',
    type: CalendarType.date,
    initialValue: DateTime(2026, 10, 5),
    minimum: DateTime(2026, 1, 1, 0, 0, _seconds),
  );
}

void main() {
  void pumpCalendar(
    ClientTester tester, {
    List<DateTime> initialRange = const [],
    ValueChanged<List<DateTime>>? onSelectedRange,
  }) {
    tester.pumpComponent(
      NakiThemeProvider(
        builder: (_) => Calendar(
          id: 'trip',
          type: CalendarType.range,
          initialRange: initialRange,
          onSelectedRange: onSelectedRange,
        ),
      ),
    );
  }

  group('Calendar date', () {
    testClient('marks a date that carries a time of day', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Calendar(
            id: 'day',
            type: CalendarType.date,
            initialValue: DateTime(2026, 10, 5, 14, 30),
          ),
        ),
      );
      await _settle();
      await _open();

      expect(_selectedDays, [5]);
    });

    testClient('stays marked when a rebuild moves the minimum', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(builder: (_) => const _MovingMinimum()),
      );
      await _settle();
      await _open();

      await _pick(2026, 10, 12);
      await _click(_action('Ok'));

      _MovingMinimum.rebuild();
      await _settle();
      await _open();

      expect(_selectedDays, [12]);
    });

    testClient('only its buttons close it', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Calendar(
            id: 'day',
            type: CalendarType.date,
            initialValue: DateTime(2026, 10, 5),
          ),
        ),
      );
      await _settle();
      await _open();

      await _pick(2026, 10, 12);
      await _tapOutside();

      expect(_selectedDays, [12]);

      await _click(_action('Cancel'));
      await _open();

      expect(_selectedDays, [5]);
    });
  });

  group('Calendar limits', () {
    testClient('disables dates outside minimum and maximum', (tester) async {
      DateTime? picked;
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Calendar(
            id: 'booking',
            type: CalendarType.date,
            initialValue: DateTime(2026, 5, 17),
            minimum: DateTime(2026, 5, 15),
            maximum: DateTime(2026, 5, 20),
            onSelected: (date) => picked = date,
          ),
        ),
      );
      await _settle();
      await _open();

      bool disabled(int day) => _day(2026, 5, day).hasAttribute('disabled');

      expect(
        [14, 15, 17, 20, 21].map(disabled),
        [true, false, false, false, true],
      );

      await _pick(2026, 5, 14);
      expect(picked, isNull);

      await _pick(2026, 5, 15);
      await _click(_action('Ok'));
      expect(picked, DateTime(2026, 5, 15));
    });
  });

  group('Calendar range', () {
    testClient('renders initialRange as a sorted, filled range', (
      tester,
    ) async {
      pumpCalendar(
        tester,
        initialRange: [DateTime(2026, 10, 30, 14), DateTime(2026, 10, 25)],
      );
      await _settle();

      expect(_trigger, contains('25/10/2026 - 30/10/2026'));

      await _open();

      expect(_selectedDays, [25, 26, 27, 28, 29, 30]);
      expect(_day(2026, 10, 25).hasAttribute('data-range-start'), isTrue);
      expect(_day(2026, 10, 30).hasAttribute('data-range-end'), isTrue);
    });

    testClient('emits every day of a range that crosses daylight saving', (
      tester,
    ) async {
      List<DateTime>? emitted;
      pumpCalendar(
        tester,
        initialRange: [DateTime(2026, 10, 1)],
        onSelectedRange: (range) => emitted = range,
      );
      await _settle();
      await _open();

      await _pick(2026, 10, 24);
      await _pick(2026, 10, 27);
      await _click(_action('Ok'));

      expect(emitted, [
        DateTime(2026, 10, 24),
        DateTime(2026, 10, 25),
        DateTime(2026, 10, 26),
        DateTime(2026, 10, 27),
      ]);
    });

    testClient('an open picker keeps its placement while selecting dates', (
      tester,
    ) async {
      const flippedAbove = '--naki-calendar-bottom';

      // a spacer pushes the trigger down, so the picker opens above it
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => div([
            div(
              id: 'spacer',
              styles: Styles(
                raw: {'height': '${web.window.innerHeight - 60}px'},
              ),
              const [],
            ),
            Calendar(
              id: 'trip',
              type: CalendarType.range,
              initialRange: [DateTime(2026, 6, 10)],
            ),
          ]),
        ),
      );
      await _settle();

      await _open();

      final modal = _element('.naki-calendar-modal');
      expect(modal.style.getPropertyValue(flippedAbove), '100%');

      // measuring again would now place it below the trigger
      _element('#spacer').style.height = '0';

      await _pick(2026, 6, 12);
      await _pick(2026, 6, 20);

      expect(modal.style.getPropertyValue(flippedAbove), '100%');
    });

    testClient('an open picker stays clear of the app bar and navbar', (
      tester,
    ) async {
      final height = web.window.innerHeight;

      // no space on either side of the trigger, and nothing to scroll
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => div([
            const span(classes: 'naki-appbar-wrapper', [
              div(
                classes: 'naki-appbar',
                styles: Styles(
                  raw: {
                    'position': 'fixed',
                    'top': '0',
                    'left': '0',
                    'right': '0',
                    'height': '40px',
                  },
                ),
                [],
              ),
            ]),
            const span(classes: 'naki-navbar-wrapper', [
              div(
                classes: 'naki-bottombar',
                styles: Styles(
                  raw: {
                    'position': 'fixed',
                    'bottom': '0',
                    'left': '0',
                    'right': '0',
                    'height': '40px',
                  },
                ),
                [],
              ),
            ]),
            div(
              styles: Styles(
                raw: {'height': '${(height / 2 - 20).round()}px'},
              ),
              const [],
            ),
            Calendar(id: 'trip', type: CalendarType.range),
          ]),
        ),
      );
      await _settle();
      await _open();
      await _settle();

      final rect = _element('.naki-calendar-modal').getBoundingClientRect();

      expect(rect.top, greaterThanOrEqualTo(47));
      expect(rect.bottom, lessThanOrEqualTo(height - 47));
    });

    testClient('Ok stays disabled until the range has an end date', (
      tester,
    ) async {
      pumpCalendar(tester, initialRange: [DateTime(2026, 10, 1)]);
      await _settle();
      await _open();

      await _pick(2026, 10, 5);
      expect(_action('Ok').disabled, isTrue);

      await _pick(2026, 10, 5);
      expect(_action('Ok').disabled, isFalse);
    });

    testClient('Escape discards a pending start date', (tester) async {
      pumpCalendar(tester, initialRange: [DateTime(2026, 10, 1)]);
      await _settle();
      await _open();

      await _pick(2026, 10, 5);
      web.document.dispatchEvent(
        web.KeyboardEvent('keydown', web.KeyboardEventInit(key: 'Escape')),
      );
      await _settle();

      await _open();
      await _pick(2026, 10, 10);

      expect(_selectedDays, [10]);
    });

    testClient('Cancel keeps the committed range styling', (tester) async {
      pumpCalendar(
        tester,
        initialRange: [DateTime(2026, 10, 1), DateTime(2026, 10, 3)],
      );
      await _settle();
      await _open();

      await _pick(2026, 10, 20);
      await _click(_action('Cancel'));
      await _open();

      expect(_selectedDays, [1, 2, 3]);
      expect(_day(2026, 10, 1).hasAttribute('data-range-start'), isTrue);
      expect(_day(2026, 10, 2).hasAttribute('data-in-range'), isTrue);
    });

    testClient('Reset keeps initialRange sorted', (tester) async {
      pumpCalendar(
        tester,
        initialRange: [DateTime(2026, 10, 30), DateTime(2026, 10, 25)],
      );
      await _settle();
      await _open();

      await _click(_action('Reset'));

      expect(_trigger, contains('25/10/2026 - 30/10/2026'));
    });

    testClient('a one-day range has no range edge styling', (tester) async {
      pumpCalendar(tester, initialRange: [DateTime(2026, 10, 5)]);
      await _settle();
      await _open();

      final day = _day(2026, 10, 5);

      expect(day.getAttribute('aria-pressed'), 'true');
      expect(day.hasAttribute('data-in-range'), isFalse);
      expect(day.hasAttribute('data-range-start'), isFalse);
    });

    testClient('trigger click discards a pending start date', (tester) async {
      pumpCalendar(tester, initialRange: [DateTime(2026, 10, 1)]);
      await _settle();
      await _open();

      await _pick(2026, 10, 5);
      await _open();

      expect(_trigger, contains('01/10/2026'));
    });

    testClient('rangeValidator receives every day of the range', (
      tester,
    ) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => Calendar(
            id: 'trip',
            type: CalendarType.range,
            initialRange: [DateTime(2026, 10, 1)],
            autoValidate: true,
            rangeValidator: (days) {
              if (days == null) return 'Select your travel dates';
              if (days.length > 3) return 'Trips can be up to 3 days';
              return null;
            },
          ),
        ),
      );
      await _settle();
      await _open();

      await _pick(2026, 10, 5);
      await _pick(2026, 10, 8);
      await _click(_action('Ok'));

      final input = _element('input[name="trip"]') as web.HTMLInputElement;

      expect(_element('naki-error').textContent, 'Trips can be up to 3 days');
      expect(input.validationMessage, 'Trips can be up to 3 days');

      await _open();
      await _pick(2026, 10, 5);
      await _pick(2026, 10, 7);
      await _click(_action('Ok'));

      expect(web.document.querySelector('naki-error'), isNull);
      expect(input.validationMessage, isEmpty);
    });

    testClient('submits the start and end dates as form values', (
      tester,
    ) async {
      pumpCalendar(
        tester,
        initialRange: [DateTime(2026, 10, 25), DateTime(2026, 10, 30)],
      );
      await _settle();

      final start = _element('input[name="trip"]') as web.HTMLInputElement;
      final end = _element('input[name="trip_end"]') as web.HTMLInputElement;

      expect(start.value, '2026-10-25');
      expect(end.value, '2026-10-30');
    });
  });
}
