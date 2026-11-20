part of 'index.dart';

/// A calendar month.
class CalendarMonth {
  final DateTime date;
  final List<CalendarDay?> days;

  const CalendarMonth({required this.date, required this.days});
}
