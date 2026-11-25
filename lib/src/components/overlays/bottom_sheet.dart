part of 'index.dart';

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

  static List<StyleRule> get styles => OverlaysStyles.bottomSheet;
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

    if (!isVisible) return const SizedBox();

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
        const span(classes: 'naki-bottomsheet-handle', [div([])]),
      component.child,
    ];

    final Component _bottomSheet = .element(
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
    );

    return OverlayEntryScope.maybeOf(context) != null
        ? _bottomSheet
        : OverlayEntryScope(
            controller: OverlayCallbackController(_close),
            child: OverlayScope(id: _id, child: _bottomSheet),
          );
  }
}
