part of 'index.dart';

/// {@template ColoredBox}
/// A component that paints a background color or gradient behind its child.
///
/// ### Example: Box with solid red background
/// ```dart
/// ColoredBox(
///   color: Colors.red,
///   child: NakiText('I am red'),
/// )
/// ```
///
/// ### Example: Box with linear gradient background
/// ```dart
/// ColoredBox(
///   gradient: Gradient()..applyLinear(colors: [Colors.red, Colors.blue]),
///   child: NakiText('I am red'),
/// )
/// ```
/// {@endtemplate}
class ColoredBox extends StatelessComponent {
  /// The component to display inside the colored box.
  final Component child;

  /// Background color of the box.
  final Color? color;

  /// Background gradient of the box.
  final Gradient? gradient;

  /// Optional CSS classes applied to the colored box component.
  final String? classes;

  /// {@macro ColoredBox}
  const ColoredBox({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.classes,
  }) : assert(
         color != null || gradient != null,
         'ColoredBox must have a color or gradient',
       );

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-coloredbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-coloredbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'display': 'block',
          'background-color': ?color?.value,
          ...?gradient?.props,
        },
      ),
      children: [child],
    );
  }
}
