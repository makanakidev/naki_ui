import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart' show LucideIcons;
import 'package:universal_web/web.dart';

import '../framework/framework.dart';
import '../framework/inherited.dart';
import '../models/gesture.dart' show Events;
import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../theme/tokens.dart' show Tokens;
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import 'basics.dart' show Button, Column, Icon, Row;

// /////////////////////////////////////////////////////////////////////////////
// LAYOUT COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Align}
/// A component that positions its child within itself using an alignment
/// value. Optionally, [widthFactor] and [heightFactor] shrink the component
/// to a fraction of the child's intrinsic size.
///
/// ### Example
/// ```dart
/// Align(
///   alignment: Alignment.center,
///   widthFactor: 0.5,
///   heightFactor: 0.5,
///   child: Container(
///     decoration: BoxDecoration(backgroundColor: Colors.red),
///     size: SizeConstraints(width: Dim.px(200), height: Dim.px(200)),
///     child: NakiText('Centered Content'),
///   ),
/// )
/// ```
/// {@endtemplate}
class Align extends StatefulComponent {
  /// Component to align.
  final Component child;

  /// How to align the child.
  final Alignment alignment;

  /// If non-null, shrinks the align component to its child's intrinsic width
  /// multiplied by this factor (e.g. `0.5` → half the child's natural width).
  ///
  /// Note: Must be non-negative. Values greater than 1 expand the component.
  final double? widthFactor;

  /// If non-null, shrinks the align component to its child's intrinsic height
  /// multiplied by this factor (e.g. `0.5` → half the child's natural height).
  ///
  /// Note: Must be non-negative. Values greater than 1 expand the component.
  final double? heightFactor;

  /// Additional CSS classes applied to the align component.
  final String? classes;

  /// {@macro Align}
  const Align({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    this.classes,
  }) : assert(
         widthFactor == null || widthFactor >= 0.0,
         'widthFactor must be non-negative',
       ),
       assert(
         heightFactor == null || heightFactor >= 0.0,
         'heightFactor must be non-negative',
       );

  @override
  State<Align> createState() => _AlignState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Align', [
    Rules.nakiAlignRules,
  ]);
}

class _AlignState extends State<Align> with NakiStatefulMixin {
  late String _id;

  double? _width;
  double? _height;

  bool _isOverflowing = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'align');
  }

  /// Returns the component html element
  HTMLElement? get _rootNode => component.key is GlobalNodeKey<HTMLElement>
      ? (component.key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById(_id) as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final wf = component.widthFactor;
    final hf = component.heightFactor;

    // If no factors are provided, reset overflow flag and exit
    if (wf == null && hf == null) {
      if (_isOverflowing) setState(() => _isOverflowing = false);
      return null;
    }

    // Locate and measure the first child element's intrinsic size
    final child = _rootNode?.firstElementChild as HTMLElement?;
    if (child == null) return null;

    final newWidth = wf != null ? child.offsetWidth * wf : null;
    final newHeight = hf != null ? child.offsetHeight * hf : null;

    // If factors changed, update dimensions and set overflow flag
    if (newWidth != _width || newHeight != _height) {
      setState(() {
        _width = newWidth;
        _height = newHeight;
        _isOverflowing = (wf != null && wf < 1) || (hf != null && hf < 1);
      });
    }

    return null;
  }

  @override
  void didUpdateComponent(Align oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.widthFactor != component.widthFactor ||
        oldComponent.heightFactor != component.heightFactor ||
        oldComponent.child != component.child) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final alignment = NakiAlignProps.mapAlignment(
      component.alignment,
    );
    final width = _width != null ? '${_width!.toCleanString}px' : null;
    final height = _height != null ? '${_height!.toCleanString}px' : null;

    final hasFactor =
        component.heightFactor != null || component.widthFactor != null;

    const baseClass = 'naki-align';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    return .element(
      tag: 'naki-align',
      key: component.key,
      id: _id,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'display': hasFactor ? 'inline-flex' : 'flex',
          'overflow': ?(_isOverflowing ? 'hidden' : null),
          'width': ?width,
          'height': ?height,
          ...alignment,
        },
      ),
      children: [component.child],
    );
  }
}

/// {@template AspectRatio}
/// A component that attempts to size its child to a specific aspect ratio.
///
/// ### Example
/// ```dart
/// AspectRatio(
///   aspectRatio: AspectRatioType.stories,
///   child: Image(
///     'https://images.pexels.com/photos/2280571/pexels-photo-2280571.jpeg',
///     fit: BoxFit.fill,
///   ),
/// )
/// ```
/// {@endtemplate}
class AspectRatio extends StatelessComponent {
  /// Component to apply aspect ratio to.
  final Component child;

  /// Aspect ratio applied to [child].
  final AspectRatioType aspectRatio;

