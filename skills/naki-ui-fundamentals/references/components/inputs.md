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
  leadingIcon: Icon(MaterialIcons.icon_round_add),
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
      formKey: formKey,
      name: 'contact',
      spacing: 16,
      bypassValidation: true,
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

Select a date, time, both, or a date range through an accessible dialog-backed picker.

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

`minimum` must not be after `maximum`, and `initialValue` and `initialRange` must fall within those bounds. Enabling `autoValidate` requires `validator` or `rangeValidator`. When providing a custom `child` trigger, keep its purpose clear; the component supplies dialog-related ARIA metadata and gesture handling around it. The label comes from `InputDecoration`.

### Date ranges

Use `CalendarType.range` with `initialRange`, `onSelectedRange`, and `rangeValidator`. `onSelected` is not called for range calendars, and `validator` receives only the start date.

```dart
Calendar(
  id: 'trip-dates',
  type: CalendarType.range,
  initialRange: [tripStart, tripEnd],
  autoValidate: true,
  rangeValidator: (days) {
    if (days == null) return 'Select your travel dates';
    if (days.length > 14) return 'Maximum 14 days allowed';
    return null;
  },
  onSelectedRange: updateTripDates,
  decoration: const InputDecoration(labelText: 'Travel dates'),
)
```

`onSelectedRange` and `rangeValidator` receive every day from start through end in ascending order; use `days.first` and `days.last` for the endpoints. `rangeValidator` receives `null` when nothing is selected. `initialRange` accepts dates in any order and ignores their time: the earliest and latest dates set the range, and a single date is a one-day range. Do not expand the range yourself with `Duration(days: 1)`, because that drifts across daylight saving changes; use `start.daysThrough(end)`.

`Ok` stays disabled until the range has an end date, and every way of closing the picker other than `Ok` discards an unconfirmed selection. Native forms receive the start date under the calendar's `id` and the end date under `{id}_end`, both as `yyyy-MM-dd`.
