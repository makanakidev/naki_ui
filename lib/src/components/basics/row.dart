part of 'index.dart';

/// {@template Row}
/// A component that displays its children in an horizontal array.
///
/// ### Example
/// ```dart
/// Row(
///   mainAxisSize: MainAxisSize.min,
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
///
/// // Example of a scrollable row
/// Row(
///   scrollable: true,
///   spacing: 10,
///   crossAxisAlignment: CrossAxisAlignment.center,
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///   ),
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
/// ```
/// {@endtemplate}
class Row extends StatelessComponent {
  /// Components below this row in the tree.
  final List<Component> children;

  /// How the children should be placed along the horizontal axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the vertical axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much horizontal space the row should occupy.
  final MainAxisSize mainAxisSize;

  /// Scrollbar configuration applied when [scrollable] is `true`.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the row.
  final String? classes;

  /// The distance (in px) between [children] components.
  final double? spacing;

  /// Reverse the order of children.
  final bool reverse;

  /// When `true`, the row will be scrollable.
  final bool scrollable;

  /// {@macro Row}
  const Row({
    super.key,
    required this.children,
    this.reverse = false,
    this.scrollable = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing,
    this.classes,
    this.scrollBarConfiguration,
  });

  @override
  Component build(BuildContext context) {
    final _id = nakiDomId(context, 'row');

    final justify = NakiAlignProps.mapMainAxisAlignment(mainAxisAlignment);
    final align = NakiAlignProps.mapCrossAxisAlignment(crossAxisAlignment);

    const baseClass = 'naki-row';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'display': 'flex',
      'flex-direction': reverse ? 'row-reverse' : 'row',
      'justify-content': justify,
      'align-items': align,
      'width': ?(mainAxisSize == MainAxisSize.max ? '100%' : null),
      'column-gap': ?spacing?.toPx,
      'overflow-x': ?(scrollable ? 'auto' : null),
    };

    Component child = .element(
      key: key,
      tag: 'naki-row',
      id: _id,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: children,
    );

    if (scrollable && scrollBarConfiguration != null) {
      child = ScrollBarWrapper(
        selector: '#$_id',
        configuration: scrollBarConfiguration,
        child: child,
      );
    }

    return FlexScope(scrollable: scrollable, child: child);
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Row', [Rules.nakiRowRules]);
}
