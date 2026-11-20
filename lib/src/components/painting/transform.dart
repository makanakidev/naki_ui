part of 'index.dart';

/// {@template Transform}
/// A component that applies a CSS 2D or 3D transform
/// transformation matrix to its child.
///
/// ### Example
/// ```dart
/// Transform(
///   transform: 'rotate(45deg)',
///   child: NakiText('I am rotated'),
/// )
/// ```
/// Supports
/// - `rotate` via [Transform.rotate],
/// - `scale` via [Transform.scale],
/// - `translate` via [Transform.translate]
/// {@endtemplate}
class Transform extends StatelessComponent {
  /// The component to display inside the transform container.
  final Component child;

  /// CSS transform string value.
  ///
  /// ### Example
  /// ```dart
  /// Transform(
  ///   transform: 'rotate(45deg)',
  ///   ...,
  /// )
  /// ```
  final String transform;

  /// Origin alignment for transformation.
  final Alignment? alignment;

  /// Optional CSS classes applied to the transform component.
  final String? classes;

  /// {@macro Transform}
  const Transform({
    super.key,
    required this.transform,
    required this.child,
    this.alignment,
    this.classes,
  });

  /// Creates a rotation transformation.
  ///
  /// ### Example
  /// ```dart
  /// Transform.rotate(
  ///   -45,
  ///   child: NakiText('I am rotated'),
  /// );
  /// ```
  Transform.rotate(
    double angle, {
    super.key,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = 'rotate(${angle.toCleanString}deg)';

  /// Creates a scaling transformation.
  ///
  /// ### Example
  /// ```dart
  /// Transform.scale(
  ///   2,
  ///   child: NakiText('I am scaled'),
  /// );
  /// ```
  Transform.scale(
    double scale, {
    super.key,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = 'scale(${scale.toCleanString})';

  /// Creates a translation transformation.
  ///
  /// - [offsetX] (horizontal displacement) and
  /// - [offsetY] (vertical displacement) can be specified in pixels, percentage
  /// or any other valid CSS unit.
  ///
  /// ### Example
  /// ```dart
  /// Transform.translate(
  ///   offsetX: Dim.px(10),
  ///   offsetY: Dim.percent(20),
  ///   child: NakiText('I am translated'),
  /// );
  /// ```
  Transform.translate({
    super.key,
    Dim? offsetX,
    Dim? offsetY,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = offsetX != null && offsetY != null
           ? 'translate(${offsetX.cssText}, ${offsetY.cssText})'
           : offsetX != null
           ? 'translateX(${offsetX.cssText})'
           : offsetY != null
           ? 'translateY(${offsetY.cssText})'
           : 'none';

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-transform';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'display': 'inline-block',
      'transform': transform,
      'transform-origin': ?(alignment != null
          ? NakiAlignProps.mapTransformOrigin(alignment!)
          : null),
    };

    return .element(
      tag: 'naki-transform',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }
}
