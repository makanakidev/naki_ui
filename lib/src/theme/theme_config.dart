part of 'theme.dart';

/// {@template ThemeConfig}
/// Naki Theme Configuration for defining global
/// light and dark theme customizations.
///
/// Theme configuration should occur once at the top-level root
/// component (e.g. inside `main()` or in the root [NakiApp] or
/// [NakiThemeProvider.fromConfig] declaration).
///
/// #### Example: Basic Usage
/// ```dart
/// final _themeConfig = ThemeConfig(
///   initialMode: ThemeMode.system,
///   cacheThemeMode: true,
///   lightThemeData: LightThemeData(
///     colorSeed: ColorSeed(
///         green: Color('#10b981'),
///       ),
///     ),
///     darkModeThemeData: DarkThemeData(
///       colorSeed: ColorSeed(
///         green: Color('#059669'),
///       ),
///     ),
///   ),
/// );
///
/// void main() {
///   runApp(NakiThemeProvider.fromConfig(
///     configuration: _themeConfig,
///     builder: (context) => MyApp(),
///   ));
/// }
/// ```
/// {@endtemplate}
final class ThemeConfig {
  /// Customise light mode properties.
  final LightThemeData? lightThemeData;

  /// Customise dark mode properties.
  final DarkThemeData? darkThemeData;

  /// Enables theme mode caching and restoration across sessions.
  final bool cacheThemeMode;

  /// Initial theme mode.
  final ThemeMode initialMode;

  /// Scroll bar configuration.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Custom styles to add to the theme
  final List<StyleRule> styles;

  /// {@macro ThemeConfig}
  const ThemeConfig({
    this.initialMode = ThemeMode.system,
    this.cacheThemeMode = false,
    this.lightThemeData,
    this.darkThemeData,
    this.scrollBarConfiguration,
    this.styles = const [],
  });

  /// The default styles for theme modes
  static final defaultStyles = [
    css(':root').styles(
      raw: {
        Tokens.current.defaultStylesMarker.name:
            Tokens.current.defaultStylesMarker.value,
      },
    ),

    css(
      ':is(.naki-light-mode, html[data-naki-theme="light"])',
    ).styles(raw: const _LightModeTokens().variables),

    css.media(const MediaQuery.all(prefersColorScheme: ColorScheme.light), [
      css(
        ':is(.naki-system-mode, html[data-naki-theme="system"])',
      ).styles(raw: const _LightModeTokens().variables),
    ]),

    css(
      ':is(.naki-dark-mode, html[data-naki-theme="dark"])',
    ).styles(raw: const _DarkModeTokens().variables),

    css.media(const MediaQuery.all(prefersColorScheme: ColorScheme.dark), [
      css(
        ':is(.naki-system-mode, html[data-naki-theme="system"])',
      ).styles(raw: const _DarkModeTokens().variables),
    ]),
  ];
}
