part of '../index.dart';

/// Internal time picker content shared by [Calendar]
/// and [showTimePicker].
class NakiCalendarTimePicker extends StatelessComponent {
  final String calendarId;
  final String titleText;
  final String timePreview;
  final Duration? selectedTime;
  final bool disabled;
  final ValueChanged<Duration> onTimeChanged;
  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const NakiCalendarTimePicker({
    super.key,
    required this.calendarId,
    required this.titleText,
    required this.timePreview,
    required this.selectedTime,
    required this.disabled,
    required this.onTimeChanged,
    required this.onClear,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Component build(BuildContext context) {
    return Column(
      classes: 'naki-time-picker',
      spacing: 12,
      mainAxisSize: MainAxisSize.min,
      children: [
        // header
        Row(
          classes: 'naki-calendar-header',
          spacing: 10,
          children: [
            Expanded(
              child: NakiText(
                titleText.isNotEmpty ? titleText : 'Select time',
                classes: 'naki-calendar-title',
                style: const TextStyle(truncate: true),
              ),
            ),

            NakiText(
              timePreview,
              classes: 'naki-calendar-picker-preview',
              style: TextStyle(
                fontSize: Dim.variable(
                  Tokens.current.fontSizeMd.name,
                  defaultValue: Tokens.current.fontSizeMd.value,
                ),
              ),
            ),
          ],
        ),

        // steppers
        Row(
          spacing: 6,
          classes: 'naki-time-picker-steppers',
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _CalendarTimeStepper(
              id: calendarId,
              hour: true,
              selectedTime: selectedTime,
              disabled: disabled,
              onTimeChanged: onTimeChanged,
            ),
            const NakiText(
              ':',
              classes: 'naki-time-separator',
            ),
            _CalendarTimeStepper(
              id: calendarId,
              hour: false,
              selectedTime: selectedTime,
              disabled: disabled,
              onTimeChanged: onTimeChanged,
            ),
          ],
        ),

        // footer actions
        Row(
          classes: 'naki-calendar-footer',
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // clear time (reset to zero)
            Button.text(
              'Clear',
              classes: 'naki-calendar-action',
              backgroundColor: Colors.transparent,
              foregroundColor: context.subtitleColor,
              disabledBackgroundColor: Colors.transparent,
              disabled:
                  disabled ||
                  selectedTime == Duration.zero ||
                  selectedTime == null,
              onTap: onClear,
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // cancel time picker
                Button.text(
                  'Cancel',
                  classes: 'naki-calendar-action',
                  backgroundColor: Colors.transparent,
                  foregroundColor: context.textColor,
                  onTap: onCancel,
                ),

                // submit time
                Button.text(
                  'Submit',
                  classes: 'naki-calendar-action',
                  disabled: disabled || selectedTime == null,
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  foregroundColor: context.primaryColor,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  onTap: onConfirm,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarTimeStepper extends StatelessComponent {
  final String id;
  final bool hour;
  final Duration? selectedTime;
  final bool disabled;
  final ValueChanged<Duration> onTimeChanged;

  const _CalendarTimeStepper({
    required this.id,
    required this.hour,
    required this.selectedTime,
    required this.disabled,
    required this.onTimeChanged,
  });

  @override
  Component build(BuildContext context) {
    final now = DateTime.now();
    final time = selectedTime ?? Duration(hours: now.hour, minutes: now.minute);

    final hrInputElem =
        document.getElementById('naki-stepper-$id-hr') as HTMLInputElement?;
    final minsInputElem =
        document.getElementById('naki-stepper-$id-mins') as HTMLInputElement?;

    int _hr = time.inHours % 24;
    int _mins = time.inMinutes % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    void _updateTime() => onTimeChanged(Duration(hours: _hr, minutes: _mins));

    void _updateMinsInputValue(int value) =>
        minsInputElem?.value = twoDigits(value);

    void _updateHrInputValue(int value) =>
        hrInputElem?.value = twoDigits(value);

    void _increase() {
      // hour block
      if (hour) {
        _hr = _hr >= 23 ? 0 : _hr + 1;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (_mins >= 59) {
        _mins = 0;
        _hr = (_hr + 1) % 24;
        _updateHrInputValue(_hr);
      } else {
        _mins += 1;
      }

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    void _decrease() {
      // hour block
      if (hour) {
        _hr = _hr <= 0 ? 23 : _hr - 1;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (_mins <= 0) {
        _mins = 59;
        _hr = _hr <= 0 ? 23 : _hr - 1;
        _updateHrInputValue(_hr);
      } else {
        _mins -= 1;
      }

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    void _onInputChange(String value) {
      int? val = int.tryParse(value);
      if (val == null) return;

      // hour block
      if (hour) {
        if (val < 0 || val > 23) val = 0;
        _hr = val;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (val < 0) val = 0;
      if (val > 59) {
        val = 0;
        _hr = (_hr + 1) % 24;
        _updateHrInputValue(_hr);
      }

      _mins = val;

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    return Column(
      classes: 'naki-time-stepper',
      mainAxisSize: MainAxisSize.min,
      children: [
        // up button
        Button.icon(
          LucideIcons.icon_chevron_up,
          size: 18,
          semanticLabel: hour ? 'Increase hour' : 'Increase minutes',
          disabled: disabled,
          disabledBackgroundColor: Colors.transparent,
          onTap: _increase,
          classes: 'naki-time-stepper-button',
        ),

        // input
        input<num>(
          id: hour ? 'naki-stepper-$id-hr' : 'naki-stepper-$id-mins',
          type: InputType.number,
          disabled: disabled,
          attributes: {
            'min': '0',
            'max': hour ? '24' : '60',
            'step': '1',
            'maxlength': '2',
            'aria-label': hour ? 'Hour' : 'Minutes',
          },
          value: twoDigits(hour ? _hr : _mins),
          onInput: (v) => _onInputChange(v.toCleanString),
        ),

        // down button
        Button.icon(
          LucideIcons.icon_chevron_down,
          size: 18,
          semanticLabel: hour ? 'Decrease hour' : 'Decrease minutes',
          disabledBackgroundColor: Colors.transparent,
          disabled: disabled,
          onTap: _decrease,
          classes: 'naki-time-stepper-button',
        ),
      ],
    );
  }
}
