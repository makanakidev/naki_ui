part of 'index.dart';

/// {@template Drawer}
/// A component that renders a side panel which slides smoothly from the
/// left or right edge of the viewport with a backdrop barrier.
///
/// **NOTE**: Use [Sidebar] for a simplified interface for rendering
/// a persistent side panel.
///
/// ### Example
/// ```dart
/// final drawerController = OverlayController();
///
/// // Trigger opening the drawer
/// Button.text(
///   'Open Drawer',
///   onTap: () => drawerController.open(),
/// )
///
/// // The Drawer will only render when opened via controller
/// Drawer(
///   controller: drawerController,
///   position: DrawerPosition.left,
///   child: Column(
///     children: [
///       NakiText('Navigation'),
///       Button.text('Item 1', onTap: () {}),
///       Button.text('Item 2', onTap: () {}),
///       Button.text('Item 3', onTap: () {}),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class Drawer extends StatefulComponent {
  /// Component displayed in the drawer.
  final Component child;

  /// Slide-in position / anchor (`left` or `right`).
  final DrawerPosition position;

  /// Whether clicking the barrier dismisses the drawer.
  final bool barrierDismissible;

  /// Whether the drawer behaves as a modal overlay
  /// or persistent side panel.
  final bool modal;

  /// Callback executed after the drawer is closed.
  final VoidCallback? onClose;

  /// Controller for managing the drawer's open/close state.
  final OverlayController? controller;

  /// Drawer's width.
  final Dim? width;

  /// Drawer's background color.
  final Color? backgroundColor;

  /// Drawer's background gradient.
  ///
  /// ### Example
  /// ```dart
  /// Drawer(
  ///   gradient: Gradient()..applyLinear(colors: [Colors.indigo, Colors.purple]),
  ///   child: NakiText('Drawer Menu'),
  /// )
  /// ```
  final Gradient? gradient;

  /// Drawer's barrier color.
  final Color? barrierColor;

  /// Additional CSS classes applied to the drawer.
  final String? classes;

  /// Accessible name announced for the drawer.
  final String semanticLabel;

  /// {@macro Drawer}
  const Drawer({
    super.key,
    required this.child,
    this.position = DrawerPosition.left,
    this.barrierDismissible = true,
    this.semanticLabel = 'Navigation drawer',
    this.onClose,
    this.controller,
    this.width,
    this.backgroundColor,
    this.gradient,
    this.barrierColor,
    this.classes,
  }) : modal = true;

  /// Creates a [Drawer] suitable for side navigation on large screens.
  const Drawer._sidebar({
    super.key,
    required this.child,
    this.semanticLabel = 'Navigation drawer',
    this.width,
    this.backgroundColor,
    this.gradient,
    this.classes,
  }) : modal = false,
       position = DrawerPosition.left,
       barrierDismissible = false,
       barrierColor = null,
       controller = null,
       onClose = null;

  /// Creates a copy of this drawer with the given fields replaced.
  Drawer copyWith({
    Key? key,
    Component? child,
    DrawerPosition? position,
    bool? barrierDismissible,
    bool? modal,
    String? semanticLabel,
    VoidCallback? onClose,
    OverlayController? controller,
    Dim? width,
    Color? backgroundColor,
    Gradient? gradient,
    Color? barrierColor,
    String? classes,
  }) {
    return modal ?? this.modal
        ? Drawer(
            key: key ?? this.key,
            child: child ?? this.child,
            position: position ?? this.position,
            barrierDismissible: barrierDismissible ?? this.barrierDismissible,
            semanticLabel: semanticLabel ?? this.semanticLabel,
            onClose: onClose ?? this.onClose,
            controller: controller ?? this.controller,
            width: width ?? this.width,
            backgroundColor: backgroundColor ?? this.backgroundColor,
            gradient: gradient ?? this.gradient,
            barrierColor: barrierColor ?? this.barrierColor,
            classes: classes ?? this.classes,
          )
        : Drawer._sidebar(
            key: key ?? this.key,
            child: child ?? this.child,
            semanticLabel: semanticLabel ?? this.semanticLabel,
            width: width ?? this.width,
            backgroundColor: backgroundColor ?? this.backgroundColor,
            gradient: gradient ?? this.gradient,
            classes: classes ?? this.classes,
          );
  }

  @override
  State<Drawer> createState() => _DrawerState();

  static List<StyleRule> get styles => OverlaysStyles.drawer;
}

class _DrawerState extends State<Drawer>
    with
        NakiAccessibleOverlayMixin<Drawer>,
        NakiOverlayVisibilityMixin<Drawer> {
  late final _id = nakiDomId(context, 'drawer');

  @override
  Duration get exitDuration => const Duration(milliseconds: 120);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  bool get _isOpen => component.controller?.isOpen ?? !component.modal;

  @override
  void initState() {
    super.initState();
    syncVisibility(_isOpen, rebuild: false);
    component.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(Drawer oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller?.removeListener(_onControllerChanged);
      component.controller?.addListener(_onControllerChanged);
    }

    syncVisibility(_isOpen, rebuild: false);
  }

  @override
  void dispose() {
    component.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => syncVisibility(_isOpen);

  void _close() {
    component.onClose?.call();
    component.controller?.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(component.modal && isInteractive, _close);

    if (!isVisible) return const SizedBox();

    final effectiveStyles = {
      Tokens.current.drawerBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.drawerWidth.name: ?component.width?.cssText,
      Tokens.current.drawerBarrierBg.name: ?component.barrierColor?.value,
      ...?component.gradient?.props,
    };

    final baseClass = component.modal ? 'naki-drawer' : 'naki-sidebar';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final contentClass = component.modal
        ? 'naki-drawer-content drawer-${component.position.name}'
        : 'naki-sidebar-content';

    final Component _drawer = .element(
      tag: baseClass,
      key: component.key,
      id: _id,
      classes: effectiveClasses,
      attributes: component.modal ? {...exitAttributes, 'modal': 'true'} : null,
      styles: Styles(raw: effectiveStyles),
      events: component.barrierDismissible
          ? {'click': (e) => _onBarrierClick(e, _close)}
          : null,
      children: [
        // Content
        aside(
          key: overlaySurfaceKey,
          classes: contentClass,
          attributes: {
            'aria-label': component.semanticLabel,
            if (component.modal) ...{
              'role': 'dialog',
              'aria-modal': 'true',
              'tabindex': '-1',
              ...exitAttributes,
            },
          },
          [component.child],
        ),
      ],
    );

    if (component.modal && OverlayEntryScope.maybeOf(context) == null) {
      return OverlayEntryScope(
        controller: OverlayCallbackController(_close),
        child: _drawer,
      );
    }

    return _drawer;
  }
}
