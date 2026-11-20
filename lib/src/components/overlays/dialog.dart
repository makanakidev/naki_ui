part of 'index.dart';

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

    final Component _dialog = .element(
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
    );

    return OverlayEntryScope.maybeOf(context) != null
        ? _dialog
        : OverlayScope(id: _id, child: _dialog);
  }
}
