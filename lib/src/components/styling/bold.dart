part of 'index.dart';

// /////////////////////////////////////////////////////////////////////////////
// STYLING COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Bold}
/// A component that renders a bold text.
///
/// Example:
/// ```dart
/// const Bold('Important message')
/// ```
/// {@endtemplate}
class Bold extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  @override
  final Map<String, String>? attributes;

  /// {@macro Bold}
  const Bold(
    this.text, {
    super.key,
    this.style,
    this.classes,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.combineWith(style).props;

    const baseClass = 'naki-text';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return strong(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: attributes,
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}
