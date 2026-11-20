part of '../index.dart';

class _CalendarGrid extends StatelessComponent {
  final String calendarId;
  final List<CalendarDay?> daysInMonth;
  final bool isMultiDayRange;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final ValueChanged<DateTime> onSelectDate;

  const _CalendarGrid({
    required this.calendarId,
    required this.daysInMonth,
    required this.isMultiDayRange,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onSelectDate,
  });

  /// Accessible label of a date cell, e.g. `Fri June 12, 2026, range start`
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
                ? const Component.empty()
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
