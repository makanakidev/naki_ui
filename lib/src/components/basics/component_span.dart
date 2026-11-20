part of 'index.dart';

/// {@template ComponentSpan}
/// A component that represents an inline span of a
/// component that is embedded inline within texts.
///
/// The child component will be rendered using the given style
/// and can be aligned with text using the [baseline] property.
///
/// ### Example
/// ```dart
/// ComponentSpan(
///   child: Button(),
///   baseline: Baseline.middle,
///   style: TextStyle(
///     color: Colors.blue,
///     decoration: TextDecoration.underline,
///   ),
/// )
/// ```
/// {@endtemplate}
class ComponentSpan extends StatelessComponent implements InlineSpan {
  /// The component embedded inline within text.
  final Component child;

  /// Vertical alignment baseline of the embedded
  /// component relative to text (default: [Baseline.baseline]).
  final Baseline baseline;

  /// Additional CSS classes applied to the component span.
  final String? classes;

  /// Style applied to the component span.
  @override
  final TextStyle? style;

  /// Optional screen-reader description for the component span.
  @override
  final String? semanticsLabel;

  /// {@macro ComponentSpan}
  const ComponentSpan({
    super.key,
    required this.child,
    this.baseline = Baseline.baseline,
    this.style,
    this.semanticsLabel,
    this.classes,
  });

  @override
  String toPlainText() => semanticsLabel ?? '';

  @override
  bool visitChildren(bool Function(InlineSpan span) visitor) {
    return visitor(this);
  }

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);
    final mergedStyle = defaultStyle.combineWith(style).props;

    const baseClass = 'naki-component-span';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      ...mergedStyle,
      'display': 'inline-block',
      'vertical-align': baseline.value,
    };

    // Override display if the computed display property is block
    if (effectiveStyles['display'] == 'block') {
      effectiveStyles['display'] = 'inline-block';
    }

    return .element(
      key: key,
      tag: 'naki-componentspan',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {'aria-label': ?semanticsLabel},
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}
