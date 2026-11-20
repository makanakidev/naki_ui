part of 'index.dart';

/// {@template ClipRect}
/// A component that clips its child to a rectangular border bounds.
///
/// ### Example
/// ```dart
/// ClipRect(
///   borderRadius: BorderRadiusData.all(Dim.px(8)),
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class ClipRect extends StatelessComponent {
  /// The component to clip.
  final Component child;

  /// Radius data for curved clipping edges.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes added to the clip rect component.
  final String? classes;

  /// {@macro ClipRect}
  const ClipRect({
    super.key,
    required this.child,
    this.borderRadius,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-cliprect';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {...?borderRadius?.props};

    return .element(
      tag: 'naki-cliprect',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ClipRect', [Rules.nakiClipRectRules]);
}
