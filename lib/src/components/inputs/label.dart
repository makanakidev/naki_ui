part of 'index.dart';

// /////////////////////////////////////////////////////////////////////////////
// INPUT COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Label}
/// A component that serves as a label for form fields.
///
/// It has a default bottom margin of 12px. To override or remove
/// the bottom margin, modify [TextStyle.margin] property in [style].
/// {@endtemplate}
class Label extends StatelessComponent {
  /// The displayed text.
  final String text;

  /// Unique identifier of the field that the label represents.
  final String? fieldId;

  /// Custom styles applied to the label.
  final TextStyle? style;

  /// {@macro Label}
  const Label(this.text, {super.key, this.fieldId, this.style});

  @override
  Component build(BuildContext context) {
    return .element(
      key: key,
      tag: fieldId.isNotNullAndEmpty ? 'label' : 'span',
      classes: 'naki-label',
      styles: Styles(raw: style?.props),
      attributes: {'for': ?fieldId},
      children: [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Label', [Rules.nakiLabelRules]);
}
