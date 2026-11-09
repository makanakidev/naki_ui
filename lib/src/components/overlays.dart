import 'dart:async';
import 'dart:math' show max;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../framework/framework.dart';
import '../framework/inherited.dart' show ScaffoldScope;
import '../models/overlays.dart';
import '../models/styling.dart';
import '../styles/css.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

import 'basics.dart';
import 'scaffold.dart';
import 'styling.dart';

/// Invokes [close] only when the barrier itself (not overlay content) was
/// clicked, so content clicks keep bubbling for outside-click handlers.
void _onBarrierClick(Event event, VoidCallback close) {
  if (identical(event.target, event.currentTarget)) close();
}

// /////////////////////////////////////////////////////////////////////////////
// SHOW / CLOSE FUNCTIONS
// /////////////////////////////////////////////////////////////////////////////

OverlayHostState _hostOf(BuildContext context, String caller) {
  final host = OverlayHost.maybeOf(context);
  assert(host != null, '$caller needs a NakiApp or Scaffold above context');
  return host!;
}

/// Shows [snackbar] above the page, closing any snackbar already open.
///
/// ### Example
/// ```dart
/// showSnackbar(context, Snackbar(content: NakiText('Item saved')));
/// ```
void showSnackbar(BuildContext context, Snackbar snackbar) {
  if (!kIsWeb) return;

  closeSnackbar();

  // The host may sit above the Scaffold (NakiApp's), so hand the snackbar
  // the caller's Scaffold: it offsets itself past the app bar and navbar.
  final scaffold = Scaffold.maybeOf(context);

  _hostOf(context, 'showSnackbar').show(
    scaffold == null
        ? snackbar
        : ScaffoldScope(state: scaffold, child: snackbar),
    controller: OverlayController(isOpen: true),
    exitDuration: snackbar.duration,
  );
}

/// Closes the snackbar that is currently open, if any.
void closeSnackbar() => SnackbarRegistry.closeCurrent();

