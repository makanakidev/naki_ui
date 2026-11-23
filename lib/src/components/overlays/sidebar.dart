part of 'index.dart';

/// {@template Sidebar}
/// A component that renders a persistent side navigation alongside
/// main content.
///
/// Unlike [Drawer], [Sidebar] remains permanently visible, does
/// not render a backdrop barrier, and does not require an
/// [OverlayController].
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
  /// {@macro Sidebar}
  const Sidebar({
    super.key,
    required super.child,
    super.semanticLabel,
    super.width,
    super.backgroundColor,
    super.gradient,
    super.classes,
  }) : super._sidebar();

  static List<StyleRule> get styles => OverlaysStyles.sidebar;
}
