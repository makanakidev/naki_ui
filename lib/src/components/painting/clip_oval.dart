part of 'index.dart';

/// {@template ClipOval}
/// A component that clips its child using an oval/circular shape.
///
/// ### Example
/// ```dart
/// ClipOval(
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class ClipOval extends StatelessComponent {
  /// The component to clip.
  final Component child;

  /// Optional CSS classes applied to the clip container.
  final String? classes;

  /// {@macro ClipOval}
  const ClipOval({super.key, required this.child, this.classes});

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-clip-oval';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-clipoval',
      key: key,
      classes: effectiveClasses,
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ClipOval', [Rules.nakiClipOvalRules]);
}
