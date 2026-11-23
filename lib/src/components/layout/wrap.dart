part of 'index.dart';

/// {@template Wrap}
/// A component that displays its children in multiple horizontal
/// or vertical runs.
///
/// ### Example
/// ```dart
/// Wrap(
///   children: [
///     NakiText('Padded Content'),
///     NakiText('Padded Content'),
///   ],
/// )
/// ```
/// {@endtemplate}
class Wrap extends StatelessComponent {
  /// Components to wrap.
  final List<Component> children;

  /// Direction to use as the main ScrollDirection.
  final Direction direction;

  /// How the children within a run should be
  /// placed in the main ScrollDirection.
  final MainAxisAlignment alignment;

  /// How the children within a run should be
  /// aligned in the cross ScrollDirection.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space (in pixels) to place between children
  /// in a run in the main ScrollDirection.
  final double? spacing;

  /// How much space (in pixels) to place between the runs
  /// themselves in the cross ScrollDirection.
  final double? runSpacing;

  /// Additional CSS classes applied to the wrap component.
  final String? classes;

  /// {@macro Wrap}
  const Wrap({
    super.key,
    required this.children,
    this.direction = Direction.horizontal,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
    this.runSpacing,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-wrap';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final justify = NakiAlignProps.mapMainAxisAlignment(alignment);
    final align = NakiAlignProps.mapCrossAxisAlignment(crossAxisAlignment);
    final isHoriz = direction == Direction.horizontal;

    return .element(
      tag: 'naki-wrap',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'flex-direction': isHoriz ? 'row' : 'column',
          'justify-content': justify,
          'align-items': align,
          'column-gap': ?(isHoriz ? spacing?.toPx : runSpacing?.toPx),
          'row-gap': ?(!isHoriz ? spacing?.toPx : runSpacing?.toPx),
        },
      ),
      children: children,
    );
  }

  static List<StyleRule> get styles => LayoutStyles.wrap;
}
