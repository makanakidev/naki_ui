part of '../theme.dart';

/// Represents customizable sizes for the `Calendar` picker.
///
/// On small screens (≤ 420px) each size is capped by its `compact*`
/// counterpart so the seven-day grid always fits the viewport; smaller themed
/// values are kept.
///
/// ### Example
/// ```dart
/// LightThemeData(
///   component: ComponentScheme(
///     calendar: CalendarScheme(cellSize: Dim.px(36), dateFontSize: Dim.px(13)),
///   ),
/// )
/// ```
class CalendarScheme {
  /// Day cell width and height (default: `42px`).
  final Dim? cellSize;

  /// Day number font size (default: `14px`).
  final Dim? dateFontSize;

  /// Weekday header font size (default: `13px`).
  final Dim? weekdayFontSize;

  /// Spacing around weekday headers (default: `5px`).
  final Dim? weekdayGap;

  /// Month / year title font size (default: `16px`).
  final Dim? titleFontSize;

  /// Time stepper width (default: `100px`).
  final Dim? stepperWidth;

  /// Time stepper input height (default: `50px`).
  final Dim? stepperHeight;

  /// Time stepper font size (default: `18px`).
  final Dim? stepperFontSize;

  /// Small-screen cap for [cellSize] (default: fits 7 columns, min `28px`).
  final Dim? compactCellSize;

  /// Small-screen cap for [dateFontSize] (default: `13px`).
  final Dim? compactDateFontSize;

  /// Small-screen cap for [weekdayFontSize] (default: `12px`).
  final Dim? compactWeekdayFontSize;

  /// Small-screen cap for [weekdayGap] (default: `2px`).
  final Dim? compactWeekdayGap;

  /// Small-screen cap for [titleFontSize] (default: `15px`).
  final Dim? compactTitleFontSize;

  /// Small-screen cap for [stepperHeight] (default: `40px`).
  final Dim? compactStepperHeight;

  /// Small-screen cap for [stepperFontSize] (default: `16px`).
  final Dim? compactStepperFontSize;

  const CalendarScheme({
    this.cellSize,
    this.dateFontSize,
    this.weekdayFontSize,
    this.weekdayGap,
    this.titleFontSize,
    this.stepperWidth,
    this.stepperHeight,
    this.stepperFontSize,
    this.compactCellSize,
    this.compactDateFontSize,
    this.compactWeekdayFontSize,
    this.compactWeekdayGap,
    this.compactTitleFontSize,
    this.compactStepperHeight,
    this.compactStepperFontSize,
  });

  CalendarScheme copyWith({
    Dim? cellSize,
    Dim? dateFontSize,
    Dim? weekdayFontSize,
    Dim? weekdayGap,
    Dim? titleFontSize,
    Dim? stepperWidth,
    Dim? stepperHeight,
    Dim? stepperFontSize,
    Dim? compactCellSize,
    Dim? compactDateFontSize,
    Dim? compactWeekdayFontSize,
    Dim? compactWeekdayGap,
    Dim? compactTitleFontSize,
    Dim? compactStepperHeight,
    Dim? compactStepperFontSize,
  }) {
    return CalendarScheme(
      cellSize: cellSize ?? this.cellSize,
      dateFontSize: dateFontSize ?? this.dateFontSize,
      weekdayFontSize: weekdayFontSize ?? this.weekdayFontSize,
      weekdayGap: weekdayGap ?? this.weekdayGap,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      stepperWidth: stepperWidth ?? this.stepperWidth,
      stepperHeight: stepperHeight ?? this.stepperHeight,
      stepperFontSize: stepperFontSize ?? this.stepperFontSize,
      compactCellSize: compactCellSize ?? this.compactCellSize,
      compactDateFontSize: compactDateFontSize ?? this.compactDateFontSize,
      compactWeekdayFontSize:
          compactWeekdayFontSize ?? this.compactWeekdayFontSize,
      compactWeekdayGap: compactWeekdayGap ?? this.compactWeekdayGap,
      compactTitleFontSize: compactTitleFontSize ?? this.compactTitleFontSize,
      compactStepperHeight: compactStepperHeight ?? this.compactStepperHeight,
      compactStepperFontSize:
          compactStepperFontSize ?? this.compactStepperFontSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarScheme &&
        other.cellSize == cellSize &&
        other.dateFontSize == dateFontSize &&
        other.weekdayFontSize == weekdayFontSize &&
        other.weekdayGap == weekdayGap &&
        other.titleFontSize == titleFontSize &&
        other.stepperWidth == stepperWidth &&
        other.stepperHeight == stepperHeight &&
        other.stepperFontSize == stepperFontSize &&
        other.compactCellSize == compactCellSize &&
        other.compactDateFontSize == compactDateFontSize &&
        other.compactWeekdayFontSize == compactWeekdayFontSize &&
        other.compactWeekdayGap == compactWeekdayGap &&
        other.compactTitleFontSize == compactTitleFontSize &&
        other.compactStepperHeight == compactStepperHeight &&
        other.compactStepperFontSize == compactStepperFontSize;
  }

  @override
  int get hashCode => Object.hash(
    cellSize,
    dateFontSize,
    weekdayFontSize,
    weekdayGap,
    titleFontSize,
    stepperWidth,
    stepperHeight,
    stepperFontSize,
    compactCellSize,
    compactDateFontSize,
    compactWeekdayFontSize,
    compactWeekdayGap,
    compactTitleFontSize,
    compactStepperHeight,
    compactStepperFontSize,
  );
}
