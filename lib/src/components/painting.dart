import 'package:jaspr/dom.dart' hide Filter, Visibility;
import 'package:jaspr/jaspr.dart';

import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

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
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-opacity',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: {'opacity': opacity.clamp(0.0, 1.0).toCleanString}),
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
    if (!visible && !maintainState) return replacement;

    const baseClass = 'naki-visibility';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final Component effectiveChild = !visible && maintainState
        ? .wrapElement(classes: 'naki-hide', child: child)
        : child;

    return .element(
      tag: 'naki-visibility',
      key: key,
      classes: effectiveClasses,
      children: [effectiveChild],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Visibility', [Rules.nakiHide]);
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
    final effectiveClasses = joinClasses([?classes, baseClass]);

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
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ClipRect', [Rules.nakiClipRectRules]);
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

  /// Background gradient of the decoration.
  ///
  /// ### Example
  /// ```dart
  /// DecoratedBox(
  ///   gradient: Gradient()..applyLinear(colors: [Colors.orange, Colors.red]),
  ///   child: NakiText('Gradient Box'),
  /// )
  /// ```
  final Gradient? gradient;

  /// Border styling.
  final BorderData? border;

  /// Box shadow.
  final Shadow? shadow;

  /// Border radius.
  final BorderRadiusData? borderRadius;

  /// Optional CSS classes applied to the decorated box component.
  final String? classes;

  /// {@macro DecoratedBox}
  const DecoratedBox({
    super.key,
    required this.child,
    this.color,
    this.gradient,
    this.border,
    this.shadow,
    this.borderRadius,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-decoratedbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      'display': 'block',
      'background-color': ?color?.value,
      ...?shadow?.props,
      ...?border?.props,
      ...?borderRadius?.props,
      ...?gradient?.props,
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
  const ClipOval({super.key, required this.child, this.classes});

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-clip-oval';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-clipoval',
      key: key,
      classes: effectiveClasses,
      children: [child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('ClipOval', [Rules.nakiClipOvalRules]);
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
///   filter: Filter()
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
  /// See [Filter] for available filter methods.
  ///
  /// ### Example
  /// ```dart
  /// BackdropFilter(
  ///   filter: Filter()
  ///     ..applyBlur(8)
  ///     ..applyContrast(250)
  ///     ..applyGrayscale(100),
  ///   ...,
  /// )
  /// ```
  final Filter filter;

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
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-backdropfilter',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: {'display': 'block', ...filter.props}),
      children: [child],
    );
  }
}

/// {@template ColoredBox}
/// A component that paints a background color or gradient behind its child.
///
/// ### Example: Box with solid red background
/// ```dart
/// ColoredBox(
///   color: Colors.red,
///   child: NakiText('I am red'),
/// )
/// ```
///
/// ### Example: Box with linear gradient background
/// ```dart
/// ColoredBox(
///   gradient: Gradient()..applyLinear(colors: [Colors.red, Colors.blue]),
///   child: NakiText('I am red'),
/// )
/// ```
/// {@endtemplate}
class ColoredBox extends StatelessComponent {
  /// The component to display inside the colored box.
  final Component child;

  /// Background color of the box.
  final Color? color;

  /// Background gradient of the box.
  final Gradient? gradient;

  /// Optional CSS classes applied to the colored box component.
  final String? classes;

  /// {@macro ColoredBox}
  const ColoredBox({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.classes,
  }) : assert(
         color != null || gradient != null,
         'ColoredBox must have a color or gradient',
       );

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-coloredbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-coloredbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'display': 'block',
          'background-color': ?color?.value,
          ...?gradient?.props,
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
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final degrees = (quarterTurns % 4) * 90;

    return .element(
      tag: 'naki-rotatedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: {'transform': 'rotate(${degrees}deg)'}),
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
  /// ### Example
  /// ```dart
  /// Transform.rotate(
  ///   -45,
  ///   child: NakiText('I am rotated'),
  /// );
  /// ```
  Transform.rotate(
    double angle, {
    super.key,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = 'rotate(${angle.toCleanString}deg)';

  /// Creates a scaling transformation.
  ///
  /// ### Example
  /// ```dart
  /// Transform.scale(
  ///   2,
  ///   child: NakiText('I am scaled'),
  /// );
  /// ```
  Transform.scale(
    double scale, {
    super.key,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = 'scale(${scale.toCleanString})';

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
  Transform.translate({
    super.key,
    required double offsetX,
    required double offsetY,
    required this.child,
    this.alignment,
    this.classes,
  }) : transform = 'translate(${offsetX.toPx}, ${offsetY.toPx})';

  @override
  Component build(BuildContext context) {
    final alignmentProps = alignment != null
        ? NakiAlignProps.mapAlignment(alignment!)
        : null;

    const baseClass = 'naki-transform';
    final effectiveClasses = joinClasses([?classes, baseClass]);

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
