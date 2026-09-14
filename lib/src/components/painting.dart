import 'package:jaspr/dom.dart' hide Visibility;
import 'package:jaspr/jaspr.dart';

import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';

// /////////////////////////////////////////////////////////////////////////////
// PAINTING COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Opacity}
/// A component that makes its child partially or fully transparent.
///
/// ### Example
/// ```dart
/// Opacity(
///   opacity: 0.5,
///   child: NakiText('Half transparent'),
/// )
/// ```
/// {@endtemplate}
class Opacity extends StatelessComponent {
  /// The component to make transparent.
  final Component child;

  /// Opacity level between 0.0 (fully transparent) and 1.0 (fully opaque).
  final double opacity;

  /// CSS Classes applied to the opacity container.
  final String? classes;

  /// {@macro Opacity}
  const Opacity({
    super.key,
    required this.opacity,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-opacity';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return .element(
      tag: 'naki-opacity',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {'opacity': opacity.toCleanString},
      ),
      children: [child],
    );
  }
}

/// {@template Visibility}
/// A component that conditionally shows or hides its child.
///
/// ### Example
/// ```dart
/// Visibility(
///   visible: isVisible,
///   child: NakiText('Visible text'),
/// )
/// ```
/// {@endtemplate}
class Visibility extends StatelessComponent {
  /// The component to conditionally display.
  final Component child;

  /// Whether the [child] is visible.
  final bool visible;

  /// Component to render when [visible] is `false`
  /// and [maintainState] is `false`.
  final Component replacement;

  /// Whether to maintain [child]'s state when hidden.
  final bool maintainState;

  /// Optional CSS Classes applied to the visibility component.
  final String? classes;

