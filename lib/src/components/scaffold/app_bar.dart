part of 'index.dart';

/// {@template AppBar}
/// An app bar component that displays a title,
/// leading component, and actions.
///
/// ### Example
/// ```dart
/// AppBar(
///   title: NakiText('App Bar'),
///   actions: [
///     Button.icon(
///       Icons.search,
///       onTap: () {},
///     ),
///     Button.icon(
///       Icons.settings,
///       onTap: () {},
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class AppBar extends StatelessComponent {
  /// Primary component displayed in the app bar when `titleText` is null.
  final Component? title;

  /// Text displayed in the app bar when `title` is null.
  final String? titleText;

  /// Style applied to `titleText` when not null.
  final TextStyle? titleStyle;

  /// Width of the app bar.
  final Dim? width;

  /// Height of the app bar.
  final Dim? height;

  /// Removes app bar shadow when `true`.
  final bool removeShadow;

  /// Enables background blur effect when `true`
  /// and ignored if [fixed] is `false`.
  final bool blurBackground;

  /// Enables fixed app bar during scroll when `true`.
  ///
  /// Ignored if app bar is not assigned to [Scaffold.appBar].
  final bool fixed;

  /// Component displayed before `title` or `titleText`.
  ///
  /// Usually a [Button] for navigation, menu, etc.
  final Component? leading;

  /// Components displayed after `title` or `titleText`.
  ///
  /// Usually [Button]s for search, settings, etc.
  final List<Component>? actions;

  /// Background color of the app bar.
  final Color? backgroundColor;

  /// Background gradient of the app bar.
  ///
  /// ### Example
  /// ```dart
  /// AppBar(
  ///   titleText: 'Gradient AppBar',
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.purple]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Custom CSS classes applied to the app bar.
  final String? classes;

  /// {@macro AppBar}
  const AppBar({
    super.key,
    this.removeShadow = false,
    this.blurBackground = true,
    this.fixed = true,
    this.height,
    this.width,
    this.title,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.gradient,
    this.classes,
    this.titleText,
    this.titleStyle,
  });

  @override
  Component build(BuildContext context) {
    final effectiveActions = actions != null && actions!.isNotEmpty
        ? div(classes: 'naki-appbar-actions', actions!)
        : null;

    final effectiveTitle = titleText.isNotNullAndEmpty
        ? NakiText(titleText!, classes: 'naki-appbar-title', style: titleStyle)
        : title;

    const baseClass = 'naki-appbar';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      Tokens.current.appbarBgColor.name: ?backgroundColor?.value,
      Tokens.current.appbarHeight.name: ?height?.cssText,
      'width': ?width?.cssText,
      'box-shadow': ?(removeShadow ? 'none' : null),
      ...?gradient?.props,
    };

    return .element(
      key: key,
      tag: 'naki-appbar',
      classes: effectiveClasses,
      attributes: {
        'role': 'banner',
        'fixed': '$fixed',
        'blur': '${blurBackground && fixed ? true : false}',
      },
      styles: Styles(raw: effectiveStyles),
      children: [?leading, ?effectiveTitle, ?effectiveActions],
    );
  }

  static List<StyleRule> get styles => ScaffoldStyles.appBar;
}
