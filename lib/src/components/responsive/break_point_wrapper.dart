part of 'index.dart';

/// {@template BreakPointWrapper}
/// A utility component for defining custom breakpoints. It builds its
/// descendant based on a [minWidth], [maxWidth] or both.
///
/// ### Example:
/// ```dart
/// BreakPointWrapper(
///   minWidth: 100,
///   maxWidth: 200,
///   child: NakiText('Show only when screen width >= 100px and width < 200px'),
/// )
/// ```
/// {@endtemplate}
class BreakPointWrapper extends StatelessComponent {
  /// Component to display when the breakpoint conditions are met.
  final Component child;

  /// Minimum width required to display [child] (in pixels).
  final double? minWidth;

  /// Maximum width required to display [child] (in pixels).
  final double? maxWidth;

  /// {@macro BreakPointWrapper}
  const BreakPointWrapper({
    super.key,
    required this.child,
    this.minWidth,
    this.maxWidth,
  }) : assert(
         minWidth != null || maxWidth != null,
         'Either provide a minWidth or maxWidth',
       ),
       assert(
         minWidth == null || maxWidth == null || minWidth < maxWidth,
         'minWidth must be less than maxWidth',
       );

  @override
  Component build(BuildContext context) {
    final String id;
    final MediaQuery query;

    if (minWidth != null && maxWidth != null) {
      id = 'mn${minWidth!.roundDown}mx${maxWidth!.roundDown}';
      query = MediaQuery.screen(
        minWidth: (minWidth! + 0.02).px,
        maxWidth: maxWidth!.px,
      );
    } else if (minWidth != null) {
      id = 'mn${minWidth!.roundDown}';
      query = MediaQuery.screen(minWidth: (minWidth! + 0.02).px);
    } else {
      id = 'mx${maxWidth!.roundDown}';
      query = MediaQuery.screen(maxWidth: maxWidth!.px);
    }

    final styles = [
      css('.br-$id').styles(raw: {'display': 'none'}),
      css.media(query, [
        css('.br-$id').styles(raw: {'display': 'contents'}),
      ]),
    ];

    return NakiFragment([
      span(classes: 'naki-breakpoint br-$id', [child]),
      Document.head(children: [StyleRules(styles, id: id)]),
    ]);
  }
}