  /// Additional CSS classes applied to aspect ratio component.
  final String? classes;

  /// {@macro AspectRatio}
  const AspectRatio({
    super.key,
    required this.child,
    required this.aspectRatio,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-aspectratio';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      key: key,
      tag: 'naki-aspectratio',
      classes: effectiveClasses,
      styles: Styles(
        raw: {'aspect-ratio': aspectRatio.value},
      ),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('AspectRatio', [
    Rules.nakiAspectRatioRules,
  ]);
}

/// {@template Flexible}
/// A component that controls how a child of a [Row]
/// or [Column] flexes.
///
/// Using a [Flexible] component gives a child of a [Row]
/// or [Column] the flexibility to expand to fill the available space
/// in the main axis, but unlike [Expanded], [Flexible] with
/// [FlexFit.loose] does not require the child to fill the available space.
///
/// ### Example
/// ```dart
/// Row(
///   children: [
///     Flexible(
///       flex: 2,
///       fit: FlexFit.loose,
///       child: NakiText('Flexible Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Flexible extends StatelessComponent {
  /// Component to flex.
  final Component child;

  /// Flex factor applied to the child.
  final int flex;

  /// How a flexible child component sizes itself along the main axis.
  final FlexFit fit;

  /// Additional CSS classes applied to the flexible component.
  final String? classes;

  /// {@macro Flexible}
  const Flexible({
    super.key,
    required this.child,
    this.flex = 1,
    this.fit = FlexFit.loose,
    this.classes,
  }) : assert(flex > 0, 'flex must be greater than zero');

  @override
  Component build(BuildContext context) {
    final flexScope = FlexScope.of(context);

    assert(
      flexScope != null,
      'Flexible must be a direct child of a Row or Column.',
    );

    assert(
      flexScope == null || !flexScope.scrollable,
      'Flexible cannot be used in a scrollable Row or '
      'Column. The main axis is unbounded.',
    );

    final baseClass = fit == FlexFit.tight ? 'naki-expanded' : 'naki-flexible';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final flexValue = fit == FlexFit.tight ? '$flex 1 0%' : '0 $flex auto';
    final effectiveTag = fit == FlexFit.tight
        ? 'naki-expanded'
        : 'naki-flexible';

    return .element(
      tag: effectiveTag,
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: {'flex': flexValue}),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Flexible', [
    Rules.nakiFlexibleRules,
  ]);
}

/// {@template Expanded}
/// A component that expands the child of a [Row] or [Column]
/// to fill the available space along the main axis.
///
/// This is equivalent to [Flexible] with [FlexFit.tight].
///
/// ### Example
/// ```dart
/// Row(
///   children: [
///     Expanded(
///       flex: 1,
///       child: NakiText('Expanded Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Expanded extends Flexible {
  /// {@macro Expanded}
  const Expanded({
    super.key,
    required super.child,
    super.flex = 1,
    super.classes,
  }) : super(fit: FlexFit.tight);

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Expanded', [
    Rules.nakiExpandedRules,
  ]);
}

/// {@template Padding}
/// A component that insets its child by the given padding.
///
/// ### Example
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(Dim.px(8)),
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class Padding extends StatelessComponent {
  /// Component to inset with padding.
  final Component child;

  /// Padding applied to the child.
  final EdgeInsets padding;

  /// Additional CSS classes applied to the padding component.
  final String? classes;

  /// {@macro Padding}
  const Padding({
    super.key,
    required this.child,
    required this.padding,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-padding';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      tag: 'naki-padding',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {...padding.pProps, 'display': 'block'},
      ),
      children: [child],
    );
  }
}

/// {@template Margin}
/// A component that surrounds its child by the given margin.
///
/// ### Example
/// ```dart
/// Margin(
///   margin: EdgeInsets.all(Dim.px(8)),
///   child: NakiText('Margined Content'),
/// )
/// ```
/// {@endtemplate}
class Margin extends StatelessComponent {
  /// Component to surround with margin.
  final Component child;

  /// Margin applied around the child.
  final EdgeInsets margin;

  /// Additional CSS classes applied to the margin component.
  final String? classes;

  /// {@macro Margin}
  const Margin({
    super.key,
    required this.child,
    required this.margin,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-margin';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      tag: 'naki-margin',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {...margin.mProps, 'display': 'block'},
      ),
      children: [child],
    );
  }
}

