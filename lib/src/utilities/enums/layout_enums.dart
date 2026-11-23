part of 'index.dart';

typedef Position = Placement;
typedef ImagePosition = ObjectPosition;
typedef ImageFit = ObjectFit;
typedef Ratio = AspectRatioType;

/// Represents placement/position of a component relative to another.
enum Placement {
  /// Place above another component.
  top,

  /// Place to the right of another component.
  right,

  /// Place below another component.
  bottom,

  /// Place to the left of another component.
  left,
}

/// Represents standard display aspect ratios.
enum AspectRatioType {
  /// 16:9 widescreen ratio (e.g. standard HD TVs).
  ratio16_9('16/9'),

  /// 4:3 standard display ratio (e.g. standard definition TVs).
  ratio4_3('4/3'),

  /// 1:1 square ratio (e.g. profile photos).
  ratio1_1('1/1'),

  /// 3:2 standard ratio (e.g. 3x2 or 6x4 photos).
  ratio3_2('3/2'),

  /// 9:16 vertical content ratio (e.g. reels, shorts, stories).
  ratio9_16('9/16'),

  /// 4:5 content ratio (e.g. instagram post).
  ratio4_5('4/5'),

  /// 21:9 cinematic ratio (e.g. ultrawide monitors).
  ratio21_9('21/9'),

  /// 1:2 vertical ratio (e.g. phone screenshots).
  ratio1_2('1/2')
  ;

  /// Suitable for Instagram stories, Instagram reels,
  /// YouTube shorts, TikTok videos related content.
  static const stories = AspectRatioType.ratio9_16;

  /// Suitable for Instagram posts related content.
  static const instagramPost = AspectRatioType.ratio4_5;

  /// Suitable for YouTube videos, Twitter videos,
  /// LinkedIn videos, Facebook videos related content.
  static const youtubeVideo = AspectRatioType.ratio16_9;

  /// Suitable for cinematic movies related content.
  static const cinematic = AspectRatioType.ratio21_9;

  /// Suitable for icons, avatars, logos related content.
  static const profile = AspectRatioType.ratio1_1;

  /// The standard CSS value representing the ratio type.
  final String css;
  const AspectRatioType(this.css);
}

/// Represents the style of glyphs in a font (upright vs. italicized).
enum FontStyle {
  /// Use upright glyphs.
  normal,

  /// Use glyphs designed for slanting (italicized).
  italic,
}

/// Represents the layout direction of a component.
enum Direction {
  /// Lay out children vertically.
  vertical,

  /// Lay out children horizontally.
  horizontal,
}

/// Represents the orientation of the browser viewport or a component.
enum Orientation {
  /// Lay out children vertically.
  portrait,

  /// Lay out children horizontally.
  landscape,

  /// Unknown orientation.
  unknown,
}

/// Represents the style of text decoration lines.
enum TextDecorationStyle {
  /// Draw a single solid line.
  solid,

  /// Draw a double line.
  double,

  /// Draw a dotted line.
  dotted,

  /// Draw a dashed line.
  dashed,

  /// Draw a wavy line.
  wavy,

  /// The border appears raised depending on the
  /// `border-style` and `border-color` properties.
  ridge,

  /// The border appears indented depending on the
  /// `border-style` and `border-color` properties.
  groove,

  /// Display no border.
  none,

  /// The border appears as if it is coming out of the page.
  outset,

  /// The border appears as if it is going into the page.
  inset,
}

/// How the children within a Flex container (Row or Column)
/// should be placed along the main axis.
enum MainAxisAlignment {
  /// Place the children as close to the start of the main axis as possible.
  start,

  /// Place the children as close to the end of the main axis as possible.
  end,

  /// Place the children as close to the middle of the main axis as possible.
  center,

  /// Place the free space evenly between the children.
  spaceBetween,

  /// Place the free space evenly between the children as well
  /// as half of that space before the first and after the last child.
  spaceAround,

  /// Place the free space evenly between the children
  /// as well as before the first and after the last child.
  spaceEvenly,
}

/// How the children within a Flex container (Row or Column)
/// should be placed along the cross axis.
enum CrossAxisAlignment {
  /// Place the children with their start edges aligned
  /// with the start side of the cross axis.
  start,

  /// Place the children as close to the end of the cross axis as possible.
  end,

  /// Place the children aligned with the middle of the cross axis.
  center,

  /// Require the children to fill the cross axis.
  stretch,

  /// Align the children along their baselines.
  baseline,
}

/// How much space should be occupied by the main
/// axis in a Flex container (Row or Column).
enum MainAxisSize {
  /// Minimize the amount of free space along the main axis.
  min,

  /// Maximize the amount of free space along the main axis.
  max,
}

/// How a flexible child component sizes itself along the main axis in a
/// Flex container Row or Column.
enum FlexFit {
  /// The child is forced to expand to fill the available space along
  /// the main axis.
  tight,

  /// The child can be at most as large as the available space along
  /// the main axis (and may begin smaller).
  loose,
}

/// How a media content (like an image) should fit within its bounds.
enum ObjectFit {
  /// Fill the target box by distorting the image's aspect ratio.
  fill('fill'),

  /// As large as possible while still containing the
  /// image within the target box.
  contain('contain'),

  /// As small as possible while still covering the entire target box.
  cover('cover'),

  /// Display the image's source at its natural size.
  none('none'),

  /// Align the image within the target box and,
  /// if necessary, scale the image down to fit.
  scaleDown('scale-down')
  ;

  /// The standard CSS value representing the object-fit type.
  final String css;
  const ObjectFit(this.css);
}

/// How a media content (like an image) should be positioned
/// within its bounds.
enum ObjectPosition {
  /// Positions the media content at its center point.
  center('center'),

  /// Positions the media content at the top edge, centered horizontally.
  topCenter('top center'),

  /// Positions the media content at the bottom edge, centered horizontally.
  bottomCenter('bottom center'),

  /// Positions the media content at the center of the left edge.
  centerLeft('left center'),

  /// Positions the media content at the center of the right edge.
  centerRight('right center'),

  /// Positions the media content at the top-left corner.
  topLeft('top left'),

  /// Positions the media content at the top-right corner.
  topRight('top right'),

  /// Positions the media content at the bottom-left corner.
  bottomLeft('bottom left'),

  /// Positions the media content at the bottom-right corner.
  bottomRight('bottom right')
  ;

  /// The standard CSS value representing the object-position type.
  final String css;
  const ObjectPosition(this.css);
}

/// Alignment points relative to a 2D box.
enum Alignment {
  /// The top-left corner.
  topLeft('top-left'),

  /// The top edge, centered horizontally.
  topCenter('top-center'),

  /// The top-right corner.
  topRight('top-right'),

  /// The center of the left edge.
  centerLeft('center-left'),

  /// The center point.
  center('center'),

  /// The center of the right edge.
  centerRight('center-right'),

  /// The bottom-left corner.
  bottomLeft('bottom-left'),

  /// The bottom edge, centered horizontally.
  bottomCenter('bottom-center'),

  /// The bottom-right corner.
  bottomRight('bottom-right')
  ;

  /// The standard CSS value representing the alignment type.
  final String value;
  const Alignment(this.value);
}
