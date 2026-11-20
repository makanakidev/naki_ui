part of 'index.dart';

/// {@template Flexible}
/// A component that controls how a child of a [Row]
/// or [Column] flexes.
///
/// Using a [Flexible] component gives a child of a [Row]
/// or [Column] the flexibility to expand to fill the available space
/// in the main axis, but unlike [Expanded], [Flexible] with
/// [FlexFit.loose] does not require the child to fill the available space.
///
/// ### Example
/// ```dart
/// Row(
///   children: [
///     Flexible(
///       flex: 2,
///       fit: FlexFit.loose,
///       child: NakiText('Flexible Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Flexible extends StatelessComponent {
  /// Component to flex.
  final Component child;

  /// Flex factor applied to the child.
  final int flex;

  /// How a flexible child component sizes itself along the main axis.
  final FlexFit fit;

  /// Additional CSS classes applied to the flexible component.
  final String? classes;

  /// {@macro Flexible}
  const Flexible({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
    this.classes,
  }) : assert(flex > 0, 'flex must be greater than zero');

  @override
  Component build(BuildContext context) {
    final flexScope = FlexScope.of(context);
    final isExpanded = fit == FlexFit.tight;

    if (isExpanded) {
      assert(
        flexScope != null,
        'Expanded must be a direct child of a Row or Column.',
      );

      assert(
        flexScope == null || !flexScope.scrollable,
        'Expanded cannot be used in a scrollable Row or '
        'Column. The main axis is unbounded.',
      );
    }

    final baseClass = isExpanded ? 'naki-expanded' : 'naki-flexible';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final flexValue = isExpanded ? '$flex 1 0%' : '$flex 1 auto';
    final effectiveTag = isExpanded ? 'naki-expanded' : 'naki-flexible';

    return .element(
      tag: effectiveTag,
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: {'flex': flexValue}),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Flexible', Rules.nakiFlexibleRules);
}
