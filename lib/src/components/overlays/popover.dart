part of 'index.dart';

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
          attributes: {'role': 'dialog', 'aria-label': component.semanticLabel},
          styles: Styles(raw: effectiveStyles),
          [component.content],
        ),
      ],
    );
  }
}
