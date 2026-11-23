part of 'index.dart';

/// {@template AspectRatio}
/// A component that attempts to size its child to a specific
/// aspect ratio.
///
/// ### Example
/// ```dart
/// AspectRatio(
///   ratio: Ratio.stories,
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

  @Deprecated('This will be removed in v2.0.0. Use ratio instead.')
  final AspectRatioType? aspectRatio;

  /// Aspect ratio applied to [child].
  final Ratio ratio;

  /// Additional CSS classes applied to aspect ratio component.
  final String? classes;

  /// {@macro AspectRatio}
  const AspectRatio({
    super.key,
    required this.child,
    this.aspectRatio,
    this.ratio = Ratio.ratio1_1,
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
      styles: Styles(raw: {'aspect-ratio': (aspectRatio ?? ratio).css}),
      children: [child],
    );
  }

  static List<StyleRule> get styles => LayoutStyles.aspectRatio;
}
