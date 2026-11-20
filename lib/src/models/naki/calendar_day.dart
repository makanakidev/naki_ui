part of 'index.dart';

/// A calendar day.
class CalendarDay {
  final DateTime date;
  final bool isSelected;
  final bool isDisabled;
  final bool isToday;

  const CalendarDay({
    required this.date,
    this.isSelected = false,
    this.isDisabled = false,
    this.isToday = false,
  });

  CalendarDay copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isDisabled,
    bool? isToday,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled,
      isToday: isToday ?? this.isToday,
    );
  }

  @override
  String toString() => date.toDateWithSlashes;
}
