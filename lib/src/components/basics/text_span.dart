part of 'index.dart';

/// {@template TextSpan}
/// A component that represents an inline span of text formatted
/// with a single style.
///
/// Spans can be nested by passing [children].
///
/// ### Example
/// ```dart
/// TextSpan(
///   text: 'Click ',
///   children: [
///     TextSpan(
///       text: 'here',
///       style: TextStyle(
///         color: Colors.blue,
///         decoration: TextDecoration.underline,
///       ),
///       recognizer: GestureRecognizer(
///         onLongPress: (e) => print('Clicked!')),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class TextSpan extends StatelessComponent implements InlineSpan {
  /// Content contained in the text span.
  final String? text;

  /// Additional inline spans contained within the text span.
  final List<InlineSpan>? children;

  /// Gesture recognizer for the text span.
  final GestureRecognizer? recognizer;

  /// Additional CSS classes applied to the text span.
  final String? classes;

  /// Style applied to the text span and its children.
  @override
  final TextStyle? style;

  /// Optional screen-reader description for the text span.
  @override
  final String? semanticsLabel;

  /// {@macro TextSpan}
  const TextSpan({
    super.key,
    this.text,
    this.style,
    this.semanticsLabel,
    this.children,
    this.recognizer,
    this.classes,
  });

  @override
  String toPlainText() {
    final buffer = StringBuffer();

    if (text.isNotNullAndEmpty) {
      buffer.write(text!);
    }

    if (children != null) {
      for (final child in children!) {
        buffer.write(child.toPlainText());
      }
    }

    return buffer.toString();
  }

  @override
  bool visitChildren(bool Function(InlineSpan span) visitor) {
    if (!visitor(this)) return false;

    if (children != null) {
      for (final child in children!) {
        if (!child.visitChildren(visitor)) return false;
      }
    }

    return true;
  }

  @override
  Component build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context);

    const baseClass = 'naki-text-span';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'display': 'inline',
      'cursor': ?(recognizer == null ? null : 'pointer'),
      ...defaultStyle.combineWith(style).props,
    };

    // Override display if the computed display property is block
    if (effectiveStyles['display'] == 'block') {
      effectiveStyles['display'] = 'inline';
    }

    final List<Component> mergedChildren = [
      // Text content
      if (text.isNotNullAndEmpty) .text(text!),

      // Inline components
      if (children != null)
        for (final child in children!) child as Component,
    ];

    return .element(
      key: key,
      tag: 'naki-textspan',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      attributes: {'aria-label': ?semanticsLabel},
      events: recognizer?.toMap,
      children: mergedChildren,
    );
  }

  static List<StyleRule> get styles => BasicsStyles.text;
}
