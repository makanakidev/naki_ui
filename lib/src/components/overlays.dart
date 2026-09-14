import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart';

import '../framework/framework.dart';
import '../models/overlays.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart'
    show
        DialogPosition,
        DrawerPosition,
        MainAxisAlignment,
        PopoverPosition,
        SnackbarPosition,
        TooltipPosition;
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import 'basics.dart';
import 'scaffold.dart';
import 'styling.dart';

/// Shared keyboard and focus management behavior for modal overlays.
mixin _AccessibleOverlay<T extends StatefulComponent> on State<T> {
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;
  HTMLElement? _previousFocus;
  bool _requestedOpen = false;

  final overlaySurfaceKey = GlobalNodeKey<HTMLElement>();

  void syncOverlayAccessibility(
    bool open,
    VoidCallback close,
  ) {
    if (_requestedOpen == open) return;

    _requestedOpen = open;

    onComponentRendered(() {
      if (!mounted) return;
      if (open) {
        _activateOverlay(close);
      } else {
        _deactivateOverlay();
      }
    });
  }

  List<HTMLElement> _focusableElements(
    HTMLElement surface,
  ) {
    final nodes = surface.querySelectorAll(
      'a[href], button:not([disabled]), input:not([disabled]), '
      'select:not([disabled]), textarea:not([disabled]), '
      '[tabindex]:not([tabindex="-1"])',
    );

    final elements = <HTMLElement>[];

    for (var index = 0; index < nodes.length; index++) {
      final node = nodes.item(index) as HTMLElement?;
      if (node != null) elements.add(node);
    }

    return elements;
  }

  void _activateOverlay(VoidCallback close) {
    final surface = overlaySurfaceKey.currentNode;
    if (surface == null) return;

    _previousFocus = document.activeElement as HTMLElement?;

    final focusable = _focusableElements(surface);
    (focusable.isNotEmpty ? focusable.first : surface).focus();

    _keyboardSubscription?.cancel();
    _keyboardSubscription = EventStreamProviders.keyDownEvent.forTarget(document).listen((event) {
      if (event.key == 'Escape') {
        event.preventDefault();
        close();
        return;
      }

      if (event.key != 'Tab') return;

      final currentFocusable = _focusableElements(
        surface,
      );
      if (currentFocusable.isEmpty) {
        event.preventDefault();
        surface.focus();
        return;
      }

      final first = currentFocusable.first;
      final last = currentFocusable.last;
      final active = document.activeElement;

      if (event.shiftKey && (active == first || !surface.contains(active))) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && (active == last || !surface.contains(active))) {
        event.preventDefault();
        first.focus();
      }
    });
  }

  void _deactivateOverlay() {
    _keyboardSubscription?.cancel();
    _keyboardSubscription = null;
    _previousFocus?.focus();
    _previousFocus = null;
    _requestedOpen = false;
  }

  @override
  void dispose() {
    _deactivateOverlay();
    super.dispose();
  }
}

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
  final OverlayController controller;

  /// Snackbar background color.
  final Color? backgroundColor;

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
    required this.controller,
    this.position = SnackbarPosition.bottom,
    this.showCloseIcon = false,
    this.duration = const Duration(seconds: 5),
    this.sizeConstraints,
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.closeIconColor,
    this.borderRadius,
    this.padding,
    this.classes,
  });

  @override
  State<Snackbar> createState() => _SnackbarState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Snackbar', [
    Rules.nakiSnackbarRules,
  ]);
}

class _SnackbarState extends State<Snackbar> {
  Timer? _timer;
  late bool _localIsOpen;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _localIsOpen = component.controller.isOpen;
    if (_localIsOpen) SnackbarRegistry.onOpen(component.controller);

