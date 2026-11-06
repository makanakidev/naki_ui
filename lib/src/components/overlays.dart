import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart';

import '../framework/framework.dart';
import '../framework/overlay_stack.dart';
import '../models/overlays.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
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

  void syncOverlayAccessibility(bool open, VoidCallback close) {
    if (_requestedOpen == open) return;

    _requestedOpen = open;

    // capture the trigger before the overlay renders and autofocus moves focus
    if (open && kIsWeb) _previousFocus = document.activeElement as HTMLElement?;

    onComponentRendered(() {
      if (!mounted) return;
      if (open) {
        _activateOverlay(close);
      } else {
        _deactivateOverlay();
      }
    });
  }

  List<HTMLElement> _focusableElements(HTMLElement surface) {
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

    NakiOverlayStack.push(this);

    final focusable = _focusableElements(surface);
    (focusable.isNotEmpty ? focusable.first : surface).focus();

    _keyboardSubscription?.cancel();
    _keyboardSubscription = EventStreamProviders.keyDownEvent
        .forTarget(document)
        .listen((event) {
          // only the top-most overlay handles keyboard
          // dismissal and trapping
          if (!NakiOverlayStack.isTop(this)) return;

          if (event.key == 'Escape') {
            event.preventDefault();
            event.stopPropagation();
            close();
            return;
          }

          if (event.key != 'Tab') return;

          final currentFocusable = _focusableElements(surface);
          if (currentFocusable.isEmpty) {
            event.preventDefault();
            surface.focus();
            return;
          }

          final first = currentFocusable.first;
          final last = currentFocusable.last;
          final active = document.activeElement;

          if (event.shiftKey &&
              (active == first || !surface.contains(active))) {
            event.preventDefault();
            last.focus();
          } else if (!event.shiftKey &&
              (active == last || !surface.contains(active))) {
            event.preventDefault();
            first.focus();
          }
        });
  }

  void _deactivateOverlay() {
    NakiOverlayStack.remove(this);
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

/// Invokes [close] only when the barrier itself (not overlay content) was
/// clicked, so content clicks keep bubbling for outside-click handlers.
void _onBarrierClick(Event event, VoidCallback close) {
  if (identical(event.target, event.currentTarget)) close();
}

/// Shared open / exit-animation state machine for overlays.
///
/// Exit state is owned by Dart and rendered through attributes, so reopening
/// during an exit animation cancels it instead of leaving a stale
/// `data-exiting` attribute on a reused DOM node.
mixin _OverlayVisibility<T extends StatefulComponent> on State<T> {
  bool _visible = false;
  bool _exiting = false;

  Timer? _exitTimer;

  /// Duration of the exit animation (matches the CSS keyframes).
  Duration get exitDuration;

  /// Whether the overlay is open and not animating out.
  bool get isInteractive => _visible && !_exiting;

  /// Attributes applied to animated elements while exiting.
  Map<String, String> get exitAttributes =>
      _exiting ? const {'data-exiting': 'true', 'inert': ''} : const {};

  /// Updates visibility; pass `rebuild: false` from lifecycle methods that
  /// are already followed by a build.
  void syncVisibility(bool open, {bool rebuild = true}) {
    void update(VoidCallback fn) => rebuild ? setState(fn) : fn();

    if (open) {
      _exitTimer?.cancel();
      _exitTimer = null;

      if (_visible && !_exiting) return;

      update(() {
        _visible = true;
        _exiting = false;
      });

      return;
    }

    if (!_visible || _exiting) return;

    // nothing to animate on the server
    if (!kIsWeb) {
      _visible = false;
      return;
    }

    update(() => _exiting = true);

    _exitTimer = Timer(exitDuration, () {
      _exitTimer = null;

      setState(() {
        _visible = false;
        _exiting = false;
      });
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
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
    required this.controller,
    this.position = SnackbarPosition.bottom,
    this.showCloseIcon = false,
    this.duration = const Duration(seconds: 5),
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

class _SnackbarState extends State<Snackbar> with _OverlayVisibility<Snackbar> {
  Timer? _timer;

  late final _id = nakiDomId(context, 'snackbar');

  @override
  Duration get exitDuration => const Duration(milliseconds: 200);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    final isOpen = component.controller.isOpen;
    syncVisibility(isOpen, rebuild: false);

    if (isOpen) SnackbarRegistry.onOpen(component.controller);
    component.controller.addListener(_onControllerChanged);

    _scheduleAutoDismiss();
  }

  @override
  void didUpdateComponent(Snackbar oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(_onControllerChanged);
      component.controller.addListener(_onControllerChanged);

      syncVisibility(component.controller.isOpen, rebuild: false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    component.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  /// Handles controller changes
  void _onControllerChanged() {
    final isOpen = component.controller.isOpen;
    if (isOpen == isInteractive) return;

    if (isOpen) {
      SnackbarRegistry.onOpen(component.controller);
      _scheduleAutoDismiss();
    } else {
      _timer?.cancel();
      _timer = null;
      SnackbarRegistry.onClose(component.controller);
    }

    syncVisibility(isOpen);
  }

  /// Schedules the auto-dismiss timer
  void _scheduleAutoDismiss() {
    _timer?.cancel();
    final isOpen = component.controller.isOpen;
    if (isOpen && kIsWeb) _timer = Timer(component.duration, _close);
  }

  /// Closes the snackbar
  void _close() {
    _timer?.cancel();
    _timer = null;
    component.onClose?.call();
    component.controller.close();
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
          'calc($appbarHeight + env(safe-area-inset-top, 0px)))';

      final bottomNavbarOffset =
          'var(${Tokens.current.bottomNavbarOffset}, '
          'calc($bottomNavbarHeight + env(safe-area-inset-bottom, 0px)))';

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
    if (!_visible) return const .empty();

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
          size: 18,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          foregroundColor: component.closeIconColor ?? context.red,
          onTap: _close,
          attributes: const {'aria-label': 'Close notification'},
        ),
    ];

    return OverlayScope(
      id: _id,
      child: .element(
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
      ),
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

  /// Tooltip background gradient.
  ///
  /// ### Example
  /// ```dart
  /// Tooltip(
  ///   text: 'Info tooltip',
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.teal]),
  ///   child: Icon(Icons.info),
  /// )
  /// ```
  final Gradient? gradient;

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
    this.gradient,
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
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final tooltipId = nakiDomId(context, 'tooltip', id: id);
    final root = document.getElementById(tooltipId) as HTMLElement?;

    final target =
        root?.querySelector(
              ':is(.naki-tooltip-target, .naki-tooltip-target *)'
              ':is(a[href], button, input, select, textarea, [tabindex])',
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
      ...?gradient?.props,
    };

    final baseClass = 'naki-tooltip-content tooltip-${position.name}';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveContent = content ?? .text(text!);

    return .element(
      tag: 'naki-tooltip',
      id: tooltipId,
      key: key,
      classes: 'naki-tooltip',
      styles: Styles(raw: effectiveStyles),
      children: [
        // Target
        .wrapElement(child: child, classes: 'naki-tooltip-target'),

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
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Tooltip', [Rules.nakiTooltipRules]);
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

  /// Dialog content background color.
  final Color? backgroundColor;

  /// Dialog barrier background color.
  final Color? barrierColor;

  /// Dialog background gradient.
  ///
  /// ### Example
  /// ```dart
  /// Dialog(
  ///   controller: controller,
  ///   title: 'Gradient Dialog',
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.blue]),
  /// )
  /// ```
  final Gradient? gradient;

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

  /// Whether the dialog is a translucent glass surface.
  ///
  /// [backgroundColor] sets the tint. `--naki-glass-tint`, `--naki-glass-rim`
  /// and `--naki-glass-blur` tune the surface. The barrier stops blurring so
  /// the glass can see the page, and the dialog turns opaque when less transparency
  /// or more contrast is required.
  final bool glass;

  /// Optional CSS classes applied to the dialog.
  final String? classes;

  /// {@macro Dialog}
  const Dialog({
    super.key,
    required this.controller,
    this.position = DialogPosition.center,
    this.barrierDismissible = false,
    this.glass = false,
    this.title,
    this.semanticLabel,
    this.subtitle,
    this.actions,
    this.content,
    this.sizeConstraints,
    this.backgroundColor,
    this.barrierColor,
    this.gradient,
    this.borderRadius,
    this.padding,
    this.classes,
    this.onClose,
  });

  @override
  State<Dialog> createState() => _DialogState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Dialog', Rules.nakiDialogRules);
}

class _DialogState extends State<Dialog>
    with _AccessibleOverlay<Dialog>, _OverlayVisibility<Dialog> {
  late final _id = nakiDomId(context, 'dialog');

  @override
  Duration get exitDuration => const Duration(milliseconds: 250);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    syncVisibility(component.controller.isOpen, rebuild: false);
    component.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(Dialog oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(_onControllerChanged);
      component.controller.addListener(_onControllerChanged);

      syncVisibility(component.controller.isOpen, rebuild: false);
    }
  }

  @override
  void dispose() {
    component.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => syncVisibility(component.controller.isOpen);

  void _onClose() {
    component.onClose?.call();
    component.controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(isInteractive, _onClose);

    if (!_visible) return const .empty();

    final effectiveStyles = {
      Tokens.current.dialogBarrierBg.name: ?component.barrierColor?.value,
      Tokens.current.dialogBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.dialogBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.dialogPadding.name: ?component.padding?.value,
    };

    final baseClass = 'naki-dialog dialog-${component.position.name}';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (component.glass) 'dialog-glass',
      baseClass,
    ]);

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
              padding: EdgeInsets.only(bottom: Dim.px(8)),
            ),
          ),

        // dialog subtitle
        if (component.subtitle.isNotNullAndEmpty)
          SubHeading(
            component.subtitle!,
            style: const TextStyle(
              padding: EdgeInsets.only(bottom: Dim.px(16)),
            ),
          ),
      ],

      // action buttons
      if (component.actions != null && component.actions!.isNotEmpty)
        Row(
          classes: 'naki-dialog-actions',
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.end,
          children: component.actions!,
        ),
    ];

    return OverlayScope(
      id: _id,
      child: .element(
        tag: 'naki-dialog',
        id: _id,
        key: component.key,
        classes: effectiveClasses,
        attributes: exitAttributes,
        styles: Styles(raw: effectiveStyles),
        events: component.barrierDismissible
            ? {'click': (e) => _onBarrierClick(e, _onClose)}
            : null,
        children: [
          div(
            key: overlaySurfaceKey,
            classes: 'naki-dialog-content',
            attributes: {
              'role': 'dialog',
              'aria-modal': 'true',
              'aria-label':
                  component.semanticLabel ?? component.title ?? 'Dialog',
              'tabindex': '-1',
              ...exitAttributes,
            },
            styles: Styles(
              raw: {
                ...?component.gradient?.props,
                ...?component.sizeConstraints?.props,
              },
            ),
            dialogChildren,
          ),
        ],
      ),
    );
  }
}

