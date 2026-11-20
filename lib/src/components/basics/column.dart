part of 'index.dart';

/// {@template Column}
/// A component that displays its children in a vertical array.
///
/// ### Example
/// ```dart
/// Column(
///   mainAxisSize: MainAxisSize.max,
///   mainAxisAlignment: MainAxisAlignment.spaceBetween,
///   children: [
///     NakiText('Hello'),
///     NakiText('World'),
///   ],
/// )
///
/// // Example of a scrollable column
/// Column(
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
class Column extends StatelessComponent {
  /// Components below this column in the tree.
  final List<Component> children;

  /// How the children should be placed along the vertical axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How the children should be placed along the horizontal axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much vertical space the column should occupy.
  final MainAxisSize mainAxisSize;

  /// Additional CSS classes applied to the column.
  final String? classes;

  /// The distance (in px) between [children] components.
  final double? spacing;

  /// Reverse the order of children.
  final bool reverse;

  /// Scrollbar configuration applied when [scrollable] is `true`.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// When `true`, the column will be scrollable.
  final bool scrollable;

  /// {@macro Column}
  const Column({
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
    final _id = nakiDomId(context, 'column');

    final justify = NakiAlignProps.mapMainAxisAlignment(mainAxisAlignment);
    final align = NakiAlignProps.mapCrossAxisAlignment(crossAxisAlignment);

    const baseClass = 'naki-column';
    final effectiveClasses = joinClasses([
      ?classes,
      ...[
        if (scrollable) ...[
          kInsetOwnerClass,
          if (mainAxisSize == MainAxisSize.max) kFillScrollClass,
        ],
      ],
      baseClass,
    ]);

    final effectiveStyles = {
      'display': 'flex',
      'flex-direction': reverse ? 'column-reverse' : 'column',
      'justify-content': justify,
      'align-items': align,
      'height': ?(mainAxisSize == MainAxisSize.max ? '100%' : null),
      'row-gap': ?spacing?.toPx,
      'overflow-y': ?(scrollable ? 'auto' : null),
      if (scrollable) ...Css.scrollPadding(null, vertical: true),
    };

    Component child = .element(
      key: key,
      id: _id,
      tag: 'naki-column',
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
      NakiStyleRegistry.once('Column', [Rules.nakiColumnRules]);
}