    component.controller.addListener(_onControllerChanged);
    _scheduleAutoDismiss();
  }

  @override
  void didUpdateComponent(Snackbar oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(
        _onControllerChanged,
      );
      component.controller.addListener(
        _onControllerChanged,
      );
    }

    _localIsOpen = component.controller.isOpen;
  }

  @override
  void dispose() {
    _timer?.cancel();
    component.controller.removeListener(
      _onControllerChanged,
    );
    super.dispose();
  }

  /// Handles controller changes
  void _onControllerChanged() {
    if (_localIsOpen == component.controller.isOpen) return;

    _localIsOpen = component.controller.isOpen;

    if (_localIsOpen) {
      SnackbarRegistry.onOpen(component.controller);
      _scheduleAutoDismiss();
    } else {
      SnackbarRegistry.onClose(component.controller);
    }

    setState(() {});
  }

  /// Schedules the auto-dismiss timer
  void _scheduleAutoDismiss() {
    _timer?.cancel();
    final isOpen = component.controller.isOpen;
    if (isOpen) _timer = Timer(component.duration, _close);
  }

  /// Closes the snackbar
  void _close() {
    component.onClose?.call();
    component.controller.close();
  }

  /// Returns offset properties when appbar or bottom navbar is present
  Map<String, String>? get _offsetProps {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null) {
      final appBarHeight = scaffold.appBarHeight ?? Tokens.current.appbarHeight.value;

      final bottomNavbarHeight =
          scaffold.bottomNavbarHeight ?? Tokens.current.bottomNavbarHeight.value;

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
          Tokens.current.snackbarOffset.name: 'calc($appBarHeight + env(--safe-area-inset-top))',
        };
      }

      if (isBottomPosition && scaffold.hasBottomNavbar) {
        return {
          Tokens.current.snackbarOffset.name:
              'calc($bottomNavbarHeight + env(--safe-area-inset-bottom))',
        };
      }
    }

    return null;
  }

  @override
  Component build(BuildContext context) {
    if (!_localIsOpen) return const .empty();

    final effectiveStyles = {
      Tokens.current.snackbarBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.snackbarForegroundColor.name: ?component.foregroundColor?.value,
      Tokens.current.snackbarBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.snackbarPadding.name: ?component.padding?.value,
      ...?component.sizeConstraints?.props,
      ...?_offsetProps,
    };

    final baseClass = 'naki-snackbar ${component.position.className}';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final List<Component> effectiveChildren = [
      // main content
      component.content,

      // optional close icon
      if (component.showCloseIcon)
        Icon(
          MaterialIcons.icon_round_close,
          size: 22,
          color: component.closeIconColor ?? context.red,
          onTap: _close,
          semanticLabel: 'Close notification',
        ),
    ];

    return .element(
      tag: 'naki-snackbar',
      key: component.key,
      classes: effectiveClasses,
      attributes: const {
        'role': 'status',
        'aria-live': 'polite',
      },
      styles: Styles(raw: effectiveStyles),
      children: effectiveChildren,
    );
  }
}

/// {@template Tooltip}
/// A component that displays contextual tooltip text or content when
/// hovering or focusing over the [child] component.
///
/// ### Example
/// ```dart
/// Tooltip(
///   text: 'Settings',
///   position: TooltipPosition.bottom,
///   child: Button(child: NakiText('Open')),
/// )
/// ```
/// {@endtemplate}
class Tooltip extends StatelessComponent with NakiStatelessMixin {
  /// Target component wrapped by the tooltip.
  final Component child;

  /// Text displayed in the tooltip when [content] is not defined.
  final String? text;

  /// Custom content that overrides [text].
  final Component? content;

  /// Tooltip placement (top, bottom, left, right).
  final TooltipPosition position;

  /// Tooltip background color.
  final Color? backgroundColor;

  /// Color applied to the tooltip content.
  final Color? foregroundColor;

  /// Tooltip border radius.
  final BorderRadiusData? borderRadius;

  /// Tooltip content padding.
  final EdgeInsets? padding;

  /// Size constraints of the tooltip content.
  final SizeConstraints? sizeConstraints;

  /// Optional CSS classes applied to the tooltip content.
  final String? classes;