/// {@template SizedBox}
/// A component with a specified size.
///
/// ### Example
/// ```dart
/// SizedBox(
///   width: Dim.px(100),
///   height: Dim.px(100),
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class SizedBox extends StatelessComponent {
  /// Component to size.
  final Component? child;

  /// Width of the sized box.
  final Dim? width;

  /// Height of the sized box.
  final Dim? height;

  /// Additional CSS classes applied to the sized box.
  final String? classes;

  /// {@macro SizedBox}
  const SizedBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.classes,
  });

  /// Creates a SizedBox of the given size.
  const SizedBox.fromSize({
    required Dim size,
    this.child,
    this.classes,
  }) : width = size,
       height = size;

  /// Creates a SizedBox that is an empty spacer of the given height.
  const SizedBox.height(this.height)
    : width = null,
      child = null,
      classes = null;

  /// Creates a SizedBox that is an empty spacer of the given width.
  const SizedBox.width(this.width)
    : height = null,
      child = null,
      classes = null;

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-sizedbox';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      tag: 'naki-sizedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'width': ?width?.cssText,
          'height': ?height?.cssText,
          'display': 'block',
        },
      ),
      children: [?child],
    );
  }
}

/// {@template Stack}
/// A component that positions its children relative
/// to the edges of its box.
///
/// ### Example
/// ```dart
/// Stack(
///   children: [
///     Positioned(
///       top: Dim.px(10),
///       left: Dim.px(10),
///       child: NakiText('Padded Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Stack extends StatelessComponent {
  /// Components to display in the stack. These components are rendered
  /// on top of each other, with later components appearing on top of
  /// earlier components.
  final List<Positioned> children;

  /// Additional CSS classes applied to the stack component.
  final String? classes;

  /// {@macro Stack}
  const Stack({
    super.key,
    required this.children,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-stack';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return StackScope(
      child: .element(
        tag: 'naki-stack',
        key: key,
        classes: effectiveClasses,
        children: children,
      ),
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Stack', [
    Rules.nakiStackRules,
  ]);
}

/// {@template Positioned}
/// A component that controls where a child of a
/// [Stack] is positioned.
///
/// ### Example
/// ```dart
/// Positioned(
///   top: Dim.px(10),
///   left: Dim.px(10),
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class Positioned extends StatelessComponent {
  /// Component to position.
  final Component child;

  /// The distance that the child's left edge
  /// is inset from the left of the stack.
  final Dim? left;

  /// The distance that the child's top edge
  /// is inset from the top of the stack.
  final Dim? top;

  /// The distance that the child's right edge
  /// is inset from the right of the stack.
  final Dim? right;

  /// The distance that the child's bottom edge
  /// is inset from the bottom of the stack.
  final Dim? bottom;

  /// Width of the positioned component.
  final Dim? width;

  /// Height of the positioned component.
  final Dim? height;

  /// Additional CSS classes applied to the positioned component.
  final String? classes;

  /// {@macro Positioned}
  const Positioned({
    super.key,
    required this.child,
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.width,
    this.height,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final stack = StackScope.of(context);

    assert(stack != null, 'Positioned must be a direct child of Stack.');

    const baseClass = 'naki-positioned';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      tag: 'naki-positioned',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'top': ?top?.cssText,
          'left': ?left?.cssText,
          'right': ?right?.cssText,
          'bottom': ?bottom?.cssText,
          'width': ?width?.cssText,
          'height': ?height?.cssText,
        },
      ),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Positioned', [
    Rules.nakiPositionedRules,
  ]);
}

/// {@template Wrap}
/// A component that displays its children in multiple
/// horizontal or vertical runs.
///
/// ### Example
/// ```dart
/// Wrap(
///   children: [
///     NakiText('Padded Content'),
///     NakiText('Padded Content'),
///   ],
/// )
/// ```
/// {@endtemplate}
class Wrap extends StatelessComponent {
  /// Components to wrap.
  final List<Component> children;

  /// Direction to use as the main ScrollDirection.
  final Direction direction;

  /// How the children within a run should be
  /// placed in the main ScrollDirection.
  final MainAxisAlignment alignment;

  /// How the children within a run should be
  /// aligned in the cross ScrollDirection.
  final CrossAxisAlignment crossAxisAlignment;

  /// How much space (in pixels) to place between children
  /// in a run in the main ScrollDirection.
  final double? spacing;

  /// How much space (in pixels) to place between the runs
  /// themselves in the cross ScrollDirection.
  final double? runSpacing;

  /// Additional CSS classes applied to the wrap component.
  final String? classes;

  /// {@macro Wrap}
  const Wrap({
    super.key,
    required this.children,
    this.direction = Direction.horizontal,
    this.alignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
    this.runSpacing,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-wrap';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final justify = NakiAlignProps.mapMainAxisAlignment(
      alignment,
    );
    final align = NakiAlignProps.mapCrossAxisAlignment(
      crossAxisAlignment,
    );
    final isHoriz = direction == Direction.horizontal;

    final effectiveSpacing = spacing != null
        ? '${spacing!.toCleanString}px'
        : null;
    final effectiveRunSpacing = runSpacing != null
        ? '${runSpacing!.toCleanString}px'
        : null;

    return .element(
      tag: 'naki-wrap',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'flex-direction': isHoriz ? 'row' : 'column',
          'justify-content': justify,
          'align-items': align,
          'column-gap': ?(isHoriz ? effectiveSpacing : effectiveRunSpacing),
          'row-gap': ?(!isHoriz ? effectiveSpacing : effectiveRunSpacing),
        },
      ),
      children: children,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Wrap', [Rules.nakiWrapRules]);
}

