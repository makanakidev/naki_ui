import 'package:naki_ui/theme.dart';
import 'package:test/test.dart';

// Daylight saving changes depend on the time zone, so also run this with:
// TZ=America/New_York dart test test/date_range_test.dart
// TZ=Europe/London dart test test/date_range_test.dart
void main() {
  group('DateTime.daysThrough', () {
    void expectEveryDayAtMidnight(DateTime start, DateTime end, int count) {
      final days = start.daysThrough(end);

      expect(days, hasLength(count));
      expect(days.first, start);
      expect(days.last, end);
      expect(days.every((DateTime day) => day.hour == 0), isTrue);
    }

    test('crosses daylight saving changes', () {
      expectEveryDayAtMidnight(DateTime(2026, 3, 7), DateTime(2026, 3, 10), 4);
      expectEveryDayAtMidnight(DateTime(2026, 3, 27), DateTime(2026, 3, 31), 5);
      expectEveryDayAtMidnight(
        DateTime(2026, 10, 23),
        DateTime(2026, 10, 27),
        5,
      );
      expectEveryDayAtMidnight(
        DateTime(2026, 10, 30),
        DateTime(2026, 11, 3),
        5,
      );
    });

    test('returns one day when start and end match', () {
      expect(DateTime(2026, 2, 24).daysThrough(DateTime(2026, 2, 24)), [
        DateTime(2026, 2, 24),
      ]);
    });

    test('ignores the time of both dates', () {
      expect(
        DateTime(2026, 2, 24, 23).daysThrough(DateTime(2026, 2, 25, 1)),
        [DateTime(2026, 2, 24), DateTime(2026, 2, 25)],
      );
    });
  });

  test('DateTime.isBeforeDay ignores the time', () {
    expect(
      DateTime(2026, 2, 24, 23).isBeforeDay(DateTime(2026, 2, 24, 8)),
      isFalse,
    );
    expect(
      DateTime(2026, 2, 24, 8).isBeforeDay(DateTime(2026, 2, 25)),
      isTrue,
    );
  });
}
