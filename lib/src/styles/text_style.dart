import 'package:jaspr/dom.dart'
    show Color, Display, FontFamily, FontWeight, TextAlign, TextDecorationLine, TextOverflow;
import 'package:jaspr/jaspr.dart';

import '../models/naki.dart' show NakiStylable;
import '../models/styling.dart' show Dim, EdgeInsets;
import '../styles/css.dart' show Css;
import '../theme/tokens.dart' show Tokens;
import '../utilities/enums.dart' show FontStyle, TextDecorationStyle;
import '../utilities/extensions.dart' show CssPropsExtension, NumExtension;

/// A styling class for text that mimics Flutter's [TextStyle]
/// and converts to CSS styles.
class TextStyle implements NakiStylable {
  /// Color to use when painting the text (default: currentcolor)
  final Color? color;

  /// Display property of the text.
  final Display? display;

  /// Background color of text.
  final Color? backgroundColor;

  /// Size of glyphs when painting the text.
  final Dim? fontSize;

  /// Typeface thickness to use when painting the text.
  final FontWeight? fontWeight;

  /// Typeface style (e.g. italic) to use when painting the text.
  final FontStyle? fontStyle;

  /// Font family to use when painting the text (e.g. 'Inter', 'sans-serif').
  final FontFamily? fontFamily;

  /// Space to add between font glyphs.
  final Dim? letterSpacing;

  /// Space to add between words.
  final Dim? wordSpacing;

  /// Line height of the text.
  final Dim? lineHeight;

  /// Width of the text.
  final Dim? width;

  /// Text overflow behavior.
  final TextOverflow? overflow;

  /// Line decoration to paint on or near the text.
  final TextDecorationLine? decorationLine;

  /// Color in which to paint the text line decoration.
  final Color? decorationLineColor;

  /// Background color of text when selected.
  final Color? selectionBackgroundColor;

  /// Color of text when selected.
  final Color? selectionTextColor;

  /// Style in which to paint the text decoration (e.g. dashed).
  final TextDecorationStyle? decorationStyle;

  /// Thickness of the text decoration.
  final Dim? decorationThickness;

  /// Alignment of the text.
  final TextAlign? textAlign;

  /// Padding of the text.
  final EdgeInsets? padding;

  /// Margin of the text.
  final EdgeInsets? margin;

  /// If true, the text will be truncated with an ellipsis if it overflows.
  /// This property is ignored if `maxLines` is greater than 1.
  final bool truncate;

  /// If true, the text will be selectable.
  final bool selectable;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// Maximum lines of text to display. If null, the full text will
  /// be rendered, otherwise the text will be truncated with an ellipsis
  /// if it overflows more than the allowed lines.
  final int? maxLines;

  /// Additional CSS style properties applied to the text.
  final Map<String, String>? extra;

  /// Creates a new [TextStyle] with the given styling attributes.
  const TextStyle({
    this.truncate = false,
    this.selectable = false,
    this.softWrap = false,
    this.display,
    this.color,
    this.fontSize,
    this.backgroundColor,
    this.fontWeight,
    this.fontStyle,
    this.fontFamily,
    this.letterSpacing,
    this.wordSpacing,
    this.lineHeight,
    this.decorationLine,
    this.decorationLineColor,
    this.decorationStyle,
    this.decorationThickness,
    this.width,
    this.textAlign,
    this.maxLines,
    this.padding,
    this.margin,
    this.extra,
    this.selectionBackgroundColor,
    this.selectionTextColor,
    this.overflow,
  });

  /// Creates a copy of this text style with the existing style
  /// attributes replaced with the new values, while null attributes
  /// remain unchanged.
  TextStyle copyWith({
    Display? display,
    Color? color,
    Color? backgroundColor,
    bool? softWrap,
    Dim? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    FontFamily? fontFamily,
    Dim? letterSpacing,
    Dim? wordSpacing,
    Dim? lineHeight,
    Dim? width,
    TextDecorationLine? decorationLine,
    Color? decorationLineColor,
    TextDecorationStyle? decorationStyle,
    Dim? decorationThickness,
    TextAlign? textAlign,
    bool? truncate,
    bool? selectable,
    int? maxLines,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Map<String, String>? extra,
    Color? selectionBackgroundColor,
    Color? selectionTextColor,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      display: display ?? this.display,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      lineHeight: lineHeight ?? this.lineHeight,
      softWrap: softWrap ?? this.softWrap,
      width: width ?? this.width,
      decorationLine: decorationLine ?? this.decorationLine,
      decorationLineColor: decorationLineColor ?? this.decorationLineColor,
      decorationStyle: decorationStyle ?? this.decorationStyle,
      decorationThickness: decorationThickness ?? this.decorationThickness,
      textAlign: textAlign ?? this.textAlign,
      truncate: truncate ?? this.truncate,
      selectable: selectable ?? this.selectable,
      maxLines: maxLines ?? this.maxLines,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      selectionBackgroundColor: selectionBackgroundColor ?? this.selectionBackgroundColor,
      selectionTextColor: selectionTextColor ?? this.selectionTextColor,
      overflow: overflow ?? this.overflow,
      extra: (this.extra ?? {}).combine(extra ?? {}),
    );
  }

