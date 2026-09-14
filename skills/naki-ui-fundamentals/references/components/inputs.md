# Input and form components

## Label

`Label` is the low-level label building block used internally by Naki input components. Do not place it beside a `TextField`, `AutoCompleteField`, `SegmentedInput`, or `Calendar`; set `InputDecoration.labelText` instead.

Use `Label` directly only for a custom native control that has no built-in label API.

The `fieldId` must exactly match the rendered control ID.

## TextField

Use `TextField` for text, email, URL, password, telephone, search, number, and multiline input.

```dart
TextField(
  id: 'account-email',
  type: InputType.email,
  required: true,
  autofill: Autofill.email,
  autoValidate: true,
  decoration: const InputDecoration(
    labelText: 'Email address',
    placeholderText: 'name@example.com',
    helperText: 'We send receipts to this address.',
  ),
  validator: (value) {
    if (!value.contains('@')) return 'Enter a valid email address.';
    return null;
  },
  onTyping: updateEmail,
  onSubmit: submitEmail,
)
```

IDs must be non-empty and unique. `autoValidate: true` requires a validator. Use `isMultiline: true` with `visibleLines` for a textarea. Use `readOnly` when a value remains focusable and `disable` when it must not be interactive. Do not add a sibling `Label`; `labelText` renders it internally.

## FormBuilder

Group Naki fields and buttons in a `FormBuilder` and provide a `GlobalNodeKey<HTMLFormElement>`. Import `HTMLFormElement` from `package:universal_web/web.dart` in code shared by server and client builds.

```dart
class _ContactFormState extends State<ContactForm> {
  final formKey = GlobalNodeKey<HTMLFormElement>();

  @override
  Component build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      name: 'contact',
      autoValidate: true,
      spacing: 16,
      children: [
        TextField(
          id: 'contact-name',
          type: InputType.text,
          required: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        Button.text(
          'Send',
          validateForm: true,
          onTap: submitContactForm,
        ),
      ],
    );
  }
}
```

The children list must not be empty. Set `direction: Direction.horizontal` only when controls remain usable at narrow widths. A button cannot set both `validateForm` and `resetForm`.

## AutoCompleteField

Filter a fixed list while the user types and receive the selected string.

```dart
AutoCompleteField(
  id: 'shipping-city',
  options: const ['Abuja', 'Accra', 'Lagos', 'Nairobi'],
  required: true,
  decoration: const InputDecoration(
    labelText: 'City',
    placeholderText: 'Start typing a city',
  ),
  dropdownMaxHeight: const Dim.px(240),
  onSelected: updateCity,
)
```

Options must not be empty. The component renders a `TextField`, including the label from `InputDecoration`. Supply a validator when enabling `autoValidate`. Its suggestions support keyboard navigation; preserve that behavior when styling or wrapping it.

## SegmentedInput

Collect OTP, PIN, or short fixed-length character sequences.

```dart
SegmentedInput(
  id: 'verification-code',
  length: 6,
  type: SegmentedInputType.number,
  required: true,
  decoration: const InputDecoration(
    labelText: 'Verification code',
    helperText: 'Enter or paste the six-digit code.',
  ),
  onChanged: updateCode,
  onCompleted: verifyCode,
)
```

Use `initialValue` for the initial uncontrolled value and `value` for controlled updates. Set `obscureText` or `SegmentedInputType.password` for private entry. The component renders one internal label associated with the first segment; do not add another label.

## Calendar

Select a date, time, or both through an accessible dialog-backed picker.

```dart
Calendar(
  id: 'appointment-time',
  type: CalendarType.both,
  required: true,
  minimum: DateTime.now(),
  decoration: const InputDecoration(
    labelText: 'Appointment',
    placeholderText: 'Choose a date and time',
    helperText: 'Times are shown in your local timezone.',
  ),
  onSelected: updateAppointment,
)
```

`minimum` must not be after `maximum`, and `initialValue` must fall within the range. Enabling `autoValidate` requires a validator. When providing a custom `child` trigger, keep its purpose clear; the component supplies dialog-related ARIA metadata and gesture handling around it. The label comes from `InputDecoration`.
