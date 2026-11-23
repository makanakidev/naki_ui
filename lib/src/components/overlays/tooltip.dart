part of 'index.dart';

/// {@template Tooltip}
/// A component that displays contextual tooltip text or content when
/// hovering or focusing over the [child] component.
///
/// It opens at [position] and stays anchored to [child]
/// inside the safe areas and the Scaffold's bars: it flips to the
/// opposite side when only that side fits, and slides along [child]
/// when it would cross an edge, its arrow still pointing at [child].
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

  /// Unique identifier used to connect the target
  /// and tooltip content.
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

  static List<StyleRule> get styles => OverlaysStyles.tooltip;
}

class _TooltipState extends State<Tooltip>
    with NakiStatefulMixin, NakiPlacementMixin {
  late final tooltipId = nakiDomId(context, 'tooltip', id: component.id);

  /// Parses the maximum border radius from a given string.
  double _parseMaxRadius(String? radiusStr, {double fallback = 12.0}) {
    if (radiusStr.isNullOrEmpty) return fallback;

    final parts = radiusStr!.trim().split(RegExp(r'\s+'));
    final radii = <double>[];

    for (final part in parts) {
      final cleaned = part.replaceAll(RegExp(r'[^0-9.]'), '');
      final val = double.tryParse(cleaned);
      if (val != null) radii.add(val);
    }

    if (radii.isEmpty) return fallback;

    return radii.reduce((a, b) => a > b ? a : b);
  }

  @override
  Map<String, String> computePlacement(
    HTMLElement overlay,
    HTMLElement anchor,
    ({double top, double right, double bottom, double left}) bounds,
  ) {
    const gap = 8.0;
    const arrowLength = 8.0;
    const arrowHalfBase = 6.0;
    const arrowOverlap = 1.0;

    final maxCornerRadius = _parseMaxRadius(component.borderRadius?.value);
    final arrowInset = maxCornerRadius + arrowHalfBase;

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

    final limit = max(0.0, across / 2 - arrowInset);
    final arrowSlide = (-slide).clamp(-limit, limit).roundDown;

    final crossing = (size + arrowLength - 2 * arrowOverlap).roundDown;
    final arrowSide = !flipped ? 0 : (startsBefore ? -crossing : crossing);

    return {
      'translate':
          '${placed.shiftX.roundDown.toPx} ${placed.shiftY.roundDown.toPx}',
      kTooltipArrowXVar: '${vertical ? arrowSlide : arrowSide}px',
      kTooltipArrowYVar: '${vertical ? arrowSide : arrowSlide}px',
      if (flipped) kTooltipArrowRotateVar: '180deg',
    };
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
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
          [component.content ?? .text(component.text!)],
        ),
      ],
    );
  }
}