  /// Unique identifier used to connect the target and tooltip content.
  final String? id;

  /// {@macro Tooltip}
  const Tooltip({
    super.key,
    required this.child,
    this.position = TooltipPosition.top,
    this.text,
    this.content,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.sizeConstraints,
    this.classes,
    this.id,
  }) : assert(
         text != null || content != null,
         'Either text or content must be provided',
       );

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final tooltipId = nakiDomId(context, 'tooltip', id: id);
    final root = document.getElementById(tooltipId) as HTMLElement?;
    final target =
        root?.querySelector(
              '.naki-tooltip-target a[href], .naki-tooltip-target button, '
              '.naki-tooltip-target input, .naki-tooltip-target [tabindex]',
            )
            as HTMLElement?;

    if (root == null || target == null) return null;

    final contentId = '${tooltipId}_content';
    target.setAttribute('aria-describedby', contentId);

    final subscriptions = <StreamSubscription<Event>>[
      EventStreamProviders.keyDownEvent.forTarget(root).listen((event) {
        if (event.key != 'Escape') return;

        event.preventDefault();
        root.setAttribute('dismissed', '');

        (document.activeElement as HTMLElement?)?.blur();
      }),

      EventStreamProviders.mouseLeaveEvent.forTarget(root).listen((_) {
        root.removeAttribute('dismissed');
      }),

      EventStreamProviders.focusEvent.forTarget(target).listen((_) {
        root.removeAttribute('dismissed');
      }),
    ];

    return () {
      if (target.getAttribute('aria-describedby') == contentId) {
        target.removeAttribute('aria-describedby');
      }

      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    };
  }

  @override
  Component build(BuildContext context) {
    final tooltipId = nakiDomId(context, 'tooltip', id: id);
    final contentId = '${tooltipId}_content';

    final effectiveStyles = {
      Tokens.current.tooltipBgColor.name: ?backgroundColor?.value,
      Tokens.current.tooltipTextColor.name: ?foregroundColor?.value,
      Tokens.current.tooltipBorderRadius.name: ?borderRadius?.value,
      Tokens.current.tooltipPadding.name: ?padding?.value,
    };

    final baseClass = 'naki-tooltip-content tooltip-${position.name}';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveContent = content ?? .text(text!);

    return .element(
      tag: 'naki-tooltip',
      id: tooltipId,
      key: key,
      classes: 'naki-tooltip',
      styles: Styles(raw: effectiveStyles),
      children: [
        // Target
        .wrapElement(
          child: child,
          classes: 'naki-tooltip-target',
        ),

        // Content
        div(
          id: contentId,
          classes: effectiveClasses,
          attributes: const {'role': 'tooltip'},
          styles: Styles(raw: sizeConstraints?.props),
          [effectiveContent],
        ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Tooltip', [
    Rules.nakiTooltipRules,
  ]);
}

/// {@template Dialog}
/// A component that renders a dialog with an optional title/subtitle
/// text, custom content, actions, and dismissible barrier.
///
/// ### Example
/// ```dart
/// final controller = OverlayController();
///
/// Column(
///   spacing: 8,
///   children: [
///     Button.text(
///       'Open Dialog',
///       onTap: () => controller.open(),
///     ),
///     Button.text(
///       'Close Dialog',
///       onTap: () => controller.close(),
///     ),
///   ],
/// )
///
/// Dialog(
///   controller: controller,
///   title: 'Confirm',
///   subtitle: 'Are you sure?',
///   actions: [
///     Button.text(
///       'Cancel',
///       onTap: () => controller.close(),
///     ),
///     Button.filled(
///       context.primaryColor,
///       child: NakiText('Confirm'),
///       onTap: () => controller.close(),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Dialog extends StatefulComponent {
  /// Custom component overriding the dialog's [title] and [subtitle].
  final Component? content;

  /// Title displayed above [subtitle] when [content] is not defined.
  final String? title;

  /// Text displayed below dialog [title] when [content] is not defined.
  final String? subtitle;

  /// Accessible name used when [title] and [subtitle]
  /// are omitted or custom [content] is used.
  final String? semanticLabel;

  /// Interactive components displayed below the dialog's primary content.
  final List<Component>? actions;

  /// Whether the backdrop barrier is dismissible when clicked.
  final bool barrierDismissible;

  /// Callback fired when the dialog is closed.
  final VoidCallback? onClose;

  /// Controller for managing the dialog's open/close state.
  final OverlayController controller;

  /// Size constraints of the dialog container.
  final SizeConstraints? sizeConstraints;

  /// Dialog background color.
  final Color? backgroundColor;

  /// Dialog border radius.
  final BorderRadiusData? borderRadius;

  /// Dialog content padding.
  final EdgeInsets? padding;

  /// Dialog positioning on screen.
  ///
  /// - [DialogPosition.center]: Centers the dialog.
  /// - [DialogPosition.top]: Aligns the dialog to the top.
  /// - [DialogPosition.bottom]: Aligns the dialog to the bottom.
  final DialogPosition position;

  /// Optional CSS classes applied to the dialog.
  final String? classes;

  /// {@macro Dialog}
  const Dialog({
    super.key,
    required this.controller,
    this.position = DialogPosition.center,
    this.barrierDismissible = true,
    this.title,
    this.semanticLabel,
    this.subtitle,
    this.actions,
    this.content,
    this.sizeConstraints,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.classes,
    this.onClose,
  });

  @override
  State<Dialog> createState() => _DialogState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'Dialog',
    Rules.nakiDialogRules,
  );
}

