# Selection components

## Checkbox

Use a checkbox for independent boolean choices.

```dart
Checkbox(
  id: 'accept-terms',
  name: 'acceptTerms',
  value: 'yes',
  label: 'I accept the terms and conditions',
  labelPosition: Position.right,
  isChecked: accepted,
  onChange: (value) => setState(() => accepted = value),
)
```

Set `label` directly; the component renders and associates its internal `Label`. Use `disabled` for unavailable choices and `expand` when the label and control should fill the row.

## Switch

Use a switch for an immediately applied on/off setting.

```dart
Switch(
  id: 'email-notifications',
  label: 'Email notifications',
  labelPosition: Position.left,
  isActive: notificationsEnabled,
  onChange: (value) {
    setState(() => notificationsEnabled = value);
    saveNotificationPreference(value);
  },
)
```

Use a checkbox instead when the choice belongs to a form submitted later. Do not add a standalone label.

## Slider

Select a numeric value from a continuous or divided range.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  spacing: 8,
  children: [
    NakiText('Volume: ${volume.round()} percent'),
    Slider(
      id: 'volume',
      name: 'volume',
      value: volume,
      minValue: 0,
      maxValue: 100,
      divisions: 10,
      showValueIndicator: true,
      onChange: (value) => setState(() => volume = value),
    ),
  ],
)
```

The minimum must be lower than the maximum, the current value must remain in range, and divisions must be at least one. Set `allowInteraction: false` for a read-only presentation. Provide nearby visible text that explains the value because the component does not expose the same built-in label property as other selection controls.

## RadioButton

Use radio buttons for one choice within a mutually exclusive group. Give every item the same native `name` and a unique ID and value.

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    RadioButton(
      id: 'plan-monthly',
      name: 'billing-plan',
      value: 'monthly',
      label: 'Monthly billing',
      isSelected: plan == 'monthly',
      onChange: (_) => setState(() => plan = 'monthly'),
    ),
    RadioButton(
      id: 'plan-yearly',
      name: 'billing-plan',
      value: 'yearly',
      label: 'Yearly billing',
      isSelected: plan == 'yearly',
      onChange: (_) => setState(() => plan = 'yearly'),
    ),
  ],
)
```

Set `label` directly. The component renders and associates its internal label.

## Dropdown

Select one `DropdownItem<T>` from a menu.

```dart
Dropdown<String>(
  id: 'country',
  placeholder: 'Choose a country',
  enableSearch: true,
  searchPlaceholder: 'Search countries',
  size: const SizeConstraints(width: Dim.px(320)),
  options: const [
    DropdownItem(value: 'gh', label: 'Ghana'),
    DropdownItem(value: 'ng', label: 'Nigeria'),
    DropdownItem(value: 'ke', label: 'Kenya'),
  ],
  onSelected: (item) => updateCountry(item.value),
)
```

Options must not be empty and at most one item can start with `selected: true`. Use `section: true` for a non-selectable grouping row. When supplying a custom `child` trigger, do not attach its own click handler because the dropdown manages trigger state. Use `statesColor`, `decoration`, and text-style properties for supported customization.
