part of '../index.dart';

/// Internal year/month popover content shared by [Calendar]
/// and dialog pickers.
class NakiCalendarYearMonthPicker extends StatelessComponent {
  final DateTime visibleDate;
  final DateTime minDate;
  final DateTime maxDate;
  final List<int> years;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<DateTime> onJumpToMonth;

  const NakiCalendarYearMonthPicker({
    super.key,
    required this.visibleDate,
    required this.minDate,
    required this.maxDate,
    required this.years,
    required this.onYearChanged,
    required this.onJumpToMonth,
  });

  @override
  Component build(BuildContext context) {
    int selectedYear = visibleDate.year;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isOutsideMonthBounds(int month) {
          return selectedYear == minDate.year && month < minDate.month ||
              selectedYear == maxDate.year && month > maxDate.month;
        }

        return Column(
          classes: 'naki-calendar-ymp',
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            // years dropdown
            Dropdown<int>(
              id: 'ymp-years',
              classes: 'naki-calendar-ymp__years',
              options: years
                  .map(
                    (year) => DropdownItem(
                      label: '$year',
                      value: year,
                      selected: year == selectedYear,
                    ),
                  )
                  .toList(),
              onSelected: (item) {
                selectedYear = item.value!;
                onYearChanged(selectedYear);
                setState(() {});
              },
              placeholder: 'Year',
              enableSearch: years.length > 10,
              menuHeight: const Dim.px(200),
              size: const SizeConstraints(
                width: Dim.percent(100),
                height: Dim.px(40),
              ),
            ),

            // months grid
            GridView.count(
              4,
              mainAxisSpacing: const Dim.px(10),
              crossAxisSpacing: const Dim.px(10),
              classes: 'naki-calendar-ymp__months',
              shrinkWrap: true,
              mainAxisExtent: const Dim.px(35),
              children: kMonths.map((month) {
                final visibleMonthIdx = visibleDate.month - 1;
                final monthIdx = kMonths.indexOf(month);
                final isDisabled = isOutsideMonthBounds(monthIdx + 1);
                final isSelected =
                    month == kMonths[visibleMonthIdx] && !isDisabled;

                return Button.text(
                  month,
                  id: 'ymp_month_$monthIdx',
                  classes: 'naki-calendar-ymp__month',
                  backgroundColor: Colors.transparent,
                  foregroundColor: context.textColor,
                  disabled: isDisabled,
                  border: BorderData(
                    color: context.popoverBorderColor,
                    radius: BorderRadiusData.all(
                      Dim.variable(
                        Tokens.current.radiusSm.name,
                        defaultValue: Tokens.current.radiusSm.value,
                      ),
                    ),
                  ),
                  attributes: {
                    'aria-label': '$month $selectedYear',
                    'aria-pressed': '$isSelected',
                  },
                  onTap: () =>
                      onJumpToMonth(DateTime(selectedYear, monthIdx + 1)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
