part of 'index.dart';

/// Size attributes of a component.
class SizeConstraints implements NakiStylable {
  /// Width.
  final Dim? width;

  /// Height.
  final Dim? height;

  /// Minimum width.
  final Dim? minWidth;

  /// Minimum height.
  final Dim? minHeight;

  /// Maximum width.
  final Dim? maxWidth;

  /// Maximum height.
  final Dim? maxHeight;

  /// Create a new size.
  const SizeConstraints({
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
  });

  /// Copy size constrains.
  SizeConstraints copyWith({
    Dim? width,
    Dim? height,
    Dim? minWidth,
    Dim? minHeight,
    Dim? maxWidth,
    Dim? maxHeight,
  }) => SizeConstraints(
    width: width ?? this.width,
    height: height ?? this.height,
    minWidth: minWidth ?? this.minWidth,
    minHeight: minHeight ?? this.minHeight,
    maxWidth: maxWidth ?? this.maxWidth,
    maxHeight: maxHeight ?? this.maxHeight,
  );

  /// Combines this size constraint with another size constraint.
  /// [other] is the constraint that takes precedence.
  SizeConstraints combineWith(SizeConstraints? other) {
    other ??= this;
    return SizeConstraints(
      width: other.width ?? width,
      height: other.height ?? height,
      minWidth: other.minWidth ?? minWidth,
      minHeight: other.minHeight ?? minHeight,
      maxWidth: other.maxWidth ?? maxWidth,
      maxHeight: other.maxHeight ?? maxHeight,
    );
  }

  /// Convert size attributes to CSS styles.
  @override
  Map<String, String> get props => {
    'width': ?width?.cssText,
    'height': ?height?.cssText,
    'min-width': ?minWidth?.cssText,
    'min-height': ?minHeight?.cssText,
    'max-width': ?maxWidth?.cssText,
    'max-height': ?maxHeight?.cssText,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeConstraints &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          minWidth == other.minWidth &&
          minHeight == other.minHeight &&
          maxWidth == other.maxWidth &&
          maxHeight == other.maxHeight;

  @override
  int get hashCode =>
      Object.hash(width, height, minWidth, minHeight, maxWidth, maxHeight);
}
