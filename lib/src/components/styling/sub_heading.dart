part of 'index.dart';

/// {@template SubHeading}
/// A component that renders a subtitle or sub-section text.
///
/// Example:
/// ```dart
/// const SubHeading('Overview and features')
/// ```
/// {@endtemplate}
class SubHeading extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  @override
  final Map<String, String>? attributes;

  /// {@macro SubHeading}
  const SubHeading(
    this.text, {
    super.key,
    this.style,
    this.classes,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    final baseTextStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseTextStyle
        .copyWith(
          color: Tokens.current.subtitleColor.color,
          fontWeight: FontWeight.w400,
          margin: EdgeInsets.zero,
        )
        .combineWith(style)
        .props;

    const baseClass = 'naki-text';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return h4(
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
