part of 'index.dart';

/// Represents spacing attributes (margins or paddings) around a component.
class EdgeInsets {
  /// Spacing on the top side.
  final Dim? top;

  /// Spacing on the right side.
  final Dim? right;

  /// Spacing on the bottom side.
  final Dim? bottom;

  /// Spacing on the left side.
  final Dim? left;

  /// Creates spacing where all four sides have the same `value`.
  const EdgeInsets.all(Dim value)
    : top = value,
      right = value,
      bottom = value,
      left = value;

  /// Creates spacing with symmetrical vertical and horizontal offsets.
  const EdgeInsets.symmetric({Dim? vertical, Dim? horizontal})
    : top = vertical,
      bottom = vertical,
      left = horizontal,
      right = horizontal;

  /// Creates spacing with only the specified sides set.
  const EdgeInsets.only({this.top, this.right, this.bottom, this.left});

  /// The default zero spacing.
  static const zero = EdgeInsets.all(Dim.zero);

  /// Converts padding attributes to a CSS style map.
  Map<String, String> get pProps => {
    if (top != null &&
        top == right &&
        bottom == left &&
        top == bottom &&
        right == left) ...{
      'padding': top!.cssText,
    } else if (top != null &&
        right != null &&
        top == bottom &&
        right == left) ...{
      'padding': '${top!.cssText} ${right!.cssText}',
    } else if (top != null &&
        right != null &&
        bottom != null &&
        left != null) ...{
      'padding':
          '${top!.cssText} ${right!.cssText} ${bottom!.cssText} ${left!.cssText}',
    } else ...{
      'padding-top': ?top?.cssText,
      'padding-right': ?right?.cssText,
      'padding-bottom': ?bottom?.cssText,
      'padding-left': ?left?.cssText,
    },
  };

  /// Converts margin attributes to a CSS style map.
  Map<String, String> get mProps => {
    if (top != null &&
        top == right &&
        bottom == left &&
        top == bottom &&
        right == left) ...{
      'margin': top!.cssText,
    } else if (top != null &&
        right != null &&
        top == bottom &&
        right == left) ...{
      'margin': '${top!.cssText} ${right!.cssText}',
    } else if (top != null &&
        right != null &&
        bottom != null &&
        left != null) ...{
      'margin':
          '${top!.cssText} ${right!.cssText} ${bottom!.cssText} ${left!.cssText}',
    } else ...{
      'margin-top': ?top?.cssText,
      'margin-right': ?right?.cssText,
      'margin-bottom': ?bottom?.cssText,
      'margin-left': ?left?.cssText,
    },
  };

  /// Gets the CSS value of the EdgeInsets.
  ///
  /// If padding properties are set, it returns the padding value.
  /// Otherwise, it returns the margin value.
  ///
  /// Returns `null` if both padding and margin properties are not set.
  ///
  /// Example:
  /// ```dart
  /// const EdgeInsets.only(top: 10, right: 20, bottom: 30, left: 40).value;
  /// // Returns '10px 20px 30px 40px'
  /// ```
  String? get value {
    final map = pProps.isEmpty ? mProps : pProps;
    if (map.isEmpty) return null;

    if (map['padding'] != null) return map['padding'];
    if (map['margin'] != null) return map['margin'];

    String value = '';

    final pTop = map['padding-top'];
    final pRight = map['padding-right'];
    final pBottom = map['padding-bottom'];
    final pLeft = map['padding-left'];

    final mTop = map['margin-top'];
    final mRight = map['margin-right'];
    final mBottom = map['margin-bottom'];
    final mLeft = map['margin-left'];

    if (pTop != null) value += '$pTop ';
    if (pRight != null) value += '$pRight ';
    if (pBottom != null) value += '$pBottom ';
    if (pLeft != null) value += '$pLeft ';

    if (mTop != null) value += '$mTop ';
    if (mRight != null) value += '$mRight ';
    if (mBottom != null) value += '$mBottom ';
    if (mLeft != null) value += '$mLeft ';

    return value.trim();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EdgeInsets &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left;

  @override
  int get hashCode => Object.hash(top, right, bottom, left);
}
