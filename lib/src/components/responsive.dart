import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../../theme.dart';
import '../styles/rules.dart';
import '../utilities/enums.dart';

/// {@template ResponsiveBuilder}
/// A component that builds its descendant based on a [breakpoint]
/// and [child], or breakpoint-specific component.
///
/// You can either provide [breakpoint] and [child], or provide one or more
/// **breakpoint-specific** components (e.g. [mobile], [largerMobile], [tablet],
/// [laptop], or [desktop]).
///
/// ### Example: Using [breakpoint] and [child]
/// ```dart
/// ResponsiveBuilder(
///   breakpoint: BreakPoint.xs,
///   child: NakiText('Show only when screen width < 480px'),
/// )
/// ```
///
/// ### Example: Using breakpoint-specific properties
/// ```dart
/// ResponsiveBuilder(
///   mobile: NakiText('Show on mobile phones (width < 480px)'),
///   tablet: NakiText('Show on tablets (576px <= width < 768px)'),
/// )
/// ```
/// {@endtemplate}
class ResponsiveBuilder extends StatelessComponent {
  /// The breakpoint to build [child] at.
  final BreakPoint? breakpoint;

  /// Component to build when [breakpoint] condition is met.
  final Component? child;

  /// Component to build at mobile breakpoint
  /// `width < 480px`.
  final Component? mobile;

  /// Component to build at larger than mobile breakpoint
  /// `480px <= width < 576px`.
  final Component? largerMobile;

  /// Component to build at tablet breakpoint
  /// `576px <= width < 768px`.
  final Component? tablet;

  /// Component to build at laptop breakpoint
  /// `768px <= width < 1024px`.
  final Component? laptop;

  /// Component to build at desktop breakpoint
  /// `width >= 1024px`.
  final Component? desktop;

  /// {@macro ResponsiveBuilder}
  const ResponsiveBuilder({
    super.key,
    this.breakpoint,
    this.mobile,
    this.largerMobile,
    this.tablet,
    this.laptop,
    this.desktop,
    this.child,
  }) : assert(
         (breakpoint != null && child != null) ||
             mobile != null ||
             largerMobile != null ||
             tablet != null ||
             laptop != null ||
             desktop != null,
         'Either provide a breakpoint with a child or provide at least one '
         'breakpoint-specific component',
       );

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ResponsiveBuilder', Rules.nakiBreakpointRules);

  @override
  Component build(BuildContext context) {
    final responsiveComponents = <Component>[];

    if (breakpoint != null && child != null) {
      responsiveComponents.add(.wrapElement(child: child!, classes: breakpoint!.className));
    }

    if (mobile != null) {
      responsiveComponents.add(.wrapElement(child: mobile!, classes: BreakPoint.mobile.className));
    }

    if (largerMobile != null) {
      responsiveComponents.add(
        .wrapElement(child: largerMobile!, classes: BreakPoint.largerPhone.className),
      );
    }

    if (tablet != null) {
      responsiveComponents.add(.wrapElement(child: tablet!, classes: BreakPoint.tablet.className));
    }

    if (laptop != null) {
      responsiveComponents.add(.wrapElement(child: laptop!, classes: BreakPoint.laptop.className));
    }

    if (desktop != null) {
      responsiveComponents.add(
        .wrapElement(child: desktop!, classes: BreakPoint.desktop.className),
      );
    }

    return responsiveComponents.isEmpty
        ? const .empty()
        : responsiveComponents.length == 1
        ? responsiveComponents.first
        : .fragment(responsiveComponents);
  }
}

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
  BreakPointWrapper({super.key, required this.child, this.minWidth, this.maxWidth})
    : assert(minWidth != null || maxWidth != null, 'Either provide a minWidth or maxWidth'),
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
      query = MediaQuery.screen(minWidth: (minWidth! + 0.02).px, maxWidth: maxWidth!.px);
    } else if (minWidth != null) {
      id = 'mn${minWidth!.roundDown}';
      query = MediaQuery.screen(minWidth: (minWidth! + 0.02).px);
    } else {
      id = 'mx${maxWidth!.roundDown}';
      query = MediaQuery.screen(maxWidth: maxWidth!.px);
    }

    final styles = [
      css('.br-$id').styles(raw: {'display': 'none !important'}),
      css.media(query, [
        css('.br-$id').styles(raw: {'display': 'revert !important'}),
      ]),
    ];

    return .fragment([
      Document.head(children: [StyleRules(styles, id: id)]),
      .wrapElement(child: child, classes: 'br-$id'),
    ]);
  }
}
