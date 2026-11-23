part of 'index.dart';

/// {@template Switch}
/// A component that displays a toggle switch, with support
/// for an optional text label placed on either the left
/// or the right side.
///
/// ### Example
/// ```dart
/// Switch(
///   label: 'Enable Notifications',
///   isActive: true,
///   labelPosition: Position.left,
///   expand: true,
///   onChange: (active) {
///     print('Switch is active: $active');
///   },
/// )
/// ```
/// {@endtemplate}
class Switch extends StatelessComponent {
  /// The label text displayed next to the switch.
  final String? label;

  /// Unique identifier of the switch.
  final String? id;

  /// Name used when this switch participates in a native form.
  final String? name;

  /// Value submitted when the switch is active.
  final String? value;

  /// Style applied to [label].
  final TextStyle? labelStyle;

  /// Position of the [label] relative to the switch
  /// (defaults to [Position.left]).
  final Position labelPosition;

  /// Custom color applied to the switch thumb.
  final Color? thumbColor;

  /// Whether the switch is currently active (toggled `on`).
  final bool isActive;

  /// Callback invoked when the user toggles the switch.
  final ValueChanged<bool> onChange;

  /// Whether the switch is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the switch component.
  final String? classes;

  /// Force this component to occupy the entire available horizontal
  /// space (the `label` and `switch` will be evenly spaced).
  final bool expand;

  /// {@macro Switch}
  Switch({
    super.key,
    required this.onChange,
    this.labelPosition = Position.left,
    this.disabled = false,
    this.expand = false,
    this.isActive = false,
    this.id,
    this.name,
    this.value,
    this.classes,
    this.label,
    this.thumbColor,
    this.labelStyle,
  }) : assert(
         labelPosition == Position.left || labelPosition == Position.right,
         'Unsupported label position: $labelPosition',
       );

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(context, 'switch', id: id);
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-switch';
    final String effectiveClasses = joinClasses([?classes, baseClass]);

    // Add switch
    children.add(
      span(classes: 'naki-control-hitbox', [
        input<bool>(
          id: _id,
          key: key,
          name: name,
          value: value,
          type: InputType.checkbox,
          classes: effectiveClasses,
          styles: Styles(
            raw: {Tokens.current.switchThumbColor.name: ?thumbColor?.value},
          ),
          attributes: {'role': 'switch', 'fcs': ?(!disabled ? '' : null)},
          checked: isActive,
          disabled: disabled,
          onChange: disabled ? null : onChange,
        ),
      ]),
    );

    // Add label
    if (label.isNotNullAndEmpty) {
      final cleanedStyle = (labelStyle ?? const TextStyle()).copyWith(
        margin: .zero,
      );
      final labelUi = Label(label!, fieldId: _id, style: cleanedStyle);

      if (labelPosition == Position.right) {
        children.add(labelUi);
      } else if (labelPosition == Position.left) {
        children.insert(0, labelUi);
      }
    }

    return .element(
      tag: 'naki-switch',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  static List<StyleRule> get styles => SelectionStyles.nakiSwitch;
}
