part of 'index.dart';

/// Dialog body used by [showDatePicker] and [showDateRangePicker],
/// reusing [Calendar]'s header, year/month picker, and day grid.
class NakiDatePickerDialog extends StatefulComponent {
  final DateTime? initialDate;
  final List<DateTime>? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool isRange;
  final String title;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final Color? barrierColor;
  final String semanticLabel;

  const NakiDatePickerDialog({
    super.key,
    this.initialDate,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
    required this.isRange,
    required this.title,
    required this.barrierDismissible,
    this.backgroundColor,
    this.barrierColor,
    required this.semanticLabel,
  });

  @override
  State<NakiDatePickerDialog> createState() => _NakiDatePickerDialogState();

  static List<StyleRule> get styles => OverlaysStyles.calendarModal;
}

class _NakiDatePickerDialogState extends State<NakiDatePickerDialog>
    with NakiOverlayVisibilityMixin {
  late final _id = nakiDomId(context, 'date_picker');
  late List<DateTime> _selectedDates;
  late DateTime _visibleDate;
  bool _showYear = false;

  DateTime get _minDate => DateTime(
    component.firstDate.year,
    component.firstDate.month,
    component.firstDate.day,
  );

  DateTime get _maxDate => DateTime(
    component.lastDate.year,
    component.lastDate.month,
    component.lastDate.day,
  );

  List<int> get _years => [
    for (var y = _minDate.year; y <= _maxDate.year; y++) y,
  ];

  bool get _isRangePending => component.isRange && _selectedDates.length == 1;

  @override
  Duration get exitDuration => const Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    syncVisibility(true, rebuild: false);
    _selectedDates = _resolveInitialDates();
    _visibleDate = _clampMonth(
      _selectedDates.isNotEmpty
          ? _selectedDates.first
          : component.initialDate ?? DateTime.now(),
    );
  }

  List<DateTime> _resolveInitialDates() {
    if (component.isRange) {
      final initial = component.initialDateRange;
      if (initial == null || initial.isEmpty) return [];

      final sorted =
          initial.map((d) => DateTime(d.year, d.month, d.day)).toList()..sort();

      return [sorted.first, sorted.last];
    }

    final d = component.initialDate;
    return d != null ? [DateTime(d.year, d.month, d.day)] : [];
  }

  DateTime _clampMonth(DateTime date) {
    final target = DateTime(date.year, date.month, 1);
    final minMonth = DateTime(_minDate.year, _minDate.month, 1);
    final maxMonth = DateTime(_maxDate.year, _maxDate.month, 1);

    if (target.isBefore(minMonth)) return minMonth;
    if (target.isAfter(maxMonth)) return maxMonth;

    return target;
  }

  void _toggleMonth([bool next = false]) {
    if (next) {
      if (_visibleDate.year == _maxDate.year &&
          _visibleDate.month == _maxDate.month) {
        return;
      }

      setState(
        () =>
            _visibleDate = DateTime(_visibleDate.year, _visibleDate.month + 1),
      );
    } else {
      if (_visibleDate.year == _minDate.year &&
          _visibleDate.month == _minDate.month) {
        return;
      }

      setState(
        () =>
            _visibleDate = DateTime(_visibleDate.year, _visibleDate.month - 1),
      );
    }
  }

  void _updateSelection(DateTime date) {
    final extendsRange =
        _isRangePending && !date.isBeforeOrSameAs(_selectedDates.first);
    setState(
      () =>
          _selectedDates = extendsRange ? [_selectedDates.first, date] : [date],
    );
  }

  String _previewText() {
    if (_selectedDates.isEmpty) return '';
    if (!component.isRange) return _selectedDates.first.toDdMmmYyyy;
    return _selectedDates.first.asRange(_selectedDates.last);
  }

  void _confirm(BuildContext context) {
    if (component.isRange) {
      if (_selectedDates.isEmpty) return;
      final range = _selectedDates.first.daysThrough(_selectedDates.last);
      _exit(() => Navigator.pop<List<DateTime>>(context, range));
      return;
    }

    _exit(() => Navigator.pop<DateTime>(context, _selectedDates.firstOrNull));
  }

  void _exit(VoidCallback action) {
    syncVisibility(false);
    action();
  }

  @override
  Component build(BuildContext context) {
    if (!isVisible) return const SizedBox();

    final daysInMonth = NakiCalendarGrid.buildMonth(
      visibleDate: _visibleDate,
      minDate: _minDate,
      maxDate: _maxDate,
      selectedDates: _selectedDates,
      isRange: component.isRange,
    ).days;

    final hasSelection = _selectedDates.isNotEmpty;
    final preview = _previewText();

    final barrierStyle = {
      Tokens.current.barrierBlur.name: '0',
      Tokens.current.dialogBarrierBg.name: ?component.barrierColor?.value,
    };

    final calendarStyle = {
      'top': 'auto',
      'left': 'auto',
      'transform': 'none',
      'background-color': ?component.backgroundColor?.value,
    };

    return span(
      classes: 'naki-dialog naki-calendar',
      styles: Styles(raw: barrierStyle),
      attributes: exitAttributes,
      events: Events(
        onClick: component.barrierDismissible
            ? (e) => _onBarrierClick(e, () {
                _exit(() => Navigator.pop(context));
              })
            : null,
        onKeyDown: (e) {
          if (e.key == 'Escape') {
            e.preventDefault();
            e.stopPropagation();
            _exit(() => Navigator.pop(context));
          }
        },
      ).toMap,
      [
        span(
          classes: 'naki-calendar-modal',
          styles: Styles(raw: calendarStyle),
          attributes: {
            'aria-label': component.semanticLabel,
            'role': 'dialog',
            'aria-modal': 'true',
            'tabindex': '-1',
          },
          [
            Column(
              classes: 'naki-date-picker',
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: NakiText(
                        component.title,
                        classes: 'naki-calendar-title',
                        style: const TextStyle(truncate: true),
                      ),
                    ),

                    if (preview.isNotEmpty)
                      NakiText(
                        preview,
                        classes: 'naki-calendar-picker-preview',
                        style: component.isRange
                            ? null
                            : TextStyle(
                                fontSize: Dim.variable(
                                  Tokens.current.fontSizeMd.name,
                                  defaultValue: Tokens.current.fontSizeMd.value,
                                ),
                              ),
                      ),
                  ],
                ),

                NakiCalendarHeader(
                  visibleDate: _visibleDate,
                  minDate: _minDate,
                  maxDate: _maxDate,
                  showYear: _showYear,
                  onPreviousMonth: () => _toggleMonth(),
                  onNextMonth: () => _toggleMonth(true),
                  onToggleYearPicker: () =>
                      setState(() => _showYear = !_showYear),
                  yearMonthPopover: NakiCalendarYearMonthPicker(
                    visibleDate: _visibleDate,
                    minDate: _minDate,
                    maxDate: _maxDate,
                    years: _years,
                    onYearChanged: (year) => setState(() {
                      _visibleDate = _clampMonth(
                        DateTime(year, _visibleDate.month),
                      );
                    }),
                    onJumpToMonth: (date) => setState(() {
                      _visibleDate = DateTime(date.year, date.month, 1);
                      _showYear = false;
                    }),
                  ),
                  onCloseYearPicker: () => setState(() => _showYear = false),
                ),

                NakiCalendarGrid(
                  calendarId: _id,
                  daysInMonth: daysInMonth,
                  isMultiDayRange:
                      component.isRange && _selectedDates.length == 2,
                  rangeStart: _selectedDates.length == 2
                      ? _selectedDates.first
                      : null,
                  rangeEnd: _selectedDates.length == 2
                      ? _selectedDates.last
                      : null,
                  onSelectDate: _updateSelection,
                ),

                Row(
                  classes: 'naki-calendar-footer',
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Button.text(
                      'Clear',
                      classes: 'naki-calendar-action',
                      disabled: !hasSelection,
                      backgroundColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      foregroundColor: context.subtitleColor,
                      onTap: () => setState(() {
                        _selectedDates = [];
                        _visibleDate = DateTime.now();
                      }),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Button.text(
                          'Cancel',
                          classes: 'naki-calendar-action',
                          backgroundColor: Colors.transparent,
                          foregroundColor: context.textColor,
                          onTap: () => _exit(() => Navigator.pop(context)),
                        ),

                        Button.text(
                          'Submit',
                          classes: 'naki-calendar-action',
                          disabled: !hasSelection || _isRangePending,
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          foregroundColor: context.primaryColor,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          onTap: () => _confirm(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
