part of 'index.dart';

/// {@template Sidebar}
/// A component that renders a persistent side navigation alongside main content.
///
/// Unlike [Drawer], [Sidebar] remains permanently visible, does not render a
/// backdrop barrier, and does not require an [OverlayController].
///
/// ### Example
/// ```dart
/// Sidebar(
///   placement: SidebarPlacement.left,
///   width: Dim.px(260),
///   child: Column(
///     children: [
///       NakiText('Navigation'),
///       Button.text('Dashboard', onTap: () {}),
///       Button.text('Settings', onTap: () {}),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class Sidebar extends Drawer {
  /// Width of the sidebar.
  final Dim? width;

  /// Background color of the sidebar.
  final Color? backgroundColor;

  /// Background gradient of the sidebar.
  final Gradient? gradient;

  /// Additional CSS classes applied to the sidebar.
  final String? classes;

  /// {@macro Sidebar}
  const Sidebar({
    super.key,
    required super.child,
    super.semanticLabel = 'Navigation sidebar',
    this.width,
    this.backgroundColor,
    this.gradient,
    this.classes,
  }) : super._sidebar(
         width: width,
         backgroundColor: backgroundColor,
         gradient: gradient,
         classes: classes,
       );

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Sidebar', Rules.nakiSidebarRules);
}