/// {@template SafeArea}
/// A component that insets its child by sufficient padding to avoid
/// system intrusions (notches, toolbars).
///
/// ### Example
/// ```dart
/// SafeArea(
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class SafeArea extends StatelessComponent {
  /// Component to display inside the safe area.
  final Component child;

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions on the top.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom.
  final bool bottom;

  /// Additional CSS classes applied to the safe area component.
  final String? classes;

  /// {@macro SafeArea}
  const SafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-safearea';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    return .element(
      tag: 'naki-safearea',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'padding-top': ?(top ? null : 'unset'),
          'padding-left': ?(left ? null : 'unset'),
          'padding-right': ?(right ? null : 'unset'),
          'padding-bottom': ?(bottom ? null : 'unset'),
        },
      ),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('SafeArea', [
    Rules.nakiSafeareRules,
  ]);
}

/// {@template Container}
/// A component that combines common painting, positioning, and sizing.
///
/// ### Example
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     color: Colors.red,
///     border: BorderData(
///       color: Colors.black,
///       radius: BorderRadiusData.all(Dim.px(10)),
///     ),
///     shadow: Shadow(
///       offsetX: 0,
///       offsetY: 10,
///       blurRadius: 10,
///       spreadRadius: 5,
///       color: Colors.black,
///     ),
///   ),
///   child: NakiText('Hello'),
/// )
/// ```
/// {@endtemplate}
class Container extends StatelessComponent {
  /// Child component of the container.
  final Component child;

  /// Height of the container.
  final Dim? height;

  /// Width of the container.
  final Dim? width;

  /// Decoration properties of the container.
  final BoxDecoration? decoration;

  /// Size constraints of the container.
  final SizeConstraints? constraints;

  /// Custom CSS classes applied to the container.
  final String? classes;

  /// When `true` and [BoxDecoration.alignment] is not set, the container
  /// will be rendered as a block box.
  final bool blockBox;

  /// When `true`, [child] component will not overflow the container.
  final bool clip;

  /// {@macro Container}
  const Container({
    super.key,
    required this.child,
    this.blockBox = false,
    this.clip = false,
    this.height,
    this.width,
    this.constraints,
    this.decoration,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-container';
    final effectiveClasses = classes.isNotNullAndEmpty
        ? '$baseClass $classes'
        : baseClass;

    final effectiveStyles = {
      'display': ?(blockBox ? 'block' : null),
      'overflow': ?(clip ? 'hidden' : null),
      'height': ?height?.cssText,
      'width': ?width?.cssText,
      ...?constraints?.props,
      ...?decoration?.props,
    };

    return .element(
      key: key,
      tag: 'naki-container',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Container', [
    Rules.nakiContainerRules,
  ]);
}

/// {@template Card}
/// A Naki component that renders a surface used to represent related
/// information, such as an album, a product card, a task item, or
/// a settings panel.
///
/// By default, a [Card] uses an elevated surface with subtle box shadow
/// and rounded corners. Use [Card.outlined] for a card bounded by a border,
/// or [Card.filled] for a solid surface-variant card.
///
/// ### Example
/// ```dart
/// Card(
///   padding: EdgeInsets.all(Dim.px(16)),
///   child: Column(
///     children: const [
///       Heading('Material Card', level: HeadingLevel.h4),
///       NakiText('Card content goes here.'),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class Card extends StatelessComponent {
  /// The component to display inside the card.
  final Component child;

  /// The background color of the card.
  final Color? color;

