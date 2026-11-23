part of 'index.dart';

/// {@template RadioButton}
/// A component that displays a radio button, with support for custom
/// color and size.
///
/// ### Example
/// ```dart
/// RadioButton(
///   isSelected: false,
///   size: Dim.px(30),
///   disabled: false,
///   onChange: (value) {},
/// )
/// ```
/// {@endtemplate}
class RadioButton extends StatelessComponent {
  /// The label text displayed next to the radio button.
  final String? label;

  /// Style applied to the label text.
  final TextStyle? labelStyle;

  /// Unique identifier of the radio button.
  final String? id;

  /// Shared native form name for a mutually-exclusive radio group.
  final String? name;

  /// Value submitted when the radio button is selected.
  final String? value;

  /// Position of the [label] relative to the radio button
  /// (default: [Position.left]).
  final Position labelPosition;

  /// Custom color applied to the radio button.
  final Color? color;

  /// Whether the radio button is currently selected.
  final bool isSelected;

  /// Callback invoked when the user toggles the radio button.
  final ValueChanged<bool> onChange;

  /// Whether the radio button is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the radio button component.
  final String? classes;

  /// The width and height of the radio button in pixels.
  final double? size;

  /// When `true`, the radio button and [label] will be
  /// evenly spaced across the available horizontal space.
  final bool expand;

  /// {@macro RadioButton}
  const RadioButton({
    super.key,
    required this.onChange,
    this.isSelected = false,
    this.disabled = false,
    this.expand = false,
    this.labelPosition = Position.left,
    this.classes,
    this.id,
    this.name,
    this.value,
    this.size,
    this.color,
    this.label,
    this.labelStyle,
  });

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(context, 'radio-btn', id: id);
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-radio-btn';
    final String effectiveClasses = joinClasses([?classes, baseClass]);

    final styles = {
      Tokens.current.radioBtnRadius.name: ?size?.toPx,
      Tokens.current.radioBtnColor.name: ?color?.value,
    };

    // Add radio
    children.add(
      span(classes: 'naki-control-hitbox', [
        input<bool>(
          id: _id,
          key: key,
          name: name,
          value: value,
          type: InputType.radio,
          classes: effectiveClasses,
          styles: Styles(raw: styles),
          checked: isSelected,
          disabled: disabled,
          attributes: {'role': 'radio', 'fcs': ?(!disabled ? '' : null)},
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
      tag: 'naki-radiobtn',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  static List<StyleRule> get styles => SelectionStyles.radioButton;
}
