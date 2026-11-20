part of 'index.dart';

/// Abstract class that represents a single inline text span.
abstract class InlineSpan {
  /// Text style of the inline span.
  final TextStyle? style;

  /// An optional screen-reader description or ARIA label for this span.
  final String? semanticsLabel;

  const InlineSpan({this.style, this.semanticsLabel});

  /// Flattens this span and its children into a plain text string.
  String toPlainText();

  /// Walks this span and all nested child spans in pre-order traversal.
  /// Stops recursion early if [visitor] returns `false`.
  bool visitChildren(bool Function(InlineSpan span) visitor);
}
