part of '../index.dart';

/// Internal weekday & day grid shared by [Calendar]
/// and dialog date pickers.
class NakiCalendarGrid extends StatelessComponent {
  final String calendarId;
  final List<CalendarDay?> daysInMonth;
  final bool isMultiDayRange;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onSelectDate;

  const NakiCalendarGrid({
    super.key,
    required this.calendarId,
    required this.daysInMonth,
    required this.isMultiDayRange,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onSelectDate,
  });

  /// Builds a [CalendarMonth] with selection and min/max bounds applied.
  static CalendarMonth buildMonth({
    required DateTime visibleDate,
    required DateTime minDate,
    required DateTime maxDate,
    required List<DateTime> selectedDates,
    bool isRange = false,
  }) {
    final first = DateTime(visibleDate.year, visibleDate.month, 1);
    final days = DateTime(visibleDate.year, visibleDate.month + 1, 0).day;
    final minOnly = dateOnly(minDate);
    final maxOnly = dateOnly(maxDate);

    bool isOutsideBounds(DateTime value) {
      final date = dateOnly(value);
      return date.isBefore(minOnly) || date.isAfter(maxOnly);
    }

    bool isSelected(DateTime date) {
      if (!isRange || selectedDates.length < 2) {
        return selectedDates.map(dateOnly).contains(date);
      }

      final start = dateOnly(selectedDates.first);
      final end = dateOnly(selectedDates.last);

      return !date.isBefore(start) && !date.isAfter(end);
    }

    final daysInMonth = <CalendarDay?>[
      for (var i = 1; i < first.weekday; i++) null,
      for (var day = 1; day <= days; day++)
        CalendarDay(
          date: DateTime(visibleDate.year, visibleDate.month, day),
          isSelected: isSelected(
            DateTime(visibleDate.year, visibleDate.month, day),
          ),
          isToday: DateTime(visibleDate.year, visibleDate.month, day).isToday,
          isDisabled: isOutsideBounds(
            DateTime(visibleDate.year, visibleDate.month, day),
          ),
        ),
    ];

    return CalendarMonth(date: visibleDate, days: daysInMonth);
  }

  /// Strips the time-of-day portion of [value].
  static DateTime dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  /// Accessible label of a date cell
  /// e.g. `Fri June 12, 2026, range start`
  String _dayLabel(CalendarDay day) {
    final label = day.date.toDayMonthYear;
    if (!isMultiDayRange) return label;
    if (day.date == rangeStart) return '$label, range start';
    if (day.date == rangeEnd) return '$label, range end';
    return label;
  }

  List<TableRow> _buildRows(BuildContext context) {
    final rows = <TableRow>[];
    final selectableDays = daysInMonth.whereType<CalendarDay>().where(
      (day) => !day.isDisabled,
    );

    final focusDay =
        selectableDays.where((day) => day.isSelected).firstOrNull ??
        selectableDays.where((day) => day.isToday).firstOrNull ??
        selectableDays.firstOrNull;

    final remainder = daysInMonth.length % 7;
    final paddedDays = [
      ...daysInMonth,
      if (remainder > 0) ...List.filled(7 - remainder, null),
    ];

    for (int i = 0; i < paddedDays.length; i += 7) {
      final rowDays = paddedDays.sublist(i, i + 7);
      final cells = rowDays
          .map(
            (day) => day == null
                ? const SizedBox()
                : Button.text(
                    '${day.date.day}',
                    id: '${calendarId}_day_${day.date.year}_${day.date.month}_${day.date.day}',
                    classes: 'naki-calendar-date',
                    backgroundColor: Colors.transparent,
                    foregroundColor: context.textColor,
                    disabled: day.isDisabled,
                    attributes: {
                      'aria-label': _dayLabel(day),
                      'aria-pressed': '${day.isSelected}',
                      'aria-current': ?(day.isToday ? 'date' : null),
                      'tabindex': identical(day, focusDay) ? '0' : '-1',
                      'data-today': ?(day.isToday ? '' : null),
                      'data-in-range': ?(isMultiDayRange && day.isSelected
                          ? ''
                          : null),
                      'data-range-start':
                          ?(isMultiDayRange && day.date == rangeStart
                          ? ''
                          : null),
                      'data-range-end':
                          ?(isMultiDayRange && day.date == rangeEnd
                          ? ''
                          : null),
                    },
                    onTap: () => onSelectDate(day.date),
                  ),
          )
          .toList();

      rows.add(TableRow(children: cells, classes: 'naki-calendar-week'));
    }

    return rows;
  }

  @override
  Component build(BuildContext context) {
    return Table(
      classes: 'naki-calendar-table',
      headers: [
        for (final day in kDays)
          NakiText(
            day,
            classes: 'naki-calendar-table-header',
            style: TextStyle(color: context.placeholderColor),
          ),
      ],
      rows: _buildRows(context),
    );
  }
}
