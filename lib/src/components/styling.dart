import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/extensions.dart';

// /////////////////////////////////////////////////////////////////////////////
// STYLING COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Bold}
/// A component that renders a bold text.
///
/// Example:
/// ```dart
/// const Bold('Important message')
/// ```
/// {@endtemplate}
class Bold extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  /// Additional text style.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the bold text.
  @override
  final String? classes;

  /// {@macro Bold}
  const Bold(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.combineWith(style).props;

    const baseClass = 'naki-bold naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return strong(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template Italic}
/// A component that renders an italic text.
///
/// Example:
/// ```dart
/// const Italic('Emphasized note')
/// ```
/// {@endtemplate}
class Italic extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  /// Additional text style.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the italic text.
  @override
  final String? classes;

  /// {@macro Italic}
  const Italic(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.combineWith(style).props;

    const baseClass = 'naki-italic naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return em(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template Underline}
/// A component that renders an underlined text.
///
/// Example:
/// ```dart
/// const Underline('Underlined text link')
/// ```
/// {@endtemplate}
class Underline extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  /// Additional text style.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the underline text.
  @override
  final String? classes;

  /// {@macro Underline}
  const Underline(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.combineWith(style).props;

    const baseClass = 'naki-underline naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return u(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template Strikethrough}
/// A component that renders a strikethrough text.
///
/// Example:
/// ```dart
/// const Strikethrough('$99.99')
/// ```
/// {@endtemplate}
class Strikethrough extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  /// Additional text style.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the strikethrough text.
  @override
  final String? classes;

  /// {@macro Strikethrough}
  const Strikethrough(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.combineWith(style).props;

    const baseClass = 'naki-strikethrough naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return s(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template Heading}
/// A component that renders a HTML heading level from `h1` to `h6`.
///
/// Example:
/// ```dart
/// const Heading(
///   'Section Title',
///   level: 2,
///   style: TextStyle(color: Colors.primary),
/// )
/// ```
/// {@endtemplate}
class Heading extends StatelessComponent with NakiTextScope {
  /// Heading text content.
  final String text;

  /// Heading level between 1 and 6 (default: 1).
  final int level;

  /// Additional text styles.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the heading text.
  @override
  final String? classes;

  /// {@macro Heading}
  const Heading(
    this.text, {
    super.key,
    this.level = 1,
    this.style,
    this.classes,
  }) : assert(
         level >= 1 && level <= 6,
         'level must be between 1 and 6',
       );

  @override
  Component build(BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseStyle.copyWith(margin: EdgeInsets.zero).combineWith(style).props;

    final baseClass = 'naki-text naki-heading-$level';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    switch (level) {
      case 1:
        return h1(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
      case 2:
        return h2(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
      case 3:
        return h3(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
      case 4:
        return h4(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
      case 5:
        return h5(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
      case 6:
      default:
        return h6(
          key: key,
          classes: effectiveClasses,
          styles: Styles(raw: effectiveStyles),
          [.text(text)],
        );
    }
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}

/// {@template SubHeading}
/// A component that renders a subtitle or sub-section text.
///
/// Example:
/// ```dart
/// const SubHeading('Overview and features')
/// ```
/// {@endtemplate}
class SubHeading extends StatelessComponent with NakiTextScope {
  /// Text content to display.
  final String text;

  /// Additional text style.
  @override
  final TextStyle? style;

  /// Additional CSS classes applied to the subheading.
  @override
  final String? classes;

  /// {@macro SubHeading}
  const SubHeading(
    this.text, {
    super.key,
    this.style,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final baseTextStyle = DefaultTextStyle.of(context);
    final effectiveStyles = baseTextStyle
        .copyWith(
          color: Tokens.current.subtitleColor.color,
          fontWeight: FontWeight.w400,
          margin: EdgeInsets.zero,
        )
        .combineWith(style)
        .props;

    const baseClass = 'naki-subheading naki-text';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    return h4(
      key: key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);
}