/// Shows the dialog [builder] returns and completes with the result passed
/// to [closeDialog], or `null` when it is dismissed another way.
///
/// Leave [Dialog.controller] out: the dialog is controlled automatically
/// and removed once it closes.
///
/// ### Example
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (context) => Dialog(
///     title: 'Delete item?',
///     barrierDismissible: true,
///     actions: [
///       Button.text('Cancel', onTap: () => closeDialog(context, false)),
///       Button.text('Delete', onTap: () => closeDialog(context, true)),
///     ],
///   ),
/// );
/// ```
Future<T?> showDialog<T>({
  required BuildContext context,
  required Component Function(BuildContext context) builder,
}) => _showWithResult<T>(context, 'showDialog', Builder(builder: builder));

/// Closes the dialog [context] belongs to, completing its [showDialog]
/// future with [result].
void closeDialog<T>(BuildContext context, [T? result]) =>
    _closeWithResult(context, result, 'closeDialog', 'showDialog');

/// Shows a modal [BottomSheet] holding the content [builder] returns and
/// completes with the result passed to [closeModalBottomSheet], or `null`
/// when it is dismissed another way.
///
/// The other arguments are passed to the [BottomSheet].
///
/// ### Example
/// ```dart
/// final choice = await showModalBottomSheet<String>(
///   context: context,
///   builder: (context) => Column(
///     children: [
///       Button.text('Share', onTap: () => closeModalBottomSheet(context, 'share')),
///       Button.text('Delete', onTap: () => closeModalBottomSheet(context, 'delete')),
///     ],
///   ),
/// );
/// ```
Future<T?> showModalBottomSheet<T>({
  required BuildContext context,
  required Component Function(BuildContext context) builder,
  bool showHandle = true,
  bool isDismissible = true,
  Dim? maxHeight,
  Dim? maxWidth,
  Color? backgroundColor,
  Gradient? gradient,
  BorderRadiusData? borderRadius,
  String? classes,
  String semanticLabel = 'Bottom sheet',
}) => _showWithResult<T>(
  context,
  'showModalBottomSheet',
  Builder(
    builder: (context) => BottomSheet(
      showHandle: showHandle,
      barrierDismissible: isDismissible,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      backgroundColor: backgroundColor,
      gradient: gradient,
      borderRadius: borderRadius,
      classes: classes,
      semanticLabel: semanticLabel,
      child: builder(context),
    ),
  ),
);

/// Closes the bottom sheet [context] belongs to, completing its
/// [showModalBottomSheet] future with [result].
void closeModalBottomSheet<T>(BuildContext context, [T? result]) =>
    _closeWithResult(
      context,
      result,
      'closeModalBottomSheet',
      'showModalBottomSheet',
    );

/// Mounts [overlay] in the host and completes with the value it closed with.
Future<T?> _showWithResult<T>(
  BuildContext context,
  String caller,
  Component overlay,
) {
  final completer = Completer<T?>();
  if (!kIsWeb) return completer.future;

  final controller = _ResultController<T>();

  _hostOf(context, caller).show(
    overlay,
    controller: controller,
    exitDuration: const Duration(milliseconds: 250),
    onClosed: () => completer.complete(controller.result),
  );

  return completer.future;
}

void _closeWithResult(
  BuildContext context,
  Object? result,
  String caller,
  String opener,
) {
  final controller = OverlayEntryScope.maybeOf(context);
  assert(
    controller is _ResultController,
    '$caller needs the context of an overlay shown with $opener',
  );

  if (controller is _ResultController) {
    controller.closeWith(result);
  } else {
    controller?.close();
  }
}

/// An [OverlayController] that keeps the value its overlay closed with.
class _ResultController<T> extends OverlayController {
  _ResultController() : super(isOpen: true);

  /// The value [closeWith] closed the overlay with.
  T? result;

  /// Closes the overlay with [value], kept when it is a [T].
  void closeWith(Object? value) {
    if (value is T) result = value;
    close();
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
/// It opens at [position] and stays anchored to [child] inside the safe areas
/// and the Scaffold's bars: it flips to the opposite side when only that side
/// fits, and slides along [child] when it would cross an edge, its arrow still
/// pointing at [child].
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
class Tooltip extends StatefulComponent {
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
  State<Tooltip> createState() => _TooltipState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Tooltip', [Rules.nakiTooltipRules]);
}

class _TooltipState extends State<Tooltip>
    with NakiStatefulMixin, NakiPlacementMixin {
  @override
  Map<String, String> computePlacement(
    HTMLElement overlay,
    HTMLElement anchor,
    ({double top, double right, double bottom, double left}) bounds,
  ) {
    const gap = 8.0;
    const arrowLength = 6.0;
    const arrowInset = 14.0;

    final position = component.position;
    final tip = elementEdges(overlay);
    final target = elementEdges(anchor);

    final placed = placePopover(
      position: switch (position) {
        TooltipPosition.top => PopoverPosition.top,
        TooltipPosition.bottom => PopoverPosition.bottom,
        TooltipPosition.left => PopoverPosition.left,
        TooltipPosition.right => PopoverPosition.right,
      },
      popover: tip,
      anchor: target,
      safe: bounds,
      gap: gap,
    );

    if (placed.shiftX == 0 && placed.shiftY == 0) return const {};

    final vertical =
        position == TooltipPosition.top || position == TooltipPosition.bottom;
    final sideShift = vertical ? placed.shiftY : placed.shiftX;
    final slide = vertical ? placed.shiftX : placed.shiftY;

    final width = tip.right - tip.left;
    final height = tip.bottom - tip.top;
    final size = vertical ? height : width;
    final across = vertical ? width : height;
    final targetSize = vertical
        ? target.bottom - target.top
        : target.right - target.left;

    final flipped = sideShift.abs() >= size + targetSize;
    final startsBefore =
        position == TooltipPosition.top || position == TooltipPosition.left;
    final arrowSide = !flipped
        ? 0.0
        : (startsBefore ? -1 : 1) * (size + arrowLength - 1);

    final limit = max(0.0, across / 2 - arrowInset);
    final arrowSlide = (-slide).clamp(-limit, limit);

    return {
      'translate': '${placed.shiftX}px ${placed.shiftY}px',
      kTooltipArrowXVar: '${vertical ? arrowSlide : arrowSide}px',
      kTooltipArrowYVar: '${vertical ? arrowSide : arrowSlide}px',
      if (flipped) kTooltipArrowRotateVar: '180deg',
    };
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final tooltipId = nakiDomId(context, 'tooltip', id: component.id);
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
    final tooltipId = nakiDomId(context, 'tooltip', id: component.id);
    final contentId = '${tooltipId}_content';

    final effectiveStyles = {
      Tokens.current.tooltipBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.tooltipTextColor.name: ?component.foregroundColor?.value,
      Tokens.current.tooltipBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.tooltipPadding.name: ?component.padding?.value,
      ...?component.gradient?.props,
    };

    final baseClass = 'naki-tooltip-content tooltip-${component.position.name}';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final effectiveContent = component.content ?? .text(component.text!);

    return .element(
      tag: 'naki-tooltip',
      id: tooltipId,
      key: component.key,
      classes: 'naki-tooltip',
      styles: Styles(raw: effectiveStyles),
      children: [
        // Target
        span(
          classes: 'naki-tooltip-target',
          events: {
            'mouseenter': (_) => place(),
            'focusin': (_) => place(),
            'pointerdown': (_) => place(),
            'mouseleave': (_) => stopPlacing(),
            'focusout': (_) => stopPlacing(),
          },
          [component.child],
        ),

        // Content
        div(
          key: placementKey,
          id: contentId,
          classes: effectiveClasses,
          attributes: const {'role': 'tooltip'},
          styles: Styles(
            raw: {...?component.sizeConstraints?.props, ...placement},
          ),
          [effectiveContent],
        ),
      ],
    );
  }
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
  ///
  /// Leave it out when showing the dialog with [showDialog],
  /// which automatically controls it.
  final OverlayController? controller;

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
    this.position = DialogPosition.center,
    this.barrierDismissible = false,
    this.glass = false,
    this.controller,
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
    with
        NakiAccessibleOverlayMixin<Dialog>,
        NakiOverlayVisibilityMixin<Dialog> {
  late final _id = nakiDomId(context, 'dialog');

  /// Controller used when neither the component nor a host provides one.
  final _ownController = OverlayController();

  late OverlayController _controller = _resolveController();

  OverlayController _resolveController() =>
      component.controller ??
      OverlayEntryScope.maybeOf(context) ??
      _ownController;

  @override
  Duration get exitDuration => const Duration(milliseconds: 150);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    syncVisibility(_controller.isOpen, rebuild: false);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(Dialog oldComponent) {
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
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => syncVisibility(_controller.isOpen);

  void _onClose() {
    component.onClose?.call();
    _controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(isInteractive, _onClose);

    if (!isVisible) return const .empty();

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

    if (!isVisible) return const .empty();

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
  final OverlayController? controller;

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
    this.showHandle = true,
    this.barrierDismissible = true,
    this.semanticLabel = 'Bottom sheet',
    this.controller,
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
    with
        NakiAccessibleOverlayMixin<BottomSheet>,
        NakiOverlayVisibilityMixin<BottomSheet> {
  late final _id = nakiDomId(context, 'bottomsheet');

  /// Controller used when neither the component nor a host provides one.
  final _ownController = OverlayController();

  late OverlayController _controller = _resolveController();

  OverlayController _resolveController() =>
      component.controller ??
      OverlayEntryScope.maybeOf(context) ??
      _ownController;

  @override
  Duration get exitDuration => const Duration(milliseconds: 190);

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    syncVisibility(_controller.isOpen, rebuild: false);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateComponent(BottomSheet oldComponent) {
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
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => syncVisibility(_controller.isOpen);

  void _close() {
    component.onClose?.call();
    _controller.close();
  }

  @override
  Component build(BuildContext context) {
    syncOverlayAccessibility(isInteractive, _close);

    if (!isVisible) return const .empty();

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
/// It opens at [position] and stays anchored to [child] inside the safe areas
/// and the Scaffold's bars: it flips to the opposite side when only that side
/// fits, and slides along [child] when it would cross an edge.
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
class Popover extends StatefulComponent {
  /// Component that triggers the popover.
  final Component child;

  /// Content displayed inside the popover.
  final Component content;

  /// Placement position relative to [child]
  /// (default: [PopoverPosition.bottomLeft]).
  final PopoverPosition position;

  /// Whether the popover content is visible.
  ///
  /// The parent controls the popover when this is set, and hovering or
  /// focusing [child] then does nothing. When it's `null`, hovering or
  /// focusing [child] shows the popover.
  final bool? visible;

  /// Callback invoked when clicking anywhere outside the popover content,
  /// [child] included.
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
    this.semanticLabel = 'Popover',
    this.visible,
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
  State<Popover> createState() => _PopoverState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Popover', Rules.nakiPopoverRules);
}

class _PopoverState extends State<Popover> with NakiPlacementMixin {
  final _triggerKey = GlobalNodeKey<HTMLElement>();

  StreamSubscription<Event>? _pressSubscription;
  StreamSubscription<Event>? _scrollSubscription;

  /// An outside press hid a popover shown by hover or focus. A touch screen
  /// keeps `:hover` on the last thing tapped, so CSS alone can't hide it.
  bool _dismissed = false;

  bool get _open => component.visible ?? false;

  bool get _isShown {
    final content = placementKey.currentNode;
    if (content == null) return false;

    final style = window.getComputedStyle(content);
    return style.getPropertyValue('pointer-events') != 'none';
  }

  @override
  void initState() {
    super.initState();
    if (_open) _follow();
  }

  @override
  void didUpdateComponent(Popover oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (_open) {
      _follow();
    } else if (oldComponent.visible ?? false) {
      _stopFollowing();
    }
  }

  @override
  void dispose() {
    _stopFollowing();
    super.dispose();
  }

  void _follow() {
    onComponentRendered(() {
      if (!mounted || !_isShown) return;

      place();

      // a scroll never bubbles, so only capturing sees every scroller
      _scrollSubscription ??= const EventStreamProvider<Event>(
        'scroll',
      ).forTarget(document, useCapture: true).listen(_closeOnScroll);

      if (component.visible == null) {
        _pressSubscription ??= const EventStreamProvider<Event>(
          'pointerdown',
        ).forTarget(document).listen(_dismissOnPress);
      }
    });
  }

  void _stopFollowing() {
    stopPlacing();
    _pressSubscription?.cancel();
    _pressSubscription = null;
    _scrollSubscription?.cancel();
    _scrollSubscription = null;
  }

  void _onHoverStarted() {
    if (_dismissed) setState(() => _dismissed = false);
    _follow();
  }

  void _onHoverEnded() {
    if (!_isShown) _stopFollowing();
  }

  @override
  void onTapOutside(Event event) => component.onClose?.call();

  void _closeOnScroll(Event event) {
    final content = placementKey.currentNode;
    final movedTrigger =
        (event.target as Node?)?.contains(content?.parentElement) ?? false;

    // focusing a field inside scrolls the page to reveal it
    if (!movedTrigger || (content?.contains(document.activeElement) ?? false)) {
      return;
    }

    if (component.visible == null) {
      _dismiss();
    } else {
      component.onClose?.call();
    }
  }

  void _dismissOnPress(Event event) {
    final anchor = placementKey.currentNode?.parentElement;
    if (!event.composedPath().toDart.contains(anchor)) _dismiss();
  }

  void _dismiss() {
    final focused = document.activeElement;
    if (_triggerKey.currentNode?.contains(focused) ?? false) {
      (focused as HTMLElement?)?.blur();
    }

    _stopFollowing();
    setState(() => _dismissed = true);
    component.onClose?.call();
  }

  @override
  Map<String, String> computePlacement(
    HTMLElement overlay,
    HTMLElement anchor,
    ({double top, double right, double bottom, double left}) bounds,
  ) {
    final placed = placePopover(
      position: component.position,
      popover: elementEdges(overlay),
      anchor: elementEdges(anchor),
      safe: bounds,
      gap: 8,
    );

    return {
      if (placed.shiftX != 0 || placed.shiftY != 0)
        'translate': '${placed.shiftX}px ${placed.shiftY}px',
      if (placed.maxHeight case final maxHeight?) ...{
        'max-height': '${maxHeight}px',
        'overflow-y': 'auto',
      },
    };
  }

  @override
  Component build(BuildContext context) {
    final effectiveStyles = {
      Tokens.current.popoverBgColor.name: ?component.backgroundColor?.value,
      Tokens.current.popoverTextColor.name: ?component.foregroundColor?.value,
      Tokens.current.popoverBorderRadius.name: ?component.borderRadius?.value,
      Tokens.current.popoverPadding.name: ?component.padding?.value,
      ...?component.size?.props,
      ...?component.gradient?.props,
      ...placement,
    };

    final baseClass =
        'naki-popover-content popover-${component.position.value}';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    return .element(
      tag: 'naki-popover',
      classes: 'naki-popover',
      attributes: {
        'tabindex': '0',
        'aria-expanded': '$_open',
        'aria-haspopup': 'dialog',
      },
      children: [
        // trigger, which shows it from CSS unless the parent controls it
        span(
          key: _triggerKey,
          classes: 'naki-popover-trigger',
          attributes: {
            'canfocus': ?(component.visible == null && !_dismissed ? '' : null),
          },
          events: component.visible == null
              ? {
                  'mouseenter': (_) => _onHoverStarted(),
                  'focusin': (_) => _onHoverStarted(),
                  'pointerdown': (_) => _onHoverStarted(),
                  'mouseleave': (_) => _onHoverEnded(),
                  'focusout': (_) => _onHoverEnded(),
                }
              : null,
          [component.child],
        ),

        // content
        div(
          key: placementKey,
          classes: effectiveClasses,
          attributes: {
            'role': 'dialog',
            'aria-label': component.semanticLabel,
          },
          styles: Styles(raw: effectiveStyles),
          [component.content],
        ),
      ],
    );
  }
}
