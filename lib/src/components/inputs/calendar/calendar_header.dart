part of '../index.dart';

/// Internal header bar shared by [Calendar] and dialog date pickers.
class NakiCalendarHeader extends StatelessComponent {
  final DateTime visibleDate;
  final DateTime minDate;
  final DateTime maxDate;
  final bool showYear;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onToggleYearPicker;
  final Component yearMonthPopover;
  final VoidCallback onCloseYearPicker;

  const NakiCalendarHeader({
    super.key,
    required this.visibleDate,
    required this.minDate,
    required this.maxDate,
    required this.showYear,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onToggleYearPicker,
    required this.yearMonthPopover,
    required this.onCloseYearPicker,
  });

  @override
  Component build(BuildContext context) {
    final currentMonth = visibleDate.month;
    final currentYear = visibleDate.year;

    return Row(
      classes: 'naki-calendar-header',
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 5,
      children: [
        // goto previous month
        Button.icon(
          MaterialSymbols.round_chevron_left,
          semanticLabel: 'Previous month',
          classes: 'naki-calendar-header-action',
          disabled:
              currentYear == minDate.year && currentMonth == minDate.month,
          height: const Dim.px(40),
          width: const Dim.px(40),
          backgroundColor: Colors.transparent,
          foregroundColor: context.textColor,
          disabledBackgroundColor: Colors.transparent,
          onTap: onPreviousMonth,
        ),

        // visible month and year
        Popover(
          visible: showYear,
          child: Button.iconText(
            icon: MaterialIcons.icon_round_arrow_drop_down,
            text: visibleDate.toMonthYear,
            classes: 'naki-calendar-year-btn',
            height: const Dim.px(40),
            iconSize: 28,
            foregroundColor: context.placeholderColor,
            backgroundColor: Colors.transparent,
            hoverColor: Colors.transparent,
            attributes: {'showyear': ?(showYear ? '' : null)},
            onTap: onToggleYearPicker,
          ),
          content: showYear ? yearMonthPopover : const SizedBox(),
          onClose: onCloseYearPicker,
          position: PopoverPosition.bottom,
        ),

        // goto next month
        Button.icon(
          MaterialSymbols.round_chevron_right,
          semanticLabel: 'Next month',
          classes: 'naki-calendar-header-action',
          disabled:
              currentYear == maxDate.year && currentMonth == maxDate.month,
          height: const Dim.px(40),
          width: const Dim.px(40),
          backgroundColor: Colors.transparent,
          foregroundColor: context.textColor,
          disabledBackgroundColor: Colors.transparent,
          onTap: onNextMonth,
        ),
      ],
    );
  }
}