class _DialogState extends State<Dialog> with _AccessibleOverlay<Dialog> {
  bool _localIsOpen = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _localIsOpen = component.controller.isOpen;
    component.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(Dialog oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(
        _onControllerChanged,
      );
      component.controller.addListener(
        _onControllerChanged,
      );
    }

    _localIsOpen = component.controller.isOpen;
  }

  @override
  void dispose() {
    component.controller.removeListener(
      _onControllerChanged,
    );
    super.dispose();
  }

  /// Handles controller changes
  void _onControllerChanged() {
    setState(
      () => _localIsOpen = component.controller.isOpen,
    );
  }

  /// Closes dialog
  void _close() {
    component.onClose?.call();
    component.controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(_localIsOpen, _close);

    if (!_localIsOpen) return const .empty();

    final effectiveStyles = {
      Tokens.current.dialogBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.dialogBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.dialogPadding.name: ?component.padding?.value,
    };

    final baseClass = 'naki-dialog dialog-${component.position.name}';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final showContentOnly = component.content != null;

    final List<Component> dialogChildren = [
      // custom content (takes precedence over title and subtitle)
      if (showContentOnly) component.content!,

      // fallback if no custom content provided
      if (!showContentOnly) ...[
        // dialog title
        if (component.title.isNotNullAndEmpty)
          NakiText(
            component.title!,
            style: const TextStyle(
              fontSize: Dim.px(18),
              fontWeight: FontWeight.w600,
              padding: EdgeInsets(bottom: Dim.px(8)),
            ),
          ),

        // dialog subtitle
        if (component.subtitle.isNotNullAndEmpty)
          SubHeading(
            component.subtitle!,
            style: const TextStyle(
              padding: EdgeInsets(bottom: Dim.px(16)),
            ),
          ),
      ],

      // action buttons
      if (component.actions != null && component.actions!.isNotEmpty)
        Row(
          classes: 'naki-dialog-actions',
          spacing: 5,
          mainAxisAlignment: MainAxisAlignment.end,
          children: component.actions!,
        ),
    ];

    return .element(
      tag: 'naki-dialog',
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      events: component.barrierDismissible ? {'click': (_) => _close()} : null,
      children: [
        div(
          key: overlaySurfaceKey,
          classes: 'naki-dialog-content',
          attributes: {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': component.semanticLabel ?? component.title ?? 'Dialog',
            'tabindex': '-1',
          },
          events: {'click': (e) => e.stopPropagation()},
          styles: Styles(
            raw: component.sizeConstraints?.props,
          ),
          dialogChildren,
        ),
      ],
    );
  }
}

