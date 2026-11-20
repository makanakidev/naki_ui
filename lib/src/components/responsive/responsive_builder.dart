part of 'index.dart';

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
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${breakpoint!.className}', [child!]),
      );
    }

    if (mobile != null) {
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${BreakPoint.mobile.className}', [
          mobile!,
        ]),
      );
    }

    if (largerMobile != null) {
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${BreakPoint.largerPhone.className}', [
          largerMobile!,
        ]),
      );
    }

    if (tablet != null) {
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${BreakPoint.tablet.className}', [
          tablet!,
        ]),
      );
    }

    if (laptop != null) {
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${BreakPoint.laptop.className}', [
          laptop!,
        ]),
      );
    }

    if (desktop != null) {
      responsiveComponents.add(
        span(classes: 'naki-breakpoint ${BreakPoint.desktop.className}', [
          desktop!,
        ]),
      );
    }

    return responsiveComponents.isEmpty
        ? const .empty()
        : responsiveComponents.length == 1
        ? responsiveComponents.first
        : .fragment(responsiveComponents);
  }
}
