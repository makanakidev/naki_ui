part of 'index.dart';

/// {@template Positioned}
/// A component that controls where a child of a [Stack] is positioned.
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

  /// CSS transform property (e.g. `translate(-50%, -50%)`).
  final String? transform;

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
    this.transform,
    this.classes,
  });

  /// Creates a [Positioned] component with [left],
  /// [top], [right], and [bottom] all set to 0.
  const Positioned.fill({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.transform,
    this.classes,
  }) : left = Dim.zero,
       top = Dim.zero,
       right = Dim.zero,
       bottom = Dim.zero;

  /// Creates a [Positioned] component centered both
  /// horizontally and vertically within the stack.
  const Positioned.center({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.classes,
  }) : top = const Dim.percent(50),
       left = const Dim.percent(50),
       right = null,
       bottom = null,
       transform = 'translate(-50%, -50%)';

  /// Creates a [Positioned] component centered horizontally within the stack.
  const Positioned.centerHorizontal({
    super.key,
    required this.child,
    this.top,
    this.bottom,
    this.width,
    this.height,
    this.classes,
  }) : left = const Dim.percent(50),
       right = null,
       transform = 'translateX(-50%)';

  /// Creates a [Positioned] component centered vertically within the stack.
  const Positioned.centerVertical({
    super.key,
    required this.child,
    this.left,
    this.right,
    this.width,
    this.height,
    this.classes,
  }) : top = const Dim.percent(50),
       bottom = null,
       transform = 'translateY(-50%)';

  /// Creates a [Positioned] component placed at the top-right corner with a
  /// `translate(50%, -50%)` offset, ideal for badge and notification dot overlays.
  const Positioned.badge({
    super.key,
    required this.child,
    this.bottom,
    this.left,
    this.width,
    this.height,
    this.classes,
  }) : right = Dim.zero,
       top = Dim.zero,
       transform = 'translate(50%, -50%)';

  /// Creates a [Positioned] component anchored to the top-left corner.
  const Positioned.topLeft({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.transform,
    this.classes,
  }) : top = Dim.zero,
       left = Dim.zero,
       right = null,
       bottom = null;

  /// Creates a [Positioned] component anchored to the top-right corner.
  const Positioned.topRight({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.transform,
    this.classes,
  }) : top = Dim.zero,
       right = Dim.zero,
       left = null,
       bottom = null;

  /// Creates a [Positioned] component anchored to the bottom-left corner.
  const Positioned.bottomLeft({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.transform,
    this.classes,
  }) : bottom = Dim.zero,
       left = Dim.zero,
       top = null,
       right = null;

  /// Creates a [Positioned] component anchored to the bottom-right corner.
  const Positioned.bottomRight({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.transform,
    this.classes,
  }) : bottom = Dim.zero,
       right = Dim.zero,
       top = null,
       left = null;

  /// Creates a [Positioned] component stretched horizontally across the top edge.
  const Positioned.top({
    super.key,
    required this.child,
    this.height,
    this.transform,
    this.classes,
  }) : top = Dim.zero,
       left = Dim.zero,
       right = Dim.zero,
       bottom = null,
       width = null;

  /// Creates a [Positioned] component stretched horizontally across the bottom edge.
  const Positioned.bottom({
    super.key,
    required this.child,
    this.height,
    this.transform,
    this.classes,
  }) : bottom = Dim.zero,
       left = Dim.zero,
       right = Dim.zero,
       top = null,
       width = null;

  @override
  Component build(BuildContext context) {
    final stack = StackScope.of(context);
    assert(stack != null, 'Positioned must be a direct child of Stack.');

    const baseClass = 'naki-positioned';
    final effectiveClasses = joinClasses([?classes, baseClass]);

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
          'transform': ?transform,
        },
      ),
      children: [child],
    );
  }

  static List<StyleRule> get styles => LayoutStyles.positioned;
}