/// {@template Drawer}
/// A component that renders a side panel which slides smoothly from the
/// left or right edge of the viewport with a backdrop barrier.
///
/// It can be used as a modal overlay or a persistent side panel.
///
/// Use [Drawer.sidebar] constructor to render a persistent side panel.
///
/// ### Example (Modal Drawer - default)
/// ```dart
/// final drawerController = OverlayController();
///
/// // Trigger opening the drawer
/// Button.text(
///   'Open Drawer',
///   onTap: () => drawerController.open(),
/// )
///
/// // The Drawer - will only render when opened via controller
/// Drawer(
///   controller: drawerController,
///   position: DrawerPosition.left,
///   child: NakiText('Drawer Navigation'),
/// )
/// ```
///
/// ### Persistent drawer for side-navigation on large screens.
/// ```dart
/// Drawer.sidebar(
///   position: DrawerPosition.left,
///   child: NakiText('Persistent navigation'),
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
    this.barrierColor,
    this.classes,
  }) : modal = true;

  /// Creates a [Drawer] suitable for side navigation on large screens.
  ///
  /// ### Example
  /// ```dart
  /// Drawer.sidebar(
  ///   position: DrawerPosition.left,
  ///   child: NakiText('Sidebar Navigation'),
  /// )
  /// ```
  const Drawer.sidebar({
    super.key,
    required this.child,
    this.position = DrawerPosition.left,
    this.semanticLabel = 'Navigation drawer',
    this.width,
    this.backgroundColor,
    this.classes,
  }) : modal = false,
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
            barrierColor: barrierColor ?? this.barrierColor,
            classes: classes ?? this.classes,
          )
        : Drawer.sidebar(
            key: key ?? this.key,
            child: child ?? this.child,
            position: position ?? this.position,
            semanticLabel: semanticLabel ?? this.semanticLabel,
            width: width ?? this.width,
            backgroundColor: backgroundColor ?? this.backgroundColor,
            classes: classes ?? this.classes,
          );
  }

  @override
  State<Drawer> createState() => _DrawerState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'Drawer',
    Rules.nakiDrawerRules,
  );
}

class _DrawerState extends State<Drawer> with _AccessibleOverlay<Drawer> {
  bool _localIsOpen = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _localIsOpen = component.modal ? (component.controller?.isOpen ?? false) : true;
    component.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(Drawer oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller?.removeListener(
        _onControllerChanged,
      );
      component.controller?.addListener(
        _onControllerChanged,
      );
    }

    _localIsOpen = component.modal ? (component.controller?.isOpen ?? false) : true;
  }

  @override
  void dispose() {
    component.controller?.removeListener(
      _onControllerChanged,
    );
    super.dispose();
  }

  /// Handles changes to the controller's open/close state.
  void _onControllerChanged() {
    final isOpen = component.controller?.isOpen ?? false;
    if (_localIsOpen != isOpen) setState(() => _localIsOpen = isOpen);
  }

  /// Closes the drawer.
  void _close() {
    if (component.controller != null) {
      component.controller!.close();
    } else {
      setState(() => _localIsOpen = false);
    }

    component.onClose?.call();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(
      component.modal && _localIsOpen,
      _close,
    );

    if (!_localIsOpen) return const .empty();

    final effectiveStyles = {
      Tokens.current.drawerBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.drawerWidth.name: ?component.width?.cssText,
      Tokens.current.drawerBarrierBg.name: ?component.barrierColor?.value,
    };

    final baseClass = component.modal ? 'naki-drawer' : 'naki-drawer persistent';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final showBarrier = component.modal && component.barrierDismissible;

    return .element(
      tag: 'naki-drawer',
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [
        // Barrier
        if (showBarrier)
          div(
            classes: 'naki-drawer-barrier',
            events: {'click': (_) => _close()},
            const [],
          ),

        // Content
        aside(
          key: overlaySurfaceKey,
          classes: 'naki-drawer-content drawer-${component.position.name}',
          attributes: {
            if (component.modal) 'role': 'dialog',
            if (component.modal) 'aria-modal': 'true',
            'aria-label': component.semanticLabel,
            if (component.modal) 'tabindex': '-1',
          },
          events: component.modal ? {'click': (e) => e.stopPropagation()} : null,
          [component.child],
        ),
      ],
    );
  }
}

