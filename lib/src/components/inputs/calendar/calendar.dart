part of '../index.dart';

/// {@template Calendar}
/// A component that enables selection of date, time, both,
/// or a date range with built-in validation, customization
/// and styling options.
///
/// ### Example
/// ```dart
/// Calendar(
///  id: 'calendar_1',
///  type: CalendarType.both,
///  onSelected: (date) {
///    print(date);
/// },
///  validator: (date) {
///    if (date == null) return 'Please select a date';
///    return null;
///  },
///  autoValidate: true,
///  height: Dim.px(40),
///  width: Dim.px(350),
///  decoration: InputDecoration(
///    labelText: 'Select a date',
///    helperText: 'Used for analytics and reporting only.',
///  ),
/// )
/// ```
/// {@endtemplate}
class Calendar extends StatefulComponent {
  /// Unique identifier of the calendar component.
  final String id;

  /// Calendar type (default: [CalendarType.date]).
  final CalendarType type;

  /// Initial value of the calendar based on [type].
  /// - If [type] is [CalendarType.time], [initialValue]
  /// will be used to initialize the time picker.
  /// - If [type] is [CalendarType.date], [initialValue]
  /// will be used to initialize the date picker.
  /// - If [type] is [CalendarType.both], [initialValue]
  /// will be used to initialize both the date and time pickers.
  final DateTime? initialValue;

  /// Initial date range values of the calendar.
  /// When [type] is [CalendarType.range], [initialRange]
  /// will be used to initialize the date picker.
  ///
  /// Dates can be in any order and their time is ignored.
  /// The earliest and latest dates set the range, so a
  /// `[start, end]` list and the list emitted by [onSelectedRange]
  /// are both accepted. A single date is a one-day range.
  final List<DateTime> initialRange;

  /// Text displayed in the header of the date or time picker.
  /// Overridden by `labelText` if provided in [decoration].
  final String? title;

  /// Minimum allowed date or time values for the calendar.
  final DateTime? minimum;

  /// The maximum allowed date or time values for the calendar.
  final DateTime? maximum;

  /// Callback invoked when a date or time is selected.
  /// This is not called when [type] is [CalendarType.range].
  final ValueChanged<DateTime>? onSelected;

  /// Callback invoked when a range of date is selected, with
  /// every day from the start date through the end date
  /// in ascending order.
  final ValueChanged<List<DateTime>>? onSelectedRange;

  /// Callback that returns an error message if the selected
  /// date or time is invalid, or `null` otherwise.
  ///
  /// **NOTE:** Use [rangeValidator] to validate the whole
  /// range when [type] is [CalendarType.range].
  final FieldValidator<DateTime?>? validator;

  /// Callback that returns an error message if the selected date
  /// range is invalid, or `null` otherwise.
  ///
  /// This receives every day in the range, or `null` if nothing
  /// is selected. It runs only when [type] is [CalendarType.range].
  final FieldValidator<List<DateTime>?>? rangeValidator;

  /// Whether the calendar component is read-only (default: `false`).
  ///
  /// When `true`, the calendar date or time pickers will
  /// be displayed and not interactive.
  final bool readOnly;

  /// Custom component such as text or icon, which opens and closes
  /// the calendar dialog.
  ///
  /// If not provided, a [Button.iconText] component is used.
  final Component? child;

  /// Whether the calendar component is disabled (default: `false`).
  ///
  /// When `true`, the [child] component will not be interactive.
  final bool disable;

  /// Whether the calendar component automatically gains focus
  /// after it is rendered in the client-side.
  ///
  /// When [child] is not provided and [autoFocus] is enabled,
  /// the default trigger component will be focused.
  ///
  /// This will not work if the calendar is inside a hidden
  /// component such as a dialog.
  final bool autoFocus;

  /// Whether the calendar component is required for form validation.
  final bool required;

  /// When [autoValidate] is enabled and [validator] returns an
  /// error message, the validation message will be displayed
  /// when a selection occurs or when the form is submitted.
  ///
  /// Note: [validator] or [rangeValidator] must be provided
  /// when [autoValidate] is true.
  final bool autoValidate;

