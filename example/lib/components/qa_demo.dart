import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

/// Showcase of form, calendar, overlay and selection behaviour.
class QaDemo extends StatefulComponent {
  const QaDemo({super.key, required this.onMessage});

  /// Reports a short status message (shown in the app snackbar).
  final ValueChanged<String> onMessage;

  @override
  State<QaDemo> createState() => _QaDemoState();
}

class _QaDemoState extends State<QaDemo> {
  final _formKey = GlobalNodeKey<HTMLFormElement>();
  final _dialogController = OverlayController();

  bool _notifications = true;
  double _volume = 40;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  Component _section(String title, List<Component> children) {
    return Card(
      padding: const EdgeInsets.all(Dim.px(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          NakiText(
            title,
            style: const TextStyle(
              fontSize: Dim.px(16),
              fontWeight: FontWeight.w600,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Component _calendar(String id, String label, CalendarType type) {
    return Calendar(
      id: id,
      type: type,
      required: true,
      decoration: InputDecoration(labelText: label),
      onSelected: (date) => component.onMessage('$label: $date'),
    );
  }

  @override
  Component build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // forms: Enter moves to the next field, submits from the last one
        _section('Form', [
          FormBuilder(
            formKey: _formKey,
            spacing: 12,
            onSubmit: () => component.onMessage('Form submitted'),
            children: [
              TextField(
                id: 'qa-name',
                type: InputType.text,
                required: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                id: 'qa-email',
                type: InputType.email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value.isNotEmpty && !value.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              TextField(
                id: 'qa-code',
                type: InputType.text,
                minLength: 4,
                decoration: const InputDecoration(
                  labelText: 'Code (min 4 chars)',
                ),
              ),
              Button(
                type: ButtonType.submit,
                foregroundColor: Colors.white,
                backgroundColor: context.primaryColor,
                child: const NakiText('Submit'),
              ),
            ],
          ),
        ]),

        // calendars at both edges (viewport placement, single open picker)
        _section('Calendars', [
          Wrap(
            alignment: MainAxisAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 12,
            children: [
              _calendar('qa-start', 'Start date', CalendarType.date),
              _calendar('qa-end', 'End date', CalendarType.date),
            ],
          ),
          _calendar('qa-time', 'Reminder time', CalendarType.time),
        ]),

        // selection controls
        _section('Selection', [
          Dropdown<String>(
            id: 'qa-priority',
            options: const [
              DropdownItem(value: 'low', label: 'Low'),
              DropdownItem(value: 'medium', label: 'Medium'),
              DropdownItem(value: 'high', label: 'High'),
            ],
            onSelected: (item) =>
                component.onMessage('Priority: ${item.label}'),
          ),
          Switch(
            id: 'qa-notifications',
            label: 'Notifications',
            isActive: _notifications,
            onChange: (value) => setState(() => _notifications = value),
          ),
          Slider(
            id: 'qa-volume',
            semanticLabel: 'Volume',
            value: _volume,
            width: const Dim.raw('min(300px, 100%)'),
            onChange: (value) => setState(() => _volume = value),
          ),
        ]),

        // dialog with a calendar inside (Escape closes only the picker)
        _section('Overlays', [
          Button(
            onTap: _dialogController.open,
            child: const NakiText('Open dialog'),
          ),
          Dialog(
            controller: _dialogController,
            barrierDismissible: true,
            title: 'Schedule',
            content: Column(
              spacing: 12,
              children: [
                _calendar('qa-dialog-date', 'Due date', CalendarType.both),
                Button(
                  onTap: _dialogController.close,
                  child: const NakiText('Close'),
                ),
              ],
            ),
          ),
        ]),

        // breakpoint wrappers inside flex / scroll parents
        _section('Responsive', [
          Row(
            spacing: 8,
            children: [
              const ResponsiveBuilder(
                mobile: NakiText('Mobile layout'),
                desktop: NakiText('Desktop layout'),
                largerMobile: NakiText('Larger mobile layout'),
                tablet: NakiText('Tablet layout'),
              ),
              BreakPointWrapper(
                maxWidth: 600,
                child: const Expanded(child: NakiText('Narrow screens only')),
              ),
            ],
          ),
        ]),
      ],
    );
  }
}
