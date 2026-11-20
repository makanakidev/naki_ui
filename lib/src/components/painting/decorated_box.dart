part of 'index.dart';

/// {@template DecoratedBox}
/// A component that paints a decoration before or after its child.
///
/// ### Example
/// ```dart
/// DecoratedBox(
///   color: Colors.red,
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class DecoratedBox extends StatelessComponent {
  /// The child component inside the box.
  final Component child;

  /// Background color of the decoration.
  final Color? color;

  /// Background gradient of the decoration.
  ///
  /// ### Example
  /// ```dart
  /// DecoratedBox(
  ///   gradient: Gradient()..applyLinear(colors: [Colors.orange, Colors.red]),
  ///   child: NakiText('Gradient Box'),
  /// )
  /// ```
  final Gradient? gradient;

  /// Border styling.
  final BorderData? border;

  /// Box shadow.
  final Shadow? shadow;

  /// Border radius.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes applied to the decorated box component.
  final String? classes;

  /// {@macro DecoratedBox}
  const DecoratedBox({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.border,
    this.shadow,
    this.borderRadius,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-decoratedbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'display': 'block',
      'background-color': ?color?.value,
      ...?shadow?.props,
      ...?border?.props,
      ...?borderRadius?.props,
      ...?gradient?.props,
    };

    return .element(
      tag: 'naki-decoratedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }
}