/// {@template BottomSheet}
/// A component that renders a sheet anchored to the bottom edge of
/// the viewport, featuring an optional top drag-handle indicator and
/// backdrop barrier dismissal.
///
/// ### Example
/// ```dart
/// final controller = OverlayController();
///
/// Column(
///   children: [
///     Button.text(
///       'Open Bottom Sheet',
///       onTap: () => controller.open(),
///     ),
///     Button.text(
///       'Close Bottom Sheet',
///       onTap: () => controller.close(),
///     ),
///   ],
/// )
///
/// BottomSheet(
///   controller: controller,
///   showHandle: true,
///   child: NakiText('Actions menu'),
/// )
/// ```
/// {@endtemplate}
class BottomSheet extends StatefulComponent {
  /// Component to render in the bottom sheet.
  final Component child;

  /// Whether to show a pill handle at the top of the [child].
  final bool showHandle;

  /// Whether clicking the backdrop dismisses the bottom sheet.
  final bool barrierDismissible;

  /// Callback executed after the bottom sheet is closed.
  final VoidCallback? onClose;

  /// Controller for managing the bottom sheet's open/close state.
  final OverlayController controller;

  /// Maximum height of the bottom sheet.
  final Dim? maxHeight;

  /// Maximum width of the bottom sheet.
  final Dim? maxWidth;

  /// Background color of the bottom sheet.
  final Color? backgroundColor;

  /// Border radius of the bottom sheet.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes applied to the bottom sheet.
  final String? classes;

  /// Accessible name announced for the bottom-sheet dialog.
  final String semanticLabel;

  /// {@macro BottomSheet}
  const BottomSheet({
    super.key,
    required this.child,
    required this.controller,
    this.showHandle = true,
    this.barrierDismissible = true,
    this.semanticLabel = 'Bottom sheet',
    this.onClose,
    this.maxHeight,
    this.maxWidth,
    this.backgroundColor,
    this.borderRadius,
    this.classes,
  });

  @override
  State<BottomSheet> createState() => _BottomSheetState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'BottomSheet',
    Rules.nakiBottomSheetRules,
  );
}

class _BottomSheetState extends State<BottomSheet> with _AccessibleOverlay<BottomSheet> {
  bool _localIsOpen = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _localIsOpen = component.controller.isOpen;
    component.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(BottomSheet oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(
        _onControllerChanged,
      );
      component.controller.addListener(
        _onControllerChanged,
      );
    }

    _localIsOpen = component.controller.isOpen;
  }

  @override
  void dispose() {
    component.controller.removeListener(
      _onControllerChanged,
    );
    super.dispose();
  }

  /// Handles controller open/close changes.
  void _onControllerChanged() {
    setState(
      () => _localIsOpen = component.controller.isOpen,
    );
  }

  /// Closes the bottom sheet.
  void _close() {
    component.onClose?.call();
    component.controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(_localIsOpen, _close);

    if (!_localIsOpen) return const .empty();

    final effectiveStyles = {
      Tokens.current.bottomSheetBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.bottomSheetMaxHeight.name: ?component.maxHeight?.cssText,
      Tokens.current.bottomSheetBorderRadius.name: ?component.borderRadius?.value,
    };

    const baseClass = 'naki-bottom-sheet';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final effectiveChildren = [
      if (component.showHandle) const div(classes: 'naki-bottom-sheet-handle', []),
      component.child,
    ];

    return .element(
      tag: 'naki-bottomsheet',
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      events: component.barrierDismissible ? {'click': (_) => _close()} : null,
      children: [
        div(
          key: overlaySurfaceKey,
          classes: 'naki-bottom-sheet-content',
          attributes: {
            'role': 'dialog',
            'aria-modal': 'true',
            'aria-label': component.semanticLabel,
            'tabindex': '-1',
          },
          events: {'click': (e) => e.stopPropagation()},
          styles: Styles(
            raw: {
              'max-width': ?component.maxWidth?.cssText,
            },
          ),
          effectiveChildren,
        ),
      ],
    );
  }
}