/// {@template Drawer}
/// A component that renders a side panel which slides smoothly from the
/// left or right edge of the viewport with a backdrop barrier.
///
/// **NOTE**: Use [Sidebar] for a simplified interface for rendering a persistent side panel.
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

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Drawer', Rules.nakiDrawerRules);
}

class _DrawerState extends State<Drawer>
    with _AccessibleOverlay<Drawer>, _OverlayVisibility<Drawer> {
  late final _id = nakiDomId(context, 'drawer');

  @override
  Duration get exitDuration => const Duration(milliseconds: 250);

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

    if (!_visible) return const .empty();

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

    final drawer = Component.element(
      tag: baseClass,
      key: component.key,
      id: _id,
      classes: effectiveClasses,
      attributes: component.modal ? {...exitAttributes, 'modal': 'true'} : null,
      styles: Styles(raw: effectiveStyles),
      events: component.barrierDismissible ? {'click': (_) => _close()} : null,
      children: [
        // Content
        aside(
          key: overlaySurfaceKey,
          classes: contentClass,
          attributes: {
            if (component.modal) ...{
              'role': 'dialog',
              'aria-modal': 'true',
              'tabindex': '-1',
              ...exitAttributes,
            },
            'aria-label': component.semanticLabel,
          },
          [component.child],
        ),
      ],
    );

    return drawer;
  }
}

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

  /// Background gradient of the bottom sheet.
  ///
  /// ### Example
  /// ```dart
  /// BottomSheet(
  ///   controller: controller,
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.blue]),
  ///   child: NakiText('Sheet Content'),
  /// )
  /// ```
  final Gradient? gradient;

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
    this.gradient,
    this.borderRadius,
    this.classes,
  });

  @override
  State<BottomSheet> createState() => _BottomSheetState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('BottomSheet', Rules.nakiBottomSheetRules);
}

