part of 'index.dart';

// /////////////////////////////////////////////////////////////////////////////
// SELECTION COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Checkbox}
/// A component that displays a standard checkbox with an optional
/// text label placed on either the left or right side.
///
/// ### Example
/// ```dart
/// Checkbox(
///   label: 'Accept Terms & Conditions',
///   isChecked: true,
///   labelPosition: Position.right,
///   onChange: (checked) {
///     print('Checkbox is now: $checked');
///   },
/// )
/// ```
/// {@endtemplate}
class Checkbox extends StatelessComponent {
  /// The label text displayed beside the checkbox.
  final String? label;

  /// Unique identifier of the checkbox.
  final String? id;

  /// Name used when this checkbox participates in a native form.
  final String? name;

  /// Value submitted when this checkbox is checked.
  final String? value;

  /// Style applied to [label].
  final TextStyle? labelStyle;

  /// Position of the [label] relative to the checkbox
  /// (defaults to [Position.left]).
  final Position labelPosition;

  /// Color of the checkbox tick.
  final Color? color;

  /// When `true`, the checkbox will use a fully rounded shape
  /// instead of the default square shape.
  final bool rounded;

  /// Custom size of the checkbox (in pixels).
  final double? size;

  /// Whether the checkbox is currently checked.
  final bool isChecked;

  /// Callback invoked when the user toggles the checkbox.
  final ValueChanged<bool> onChange;

  /// Whether the checkbox is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the checkbox component.
  final String? classes;

  /// Force this component to occupy the entire available horizontal
  /// space (the `label` and `checkbox` will be evenly spaced).
  final bool expand;

  /// {@macro Checkbox}
  Checkbox({
    super.key,
    required this.onChange,
    this.labelPosition = Position.left,
    this.rounded = false,
    this.disabled = false,
    this.isChecked = false,
    this.expand = false,
    this.id,
    this.name,
    this.value,
    this.classes,
    this.label,
    this.size,
    this.color,
    this.labelStyle,
  }) : assert(
         labelPosition == Position.left || labelPosition == Position.right,
         'Unsupported label position: $labelPosition',
       );

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(context, 'checkbox', id: id);
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-checkbox';
    final String effectiveClasses = joinClasses([?classes, baseClass]);

    // Input
    children.add(
      span(classes: 'naki-control-hitbox', [
        input<bool>(
          key: key,
          id: _id,
          name: name,
          value: value,
          type: InputType.checkbox,
          attributes: {
            'fcs': ?(!disabled ? '' : null),
            'shape': rounded ? 'round' : 'square',
          },
          classes: effectiveClasses,
          styles: Styles(
            raw: {
              'color': ?color?.value,
              'height': ?size?.toPx,
              'width': ?size?.toPx,
            },
          ),
          checked: isChecked,
          disabled: disabled,
          onChange: disabled ? null : onChange,
        ),
      ]),
    );

    // Label
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
      tag: 'naki-checkbox',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Checkbox', [
    Rules.nakiCheckboxRules,
    Rules.nakiHitboxRules,
  ]);
}
