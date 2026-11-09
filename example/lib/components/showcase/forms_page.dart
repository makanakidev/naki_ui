import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

/// The input and selection groups.
class FormsPage extends StatefulComponent {
  const FormsPage({super.key, required this.onMessage});

  /// Reports a short status message.
  final ValueChanged<String> onMessage;

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _formKey = GlobalNodeKey<HTMLFormElement>();

  bool _newsletter = true;
  bool _notifications = false;
  String _shipping = 'standard';
  double _volume = 40;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  RadioButton _shippingOption(String value, String label) {
    return RadioButton(
      name: 'showcase-shipping',
      value: value,
      isSelected: _shipping == value,
      label: label,
      onChange: (selected) {
        if (selected) setState(() => _shipping = value);
      },
    );
  }

  @override
  Component build(BuildContext context) {
    return ShowcasePage(
      groups: [
        ShowcaseGroup(
          title: 'Inputs',
          subtitle: 'Text entry with validation built in.',
          demos: [
            Demo(
              name: 'TextField with focus',
              child: TextField(
                id: 'showcase-email',
                type: InputType.email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  focusBorderColor: context.primaryColor,
                ),
              ),
            ),
            Demo(
              name: 'FormBuilder',
              child: FormBuilder(
                formKey: _formKey,
                spacing: 12,
                onSubmit: () => component.onMessage('Form submitted'),
                children: [
                  TextField(
                    id: 'showcase-name',
                    type: InputType.text,
                    required: true,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  Button(
                    type: ButtonType.submit,
                    foregroundColor: Colors.white,
                    height: const Dim.px(40),
                    backgroundColor: context.primaryColor,
                    child: const NakiText('Submit'),
                  ),
                ],
              ),
            ),
            Demo(
              name: 'AutoCompleteField',
              child: AutoCompleteField(
                id: 'showcase-framework',
                options: const ['Jaspr', 'Flutter', 'Dart', 'Naki UI'],
                decoration: const InputDecoration(
                  labelText: 'Framework',
                  placeholderText: 'Type to search',
                  helperText: 'Try typing "a" to see suggestions',
                ),
                onSelected: (selection) =>
                    component.onMessage('Selected $selection'),
              ),
            ),
            Demo(
              name: 'SegmentedInput',
              child: SegmentedInput(
                id: 'showcase-pin',
                length: 4,
                type: SegmentedInputType.number,
                onCompleted: (pin) => component.onMessage('PIN $pin'),
              ),
            ),
            Demo(
              name: 'Calendar',
              child: Calendar(
                id: 'showcase-trip',
                type: CalendarType.range,
                decoration: const InputDecoration(
                  labelText: 'Select trip dates',
                ),
                onSelectedRange: (range) => component.onMessage(
                  'Trip: ${range.first.asRange(range.last)}',
                ),
              ),
            ),
            Demo(
              name: 'Calendar with limits',
              child: Calendar(
                id: 'showcase-booking',
                type: CalendarType.date,
                minimum: DateTime.now(),
                maximum: DateTime.now().add(const Duration(days: 14)),
                decoration: const InputDecoration(
                  labelText: 'Book within two weeks',
                ),
                onSelected: (date) =>
                    component.onMessage('Booked ${date.toDdMmmYyyy}'),
              ),
            ),
          ],
        ),
        ShowcaseGroup(
          title: 'Selection',
          subtitle: 'Controlled toggles, just pass the value and a callback.',
          demos: [
            Demo(
              name: 'Checkbox',
              child: Checkbox(
                isChecked: _newsletter,
                label: 'Subscribe to the newsletter',
                size: 22,
                rounded: true,
                onChange: (value) => setState(() => _newsletter = value),
              ),
            ),
            Demo(
              name: 'RadioButton',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  _shippingOption('standard', 'Standard shipping'),
                  _shippingOption('express', 'Express shipping'),
                ],
              ),
            ),
            Demo(
              name: 'Switch',
              child: Switch(
                id: 'showcase-notifications',
                label: 'Notifications',
                isActive: _notifications,
                onChange: (value) => setState(() => _notifications = value),
              ),
            ),
            Demo(
              name: 'Slider',
              child: Slider(
                id: 'showcase-volume',
                semanticLabel: 'Volume',
                value: _volume,
                showValueIndicator: true,
                width: const Dim.raw('min(300px, 100%)'),
                onChange: (value) => setState(() => _volume = value),
              ),
            ),
            Demo(
              name: 'Dropdown',
              child: Dropdown<String>(
                id: 'showcase-priority',
                placeholder: 'Choose priority',
                options: const [
                  DropdownItem(value: 'low', label: 'Low'),
                  DropdownItem(value: 'medium', label: 'Medium'),
                  DropdownItem(value: 'high', label: 'High'),
                  DropdownItem(label: 'Premium Plans', section: true),
                  DropdownItem(value: 'platinum', label: 'Platinum'),
                  DropdownItem(value: 'enterprise', label: 'Enterprise'),
                ],
                onSelected: (item) =>
                    component.onMessage('Priority: ${item.label}'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