  /// Calendar background color.
  final Color? backgroundColor;

  /// Width of the calendar [child].
  /// Ignored when [child] is provided.
  final Dim? width;

  /// Height of the calendar [child].
  /// Ignored when [child] is provided.
  final Dim? height;

  /// Decoration configuration for placeholder, label, helper text,
  /// error text, and the default calendar trigger.
  final InputDecoration? decoration;

  /// Additional CSS classes applied to the calendar component.
  final String? classes;

  /// {@macro Calendar}
  Calendar({
    super.key,
    required this.id,
    required this.type,
    this.readOnly = false,
    this.disable = false,
    this.autoFocus = false,
    this.required = false,
    this.autoValidate = false,
    this.initialRange = const [],
    this.onSelected,
    this.onSelectedRange,
    this.child,
    this.initialValue,
    this.title,
    this.validator,
    this.rangeValidator,
    this.decoration,
    this.classes,
    this.backgroundColor,
    this.width,
    this.height,
    this.minimum,
    this.maximum,
  }) : assert(id != '', 'id must not be empty'),
       assert(
         minimum == null || maximum == null || !minimum.isAfter(maximum),
         'minimum must not be after maximum',
       ),
       assert(
         initialValue == null ||
             minimum == null ||
             !initialValue.isBefore(minimum),
         'initialValue must not be before minimum',
       ),
       assert(
         initialValue == null ||
             maximum == null ||
             !initialValue.isAfter(maximum),
         'initialValue must not be after maximum',
       ),
       assert(
         minimum == null ||
             !initialRange.any((date) => date.isBeforeDay(minimum)),
         'initialRange must not be before minimum',
       ),
       assert(
         maximum == null ||
             !initialRange.any((date) => maximum.isBeforeDay(date)),
         'initialRange must not be after maximum',
       ),
       assert(
         !autoValidate || validator != null || rangeValidator != null,
         'validator or rangeValidator is required when autoValidate is true',
       );

  @override
  State<Calendar> createState() => _CalendarState();

  static List<StyleRule> get styles => InputsStyles.calendar;
}