  /// Combines this text style with another text style.
  /// [other] is the style that takes precedence.
  TextStyle combineWith(TextStyle? other) {
    other ??= this;
    return TextStyle(
      truncate: other.truncate,
      softWrap: other.softWrap,
      selectable: other.selectable,
      display: other.display ?? display,
      color: other.color ?? color,
      fontSize: other.fontSize ?? fontSize,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      fontWeight: other.fontWeight ?? fontWeight,
      fontStyle: other.fontStyle ?? fontStyle,
      fontFamily: other.fontFamily ?? fontFamily,
      letterSpacing: other.letterSpacing ?? letterSpacing,
      wordSpacing: other.wordSpacing ?? wordSpacing,
      lineHeight: other.lineHeight ?? lineHeight,
      decorationLine: other.decorationLine ?? decorationLine,
      decorationLineColor: other.decorationLineColor ?? decorationLineColor,
      decorationStyle: other.decorationStyle ?? decorationStyle,
      decorationThickness: other.decorationThickness ?? decorationThickness,
      width: other.width ?? width,
      textAlign: other.textAlign ?? textAlign,
      maxLines: other.maxLines ?? maxLines,
      padding: other.padding ?? padding,
      margin: other.margin ?? margin,
      selectionBackgroundColor: other.selectionBackgroundColor ?? selectionBackgroundColor,
      selectionTextColor: other.selectionTextColor ?? selectionTextColor,
      overflow: other.overflow ?? overflow,
      extra: (extra ?? {}).combine(other.extra ?? {}),
    );
  }

  bool get _shouldTruncate => maxLines == 1 || (truncate && maxLines == null);

  bool get _shouldClamp => maxLines != null && maxLines! > 1;

  @override
  String get cssText => props.cssText;

  /// Converts the text style attributes to a CSS style map.
  @override
  Map<String, String> get props => {
    Tokens.current.selectedTextBgColor.name: ?selectionBackgroundColor?.value,
    Tokens.current.selectedTextColor.name: ?selectionTextColor?.value,
    'display': ?display?.value,
    'color': ?color?.value,
    'background-color': ?backgroundColor?.value,
    'font-size': ?fontSize?.cssText,
    'font-weight': ?fontWeight?.value,
    'font-style': ?fontStyle?.name,
    'font-family': ?fontFamily?.value,
    'width': ?width?.cssText,
    'letter-spacing': ?letterSpacing?.cssText,
    'word-spacing': ?wordSpacing?.cssText,
    'line-height': ?lineHeight?.cssText,
    'text-decoration-line': ?decorationLine?.value,
    'text-decoration-color': ?decorationLineColor?.value,
    'text-decoration-style': ?decorationStyle?.name,
    'text-decoration-thickness': ?decorationThickness?.cssText,
    'text-align': ?textAlign?.value,
    'user-select': selectable ? 'text' : 'none',
    'text-wrap-mode': ?(softWrap && !_shouldTruncate ? 'wrap' : null),
    'text-overflow': ?overflow?.value,
    ...?padding?.pProps,
    ...?margin?.mProps,
    ...?extra,
    if (_shouldTruncate) ...Css.nakiTextTruncateStyle,
    if (_shouldClamp) ...{
      Tokens.current.textMaxLines.name: maxLines!.toCleanString,
      ...Css.nakiTextClampStyle,
    },
  };
}

/// {@template DefaultTextStyle}
/// A Naki component that applies a default [style] to descendant Naki text
/// components in the component tree.
/// {@endtemplate}
class DefaultTextStyle extends InheritedComponent {
  /// The default text style to apply to descendant Naki text components.
  final TextStyle style;

  /// {@macro DefaultTextStyle}
  const DefaultTextStyle({
    super.key,
    required super.child,
    required this.style,
  });

  /// Finds the nearest [DefaultTextStyle] instance in the component tree.
  static DefaultTextStyle? _of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<DefaultTextStyle>();
  }

  /// Finds the nearest [DefaultTextStyle] instance in the component tree
  /// and returns its style.
  ///
  /// If no [DefaultTextStyle] is found, it returns a [TextStyle] instance
  /// with all properties set to their default values.
  static TextStyle of(BuildContext context) {
    return _of(context)?.style ?? const TextStyle();
  }

  @override
  bool updateShouldNotify(DefaultTextStyle oldComponent) => style != oldComponent.style;
}
