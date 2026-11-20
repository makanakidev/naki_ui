part of 'index.dart';

/// {@template Container}
/// A component that combines common painting, positioning, and sizing.
///
/// ### Example
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: Colors.red,
///     border: BorderData(
///       color: Colors.black,
///       radius: BorderRadiusData.all(Dim.px(10)),
///     ),
///     shadow: Shadow(
///       offsetX: 0,
///       offsetY: 10,
///       blurRadius: 10,
///       spreadRadius: 5,
///       color: Colors.black,
///     ),
///   ),
///   child: NakiText('Hello'),
/// )
/// ```
/// {@endtemplate}
class Container extends StatelessComponent {
  /// Child component of the container.
  final Component? child;

  /// Height of the container.
  final Dim? height;

  /// Width of the container.
  final Dim? width;

  /// Decoration properties of the container.
  final BoxDecoration? decoration;

  /// Size constraints of the container.
  final SizeConstraints? constraints;

  /// Custom CSS classes applied to the container.
  final String? classes;

  /// {@macro Container}
  const Container({
    super.key,
    this.child,
    this.height,
    this.width,
    this.constraints,
    this.decoration,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-container';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'height': ?height?.cssText,
      'width': ?width?.cssText,
      ...?constraints?.props,
      ...?decoration?.props,
    };

    return .element(
      key: key,
      tag: 'naki-container',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [?child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Container', [Rules.nakiContainerRules]);
}
