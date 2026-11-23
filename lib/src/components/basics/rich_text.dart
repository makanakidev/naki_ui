part of 'index.dart';

/// {@template RichText}
/// A component that renders rich text with styled inline spans.
///
/// ### Example
/// ```dart
/// RichText(
///   text: TextSpan(
///     text: 'Hello ',
///     style: TextStyle(
///       fontWeight: FontWeight.bold,
///     ),
///     children: [
///       TextSpan(
///         text: 'World',
///         style: TextStyle(
///           color: Colors.blue,
///         ),
///         onTap: () => print('Clicked!'),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class RichText extends StatelessComponent with NakiTextScope {
  /// The root inline span to render.
  final InlineSpan text;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  @override
  final TextStyle? style;

  @override
  final String? classes;

  @override
  final Map<String, String>? attributes;

  /// {@macro RichText}
  const RichText({
    super.key,
    required this.text,
    this.textAlign,
    this.style,
    this.classes,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final effectiveStyles = defaultStyle.combineWith(style).props;

    const baseClass = 'naki-richtext';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      key: key,
      tag: 'naki-richtext',
      classes: effectiveClasses,
      attributes: attributes,
      styles: Styles(
        raw: {...effectiveStyles, 'text-align': ?textAlign?.value},
      ),
      children: [text as Component],
    );
  }

  static List<StyleRule> get styles => BasicsStyles.text;
}
