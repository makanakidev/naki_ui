part of 'index.dart';

/// {@template ResponsiveBuilder}
/// Deprecated alias for [ResponsiveLayout].
///
/// Use [ResponsiveLayout] instead. [ResponsiveBuilder] will be
/// removed in `v2.0.0`.
/// {@endtemplate}
@Deprecated('This will be removed in v2.0.0. Use ResponsiveLayout instead.')
class ResponsiveBuilder extends ResponsiveLayout {
  /// {@macro ResponsiveBuilder}
  const ResponsiveBuilder({
    super.key,
    super.breakpoint,
    super.mobile,
    super.largerMobile,
    super.tablet,
    super.laptop,
    super.desktop,
    super.child,
  });

  static List<StyleRule> get styles => ResponsiveLayout.styles;
}
