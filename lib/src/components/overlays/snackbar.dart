part of 'index.dart';

// /////////////////////////////////////////////////////////////////////////////
// OVERLAY COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Snackbar}
/// A component that displays a snackbar / toast notification
/// positioned dynamically on the screen.
///
/// ### Example
/// ```dart
/// final controller = OverlayController();
///
/// Column(children: [
///   Button(
///     child: NakiText('Show Snackbar'),
///     onPressed: () {
///       controller.open();
///     },
///   ),
/// ])
///
/// Snackbar(
///   controller: controller,
///   content: NakiText('Item saved'),
///   position: SnackbarPosition.bottom,
///   duration: Duration(seconds: 3),
/// )
/// ```
/// {@endtemplate}
class Snackbar extends StatefulComponent {
  /// Content displayed in the snackbar.
  ///
  /// Usually a [NakiText] component, but can be any other component.
  final Component content;

  /// Duration before the snackbar closes (default: 5 seconds).
  final Duration duration;

  /// Snackbar position (default: bottom center).
  final SnackbarPosition position;

  /// Whether to display a close icon (default: `false`).
  final bool showCloseIcon;

  /// Callback invoked when the snackbar is closed.
  final VoidCallback? onClose;

  /// Controller for managing the snackbar's open/close state.
  ///
  /// Leave it out when showing the snackbar with [showSnackbar],
  /// which automatically controls it.
  final OverlayController? controller;

  /// Snackbar background color.
  final Color? backgroundColor;

  /// Snackbar background gradient.
  ///
  /// ### Example
  /// ```dart
  /// Snackbar(
  ///   content: NakiText('Gradient Snackbar'),
  ///   controller: controller,
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.indigo]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Color applied on the snackbar [content].
  final Color? foregroundColor;

  /// Color applied on the close icon.
  final Color? closeIconColor;

  /// Snackbar border radius.
  final BorderRadiusData? borderRadius;

  /// Snackbar content padding.
  final EdgeInsets? padding;

  /// Size constraints of the snackbar.
  final SizeConstraints? sizeConstraints;

  /// Optional CSS classes applied to the snackbar.
  final String? classes;

  /// {@macro Snackbar}
  const Snackbar({
    super.key,
    required this.content,
    this.position = SnackbarPosition.bottom,
    this.showCloseIcon = false,
    this.duration = const Duration(seconds: 5),
    this.controller,
    this.sizeConstraints,
    this.onClose,
    this.backgroundColor,
    this.gradient,
    this.foregroundColor,
    this.closeIconColor,
    this.borderRadius,
    this.padding,
    this.classes,
  });

  @override
  State<Snackbar> createState() => _SnackbarState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Snackbar', [Rules.nakiSnackbarRules]);
}

class _SnackbarState extends State<Snackbar>
    with NakiOverlayVisibilityMixin<Snackbar> {
  Timer? _timer;

  late final _id = nakiDomId(context, 'snackbar');

  /// Controller used when neither the component nor a host provides one.
  final _ownController = OverlayController();

  late OverlayController _controller = _resolveController();

  OverlayController _resolveController() =>
      component.controller ??
      OverlayEntryScope.maybeOf(context) ??
      _ownController;

  @override
  Duration get exitDuration => const Duration(milliseconds: 200);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    final isOpen = _controller.isOpen;
    syncVisibility(isOpen, rebuild: false);

    if (isOpen) SnackbarRegistry.onOpen(_controller);
    _controller.addListener(_onControllerChanged);

    _scheduleAutoDismiss();
  }

  @override
  void didUpdateComponent(Snackbar oldComponent) {
    super.didUpdateComponent(oldComponent);

    final controller = _resolveController();
    if (controller != _controller) {
      _controller.removeListener(_onControllerChanged);
      _controller = controller..addListener(_onControllerChanged);
      syncVisibility(controller.isOpen, rebuild: false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Handles controller changes
  void _onControllerChanged() {
    final isOpen = _controller.isOpen;
    if (isOpen == isInteractive) return;

    if (isOpen) {
      SnackbarRegistry.onOpen(_controller);
      _scheduleAutoDismiss();
    } else {
      _timer?.cancel();
      _timer = null;
      SnackbarRegistry.onClose(_controller);
    }

    syncVisibility(isOpen);
  }

  /// Schedules the auto-dismiss timer
  void _scheduleAutoDismiss() {
    _timer?.cancel();
    final isOpen = _controller.isOpen;
    if (isOpen && kIsWeb) _timer = Timer(component.duration, _close);
  }

  /// Closes the snackbar
  void _close() {
    _timer?.cancel();
    _timer = null;
    component.onClose?.call();
    _controller.close();
  }

  /// Returns offset properties when appbar or bottom navbar is present
  Map<String, String>? get _offsetProps {
    final scaffold = Scaffold.maybeOf(context);

    if (scaffold != null) {
      String appbarHeight = Tokens.current.appbarHeight.name;
      String bottomNavbarHeight = Tokens.current.bottomNavbarHeight.name;

      appbarHeight = 'var($appbarHeight, 56px)';
      bottomNavbarHeight = 'var($bottomNavbarHeight, 64px)';

      final appbarOffset =
          'var(${Tokens.current.appbarOffset}, '
          'calc($appbarHeight + ${Css.safeAreaTop}))';

      final bottomNavbarOffset =
          'var(${Tokens.current.bottomNavbarOffset}, '
          'calc($bottomNavbarHeight + ${Css.safeAreaBottom}))';

      final isTopPosition =
          component.position == .top ||
          component.position == .topLeft ||
          component.position == .topRight;

      final isBottomPosition =
          component.position == .bottom ||
          component.position == .bottomLeft ||
          component.position == .bottomRight;

      if (isTopPosition && scaffold.hasAppbar) {
        return {
          Tokens.current.snackbarOffset.name: 'calc($appbarOffset + 5px)',
        };
      }

      if (isBottomPosition && scaffold.hasBottomNavbar) {
        return {
          Tokens.current.snackbarOffset.name: 'calc($bottomNavbarOffset + 5px)',
        };
      }
    }

    return null;
  }

  @override
  Component build(BuildContext context) {
    if (!isVisible) return const .empty();

    final effectiveStyles = {
      Tokens.current.snackbarBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.snackbarForegroundColor.name:
          ?component.foregroundColor?.value,
      Tokens.current.snackbarBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.snackbarPadding.name: ?component.padding?.value,
      ...?component.sizeConstraints?.props,
      ...?_offsetProps,
      ...?component.gradient?.props,
    };

    final baseClass = 'naki-snackbar ${component.position.className}';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final List<Component> effectiveChildren = [
      // main content
      component.content,

      // optional close icon
      if (component.showCloseIcon)
        Button.icon(
          MaterialIcons.icon_round_close,
          size: 20,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: component.closeIconColor ?? context.red,
          height: Dim.auto,
          width: Dim.auto,
          onTap: _close,
          attributes: const {'aria-label': 'Close notification'},
        ),
    ];

    final Component _snackbar = .element(
      tag: 'naki-snackbar',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      attributes: {
        'role': 'status',
        'aria-live': 'polite',
        ...exitAttributes,
      },
      styles: Styles(raw: effectiveStyles),
      children: effectiveChildren,
    );

    return OverlayEntryScope.maybeOf(context) != null
        ? _snackbar
        : OverlayScope(id: _id, child: _snackbar);
  }
}