/// {@template Popover}
/// A component that displays contextual popover overlay content when
/// interacting with a target [child] component.
///
/// ### Example
/// ```dart
/// Popover(
///   visible: _isOpen,
///   onClose: () => setState(() => _isOpen = false),
///   position: PopoverPosition.bottomLeft,
///   child: Button.text(
///     'Open Popover',
///     onTap: () => setState(() => _isOpen = !_isOpen),
///   ),
///   content: Column(
///     children: [
///       NakiText('Popover Content'),
///       Button.text(
///         'Close',
///         onTap: () => setState(() => _isOpen = false),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class Popover extends StatelessComponent {
  /// Component that triggers the popover.
  final Component child;

  /// Content displayed inside the popover.
  final Component content;

  /// Placement position relative to [child]
  /// (default: [PopoverPosition.bottomLeft]).
  final PopoverPosition position;

  /// Whether the popover content is visible (default: `false`).
  final bool visible;

  /// Callback invoked when tapping outside the popover content.
  final VoidCallback? onClose;

  /// Background color of the popover content.
  final Color? backgroundColor;

  /// Color applied to the popover content.
  final Color? foregroundColor;

  /// Border radius of the popover content.
  final BorderRadiusData? borderRadius;

  /// Padding of the popover content.
  final EdgeInsets? padding;

  /// Size constraints of the popover content.
  final SizeConstraints? size;

  /// Optional CSS classes applied to the popover content.
  final String? classes;

  /// Accessible name for the popover surface.
  final String semanticLabel;

  /// {@macro Popover}
  const Popover({
    super.key,
    required this.child,
    required this.content,
    this.position = PopoverPosition.bottomLeft,
    this.visible = false,
    this.semanticLabel = 'Popover',
    this.onClose,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.size,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final effectiveStyles = {
      Tokens.current.popoverBgColor.name: ?backgroundColor?.value,
      Tokens.current.popoverTextColor.name: ?foregroundColor?.value,
      Tokens.current.popoverBorderRadius.name: ?borderRadius?.value,
      Tokens.current.popoverPadding.name: ?padding?.value,
      ...?size?.props,
    };

    final baseClass = 'naki-popover-content popover-${position.value}';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return .element(
      tag: 'naki-popover',
      key: key,
      classes: 'naki-popover',
      attributes: {
        'tabindex': '0',
        'aria-expanded': '$visible',
        'aria-haspopup': 'dialog',
      },
      children: [
        // Backdrop for dismissing popover
        if (visible)
          div(
            classes: 'naki-popover-barrier',
            events: onClose == null ? null : {'click': (_) => onClose!()},
            const [],
          ),

        // Popover trigger
        .wrapElement(
          child: child,
          classes: 'naki-popover-trigger',
          attributes: {
            'canfocus': ?(!visible && onClose == null ? '' : null),
          },
        ),

        // Popover content
        .wrapElement(
          classes: effectiveClasses,
          attributes: {
            'role': 'dialog',
            'aria-label': semanticLabel,
          },
          styles: Styles(raw: effectiveStyles),
          child: content,
        ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'Popover',
    Rules.nakiPopoverRules,
  );
}