  /// {@macro Visibility}
  const Visibility({
    super.key,
    required this.child,
    this.visible = true,
    this.replacement = const .empty(),
    this.maintainState = false,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    Component effectiveChild = child;

    const baseClass = 'naki-visibility';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    if (!visible) {
      if (maintainState) {
        effectiveChild = .wrapElement(
          classes: 'naki-hide',
          child: child,
        );
      } else {
        effectiveChild = replacement;
      }
    }

    return .element(
      tag: 'naki-visibility',
      classes: effectiveClasses,
      children: [effectiveChild],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Visibility', [
    Rules.nakiHide,
  ]);
}

/// {@template ClipRect}
/// A component that clips its child to a rectangular border bounds.
///
/// ### Example
/// ```dart
/// ClipRect(
///   borderRadius: BorderRadiusData.all(Dim.px(8)),
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class ClipRect extends StatelessComponent {
  /// The component to clip.
  final Component child;

  /// Radius data for curved clipping edges.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes added to the clip rect component.
  final String? classes;

  /// {@macro ClipRect}
  const ClipRect({
    super.key,
    required this.child,
    this.borderRadius,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-cliprect';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveStyles = {...?borderRadius?.props};

    return .element(
      tag: 'naki-cliprect',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('ClipRect', [
    Rules.nakiClipRectRules,
  ]);
}

/// {@template DecoratedBox}
/// A component that paints a decoration before or after its child.
///
/// ### Example
/// ```dart
/// DecoratedBox(
///   color: Colors.red,
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class DecoratedBox extends StatelessComponent {
  /// The child component inside the box.
  final Component child;

  /// Background color of the decoration.
  final Color? color;

  /// Border styling.
  final BorderData? border;

  /// Box shadow.
  final ShadowData? shadow;

  /// Border radius.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes applied to the decorated box component.
  final String? classes;

  /// {@macro DecoratedBox}
  const DecoratedBox({
    super.key,
    required this.child,
    this.color,
    this.border,
    this.shadow,
    this.borderRadius,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-decoratedbox';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveStyles = {
      'display': 'block',
      'background-color': ?color?.value,
      'box-shadow': ?shadow?.value,
      ...?border?.props,
      ...?borderRadius?.props,
    };

    return .element(
      tag: 'naki-decoratedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }
}

/// {@template ClipOval}
/// A component that clips its child using an oval/circular shape.
///
/// ### Example
/// ```dart
/// ClipOval(
///   child: NakiText('Clipped text'),
/// )
/// ```
/// {@endtemplate}
class ClipOval extends StatelessComponent {
  /// The component to clip.
  final Component child;

  /// Optional CSS classes applied to the clip container.
  final String? classes;

  /// {@macro ClipOval}
  const ClipOval({
    super.key,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-clip-oval';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return .element(
      tag: 'naki-clipoval',
      key: key,
      classes: effectiveClasses,
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('ClipOval', [
    Rules.nakiClipOvalRules,
  ]);
}

/// {@template BackdropFilter}
/// A component that applies a backdrop filter to the area
/// behind its child.
///
/// This component is useful for creating frosted glass effects and
/// other cool visual effects.
///
/// ### Example
/// ```dart
/// BackdropFilter(
///   filter: FilterBuilder()
///     ..applyBlur(8)
///     ..applyContrast(250)
///     ..applyGrayscale(100),
///   child: Container(
///     size: SizeConstraints(
///       width: Dim.px(100),
///       height: Dim.px(100),
///     ),
///     decoration: BoxDecoration(backgroundColor: Colors.red),
///     child: NakiText('I am behind the filter'),
///   ),
/// )
/// ```
/// {@endtemplate}
class BackdropFilter extends StatelessComponent {
  /// Component that will be displayed with the backdrop
  /// filter applied behind it.
  final Component child;

  /// Filters to apply to the backdrop.
  /// This is used to create effects like blur, contrast, grayscale, etc.
  ///
  /// See [FilterBuilder] for available filter methods.
  ///
  /// ### Example
  /// ```dart
  /// BackdropFilter(
  ///   filter: FilterBuilder()
  ///     ..applyBlur(8)
  ///     ..applyContrast(250)
  ///     ..applyGrayscale(100),
  ///   ...,
  /// )
  /// ```
  final FilterBuilder filter;

  /// Optional CSS classes applied to the backdrop filter component.
  final String? classes;

  /// {@macro BackdropFilter}
  const BackdropFilter({
    super.key,
    required this.filter,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-backdropfilter';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return .element(
      tag: 'naki-backdropfilter',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {'display': 'block', ...filter.props},
      ),
      children: [child],
    );
  }
}

/// {@template ColoredBox}
/// A component that paints a solid background color behind its child.
///
/// ### Example
/// ```dart
/// ColoredBox(
///   color: Colors.red,
///   child: NakiText('I am red'),
/// )
/// ```
/// {@endtemplate}
class ColoredBox extends StatelessComponent {
  /// The component to display inside the colored box.
  final Component child;

  /// Background color of the box.
  final Color color;

  /// Optional CSS classes applied to the colored box component.
  final String? classes;

  /// {@macro ColoredBox}
  const ColoredBox({
    super.key,
    required this.color,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-coloredbox';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return .element(
      tag: 'naki-coloredbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'display': 'block',
          'background-color': color.value,
        },
      ),
      children: [child],
    );
  }
}

/// {@template RotatedBox}
/// A component that rotates its child by integral numbers of quarter turns.
///
/// ### Example
/// ```dart
/// RotatedBox(
///   quarterTurns: 1,
///   child: NakiText('I am rotated'),
/// )
/// ```
/// {@endtemplate}
class RotatedBox extends StatelessComponent {
  /// The component to display inside the rotated box.
  final Component child;

  /// Number of quarter turns (90 degree increments) to rotate.
  final int quarterTurns;

  /// Optional CSS classes applied to the rotated box component.
  final String? classes;

  /// {@macro RotatedBox}
  const RotatedBox({
    super.key,
    required this.quarterTurns,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-rotatedbox';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final degrees = (quarterTurns % 4) * 90;

    return .element(
      tag: 'naki-rotatedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {'transform': 'rotate(${degrees}deg)'},
      ),
      children: [child],
    );
  }
}

/// {@template Transform}
/// A component that applies a CSS 2D or 3D transform
/// transformation matrix to its child.
///
/// ### Example
/// ```dart
/// Transform(
///   transform: 'rotate(45deg)',
///   child: NakiText('I am rotated'),
/// )
/// ```
/// Supports
/// - `rotate` via [Transform.rotate],
/// - `scale` via [Transform.scale],
/// - `translate` via [Transform.translate]
/// {@endtemplate}
class Transform extends StatelessComponent {
  /// The component to display inside the transform container.
  final Component child;

  /// CSS transform string value.
  ///
  /// ### Example
  /// ```dart
  /// Transform(
  ///   transform: 'rotate(45deg)',
  ///   ...,
  /// )
  /// ```
  final String transform;

  /// Origin alignment for transformation.
  final Alignment? alignment;

  /// Optional CSS classes applied to the transform component.
  final String? classes;

  /// {@macro Transform}
  const Transform({
    super.key,
    required this.transform,
    required this.child,
    this.alignment,
    this.classes,
  });

  /// Creates a rotation transformation.
  ///
  /// [angle] must be between 0 and 360 degrees.
  ///
  /// ### Example
  /// ```dart
  /// Transform.rotate(
  ///   45,
  ///   child: NakiText('I am rotated'),
  /// );
  /// ```
  factory Transform.rotate(
    double angle, {
    Key? key,
    required Component child,
    Alignment? alignment,
    String? classes,
  }) {
    return Transform(
      key: key,
      transform: 'rotate(${angle.toCleanString}deg)',
      alignment: alignment,
      classes: classes,
      child: child,
    );
  }

  /// Creates a scaling transformation.
  ///
  /// ### Example
  /// ```dart
  /// Transform.scale(
  ///   2,
  ///   child: NakiText('I am scaled'),
  /// );
  /// ```
  factory Transform.scale(
    double scale, {
    Key? key,
    required Component child,
    Alignment? alignment,
    String? classes,
  }) {
    return Transform(
      key: key,
      transform: 'scale(${scale.toCleanString})',
      alignment: alignment,
      classes: classes,
      child: child,
    );
  }

  /// Creates a translation transformation.
  ///
  /// - [offsetX] (horizontal displacement) and
  /// - [offsetY] (vertical displacement) are in pixels.
  ///
  /// ### Example
  /// ```dart
  /// Transform.translate(
  ///   offsetX: 10,
  ///   offsetY: 20,
  ///   child: NakiText('I am translated'),
  /// );
  /// ```
  factory Transform.translate({
    Key? key,
    required double offsetX,
    required double offsetY,
    required Component child,
    String? classes,
  }) {
    return Transform(
      key: key,
      transform: 'translate(${offsetX.toCleanString}px, ${offsetY.toCleanString}px)',
      classes: classes,
      child: child,
    );
  }

  @override
  Component build(BuildContext context) {
    final alignmentProps = alignment != null ? NakiAlignProps.mapAlignment(alignment!) : null;

    const baseClass = 'naki-transform';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveStyles = {
      'display': alignment != null ? 'flex' : 'block',
      'transform': transform,
      ...?alignmentProps,
    };

    return .element(
      tag: 'naki-transform',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [child],
    );
  }
}