  /// The background gradient of the card.
  ///
  /// ### Example
  /// ```dart
  /// Card(
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.purple]),
  ///   child: NakiText('Gradient Card'),
  /// )
  /// ```
  final Gradient? gradient;

  /// The elevation of the card, controlling its shadow depth.
  ///
  /// Set to `0` or use [Card.outlined] / [Card.filled] for a flat card.
  final double? elevation;

  /// Explicit custom shadow. If provided, overrides [elevation].
  final Shadow? shadow;

  /// Color override for the elevation shadow.
  final Color? shadowColor;

  /// Border styling for the card.
  final BorderData? border;

  /// Border radius of the card corners.
  final BorderRadiusData? borderRadius;

  /// Outer margin surrounding the card.
  final EdgeInsets? margin;

  /// Inner padding inside the card.
  final EdgeInsets? padding;

  /// Explicit width of the card.
  final Dim? width;

  /// Explicit height of the card.
  final Dim? height;

  /// Size constraints applied to the card.
  final SizeConstraints? constraints;

  /// Whether to clip content that overflows the card's rounded borders.
  final bool clip;

  /// Additional CSS classes applied to the card element.
  final String? classes;

  /// Optional callback invoked when the card is clicked.
  ///
  /// When provided, the card renders with an interactive pointer cursor
  /// and hover feedback.
  final FutureOr<void> Function()? onTap;

  final CardVariant _variant;

  /// {@macro Card}
  const Card({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.elevation = 1.0,
    this.shadow,
    this.shadowColor,
    this.border,
    this.borderRadius,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.clip = false,
    this.classes,
    this.onTap,
  }) : _variant = CardVariant.elevated;

  /// Creates an outlined card.
  ///
  /// Outlined cards have a default border and zero elevation shadow.
  const Card.outlined({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.clip = false,
    this.classes,
    this.onTap,
  }) : elevation = 0,
       shadow = null,
       shadowColor = null,
       _variant = CardVariant.outlined;

  /// Creates a filled card.
  ///
  /// Filled cards use a distinct surface container background color
  /// and zero elevation shadow.
  const Card.filled({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.constraints,
    this.clip = false,
    this.classes,
    this.onTap,
  }) : elevation = 0,
       shadow = null,
       shadowColor = null,
       _variant = CardVariant.filled;

  static String? _elevationToBoxShadow(
    double? elevation,
    Color? shadowColor,
  ) {
    if (elevation == null) return null;

    if (elevation <= 0) return 'none';

    final col =
        shadowColor?.value ?? 'var(--naki-shadow-color, rgba(0, 0, 0, 0.1))';
    final y = (elevation * 2).clamp(1, 24).toInt();
    final blur = (elevation * 4).clamp(2, 48).toInt();
    final spread = (elevation * 0.5).clamp(0, 8).toInt();

    return '0px ${y}px ${blur}px ${spread}px $col';
  }

  @override
  Component build(BuildContext context) {
    final isInteractive = onTap != null;
    final variantClass = 'naki-card--${_variant.name}';
    final interactiveClass = isInteractive ? 'naki-card--interactive' : '';

    final effectiveClasses = [
      'naki-card',
      variantClass,
      if (interactiveClass.isNotEmpty) interactiveClass,
      if (classes.isNotNullAndEmpty) classes!,
    ].join(' ');

    final effectiveStyles = {
      'overflow': ?(clip ? 'hidden' : null),
      'background-color': ?color?.value,
      'height': ?height?.cssText,
      'width': ?width?.cssText,
      ...?borderRadius?.props,
      ...?border?.props,
      ...?padding?.pProps,
      ...?margin?.mProps,
      ...?constraints?.props,
      ...?shadow?.props,
      ...?gradient?.props,
      if (shadow == null &&
          elevation != null &&
          _variant == CardVariant.elevated &&
          elevation != 1.0)
        'box-shadow': ?_elevationToBoxShadow(
          elevation,
          shadowColor,
        ),
      if (elevation == 0 && _variant == CardVariant.elevated)
        'box-shadow': 'none',
    };

    return .element(
      key: key,
      tag: 'naki-card',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      events: isInteractive
          ? Events(
              onClick: (_) async {
                final value = onTap!();
                if (value is Future) await value;
              },
              onKeyDown: (event) {
                if (event.key == 'Enter' || event.key == ' ') {
                  event.preventDefault();
                  onTap!();
                }
              },
            ).toMap
          : null,
      attributes: isInteractive
          ? {'tabindex': '0', 'role': 'button', 'hvr': ''}
          : null,
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Card', [Rules.nakiCardRules]);
}

/// Signature for [ExpansionPanel] header builder.
typedef ExpansionPanelHeaderBuilder =
    Component Function(
      BuildContext context,
      bool isExpanded,
    );

/// Signature for [ExpansionPanelList] expansion callback.
typedef ExpansionPanelCallback = void Function(int panelIndex, bool isExpanded);

/// {@template ExpansionPanel}
/// An item in an [ExpansionPanelList].
///
/// Holds the header and body components of a collapsible panel.
///
/// ### Example
/// ```dart
/// ExpansionPanel(
///   header: const NakiText('General Settings'),
///   body: const NakiText('Account preferences and details.'),
///   isExpanded: true,
/// )
/// ```
/// {@endtemplate}
class ExpansionPanel {
  /// The component that will be displayed in the header.
  final Component? header;

  /// Optional header builder function that constructs the header
  /// based on whether the panel is expanded.
  final ExpansionPanelHeaderBuilder? headerBuilder;

  /// The body of the expansion panel that is shown when the
  /// panel is expanded.
  final Component body;

  /// Whether the panel is expanded (for controlled mode).
  final bool isExpanded;

  /// Whether tapping on the header will expand or collapse the panel.
  final bool canTapOnHeader;

  /// Background color for this panel.
  final Color? backgroundColor;

  /// Background gradient for this panel.
  ///
  /// ### Example
  /// ```dart
  /// ExpansionPanel(
  ///   header: NakiText('Gradient Panel'),
  ///   body: NakiText('Panel content'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.pink]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Optional leading component in the header (e.g. an icon).
  final Component? leading;

  /// Optional trailing component in the header.
  ///
  /// If `null`, an animated rotating chevron is displayed.
  final Component? trailing;

  /// Whether this panel is disabled.
  final bool disabled;

  /// Custom padding for the header.
  final EdgeInsets? headerPadding;

  /// Custom padding for the body.
  final EdgeInsets? bodyPadding;

  /// Additional CSS classes applied to this panel.
  final String? classes;

  /// Value identifying this panel in an [ExpansionPanelList.radio].
  final dynamic value;

  /// {@macro ExpansionPanel}
  const ExpansionPanel({
    this.header,
    this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.canTapOnHeader = true,
    this.disabled = false,
    this.backgroundColor,
    this.gradient,
    this.leading,
    this.trailing,
    this.headerPadding,
    this.bodyPadding,
    this.classes,
    this.value,
  }) : assert(
         header != null || headerBuilder != null,
         'Either header or headerBuilder must be provided.',
       );

  /// Creates a radio expansion panel item with a unique [value].
  const ExpansionPanel.radio({
    required this.value,
    this.header,
    this.headerBuilder,
    required this.body,
    this.canTapOnHeader = true,
    this.disabled = false,
    this.backgroundColor,
    this.gradient,
    this.leading,
    this.trailing,
    this.headerPadding,
    this.bodyPadding,
    this.classes,
  }) : isExpanded = false,
       assert(
         header != null || headerBuilder != null,
         'Either header or headerBuilder must be provided.',
       );
}

/// {@template ExpansionPanelList}
/// A Naki component that creates a list of expandable accordions/panels
/// that can be expanded or collapsed.
///
/// Supports both traditional single-open mode when [allowMultiple] is
/// `false` and multi-open mode when [allowMultiple] is `true`.
///
/// ### Example
/// ```dart
/// ExpansionPanelList(
///   allowMultiple: false,
///   expansionCallback: (index, isExpanded) {
///     print('Panel $index isExpanded: $isExpanded');
///   },
///   children: [
///     ExpansionPanel(
///       header: const NakiText('What is Naki UI?'),
///       body: const NakiText('A Material-inspired design system for Jaspr.'),
///       isExpanded: true,
///     ),
///     ExpansionPanel(
///       header: const NakiText('Does it support dark mode?'),
///       body: const NakiText('Yes, with full CSS variable theming.'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class ExpansionPanelList extends StatefulComponent {
  /// The expansion panel children.
  final List<ExpansionPanel> children;

  /// Callback called when any panel expands or collapses.
  final ExpansionPanelCallback? expansionCallback;

  /// Whether multiple panels can be expanded at the same time.
  ///
  /// Set to `true` to allow multiple panels to stay open.
  final bool allowMultiple;

  /// The initially expanded panel value for radio mode.
  final dynamic initialOpenPanelValue;

  /// Custom elevation shadow of the expansion panel list.
  final double? elevation;

  /// Custom border for the expansion panel list.
  final BorderData? border;

  /// Custom border radius for the expansion panel list container.
  final BorderRadiusData? borderRadius;

  /// Divider color between panels.
  final Color? dividerColor;

  /// Color of the text and icon in the panels' header when hovered.
  final Color? hoverColor;

  /// Background color of the expansion panel list.
  final Color? color;

  /// Outer margin surrounding the list.
  final EdgeInsets? margin;

  /// Additional CSS classes.
  final String? classes;

  /// {@macro ExpansionPanelList}
  const ExpansionPanelList({
    super.key,
    this.children = const [],
    this.expansionCallback,
    this.allowMultiple = false,
    this.elevation,
    this.border,
    this.borderRadius,
    this.hoverColor,
    this.dividerColor,
    this.color,
    this.margin,
    this.classes,
  }) : initialOpenPanelValue = null;

  /// Creates an expansion panel list where only one panel can be
  /// open at a time.
  const ExpansionPanelList.radio({
    super.key,
    this.children = const [],
    this.expansionCallback,
    this.initialOpenPanelValue,
    this.elevation,
    this.border,
    this.borderRadius,
    this.hoverColor,
    this.dividerColor,
    this.color,
    this.margin,
    this.classes,
  }) : allowMultiple = false;

  @override
  State<ExpansionPanelList> createState() => _ExpansionPanelListState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'ExpansionPanelList',
    Rules.nakiExpansionPanelRules,
  );
}

