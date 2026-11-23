part of 'index.dart';

/// {@template NakiText}
/// A Naki component that is just a run of text with single style.
///
/// ### Example
/// ```dart
/// NakiText(
///   'Hello',
///   style: TextStyle(
///     color: Colors.black,
///     fontSize: Dim.px(16),
///     fontWeight: FontWeight.bold,
///   ),
/// )
/// ```
/// {@endtemplate}
class NakiText extends StatelessComponent with NakiTextScope {
  /// Text to display.
  final String text;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  @override
  final Map<String, String>? attributes;

  /// {@macro NakiText}
  const NakiText(
    this.text, {
    super.key,
    this.style,
    this.classes,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveStyles = defaultStyle.combineWith(style);

    const baseClass = 'naki-text';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      key: key,
      tag: 'naki-text',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles.props),
      attributes: attributes,
      children: [.text(text)],
    );
  }

  static List<StyleRule> get styles => BasicsStyles.text;
}