class _CalendarState extends State<Calendar>
    with NakiStatefulMixin, NakiPlacementMixin {
  late DateTime _visibleDate, _minDate, _maxDate;

  late final String _calendarId = nakiDomId(context, 'ncp', id: component.id);

  bool _pickTime = false;
  bool _pickDate = false;
  bool _showYear = false;

  List<DateTime> _selectedDates = [];
  List<DateTime> _committedDates = [];

  Duration? _selectedTime;
  Duration? _committedTime;

  List<int> _years = [];
  bool _requestedOpen = false;
  bool _skipFocusRestore = false;

  HTMLElement? _previousFocus;
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;

  String? _triggerText;

  static _CalendarState? _openCalendar;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _initCalendar();
  }

  @override
  void didUpdateComponent(Calendar oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.type != component.type ||
        oldComponent.initialValue != component.initialValue ||
        !listEquals(oldComponent.initialRange, component.initialRange)) {
      _initCalendar();
    } else if (oldComponent.minimum != component.minimum ||
        oldComponent.maximum != component.maximum) {
      _updateBounds();
    }
  }

  /// Returns the calendar element node
  HTMLElement? get calendarNode => component.key is GlobalNodeKey<HTMLElement>
      ? (component.key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById('${_calendarId}__calendar') as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (component.autoFocus && component.child == null) {
      final triggerId = '${_calendarId}_default_trigger';
      (document.getElementById(triggerId) as HTMLButtonElement?)?.focus();
    }

    return null;
  }

  /// Initializes the calendar
  void _initCalendar() {
    final now = DateTime.now();
    final type = component.type;
    final initialDates = _initialDates;

    _pickTime = false;
    _pickDate = false;
    _showYear = false;

    _visibleDate = initialDates.firstOrNull ?? now;
    _selectedDates = initialDates;

    if (type == CalendarType.time) {
      _selectedDates = [_visibleDate];
      _selectedTime = Duration(
        hours: _visibleDate.hour,
        minutes: _visibleDate.minute,
      );
    }

    if (type == CalendarType.both) {
      _selectedTime = Duration(
        hours: _visibleDate.hour,
        minutes: _visibleDate.minute,
      );
    }

    _updateBounds();

    _committedDates = [..._selectedDates];
    _committedTime = _selectedTime;

    _updateTriggerText();
  }

  void _updateBounds() {
    _minDate =
        component.minimum ??
        _visibleDate.subtract(const Duration(days: 100 * 365));
    _maxDate =
        component.maximum ??
        (_initialDates.lastOrNull ?? _visibleDate).add(
          const Duration(days: 10 * 365),
        );

    final minYear = _minDate.year;
    final maxYear = _maxDate.year;
    final count = maxYear >= minYear ? (maxYear - minYear) + 1 : 0;

    _years = List.generate(count, (i) => minYear + i);
  }

  bool get _isRange => component.type == CalendarType.range;

  /// Whether a range has a start date but no end date yet.
  ///
  /// [_selectedDates] holds `[start]` until a range is complete, then
  /// `[start, end]`, which are the same date for a one-day range.
  bool get _isRangePending => _isRange && _selectedDates.length == 1;

  /// Whether a complete range spans more than one day.
  bool get _isMultiDayRange =>
      _isRange &&
      _selectedDates.length == 2 &&
      _selectedDates.first != _selectedDates.last;

  /// Dates the calendar starts with and resets to.
  List<DateTime> get _initialDates {
    if (!_isRange) return [?component.initialValue];

    final dates = [
      for (final date in component.initialRange)
        NakiCalendarGrid.dateOnly(date),
    ]..sort();

    return dates.isEmpty ? [] : [dates.first, dates.last];
  }

  /// Every day in the selected range, in ascending order
  List<DateTime> get _rangeDays =>
      _selectedDates.firstOrNull?.daysThrough(_selectedDates.last) ?? [];

  /// Whether to validate the input (when autoValidate or required is true)
  bool get _shouldValidate => component.autoValidate || component.required;

  void _updateTriggerText() {
    if (component.child == null) {
      _triggerText = _displayedValue(currentValue);
    }
  }

  /// Builds the calendar month component
  CalendarMonth _buildCalendarMonth(DateTime date) =>
      NakiCalendarGrid.buildMonth(
        visibleDate: date,
        minDate: _minDate,
        maxDate: _maxDate,
        selectedDates: _selectedDates,
        isRange: _isRange,
      );

  void _togglePicker() {
    if (component.disable) return;

    // open the picker for the first time
    if (!_pickDate && !_pickTime) {
      final other = _openCalendar;
      if (other != null && !identical(other, this) && other.mounted) {
        // close any other open calendar
        other._dismissPicker(restoreFocus: false);
      }

      _openCalendar = this;
      _committedDates = [..._selectedDates];
      _committedTime = _selectedTime;
    } else {
      _dismissPicker();
      return;
    }

    setState(() {
      if (component.type == CalendarType.time) {
        _pickTime = !_pickTime;
        _pickDate = false;
      } else {
        _pickDate = !_pickDate;
        _pickTime = false;
      }
    });
  }

  void _syncDialogAccessibility(bool open) {
    if (_requestedOpen == open) return;
    _requestedOpen = open;

    onComponentRendered(() {
      if (!mounted) return;

      if (open) {
        _activateDialog();
      } else {
        _deactivateDialog(restoreFocus: !_skipFocusRestore);
        _skipFocusRestore = false;
      }
    });
  }

  /// Closes the picker and discards any uncommitted selection.
  void _dismissPicker({bool restoreFocus = true}) {
    if (!_pickDate && !_pickTime) return;

    _skipFocusRestore = !restoreFocus;

    setState(() {
      _selectedDates = [..._committedDates];
      _selectedTime = _committedTime;
      _pickDate = false;
      _pickTime = false;
      _showYear = false;
    });
  }

  @override
  Map<String, String> computePlacement(
    HTMLElement modal,
    HTMLElement anchor,
    ({double top, double right, double bottom, double left}) bounds,
  ) {
    const tokens = Tokens.current;
    const gap = 10.0;

    final style = modal.style;
    final values = <String, String>{};

    final anchorRect = anchor.getBoundingClientRect();
    final height = modal.getBoundingClientRect().height.toDouble();

    // vertical placement
    final vertical = placePicker(
      height: height,
      anchorTop: anchorRect.top.toDouble(),
      anchorBottom: anchorRect.bottom.toDouble(),
      safeTop: bounds.top,
      safeBottom: bounds.bottom,
      gap: gap,
    );

    if (vertical.above) {
      values[tokens.calendarTop.name] = 'auto';
      values[tokens.calendarBottom.name] = '100%';
      values[tokens.calendarGap.name] = '-${gap}px';
    }

    if (vertical.top case final top?) {
      final parentTop = (modal.offsetParent ?? anchor)
          .getBoundingClientRect()
          .top;
      final gapToTop = top - (parentTop + modal.offsetTop);
      values[tokens.calendarGap.name] = '${gapToTop}px';
    }

    if (vertical.maxHeight case final maxHeight?) {
      values[tokens.calendarMaxHeight.name] = '${maxHeight}px';
    }

    values.forEach((name, value) => style.setProperty(name, value));

    // horizontal placement
    final rect = modal.getBoundingClientRect();
    var shift = 0.0;

    if (rect.width > bounds.right - bounds.left || rect.left < bounds.left) {
      shift = bounds.left - rect.left;
    } else if (rect.right > bounds.right) {
      shift = bounds.right - rect.right;
    }

    if (shift != 0) {
      values[tokens.calendarShiftX.name] = '${shift}px';
    }

    return values;
  }

  List<HTMLElement> _focusableElements(HTMLElement surface) {
    final nodes = surface.querySelectorAll(
      'button:not([disabled]), input:not([disabled]), '
      '[tabindex]:not([tabindex="-1"])',
    );

    return [
      for (var index = 0; index < nodes.length; index++)
        nodes.item(index) as HTMLElement,
    ];
  }

  void _activateDialog() {
    final surface = placementKey.currentNode;
    if (surface == null) return;

    place();

    _previousFocus = document.activeElement as HTMLElement?;

    final initialFocus =
        surface.querySelector(
              '.naki-calendar-date[tabindex="0"], button:not([disabled]), '
              'input:not([disabled])',
            )
            as HTMLElement?;

    // scrolling here would move the picker off the place just measured
    (initialFocus ?? surface).focus(FocusOptions(preventScroll: true));
    _keyboardSubscription?.cancel();

    NakiOverlayStack.push(this);

    _keyboardSubscription = EventStreamProviders.keyDownEvent
        .forTarget(document)
        .listen((event) => _handleDialogKeyDown(event, surface));
  }

  void _handleDialogKeyDown(KeyboardEvent event, HTMLElement surface) {
    // a picker inside another overlay only reacts while it is top-most
    if (!NakiOverlayStack.isTop(this)) return;

    if (event.key == 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      _dismissPicker();
      return;
    }

    final target = event.target as HTMLElement?;
    if (target != null && target.classList.contains('naki-calendar-date')) {
      final delta = switch (event.key) {
        'ArrowLeft' => -1,
        'ArrowRight' => 1,
        'ArrowUp' => -7,
        'ArrowDown' => 7,
        _ => 0,
      };

      if (delta != 0) {
        final nodes = surface.querySelectorAll(
          '.naki-calendar-date:not([disabled])',
        );

        final dates = [
          for (var index = 0; index < nodes.length; index++)
            nodes.item(index) as HTMLElement,
        ];

        final current = dates.indexOf(target);

        if (current != -1 && dates.isNotEmpty) {
          event.preventDefault();

          dates[(current + delta).clamp(0, dates.length - 1)].focus();
        }
        return;
      }
    }

    if (event.key != 'Tab') return;

    final focusable = _focusableElements(surface);
    if (focusable.isEmpty) {
      event.preventDefault();
      surface.focus();
      return;
    }

    final active = document.activeElement;

    if (event.shiftKey &&
        (active == focusable.first || !surface.contains(active))) {
      event.preventDefault();
      focusable.last.focus();
    } else if (!event.shiftKey &&
        (active == focusable.last || !surface.contains(active))) {
      event.preventDefault();
      focusable.first.focus();
    }
  }

  void _deactivateDialog({bool restoreFocus = true}) {
    NakiOverlayStack.remove(this);

    if (identical(_openCalendar, this)) _openCalendar = null;

    stopPlacing();

    _keyboardSubscription?.cancel();
    _keyboardSubscription = null;

    if (restoreFocus) _previousFocus?.focus();

    _previousFocus = null;
    _requestedOpen = false;
  }

  /// Converts [CalendarType] to [InputType]
  InputType get inputType => switch (component.type) {
    CalendarType.date => InputType.date,
    CalendarType.time => InputType.time,
    CalendarType.range => InputType.date,
    CalendarType.both => InputType.dateTimeLocal,
  };

  /// Current value of the calendar picker
  DateTime? get currentValue {
    if (_selectedDates.isEmpty) return null;
    if (_selectedTime == null) return _selectedDates.first;

    return _selectedDates.first.copyWith(
      hour: _selectedTime!.inHours,
      minute: _selectedTime!.inMinutes % 60,
      second: 0,
    );
  }

  /// String representation of date/time based on picker type
  String _displayedValue(DateTime? value) => value == null
      ? ''
      : switch (component.type) {
          CalendarType.date => value.toDdMmmYyyy,
          CalendarType.time => value.toFullTimeAmPm,
          CalendarType.range => value.asRange(_selectedDates.last),
          CalendarType.both => value.toDateAndTimeWithSlashes,
        };

  /// Native HTML value format for the configured calendar type
  String _inputValue(DateTime? value) {
    if (value == null) return '';

    String twoDigits(int part) => part.toString().padLeft(2, '0');

    final date =
        '${value.year.toString().padLeft(4, '0')}-'
        '${twoDigits(value.month)}-${twoDigits(value.day)}';

    final time =
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}:'
        '${twoDigits(value.second)}';

    return switch (component.type) {
      CalendarType.date => date,
      CalendarType.range => date,
      CalendarType.time => time,
      CalendarType.both => '${date}T$time',
    };
  }

  /// Updates displayed value and optionally closes the calendar
  void _updateValue({bool close = false}) {
    if (component.disable || component.readOnly) return;

    final inputElem = document.getElementById(_calendarId) as HTMLInputElement?;
    inputElem?.value = _inputValue(currentValue);

    if (close) {
      _committedDates = [..._selectedDates];
      _committedTime = _selectedTime;

      _showError();

      if (currentValue != null) {
        if (_isRange) {
          component.onSelectedRange?.call(_rangeDays);
        } else {
          component.onSelected?.call(currentValue!);
        }
      }

      setState(() {
        _updateTriggerText();
        _pickDate = false;
        _pickTime = false;
      });
    }
  }

  /// Shows custom validation message
  void _showError() {
    final rangeValidator = _isRange ? component.rangeValidator : null;
    final baseValidator = !_isRange ? component.validator : null;

    if (kIsWeb &&
        (baseValidator != null ||
            rangeValidator != null ||
            component.required)) {
      final error = component.required && currentValue == null
          ? 'This field is required'
          : rangeValidator?.call(currentValue == null ? null : _rangeDays) ??
                baseValidator?.call(currentValue) ??
                '';

      // show custom validation message if enabled
      if (_shouldValidate) {
        showValidationError(_calendarId, error, isCalendar: true);
      }

      // set browser-default validity
      final inputElem =
          document.querySelector('input[name="${component.id}"]')
              as HTMLInputElement?;
      final rangeInputElem =
          document.querySelector('input[name="${component.id}_end"]')
              as HTMLInputElement?;

      inputElem?.setCustomValidity(error);
      rangeInputElem?.setCustomValidity(error);
    }
  }

  /// Handles invalid event when parent form is submitted
  void _invalid(Event event) {
    if (kIsWeb && _shouldValidate) {
      event.preventDefault();
      _showError();
    }
  }

  /// Toggles between months
  void _toggleMonth([bool next = false]) {
    if (_years.isEmpty) return;

    final currentMonth = _visibleDate.month;
    final currentYear = _visibleDate.year;

    if (next) {
      // Move to next month, respecting max date boundary
      if (currentYear == _maxDate.year && currentMonth == _maxDate.month) {
        return;
      }
      setState(() {
        _visibleDate = DateTime(currentYear, currentMonth + 1);
      });
    } else {
      // Move to previous month, respecting min date boundary
      if (currentYear == _minDate.year && currentMonth == _minDate.month) {
        return;
      }
      setState(() {
        _visibleDate = DateTime(currentYear, currentMonth - 1);
      });
    }
  }

  /// Resets to current month view, based on selected value
  void _jumpToMonth(DateTime date) => setState(() {
    _visibleDate = DateTime(date.year, date.month, 1);
    _showYear = false;
  });

  /// Adds or removes date from the selected dates
  void _updateSelection(DateTime date) {
    if (component.readOnly || component.disable) return;

    final extendsRange =
        _isRangePending && !date.isBeforeOrSameAs(_selectedDates.first);

    setState(() {
      _selectedDates = extendsRange ? [_selectedDates.first, date] : [date];
    });
  }

  @override
  void dispose() {
    _deactivateDialog(restoreFocus: false);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final backgroundColor = component.backgroundColor;
    final decoration = component.decoration;

    final labelText = decoration?.labelText ?? '';
    final placeholderText = decoration?.placeholderText ?? '';
    final helperText = decoration?.helperText ?? '';
    final titleText = decoration?.labelText ?? component.title ?? '';

    final hoverColor = decoration?.hoverBorderColor;
    final focusColor = decoration?.focusBorderColor;

    final errorStyle = decoration?.errorStyle;
    final helperStyle = decoration?.helperStyle;
    final labelStyle = decoration?.labelStyle;

    final allowHover =
        hoverColor != null && !component.disable && !component.readOnly;
    final allowFocus =
        focusColor != null && !component.disable && !component.readOnly;

    final effectiveClasses = joinClasses([?component.classes, 'naki-calendar']);

    final showDatePickerOnly = inputType == InputType.date;
    final showBoth = inputType == InputType.dateTimeLocal;
    final pickerOpen = _pickDate || _pickTime;

    final triggerContent = _triggerText.isNotNullAndEmpty
        ? _triggerText!
        : placeholderText.isNotEmpty
        ? placeholderText
        : _isRange
        ? 'Select date range'
        : showBoth
        ? 'Select date and time'
        : showDatePickerOnly
        ? 'Select date'
        : 'Select time';

    _syncDialogAccessibility(pickerOpen);

    final daysInMonth = _buildCalendarMonth(_visibleDate).days;

    final triggerIcon = showDatePickerOnly || showBoth
        ? LucideIcons.icon_calendar
        : LucideIcons.icon_clock;

    final defaultPickerName = _isRange ? 'date range' : 'date and time';
    final triggerLabel = labelText.isNotEmpty
        ? '${pickerOpen ? 'Close' : 'Open'} $labelText picker'
        : '${pickerOpen ? 'Close' : 'Open'} $defaultPickerName picker';

    final triggerAttributes = {
      'aria-haspopup': 'dialog',
      'aria-expanded': '$pickerOpen',
      'aria-controls': '${_calendarId}_dialog',
      'aria-label': triggerLabel,
    };

    final Component effectiveChild = component.child == null
        ? Button.iconText(
            id: '${_calendarId}_default_trigger',
            classes: 'default_trigger',
            text: triggerContent,
            icon: triggerIcon,
            iconSize: 16,
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            width: component.width,
            height:
                component.height ??
                Dim.variable(
                  Tokens.current.inputHeight.name,
                  defaultValue: Tokens.current.inputHeight.value,
                ),
            border: decoration?.border,
            padding: decoration?.padding,
            textStyle: decoration?.inputStyle,
            backgroundColor: context.fieldBackgroundColor,
            foregroundColor: context.inputTextColor,
            disabled: component.disable,
            attributes: triggerAttributes,
            onTap: _togglePicker,
          )
        : div(
            attributes: triggerAttributes,
            events: events(onClick: _togglePicker),
            [component.child!],
          );

    return .element(
      key: component.key,
      tag: 'naki-calendar',
      id: '${_calendarId}__calendar',
      classes: 'naki-form-field',
      styles: Styles(
        raw: {
          Tokens.current.errorColor.name: ?errorStyle?.color?.value,
          Tokens.current.fontSizeError.name: ?errorStyle?.fontSize?.cssText,
          Tokens.current.fontSizeHint.name: ?helperStyle?.fontSize?.cssText,
          Tokens.current.mutedColor.name: ?helperStyle?.color?.value,
          Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
          Tokens.current.focusBorderColor.name: ?focusColor?.value,
          Tokens.current.dropdownMenuBgColor.name: ?backgroundColor?.value,
          ...?decoration?.margin?.mProps,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(labelText, fieldId: _calendarId, style: labelStyle),

        // Helper
        if (helperText.isNotEmpty)
          p(classes: 'naki-helper', styles: Styles(raw: helperStyle?.props), [
            .text(helperText),
          ]),

        // Main
        span(
          classes: effectiveClasses,
          attributes: {'data-type': component.type.name},
          [
            // Input for form validation (hidden)
            input(
              name: component.id,
              type: inputType,
              value: currentValue != null ? _inputValue(currentValue!) : null,
              attributes: {
                'required': ?(component.required ? '' : null),
                'tabindex': '-1',
                'aria-hidden': 'true',
              },
              events: InputEvents(onInvalid: _invalid).toMap,
            ),

            // Range end date for form submission (hidden)
            if (_isRange)
              input(
                name: '${component.id}_end',
                type: inputType,
                value: currentValue != null
                    ? _inputValue(_selectedDates.last)
                    : null,
                attributes: {
                  'tabindex': '-1',
                  'aria-hidden': 'true',
                  'required': ?(component.required ? '' : null),
                },
                events: InputEvents(onInvalid: _invalid).toMap,
              ),

            // Trigger (opens/closes modal)
            .wrapElement(
              classes: 'naki-calendar-trigger',
              attributes: {
                'novalue': ?(currentValue == null ? '' : null),
                'selected': ?(currentValue != null ? '' : null),
                'disabled': ?(component.disable ? '' : null),
                'hvr': ?(allowHover ? '' : null),
                'fcs': ?(allowFocus ? '' : null),
              },
              child: effectiveChild,
            ),

            // Modal
            if (pickerOpen)
              ScrollBarWrapper(
                selector: '#${_calendarId}_dialog',
                configuration: ScrollBarConfiguration(
                  thumbColor: context.primaryColor.withOpacity(0.4),
                  trackColor: Colors.transparent,
                  radius: 4,
                  width: 2,
                ),
                child: span(
                  key: placementKey,
                  id: '${_calendarId}_dialog',
                  classes: 'naki-calendar-modal',
                  styles: Styles(raw: placement),
                  attributes: {
                    'role': 'dialog',
                    'aria-modal': 'true',
                    'aria-label': labelText.isNotEmpty
                        ? '$labelText picker'
                        : _isRange
                        ? 'Date range picker'
                        : 'Date and time picker',
                    'tabindex': '-1',
                  },
                  [
                    // Date picker
                    if (_pickDate)
                      Column(
                        classes: 'naki-date-picker',
                        spacing: 12,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // title
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: NakiText(
                                  titleText.isNotEmpty
                                      ? titleText
                                      : _isRange
                                      ? 'Select date range'
                                      : 'Select date',
                                  classes: 'naki-calendar-title',
                                  style: const TextStyle(truncate: true),
                                ),
                              ),

                              if (currentValue != null)
                                NakiText(
                                  _displayedValue(currentValue),
                                  classes: 'naki-calendar-picker-preview',
                                  style: _isRange
                                      ? null
                                      : TextStyle(
                                          fontSize: Dim.variable(
                                            Tokens.current.fontSizeMd.name,
                                            defaultValue:
                                                Tokens.current.fontSizeMd.value,
                                          ),
                                        ),
                                ),
                            ],
                          ),

                          // header
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
                              onYearChanged: (year) => _visibleDate =
                                  _visibleDate.copyWith(year: year),
                              onJumpToMonth: _jumpToMonth,
                            ),
                            onCloseYearPicker: () {
                              final dropdownMenu =
                                  calendarNode?.querySelector(
                                        'naki-dropdown[open]',
                                      )
                                      as HTMLElement? ??
                                  document.querySelector(
                                        'naki-dropdown[open]',
                                      )
                                      as HTMLElement?;
                              if (dropdownMenu != null) return;
                              setState(() => _showYear = false);
                            },
                          ),

                          // days in the month
                          NakiCalendarGrid(
                            calendarId: _calendarId,
                            daysInMonth: daysInMonth,
                            isMultiDayRange: _isMultiDayRange,
                            rangeStart: _selectedDates.firstOrNull,
                            rangeEnd: _selectedDates.lastOrNull,
                            onSelectDate: _updateSelection,
                          ),

                          // footer buttons
                          Row(
                            classes: 'naki-calendar-footer',
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              showBoth
                                  ? Button.text(
                                      _timePreview(),
                                      classes: 'naki-calendar-action',
                                      foregroundColor: context.textColor,
                                      backgroundColor: Colors.transparent,
                                      border: BorderData(
                                        color: context.primaryColor,
                                        radius: BorderRadiusData.all(
                                          Dim.variable(
                                            Tokens.current.paddingXs.name,
                                            defaultValue:
                                                Tokens.current.paddingXs.value,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _pickTime = true;
                                          _pickDate = false;
                                          if (_selectedDates.isEmpty)
                                            _selectedDates = [_visibleDate];
                                        });
                                      },
                                    )
                                  : Button.text(
                                      'Clear',
                                      classes: 'naki-calendar-action',
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: context.subtitleColor,
                                      onTap: () {
                                        if (component.disable ||
                                            component.readOnly) {
                                          return;
                                        }

                                        setState(() {
                                          _committedDates = [];
                                          _selectedDates = [];
                                          _visibleDate = DateTime.now();
                                        });

                                        _updateValue();
                                      },
                                    ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // cancel date picker
                                  Button.text(
                                    'Cancel',
                                    classes: 'naki-calendar-action',
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: context.textColor,
                                    onTap: () {
                                      setState(() {
                                        _selectedDates = [..._committedDates];
                                        _selectedTime = _committedTime;
                                        _visibleDate =
                                            currentValue ?? DateTime.now();
                                        _pickDate = false;
                                        _pickTime = false;
                                      });
                                    },
                                  ),

                                  // submit date
                                  Button.text(
                                    'Submit',
                                    classes: 'naki-calendar-action',
                                    disabled:
                                        _selectedDates.isEmpty ||
                                        _isRangePending,
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    foregroundColor: context.primaryColor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onTap: () => _updateValue(close: true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Time picker
                    if (_pickTime)
                      NakiCalendarTimePicker(
                        calendarId: _calendarId,
                        titleText: titleText,
                        timePreview: _timePreview(),
                        selectedTime: _selectedTime,
                        disabled: component.disable || component.readOnly,
                        onTimeChanged: (time) =>
                            setState(() => _selectedTime = time),
                        onClear: () {
                          setState(() {
                            _committedTime = Duration.zero;
                            _selectedTime = Duration.zero;
                          });
                          _updateValue();
                        },
                        onCancel: () {
                          setState(() {
                            _selectedTime = _committedTime;
                            _pickTime = false;
                            if (showBoth) {
                              _pickDate = true;
                            } else {
                              _selectedDates = [..._committedDates];
                            }
                          });
                        },
                        onConfirm: () => _updateValue(close: true),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// 12-hour preview of the selected time, e.g. `1:27 PM`
  String _timePreview() {
    final now = DateTime.now();
    final time =
        _selectedTime ?? Duration(hours: now.hour, minutes: now.minute);

    final hr = time.inHours % 24;
    final mins = (time.inMinutes % 60).toString().padLeft(2, '0');
    final displayHr = hr % 12 == 0 ? 12 : hr % 12;

    return '$displayHr:$mins ${hr < 12 ? 'AM' : 'PM'}';
  }
}
