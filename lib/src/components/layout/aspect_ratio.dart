part of 'index.dart';

/// {@template AspectRatio}
/// A component that attempts to size its child to a specific aspect ratio.
///
/// ### Example
/// ```dart
/// AspectRatio(
///   aspectRatio: AspectRatioType.stories,
///   child: Image(
///     'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
///     fit: ObjectFit.fill,
///   ),
/// )
/// ```
/// {@endtemplate}
class AspectRatio extends StatelessComponent {
  /// Component to apply aspect ratio to.
  final Component child;

  /// Aspect ratio applied to [child].
  final AspectRatioType aspectRatio;

  /// Additional CSS classes applied to aspect ratio component.
  final String? classes;

  /// {@macro AspectRatio}
  const AspectRatio({
    super.key,
    required this.child,
    required this.aspectRatio,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-aspectratio';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      key: key,
      tag: 'naki-aspectratio',
      classes: effectiveClasses,
      styles: Styles(raw: {'aspect-ratio': aspectRatio.css}),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('AspectRatio', [Rules.nakiAspectRatioRules]);
}
