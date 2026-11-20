part of 'index.dart';

/// Defines `Gradient` type.
enum GradientType {
  /// Linear gradient.
  linear('linear-gradient'),

  /// Radial gradient.
  radial('radial-gradient'),

  /// Conic gradient.
  conic('conic-gradient'),

  /// Repeating linear gradient.
  repeatingLinear('repeating-linear-gradient'),

  /// Repeating radial gradient.
  repeatingRadial('repeating-radial-gradient'),

  /// Repeating conic gradient.
  repeatingConic('repeating-conic-gradient')
  ;

  /// The CSS class name representing the gradient style.
  final String css;
  const GradientType(this.css);

  /// Converts the gradient type and stops to a CSS string
  /// (e.g., "linear-gradient(to right, red, blue)").
  String cssText(List<String> parts) => '$css(${parts.join(", ")})';
}

/// Defines direction for linear gradients.
enum LinearGradientDirection {
  /// Gradients towards the top (`to top`).
  toTop('to top'),

  /// Gradients towards the bottom (`to bottom`).
  toBottom('to bottom'),

  /// Gradients towards the left (`to left`).
  toLeft('to left'),

  /// Gradients towards the right (`to right`).
  toRight('to right'),

  /// Gradients towards the top-left corner (`to top left`).
  toTopLeft('to top left'),

  /// Gradients towards the top-right corner (`to top right`).
  toTopRight('to top right'),

  /// Gradients towards the bottom-left corner (`to bottom left`).
  toBottomLeft('to bottom left'),

  /// Gradients towards the bottom-right corner (`to bottom right`).
  toBottomRight('to bottom right')
  ;

  /// The standard CSS direction value.
  final String css;
  const LinearGradientDirection(this.css);
}

/// Defines center position for radial gradients.
enum RadialGradientPosition {
  /// Centered position (`center`).
  center('center'),

  /// Top center position (`top`).
  top('top'),

  /// Bottom center position (`bottom`).
  bottom('bottom'),

  /// Left center position (`left`).
  left('left'),

  /// Right center position (`right`).
  right('right'),

  /// Top-left corner (`top left`).
  topLeft('top left'),

  /// Top-right corner (`top right`).
  topRight('top right'),

  /// Bottom-left corner (`bottom left`).
  bottomLeft('bottom left'),

  /// Bottom-right corner (`bottom right`).
  bottomRight('bottom right')
  ;

  /// The standard CSS position value.
  final String css;
  const RadialGradientPosition(this.css);
}

/// Defines center position for conic gradients.
enum ConicGradientPosition {
  /// Centered position (`center`).
  center('center'),

  /// Top center position (`top`).
  top('top'),

  /// Bottom center position (`bottom`).
  bottom('bottom'),

  /// Left center position (`left`).
  left('left'),

  /// Right center position (`right`).
  right('right'),

  /// Top-left corner (`top left`).
  topLeft('top left'),

  /// Top-right corner (`top right`).
  topRight('top right'),

  /// Bottom-left corner (`bottom left`).
  bottomLeft('bottom left'),

  /// Bottom-right corner (`bottom right`).
  bottomRight('bottom right')
  ;

  /// The standard CSS position value.
  final String css;
  const ConicGradientPosition(this.css);
}

/// Defines geometric shape types for components, gradients, and clippings.
enum Shape {
  /// Circular shape (`circle`).
  circle('circle'),

  /// Elliptical shape (`ellipse`).
  ellipse('ellipse'),

  /// Rectangular shape (`rectangle`).
  rectangle('rectangle'),

  /// Square shape (`square`).
  square('square'),

  /// Pill/capsule shape (`pill`).
  pill('pill'),

  /// Triangle shape (`triangle`).
  triangle('triangle')
  ;

  /// The standard CSS value representing the shape.
  final String css;
  const Shape(this.css);
}

/// How to size the non-positioned children of a Stack.
enum StackFit {
  /// The non-positioned children are allowed to take their intrinsic size.
  loose,

  /// The non-positioned children are forced to expand to fit the stack.
  expand,

  /// Sizing constraints are passed unmodified.
  passthrough,
}
