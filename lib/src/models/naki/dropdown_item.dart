part of 'index.dart';

/// Represents a single item in the Dropdown component.
class DropdownItem<T> {
  /// The value of the item (usually a string or int).
  final T? value;

  /// The display text of the item.
  final String? label;

  /// If true, the item will be visually highlighted.
  final bool selected;

  /// If true, the item will be displayed as a section header (not selectable).
  final bool section;

  /// If true, the item will be displayed as a placeholder (not selectable).
  final bool placeholder;

  /// Cannot be selected if [section] or [placeholder] is `true`.
  final bool disabled;

  const DropdownItem({
    this.value,
    this.label,
    this.selected = false,
    this.section = false,
    this.placeholder = false,
  }) : disabled = section || placeholder;

  DropdownItem<T> copyWith({
    T? value,
    String? label,
    bool? selected,
    bool? section,
    bool? placeholder,
  }) {
    return DropdownItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      selected: selected ?? this.selected,
      section: section ?? this.section,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  /// Returns the string representation of the dropdown item value.
  /// If the value is null, it returns the label, or 'n/a' if label is null.
  @override
  String toString() => value?.toString() ?? label ?? 'n/a';

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem<T> &&
        value == other.value &&
        label == other.label;
  }
}