class _BottomSheetState extends State<BottomSheet>
    with _AccessibleOverlay<BottomSheet>, _OverlayVisibility<BottomSheet> {
  late final _id = nakiDomId(context, 'bottomsheet');

  @override
  Duration get exitDuration => const Duration(milliseconds: 300);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    syncVisibility(component.controller.isOpen, rebuild: false);
    component.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(BottomSheet oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller) {
      oldComponent.controller.removeListener(_onControllerChanged);
      component.controller.addListener(_onControllerChanged);

      syncVisibility(component.controller.isOpen, rebuild: false);
    }
  }

  @override
  void dispose() {
    component.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => syncVisibility(component.controller.isOpen);

  void _close() {
    component.onClose?.call();
    component.controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(isInteractive, _close);

    if (!_visible) return const .empty();

    final effectiveStyles = {
      Tokens.current.bottomSheetBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.bottomSheetMaxHeight.name: ?component.maxHeight?.cssText,
      Tokens.current.bottomSheetBorderRadius.name:
          ?component.borderRadius?.value,
    };

    const baseClass = 'naki-bottomsheet';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final effectiveChildren = [
      if (component.showHandle)
        const span(classes: 'naki-bottomsheet-handle', []),
      component.child,
    ];

    return OverlayScope(
      id: _id,
      child: .element(
        tag: 'naki-bottomsheet',
        id: _id,
        key: component.key,
        classes: effectiveClasses,
        attributes: exitAttributes,
        styles: Styles(raw: effectiveStyles),
        events: component.barrierDismissible
            ? {'click': (e) => _onBarrierClick(e, _close)}
            : null,
        children: [
          div(
            key: overlaySurfaceKey,
            classes: 'naki-bottomsheet-content',
            attributes: {
              'role': 'dialog',
              'aria-modal': 'true',
              'aria-label': component.semanticLabel,
              'tabindex': '-1',
              ...exitAttributes,
            },
            styles: Styles(
              raw: {
                'max-width': ?component.maxWidth?.cssText,
                ...?component.gradient?.props,
              },
            ),
            effectiveChildren,
          ),
        ],
      ),
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

  /// Background gradient of the popover content.
  ///
  /// ### Example
  /// ```dart
  /// Popover(
  ///   content: NakiText('Gradient Popover'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.purple]),
  ///   child: Button.text('Open', onTap: () {}),
  /// )
  /// ```
  final Gradient? gradient;

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
    this.gradient,
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
      ...?gradient?.props,
    };

    final baseClass = 'naki-popover-content popover-${position.value}';
    final effectiveClasses = joinClasses([?classes, baseClass]);

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
        // backdrop
        if (visible)
          div(
            classes: 'naki-popover-barrier',
            events: onClose == null ? null : {'click': (_) => onClose!()},
            const [],
          ),

        // trigger
        span(
          classes: 'naki-popover-trigger',
          attributes: {'canfocus': ?(!visible && onClose == null ? '' : null)},
          [child],
        ),

        // content
        div(
          classes: effectiveClasses,
          attributes: {'role': 'dialog', 'aria-label': semanticLabel},
          styles: Styles(raw: effectiveStyles),
          [content],
        ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Popover', Rules.nakiPopoverRules);
}