class _ExpansionPanelListState extends State<ExpansionPanelList> {
  final Set<int> _openIndices = {};
  late final String _id = nakiDomId(
    context,
    'expansion-panel-list',
  );

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _syncInitialState();
  }

  @override
  void didUpdateComponent(ExpansionPanelList oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.children != component.children) {
      _syncInitialState();
    }
  }

  /// Syncs the initial state of the expansion panel list.
  void _syncInitialState() {
    _openIndices.clear();

    for (int i = 0; i < component.children.length; i++) {
      final child = component.children[i];

      final isInitialPanel =
          component.initialOpenPanelValue != null &&
          child.value == component.initialOpenPanelValue;

      if (child.isExpanded || isInitialPanel) {
        _openIndices.add(i);

        if (!component.allowMultiple) break;
      }
    }
  }

  /// Handles the toggle event of an expansion panel.
  void _handleToggle(int index) {
    final currentlyOpen = _openIndices.contains(index);
    final willBeOpen = !currentlyOpen;

    setState(() {
      if (willBeOpen) {
        if (!component.allowMultiple) _openIndices.clear();
        _openIndices.add(index);
      } else {
        _openIndices.remove(index);
      }
    });

    component.expansionCallback?.call(index, willBeOpen);
  }

  /// Creates a default chevron component for the expansion panel.
  static Component _defaultChevron(bool isExpanded) {
    return Icon(
      LucideIcons.icon_chevron_down,
      size: 20,
      classes:
          'naki-expansion-panel__chevron${isExpanded ? " is-expanded" : ""}',
    );
  }

  @override
  Component build(BuildContext context) {
    final panels = <Component>[];

    const baseClass = 'naki-expansion-panel-list';
    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

    final effectiveStyles = {
      Tokens.current.hoverColor.name: component.hoverColor?.value ?? 'initial',
      'background-color': ?component.color?.value,
      ...?component.borderRadius?.props,
      ...?component.border?.props,
      ...?component.margin?.mProps,
      if (component.elevation != null && component.elevation! > 0)
        'box-shadow':
            '0 ${component.elevation! * 2}px ${component.elevation! * 4}px rgba(0,0,0,0.1)',
    };

    for (int i = 0; i < component.children.length; i++) {
      final panel = component.children[i];
      final isExpanded = _openIndices.contains(i);
      final headerId = '${_id}_header_$i';
      final bodyId = '${_id}_body_$i';

      final header = panel.headerBuilder != null
          ? panel.headerBuilder!(context, isExpanded)
          : panel.header!;

      final trailing = panel.trailing ?? _defaultChevron(isExpanded);

      final panelClasses = [
        'naki-expansion-panel',
        if (isExpanded) 'is-expanded',
        if (panel.classes.isNotNullAndEmpty) panel.classes!,
      ].join(' ');

      panels.add(
        div(
          classes: panelClasses,
          styles: Styles(
            raw: {
              'background-color': ?panel.backgroundColor?.value,
              'border-bottom-color': ?component.dividerColor?.value,
              ...?panel.gradient?.props,
            },
          ),
          [
            // Header button
            .wrapElement(
              child: Button(
                id: headerId,
                classes: 'naki-expansion-panel__header',
                child: Row(
                  classes: 'naki-expansion-panel__header-content',
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 12,
                  children: [
                    Row(
                      spacing: 10,
                      children: [?panel.leading, header],
                    ),

                    trailing,
                  ],
                ),
                hoverColor: panel.backgroundColor ?? Colors.transparent,
                disabled: panel.disabled,
                attributes: {
                  'aria-expanded': isExpanded ? 'true' : 'false',
                  'aria-controls': bodyId,
                },
                onTap: panel.canTapOnHeader && !panel.disabled
                    ? () => _handleToggle(i)
                    : null,
              ),
              styles: Styles(
                raw: panel.headerPadding?.pProps,
              ),
            ),

            // Collapsible body
            div(
              id: bodyId,
              classes: 'naki-expansion-panel__body-wrapper',
              attributes: {
                'role': 'region',
                'aria-labelledby': headerId,
                'aria-hidden': (!isExpanded).toString(),
              },
              [
                div(
                  classes: 'naki-expansion-panel__body-content',
                  [
                    div(
                      classes: 'naki-expansion-panel__body-inner',
                      styles: Styles(
                        raw: panel.bodyPadding?.pProps,
                      ),
                      [panel.body],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    return .element(
      key: component.key,
      tag: 'naki-expansion-panel',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: panels,
    );
  }
}

/// {@template ExpansionTile}
/// A Naki component that renders an expandable card with a header
/// and collapsible content.
///
/// ### Example
/// ```dart
/// ExpansionTile(
///   title: const NakiText('Account Details'),
///   leading: const Icon(MaterialIcons.icon_round_person),
///   children: const [
///     NakiText('Username: @johndoe'),
///     NakiText('Email: user@example.com'),
///   ],
/// )
/// ```
/// {@endtemplate}
class ExpansionTile extends StatefulComponent {
  /// The primary content of the tile header.
  final Component title;

  /// Additional subtitle displayed below [title].
  final Component? subtitle;

  /// Leading component displayed before the title (e.g. an [Icon]).
  final Component? leading;

  /// Trailing component displayed after the title (defaults to a
  /// rotating chevron icon).
  final Component? trailing;

  /// The components that are displayed when the tile expands.
  final List<Component> children;

  /// Callback invoked when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether the tile should be initially expanded.
  final bool initiallyExpanded;

  /// Background color of the tile when expanded.
  final Color? backgroundColor;

  /// Background color of the tile when collapsed.
  final Color? collapsedBackgroundColor;

  /// Background gradient of the tile when expanded.
  ///
  /// ### Example
  /// ```dart
  /// ExpansionTile(
  ///   title: NakiText('Gradient ExpansionTile'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.teal]),
  ///   children: [NakiText('Expanded content')],
  /// )
  /// ```
  final Gradient? gradient;

  /// Background gradient of the tile when collapsed.
  final Gradient? collapsedGradient;

  /// Color of the title and leading icon when hovered.
  final Color? hoverColor;

  /// Border shape of the tile when expanded.
  final BorderData? shape;

  /// Border shape of the tile when collapsed.
  final BorderData? collapsedShape;

  /// Border radius of the tile.
  final BorderRadiusData? borderRadius;

  /// Content padding inside the tile header.
  final EdgeInsets? tilePadding;

  /// Padding for the collapsible children.
  final EdgeInsets? childrenPadding;

  /// Additional CSS classes applied to the expansion tile.
  final String? classes;

  /// {@macro ExpansionTile}
  const ExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.children = const [],
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.gradient,
    this.collapsedGradient,
    this.onExpansionChanged,
    this.hoverColor,
    this.shape,
    this.collapsedShape,
    this.borderRadius,
    this.tilePadding,
    this.childrenPadding,
    this.classes,
  });

  @override
  State<ExpansionTile> createState() => _ExpansionTileState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'ExpansionTile',
    Rules.nakiExpansionPanelRules,
  );
}

class _ExpansionTileState extends State<ExpansionTile> {
  late bool _isExpanded;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = component.initiallyExpanded;
  }

  @override
  void didUpdateComponent(ExpansionTile oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.initiallyExpanded != component.initiallyExpanded) {
      _isExpanded = component.initiallyExpanded;
    }
  }

  /// Toggles expansion state of the tile.
  void _toggle() {
    final next = !_isExpanded;
    setState(() => _isExpanded = next);
    component.onExpansionChanged?.call(next);
  }

  @override
  Component build(BuildContext context) {
    final activeBg = _isExpanded
        ? component.backgroundColor
        : component.collapsedBackgroundColor;

    final activeGradient = _isExpanded
        ? component.gradient
        : component.collapsedGradient;

    final activeShape = _isExpanded
        ? component.shape
        : component.collapsedShape;

    final effectiveClasses = [
      'naki-expansion-tile',
      if (_isExpanded) 'is-expanded',
      if (component.classes.isNotNullAndEmpty) component.classes!,
    ].join(' ');

    final effectiveStyles = {
      Tokens.current.hoverColor.name: component.hoverColor?.value ?? 'initial',
      'background-color': ?activeBg?.value,
      ...?component.borderRadius?.props,
      ...?activeShape?.props,
      ...?activeGradient?.props,
    };

    final trailing =
        component.trailing ??
        _ExpansionPanelListState._defaultChevron(
          _isExpanded,
        );

    return .element(
      key: component.key,
      tag: 'naki-expansion-tile',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [
        // Header
        .wrapElement(
          child: Button(
            classes: 'naki-expansion-panel__header',
            attributes: {
              'aria-expanded': _isExpanded ? 'true' : 'false',
            },
            hoverColor: activeBg ?? Colors.transparent,
            child: Row(
              classes: 'naki-expansion-panel__header-content',
              spacing: 12,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    ?component.leading,

                    Column(
                      spacing: 2,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        component.title,
                        ?component.subtitle,
                      ],
                    ),
                  ],
                ),

                trailing,
              ],
            ),
            onTap: _toggle,
          ),
          styles: Styles(
            raw: component.tilePadding?.pProps,
          ),
        ),

        // Collapsible body
        div(
          classes: 'naki-expansion-panel__body-wrapper',
          attributes: {
            'role': 'region',
            if (_isExpanded) 'aria-expanded': 'true',
          },
          [
            div(
              classes: 'naki-expansion-panel__body-content',
              [
                div(
                  classes: 'naki-expansion-panel__body-inner',
                  styles: Styles(
                    raw: component.childrenPadding?.pProps,
                  ),
                  component.children,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
