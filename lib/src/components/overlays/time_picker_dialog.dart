part of 'index.dart';

/// Dialog body used by [showTimePicker], reusing [NakiCalendarTimePicker].
class NakiTimePickerDialog extends StatefulComponent {
  final DateTime initialTime;
  final String title;
  final bool barrierDismissible;
  final Color? backgroundColor;
  final Color? barrierColor;
  final String semanticLabel;

  const NakiTimePickerDialog({
    super.key,
    required this.initialTime,
    required this.title,
    required this.barrierDismissible,
    this.backgroundColor,
    this.barrierColor,
    required this.semanticLabel,
  });

  @override
  State<NakiTimePickerDialog> createState() => _NakiTimePickerDialogState();

  static List<StyleRule> get styles => OverlaysStyles.calendarModal;
}

class _NakiTimePickerDialogState extends State<NakiTimePickerDialog>
    with NakiOverlayVisibilityMixin {
  late final _id = nakiDomId(context, 'time_picker');
  late Duration _selectedTime;

  Duration get _initialDuration => Duration(
    hours: component.initialTime.hour,
    minutes: component.initialTime.minute,
  );

  @override
  Duration get exitDuration => const Duration(milliseconds: 150);

  @override
  void initState() {
    super.initState();
    _selectedTime = _initialDuration;
  }

  String _formatPreview(Duration d) {
    final h = (d.inHours % 24).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _exit(VoidCallback action) {
    syncVisibility(false);
    action();
  }

  @override
  Component build(BuildContext context) {
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
            ? (e) =>
                  _onBarrierClick(e, () => _exit(() => Navigator.pop(context)))
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
            NakiCalendarTimePicker(
              calendarId: _id,
              titleText: component.title,
              timePreview: _formatPreview(_selectedTime),
              selectedTime: _selectedTime,
              disabled: false,
              onTimeChanged: (d) => setState(() => _selectedTime = d),
              onClear: () => setState(() => _selectedTime = Duration.zero),
              onCancel: () => _exit(() => Navigator.pop(context)),
              onConfirm: () {
                final base = component.initialTime;
                _exit(
                  () => Navigator.pop<DateTime>(
                    context,
                    DateTime(
                      base.year,
                      base.month,
                      base.day,
                      _selectedTime.inHours % 24,
                      _selectedTime.inMinutes.remainder(60),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
