part of 'index.dart';

/// {@template Strikethrough}
/// A component that renders a strikethrough text.
///
/// Example:
/// ```dart
/// const Strikethrough('$99.99')
/// ```
/// {@endtemplate}
class Strikethrough extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  @override
  final Map<String, String>? attributes;

  /// {@macro Strikethrough}
  const Strikethrough(
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

    return s(
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
