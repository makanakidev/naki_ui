import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/app.dart' show NakiApp;
import '../framework/framework.dart' show NakiStatefulMixin;
import '../framework/inherited.dart'
    show AppScope, NakiDomIdRegistry, NakiDomIdScope;
import '../framework/lifecycle.dart' show BrowserLifecycleListeners;
import '../models/naki.dart' show ScrollBarConfiguration;
import '../models/styling.dart' show Dim;
import '../styles/rules.dart';
import '../utilities/enums.dart' show Brightness, ThemeMode;
import '../utilities/helpers.dart' show updateRootTheme;
import '../utilities/storage.dart';

import 'tokens.dart';

// /////////////////////////////////////////////////////////////////////////////
// NAKI THEME COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template NakiThemeProvider}
/// A Naki component that propagates theme state down the component tree.
///
/// * Enables switching between theme modes.
/// * Caches theme mode and restores it in subsequent sessions.
/// * Can be used as the root component of a Jaspr application or
/// wrap a Naki component to access and use theme-specific styles.
///
/// **For a more robust theme management, consider using [NakiApp] or
/// [NakiThemeProvider.fromConfig] constructor in a `@client` annotated
/// component.**
///
/// ### Example
///
/// ```dart
/// @override
/// Component build(BuildContext context) {
///   return NakiThemeProvider(
///     mode: ThemeMode.light,
///     builder: (context) => const Scaffold(
///       body: NakiText('Hello world'),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
class NakiThemeProvider extends StatefulComponent {
  /// Initial theme mode (default is [ThemeMode.system]).
  final ThemeMode mode;

  /// Allow theme mode caching and restoration on page loads.
  ///
  /// When [configuration] is provided, this value is ignored and
  /// [ThemeConfig.cacheThemeMode] value is used instead.
  final bool enableCache;

  /// [ThemeConfig] enables you to customize theme by:
  ///
  /// * setting custom light and dark mode styles
  /// * providing additional custom styles
  /// * overriding the default theme
  /// * enabling theme caching and restoration
  final ThemeConfig? configuration;

  /// Child component subtree.
  final ComponentBuilder builder;

  /// Optional callback executed when theme mode changes.
  final ValueChanged<ThemeMode>? onModeChanged;

  /// {@macro NakiThemeProvider}
  const NakiThemeProvider({
    required this.builder,
    this.mode = ThemeMode.system,
    this.onModeChanged,
    super.key,
  }) : enableCache = false,
       configuration = null;

  /// Creates a [NakiThemeProvider] instance using [ThemeConfig].
  ///
  /// This is the recommended constructor when you need to customize
  /// light and dark mode theme tokens.
  ///
  /// **NOTE: Do not use this constructor if theme configuration is already
  /// handled by [NakiApp] because there can only be one instance of
  /// [ThemeConfig] in an application.**
  NakiThemeProvider.fromConfig({
    required this.configuration,
    required this.builder,
    super.key,
  }) : onModeChanged = null,
       mode = configuration?.initialMode ?? ThemeMode.system,
       enableCache = configuration?.cacheThemeMode ?? false;

  /// Finds the nearest [InheritedTheme] instance in the component tree.
  /// This scans the component tree upwards from the parent of [context]
  /// until it finds an instance of [InheritedTheme].
  ///
  /// Returns `null` if no [InheritedTheme] is in the component tree.
  static InheritedTheme? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<InheritedTheme>();
  }

  /// Toggles the current theme mode.
  ///
  /// Returns `true` if successful, `false` if no [NakiThemeProvider]
  /// is in the component tree.
  static bool toggleMode(BuildContext context) {
    final state = of(context);
    if (state == null) return false;
    state.toggleMode();
    return true;
  }

  /// Sets theme mode to the provided mode.
  ///
  /// Returns `true` if successful, `false` if no [NakiThemeProvider]
  /// is in the component tree.
  static bool setMode(BuildContext context, ThemeMode mode) {
    final state = of(context);
    if (state == null) return false;
    state.setMode(mode);
    return true;
  }

  /// Brightness of the active theme relative to the [context].
  ///
  /// Returns [Brightness.light] if no [NakiThemeProvider]
  /// is in the component tree.
  static Brightness brightnessOf(BuildContext context) {
    return of(context)?.brightness ?? Brightness.light;
  }

  /// System brightness is only available in client-side.
  ///
  /// Returns `null` in server-side or when no [NakiThemeProvider]
  /// is in the component tree.
  static Brightness? systemBrightness(BuildContext context) =>
      of(context)?.systemBrightness;

  /// Design tokens of the active theme relative to the [context].
  ///
  /// Returns global tokens for backward compatibility if no
  /// [NakiThemeProvider] is in the component tree.
  static Tokens tokensOf(BuildContext context) =>
      of(context)?.tokens ?? Tokens.current;

  @override
  State<NakiThemeProvider> createState() => _NakiThemeProviderState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('NakiFoundationRules', Rules.nakiFoundationRules);
}

class _NakiThemeProviderState extends State<NakiThemeProvider>
    with NakiStatefulMixin {
  late Tokens _tokens;

  ThemeMode _mode = ThemeMode.system;
  Brightness _brightness = Brightness.light;

  ThemeConfig? _config;
  Brightness? _systemBrightness;

  bool _isRoot = false;
  bool _allowCache = false;

  final BrowserLifecycleListeners _lifecycle = BrowserLifecycleListeners();
  final _domIdRegistry = NakiDomIdRegistry();

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _initializeTheme();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (_isRoot) {
      _lifecycle.whenSystemThemeChanged = (mode) {
        _systemBrightness = mode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light;

        if (_mode == ThemeMode.system) {
          _brightness = _systemBrightness!;

          _tokens = _brightness == Brightness.dark
              ? (_config?.darkThemeData ?? const _DarkModeTokens())
              : (_config?.lightThemeData ?? const _LightModeTokens());
        }

        setState(() {});
      };

      _lifecycle.register();
    }

    return _lifecycle.dispose;
  }

  @override
  void didUpdateComponent(NakiThemeProvider oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.mode != component.mode ||
        oldComponent.configuration != component.configuration) {
      _initializeTheme(true);
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Returns the brightness of the active theme.
  Brightness get brightness => _brightness;

  /// Returns the browser's brightness preference.
  /// Returns `null` in server-side.
  Brightness? get systemBrightness => _systemBrightness;

  /// Returns the current theme tokens.
  Tokens get tokens => _tokens;

  /// Initialize theme data from component properties.
  void _initializeTheme([bool refresh = false]) {
    // set theme mode
    _mode = component.mode;

    // set configuration
    _config = component.configuration;

    // determine if this is the root theme component
    _isRoot = _config != null;

    // set cache flag
    _allowCache = component.enableCache;

    // sync tokens
    _syncTokens(refresh: refresh);
  }

  /// Set new theme mode.
  void setMode(ThemeMode newMode) {
    if (_mode == newMode) return;

    _mode = newMode;
    _syncTokens(refresh: true);

    component.onModeChanged?.call(_mode);
    setState(() {});
  }

  /// Toggle theme mode (light <-> dark <-> system).
  void toggleMode() {
    setMode(
      _mode == ThemeMode.dark
          ? ThemeMode.light
          : _mode == ThemeMode.light
          ? ThemeMode.system
          : ThemeMode.dark,
    );
  }

  /// Sync tokens.
  void _syncTokens({bool refresh = false}) {
    // restore cached theme if enabled
    if (_allowCache && kIsWeb) {
      final cachedTheme = _getCachedTheme(refresh);
      if (_mode != cachedTheme) _mode = cachedTheme;
    }

    // update brightness
    _brightness = _mode == ThemeMode.dark
        ? Brightness.dark
        : _mode == ThemeMode.light
        ? Brightness.light
        : (_systemBrightness ?? Brightness.light);

    // update tokens
    final lmTokens = _config?.lightThemeData ?? const _LightModeTokens();
    final dmTokens = _config?.darkThemeData ?? const _DarkModeTokens();

    _tokens = switch (_mode) {
      ThemeMode.dark => dmTokens,
      ThemeMode.light => lmTokens,
      ThemeMode.system => _brightness == Brightness.dark ? dmTokens : lmTokens,
    };

    if (refresh) updateRootTheme(_mode.name);
  }

  /// Get cached theme from local storage. If not found,
  /// set it to [_mode] and return it.
  ThemeMode _getCachedTheme([bool refresh = false]) {
    final cached = NakiStorage.get<String>('theme-mode');

    if (cached == null || refresh) {
      NakiStorage.set('theme-mode', _mode.name);
      return _mode;
    }

    return ThemeMode.from(cached);
  }

  @override
  Component build(BuildContext context) {
    final lmTokens = _config?.lightThemeData;
    final dmTokens = _config?.darkThemeData;
    final scrollBarConfig = _config?.scrollBarConfiguration;
    final hasCustomTokens = lmTokens != null || dmTokens != null;

    final styles = <StyleRule>[];
    final baseStyles = ThemeConfig.defaultStyles;
    final hasNakiApp = AppScope.of(context) != null;

    // Set default styles if NakiApp is not in the component tree and this
    // provider is the top-level theme component without custom tokens
    if (!hasNakiApp && !hasCustomTokens) {
      // scroll bar styles
      if (scrollBarConfig != null) {
        styles.addAll(Rules.buildScrollbarRules('html', scrollBarConfig));
      }

      // default styles
      styles.addAll(baseStyles);

      // custom styles
      styles.addAll(_config?.styles ?? []);
    }

    // Set custom theme styles if tokens are provided
    if (hasCustomTokens) {
      // scroll bar styles
      if (scrollBarConfig != null) {
        styles.addAll(Rules.buildScrollbarRules('html', scrollBarConfig));
      }

      // light mode styles
      if (lmTokens != null) {
        styles.addAll([
          css(
            ':is(.naki-light-mode, html[data-naki-theme="light"])',
          ).styles(raw: lmTokens.variables),

          css.media(
            const MediaQuery.all(prefersColorScheme: ColorScheme.light),
            [
              css(
                ':is(.naki-system-mode, html[data-naki-theme="system"])',
              ).styles(raw: lmTokens.variables),
            ],
          ),
        ]);
      } else {
        styles.addAll([baseStyles[1], baseStyles[2]]);
      }

      // dark mode styles
      if (dmTokens != null) {
        styles.addAll([
          css(
            ':is(.naki-dark-mode, html[data-naki-theme="dark"])',
          ).styles(raw: dmTokens.variables),

          css.media(
            const MediaQuery.all(prefersColorScheme: ColorScheme.dark),
            [
              css(
                ':is(.naki-system-mode, html[data-naki-theme="system"])',
              ).styles(raw: dmTokens.variables),
            ],
          ),
        ]);
      } else {
        styles.addAll([baseStyles[3], baseStyles[4]]);
      }

      // custom styles
      styles.addAll(_config?.styles ?? []);
    }

    final themedContent = InheritedTheme(
      mode: _mode,
      tokens: _tokens,
      brightness: _brightness,
      systemBrightness: _systemBrightness,
      onSetMode: setMode,
      onToggleMode: toggleMode,
      child: _ThemeBuilder(
        mode: _mode,
        styles: styles,
        builder: component.builder,
        hasConfig: _isRoot,
      ),
    );

    if (NakiDomIdScope.maybeOf(context) != null) return themedContent;

    return NakiDomIdScope(registry: _domIdRegistry, child: themedContent);
  }
}

/// Inherited theme component propagated down the component tree.
class InheritedTheme extends InheritedComponent {
  /// Active theme mode.
  final ThemeMode mode;

  /// Design tokens for the active theme.
  final Tokens tokens;

  /// Brightness preference of the browser.
  /// Returns `null` in server mode.
  final Brightness? systemBrightness;

  /// Brightness of the active theme.
  final Brightness brightness;

  /// Callback to set theme mode.
  final ValueChanged<ThemeMode> _onSetMode;

  /// Callback to toggle theme mode.
  final VoidCallback _onToggleMode;

  /// Creates an [InheritedTheme] instance.
  const InheritedTheme({
    super.key,
    required this.mode,
    required this.tokens,
    required super.child,
    required this.brightness,
    this.systemBrightness,
    required ValueChanged<ThemeMode> onSetMode,
    required VoidCallback onToggleMode,
  }) : _onSetMode = onSetMode,
       _onToggleMode = onToggleMode;

  /// Toggles the theme mode between light, dark, and system.
  void toggleMode() => _onToggleMode();

  /// Sets the theme mode to the provided mode.
  void setMode(ThemeMode mode) => _onSetMode(mode);

  @override
  bool updateShouldNotify(InheritedTheme oldComponent) {
    return oldComponent.mode != mode ||
        oldComponent.tokens != tokens ||
        oldComponent.brightness != brightness ||
        oldComponent.systemBrightness != systemBrightness;
  }
}

class _LocalThemeBuilder extends StatelessComponent {
  final ComponentBuilder builder;
  final ThemeMode mode;

  const _LocalThemeBuilder({required this.builder, required this.mode});

  @override
  Component build(BuildContext context) => .wrapElement(
    child: builder(context),
    classes: switch (mode) {
      ThemeMode.light => 'naki-light-mode',
      ThemeMode.dark => 'naki-dark-mode',
      _ => 'naki-system-mode',
    },
  );
}

class _ThemeBuilder extends StatelessComponent {
  final List<StyleRule> styles;
  final ComponentBuilder builder;
  final ThemeMode mode;
  final bool hasConfig;

  _ThemeBuilder({
    required this.styles,
    required this.builder,
    required this.mode,
    this.hasConfig = false,
  });

  @override
  Component build(BuildContext context) {
    final child = hasConfig
        ? builder(context)
        : _LocalThemeBuilder(builder: builder, mode: mode);

    return styles.isEmpty
        ? child
        : .fragment([
            Document.head(children: [StyleRules(styles, id: 'tokens')]),
            child,
          ]);
  }
}

// /////////////////////////////////////////////////////////////////////////////
// NAKI THEME MODE TOKENS
// /////////////////////////////////////////////////////////////////////////////

/// Default light theme mode tokens extending [Tokens].
class _LightModeTokens extends Tokens {
  /// Creates a [_LightModeTokens] instance.
  const _LightModeTokens([super.customVariables]);

  @override
  String get colorScheme => 'light';
}

/// Dark theme mode tokens extending [Tokens], overriding
/// color-related variables for dark theme.
class _DarkModeTokens extends Tokens {
  /// Creates a [_DarkModeTokens] instance.
  const _DarkModeTokens([super.customVariables]);

  @override
  String get colorScheme => 'dark';

  // Brand Color Overrides

  @override
  String get primaryColorValue => '#3182ce';

  @override
  String get secondaryColorValue => '#64748b';

  @override
  String get accentColorValue => '#059669';

  // Base Color Overrides

  /// Green accent color (dark: `#4ade80`).
  @override
  String get greenValue => '#4ade80';

  /// Yellow accent color (dark: `#fbbf24`).
  @override
  String get yellowValue => '#fbbf24';

  /// Red accent color (dark: `#ff3d00`).
  @override
  String get redValue => '#ff3d00';

  /// Default text placeholder color (dark: `#94a3b8`).
  @override
  String get placeholderColorValue => '#94a3b8';

  /// Muted background/foreground color (dark: `#94a3b8`).
  @override
  String get mutedColorValue => '#94a3b8';

  /// Subtitle or secondary text color (dark: `#94a3b8`).
  @override
  String get subtitleColorValue => '#94a3b8';

  /// Selected item color for dropdowns and list items (dark: `#0f172a`).
  @override
  String get selectedItemColorValue => '#0f172a';

  /// Selected text background color (dark: `#60a5fa`).
  @override
  String get selectedTextBgColorValue => '#60a5fa';

  /// Selected text color (dark: `#0f172a`).
  @override
  String get selectedTextColorValue => '#0f172a';

  /// Selected item background color for dropdowns
  /// and list items (dark: `#60a5fa`).
  @override
  String get selectedItemBgColorValue => '#60a5fa';

  /// Root background color (dark: `#0f172a`).
  @override
  String get backgroundColorValue => '#0f172a';

  /// Default border color (dark: `#64748b`).
  @override
  String get borderColorValue => '#64748b';

  /// Error state color (dark: `#f43f5e`).
  @override
  String get errorColorValue => '#f43f5e';

  /// Success state color (dark: `#4ade80`).
  @override
  String get successColorValue => '#4ade80';

  /// Warning state color (dark: `#fbbf24`).
  @override
  String get warningColorValue => '#fbbf24';

  /// Info state color (dark: `#60a5fa`).
  @override
  String get infoColorValue => '#60a5fa';

  /// Weak background color for error/alert callouts (dark: `#3f1d24`).
  @override
  String get errorWeakColorValue => '#3f1d24';

  /// Weak background color for success callouts (dark: `#132e19`).
  @override
  String get successWeakColorValue => '#132e19';

  /// Weak background color for warning callouts (dark: `#362415`).
  @override
  String get warningWeakColorValue => '#362415';

  /// Weak background color for info callouts (dark: `#162a3d`).
  @override
  String get infoWeakColorValue => '#162a3d';

  /// Secondary surface background color variation (dark: `#334155`).
  @override
  String get surfaceVariantColorValue => '#334155';

  /// Muted background color for container surfaces (dark: `#1e293b`).
  @override
  String get surfaceMutedColorValue => '#1e293b';

  // Shadow Color Overrides

  /// Default shadow color (dark: `rgba(0, 0, 0, 0.4)`).
  @override
  String get shadowColorValue => 'rgba(0, 0, 0, 0.4)';

  /// Small shadow color (dark: `rgba(0, 0, 0, 0.3)`).
  @override
  String get smallShadowColorValue => 'rgba(0, 0, 0, 0.3)';

  /// Medium shadow color (dark: `rgba(0, 0, 0, 0.5)`).
  @override
  String get mediumShadowColorValue => 'rgba(0, 0, 0, 0.5)';

  /// Large shadow color (dark: `rgba(0, 0, 0, 0.6)`).
  @override
  String get largeShadowColorValue => 'rgba(0, 0, 0, 0.6)';

  // State Color Overrides

  /// Hover background color for buttons (dark: `#334155`).
  @override
  String get buttonHoverBgColorValue => '#334155';

  /// Hover color for components (dark: `#334155`).
  @override
  String get hoverColorValue => '#334155';

  /// Border color for focused components (dark: `#60a5fa`).
  @override
  String get focusBorderColorValue => '#60a5fa';

  /// Border color for hovered form fields (dark: `#64748b`).
  @override
  String get fieldHoverColorValue => '#64748b';

  /// Background color for disabled components (dark: `#334155`).
  @override
  String get disabledBgColorValue => '#334155';

  /// Foreground color for disabled components (dark: `#94a3b8`).
  @override
  String get disabledColorValue => '#94a3b8';

  // Component Color Overrides

  /// Background color for dropdown menu (dark: `#1e293b`).
  @override
  String get dropdownMenuBgColorValue => '#1e293b';

  /// Text color inside input fields (dark: `#f8fafc`).
  @override
  String get inputTextColorValue => '#f8fafc';

  /// Form field label color (dark: `#94a3b8`).
  @override
  String get labelColorValue => '#94a3b8';

  /// Base text color (dark: `#f8fafc`).
  @override
  String get baseTextColorValue => '#f8fafc';

  /// Button background color (dark: `#1e293b`).
  @override
  String get buttonBackgroundColorValue => '#1e293b';

  /// Button foreground color (dark: `#f8fafc`).
  @override
  String get buttonColorValue => '#f8fafc';

  /// Form field background color (dark: `#1e293b`).
  @override
  String get fieldBackgroundColorValue => '#1e293b';

  // Selection Component Overrides

  /// Slider thumb color (dark: `currentcolor`).
  @override
  String get sliderThumbColorValue => 'currentcolor';

  /// Slider track color (dark: opacity 70%).
  @override
  String get sliderTrackColorValue =>
      'color-mix(in srgb, currentcolor 70%, transparent)';

  /// Switch thumb color (dark: `currentcolor`).
  @override
  String get switchThumbColorValue => 'currentcolor';

  /// Radio button color (dark: `currentcolor`).
  @override
  String get radioBtnColorValue => 'currentcolor';

  /// Appbar background color (dark: `#1e293b`).
  @override
  String get appbarBgColorValue => '#1e293b';

  /// Bottom navbar background color (dark: `#1e293b`).
  @override
  String get bottomNavbarBgColorValue => '#1e293b';

  // Scrolling Component Overrides

  /// Table header background color (dark: `transparent`).
  @override
  String get tableHeaderBgValue => 'transparent';

  /// Table row hover background color (dark: `transparent`).
  @override
  String get tableRowHoverBgValue => 'transparent';

  /// Table header border color (dark: `"#64748b"`).
  @override
  String get tableHeaderBorderColorValue => '#64748b';

  // Spinner Component Overrides

  /// Spinner track color (dark: `rgba(255, 255, 255, 0.15)`).
  @override
  String get spinnerTrackColorValue => 'rgba(255, 255, 255, 0.15)';

  /// Spinner glass surface color (dark: `#1e293b`).
  @override
  String get spinnerSurfaceColorValue => '#1e293b';

  // Overlay Component Overrides

  /// Snackbar background color (dark: `#1e293b`).
  @override
  String get snackbarBgColorValue => '#1e293b';

  /// Snackbar foreground color (dark: `#f8fafc`).
  @override
  String get snackbarForegroundColorValue => '#f8fafc';

  /// Banner background color (dark: `#1e293b`).
  @override
  String get bannerBgColorValue => '#1e293b';

  /// Banner foreground color (dark: `#f8fafc`).
  @override
  String get bannerForegroundColorValue => '#f8fafc';

  /// Banner border color (dark: `#64748b`).
  @override
  String get bannerBorderColorValue => '#64748b';

  /// Tooltip background color (dark: `#334155`).
  @override
  String get tooltipBgColorValue => '#334155';

  /// Tooltip text color (dark: `#f8fafc`).
  @override
  String get tooltipTextColorValue => '#f8fafc';

  /// Popover background color (dark: `#1e293b`).
  @override
  String get popoverBgColorValue => '#1e293b';

  /// Popover text color (dark: `#f8fafc`).
  @override
  String get popoverTextColorValue => '#f8fafc';

  /// Popover border color (dark: `#334155`).
  @override
  String get popoverBorderColorValue => '#334155';

  /// Popover box shadow
  /// (dark: `0 10px 15px -3px rgba(0, 0, 0, 0.4),
  /// 0 4px 6px -4px rgba(0, 0, 0, 0.4)`).
  @override
  String get popoverShadowValue =>
      '0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -4px rgba(0, 0, 0, 0.4)';

  /// Dialog background color (dark: `#1e293b`).
  @override
  String get dialogBgColorValue => '#1e293b';

  /// Dialog barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get dialogBarrierBgValue => 'rgba(0, 0, 0, 0.7)';

  /// Drawer background color (dark: `#1e293b`).
  @override
  String get drawerBgColorValue => '#1e293b';

  /// Drawer barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get drawerBarrierBgValue => 'rgba(0, 0, 0, 0.7)';

  /// BottomSheet background color (dark: `#1e293b`).
  @override
  String get bottomSheetBgColorValue => '#1e293b';

  /// BottomSheet barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get bottomSheetBarrierBgValue => 'rgba(0, 0, 0, 0.7)';
}

// /////////////////////////////////////////////////////////////////////////////
// NAKI THEME CONFIG (USER MODIFIABLE)
// /////////////////////////////////////////////////////////////////////////////

/// Helper function to compare two lists for equality.
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Represents customizable base and semantic color variables.
class ColorSeed {
  /// Primary color.
  final Color? primary;

  /// Secondary color.
  final Color? secondary;

  /// Accent color.
  final Color? accent;

  /// Accent green color.
  final Color? green;

  /// Accent yellow color.
  final Color? yellow;

  /// Accent red color.
  final Color? red;

  /// Base text color.
  final Color? baseTextColor;

  /// Default text placeholder color.
  final Color? placeholderColor;

  /// Muted background/foreground color.
  final Color? mutedColor;

  /// Subtitle or secondary text color.
  final Color? subtitleColor;

  /// Selected item color for dropdowns and list items.
  final Color? selectedItemColor;

  /// Selected text background color.
  final Color? selectedTextBackgroundColor;

  /// Selected text color.
  final Color? selectedTextColor;

  /// Selected item background color for dropdown items.
  final Color? selectedItemBackgroundColor;

  /// Root background color.
  final Color? backgroundColor;

  /// Error state color.
  final Color? errorColor;

  /// Success state color.
  final Color? successColor;

  /// Warning state color.
  final Color? warningColor;

  /// Info state color.
  final Color? infoColor;

  /// Weak background color for error callouts.
  final Color? errorWeakColor;

  /// Weak background color for success callouts.
  final Color? successWeakColor;

  /// Weak background color for warning callouts.
  final Color? warningWeakColor;

  /// Weak background color for info callouts.
  final Color? infoWeakColor;

  /// Secondary surface background color variation.
  final Color? surfaceVariantColor;

  /// Muted background color for container surfaces.
  final Color? surfaceMutedColor;

  /// Border color for focused components.
  final Color? focusBorderColor;

  /// Hover color for components.
  final Color? hoverColor;

  /// Background color for disabled components.
  final Color? disabledBackgroundColor;

  /// Color for disabled components.
  final Color? disabledColor;

  const ColorSeed({
    this.primary,
    this.secondary,
    this.accent,
    this.green,
    this.yellow,
    this.red,
    this.baseTextColor,
    this.placeholderColor,
    this.mutedColor,
    this.subtitleColor,
    this.selectedItemColor,
    this.selectedTextBackgroundColor,
    this.selectedTextColor,
    this.selectedItemBackgroundColor,
    this.backgroundColor,
    this.errorColor,
    this.successColor,
    this.warningColor,
    this.infoColor,
    this.errorWeakColor,
    this.successWeakColor,
    this.warningWeakColor,
    this.infoWeakColor,
    this.surfaceVariantColor,
    this.surfaceMutedColor,
    this.focusBorderColor,
    this.hoverColor,
    this.disabledBackgroundColor,
    this.disabledColor,
  });

  ColorSeed copyWith({
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? green,
    Color? yellow,
    Color? red,
    Color? baseTextColor,
    Color? placeholderColor,
    Color? mutedColor,
    Color? subtitleColor,
    Color? selectedItemColor,
    Color? selectedTextBackgroundColor,
    Color? selectedTextColor,
    Color? selectedItemBackgroundColor,
    Color? backgroundColor,
    Color? errorColor,
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? errorWeakColor,
    Color? successWeakColor,
    Color? warningWeakColor,
    Color? infoWeakColor,
    Color? surfaceVariantColor,
    Color? surfaceMutedColor,
    Color? focusBorderColor,
    Color? hoverColor,
    Color? disabledBackgroundColor,
    Color? disabledColor,
  }) {
    return ColorSeed(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      green: green ?? this.green,
      yellow: yellow ?? this.yellow,
      red: red ?? this.red,
      baseTextColor: baseTextColor ?? this.baseTextColor,
      placeholderColor: placeholderColor ?? this.placeholderColor,
      mutedColor: mutedColor ?? this.mutedColor,
      subtitleColor: subtitleColor ?? this.subtitleColor,
      selectedItemColor: selectedItemColor ?? this.selectedItemColor,
      selectedTextBackgroundColor:
          selectedTextBackgroundColor ?? this.selectedTextBackgroundColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      selectedItemBackgroundColor:
          selectedItemBackgroundColor ?? this.selectedItemBackgroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      errorColor: errorColor ?? this.errorColor,
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      errorWeakColor: errorWeakColor ?? this.errorWeakColor,
      successWeakColor: successWeakColor ?? this.successWeakColor,
      warningWeakColor: warningWeakColor ?? this.warningWeakColor,
      infoWeakColor: infoWeakColor ?? this.infoWeakColor,
      surfaceVariantColor: surfaceVariantColor ?? this.surfaceVariantColor,
      surfaceMutedColor: surfaceMutedColor ?? this.surfaceMutedColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      hoverColor: hoverColor ?? this.hoverColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorSeed &&
        other.primary == primary &&
        other.secondary == secondary &&
        other.accent == accent &&
        other.green == green &&
        other.yellow == yellow &&
        other.red == red &&
        other.baseTextColor == baseTextColor &&
        other.placeholderColor == placeholderColor &&
        other.mutedColor == mutedColor &&
        other.subtitleColor == subtitleColor &&
        other.selectedItemColor == selectedItemColor &&
        other.selectedTextBackgroundColor == selectedTextBackgroundColor &&
        other.selectedTextColor == selectedTextColor &&
        other.selectedItemBackgroundColor == selectedItemBackgroundColor &&
        other.backgroundColor == backgroundColor &&
        other.errorColor == errorColor &&
        other.successColor == successColor &&
        other.warningColor == warningColor &&
        other.infoColor == infoColor &&
        other.errorWeakColor == errorWeakColor &&
        other.successWeakColor == successWeakColor &&
        other.warningWeakColor == warningWeakColor &&
        other.infoWeakColor == infoWeakColor &&
        other.surfaceVariantColor == surfaceVariantColor &&
        other.surfaceMutedColor == surfaceMutedColor &&
        other.focusBorderColor == focusBorderColor &&
        other.hoverColor == hoverColor &&
        other.disabledBackgroundColor == disabledBackgroundColor &&
        other.disabledColor == disabledColor;
  }

  @override
  int get hashCode => Object.hashAll([
    primary,
    secondary,
    accent,
    green,
    yellow,
    red,
    baseTextColor,
    placeholderColor,
    mutedColor,
    subtitleColor,
    selectedItemColor,
    selectedTextBackgroundColor,
    selectedTextColor,
    selectedItemBackgroundColor,
    backgroundColor,
    errorColor,
    successColor,
    warningColor,
    infoColor,
    errorWeakColor,
    successWeakColor,
    warningWeakColor,
    infoWeakColor,
    surfaceVariantColor,
    surfaceMutedColor,
    focusBorderColor,
    hoverColor,
    disabledBackgroundColor,
    disabledColor,
  ]);
}

/// Represents customizable font family, font size,
/// and font weight variables.
class TypographyScheme {
  /// Font family stack.
  final List<String>? fontFamily;

  /// Small font size.
  final Dim? fontSizeSm;

  /// Medium font size.
  final Dim? fontSizeMd;

  /// Large font size.
  final Dim? fontSizeLg;

  /// Extra large font size.
  final Dim? fontSizeXl;

  /// 2X large title font size.
  final Dim? fontSize2xl;

  /// 3X large title font size.
  final Dim? fontSize3xl;

  /// 4X large title font size.
  final Dim? fontSize4xl;

  /// 5X large title font size.
  final Dim? fontSize5xl;

  /// Validation error font size.
  final Dim? fontSizeError;

  /// Hint font size.
  final Dim? fontSizeHint;

  /// Label font size.
  final Dim? fontSizeLabel;

  /// Section header font size.
  final Dim? fontSizeSectionHeader;

  /// Normal font weight.
  final int? fontWeightNormal;

  /// Medium font weight.
  final int? fontWeightMedium;

  /// Semi-bold font weight.
  final int? fontWeightSemiBold;

  /// Bold font weight.
  final int? fontWeightBold;

  /// Section header font weight.
  final int? fontWeightSectionHeader;

  const TypographyScheme({
    this.fontFamily,
    this.fontSizeSm,
    this.fontSizeMd,
    this.fontSizeLg,
    this.fontSizeXl,
    this.fontSize2xl,
    this.fontSize3xl,
    this.fontSize4xl,
    this.fontSize5xl,
    this.fontSizeError,
    this.fontSizeHint,
    this.fontSizeLabel,
    this.fontSizeSectionHeader,
    this.fontWeightNormal,
    this.fontWeightMedium,
    this.fontWeightSemiBold,
    this.fontWeightBold,
    this.fontWeightSectionHeader,
  });

  TypographyScheme copyWith({
    List<String>? fontFamily,
    Dim? fontSizeSm,
    Dim? fontSizeMd,
    Dim? fontSizeLg,
    Dim? fontSizeXl,
    Dim? fontSize2xl,
    Dim? fontSize3xl,
    Dim? fontSize4xl,
    Dim? fontSize5xl,
    Dim? fontSizeError,
    Dim? fontSizeHint,
    Dim? fontSizeLabel,
    Dim? fontSizeSectionHeader,
    int? fontWeightNormal,
    int? fontWeightMedium,
    int? fontWeightSemiBold,
    int? fontWeightBold,
    int? fontWeightSectionHeader,
  }) {
    return TypographyScheme(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSizeSm: fontSizeSm ?? this.fontSizeSm,
      fontSizeMd: fontSizeMd ?? this.fontSizeMd,
      fontSizeLg: fontSizeLg ?? this.fontSizeLg,
      fontSizeXl: fontSizeXl ?? this.fontSizeXl,
      fontSize2xl: fontSize2xl ?? this.fontSize2xl,
      fontSize3xl: fontSize3xl ?? this.fontSize3xl,
      fontSize4xl: fontSize4xl ?? this.fontSize4xl,
      fontSize5xl: fontSize5xl ?? this.fontSize5xl,
      fontSizeError: fontSizeError ?? this.fontSizeError,
      fontSizeHint: fontSizeHint ?? this.fontSizeHint,
      fontSizeLabel: fontSizeLabel ?? this.fontSizeLabel,
      fontSizeSectionHeader:
          fontSizeSectionHeader ?? this.fontSizeSectionHeader,
      fontWeightNormal: fontWeightNormal ?? this.fontWeightNormal,
      fontWeightMedium: fontWeightMedium ?? this.fontWeightMedium,
      fontWeightSemiBold: fontWeightSemiBold ?? this.fontWeightSemiBold,
      fontWeightBold: fontWeightBold ?? this.fontWeightBold,
      fontWeightSectionHeader:
          fontWeightSectionHeader ?? this.fontWeightSectionHeader,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TypographyScheme &&
        _listEquals(other.fontFamily, fontFamily) &&
        other.fontSizeSm == fontSizeSm &&
        other.fontSizeMd == fontSizeMd &&
        other.fontSizeLg == fontSizeLg &&
        other.fontSizeXl == fontSizeXl &&
        other.fontSize2xl == fontSize2xl &&
        other.fontSize3xl == fontSize3xl &&
        other.fontSize4xl == fontSize4xl &&
        other.fontSize5xl == fontSize5xl &&
        other.fontSizeSectionHeader == fontSizeSectionHeader &&
        other.fontSizeError == fontSizeError &&
        other.fontSizeHint == fontSizeHint &&
        other.fontSizeLabel == fontSizeLabel &&
        other.fontWeightNormal == fontWeightNormal &&
        other.fontWeightMedium == fontWeightMedium &&
        other.fontWeightSemiBold == fontWeightSemiBold &&
        other.fontWeightBold == fontWeightBold &&
        other.fontWeightSectionHeader == fontWeightSectionHeader;
  }

  @override
  int get hashCode => Object.hashAll([
    Object.hashAll(fontFamily ?? const []),
    fontSizeSm,
    fontSizeMd,
    fontSizeLg,
    fontSizeXl,
    fontSize2xl,
    fontSize3xl,
    fontSize4xl,
    fontSize5xl,
    fontSizeError,
    fontSizeHint,
    fontSizeLabel,
    fontSizeSectionHeader,
    fontWeightNormal,
    fontWeightMedium,
    fontWeightSemiBold,
    fontWeightBold,
    fontWeightSectionHeader,
  ]);
}

/// Represents customizable global padding and margin spacing variables.
class SpacingScheme {
  /// Small padding.
  final Dim? paddingSm;

  /// Medium padding.
  final Dim? paddingMd;

  /// Large padding.
  final Dim? paddingLg;

  /// Small margin.
  final Dim? marginSm;

  /// Medium margin.
  final Dim? marginMd;

  /// Large margin.
  final Dim? marginLg;

  const SpacingScheme({
    this.paddingSm,
    this.paddingMd,
    this.paddingLg,
    this.marginSm,
    this.marginMd,
    this.marginLg,
  });

  SpacingScheme copyWith({
    Dim? paddingSm,
    Dim? paddingMd,
    Dim? paddingLg,
    Dim? marginSm,
    Dim? marginMd,
    Dim? marginLg,
  }) {
    return SpacingScheme(
      paddingSm: paddingSm ?? this.paddingSm,
      paddingMd: paddingMd ?? this.paddingMd,
      paddingLg: paddingLg ?? this.paddingLg,
      marginSm: marginSm ?? this.marginSm,
      marginMd: marginMd ?? this.marginMd,
      marginLg: marginLg ?? this.marginLg,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpacingScheme &&
        other.paddingSm == paddingSm &&
        other.paddingMd == paddingMd &&
        other.paddingLg == paddingLg &&
        other.marginSm == marginSm &&
        other.marginMd == marginMd &&
        other.marginLg == marginLg;
  }

  @override
  int get hashCode => Object.hash(
    paddingSm,
    paddingMd,
    paddingLg,
    marginSm,
    marginMd,
    marginLg,
  );
}

/// Represents customizable global border color and width variables.
class BorderScheme {
  /// Default border color.
  final Color? borderColor;

  /// Default border width.
  final Dim? borderWidth;

  /// Field hover border width.
  final Dim? fieldHoverBorderWidth;

  /// Focus border width.
  final Dim? focusBorderWidth;

  /// Error border width.
  final Dim? errorBorderWidth;

  const BorderScheme({
    this.borderColor,
    this.borderWidth,
    this.fieldHoverBorderWidth,
    this.focusBorderWidth,
    this.errorBorderWidth,
  });

  BorderScheme copyWith({
    Color? borderColor,
    Dim? borderWidth,
    Dim? fieldHoverBorderWidth,
    Dim? focusBorderWidth,
    Dim? errorBorderWidth,
  }) {
    return BorderScheme(
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      fieldHoverBorderWidth:
          fieldHoverBorderWidth ?? this.fieldHoverBorderWidth,
      focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BorderScheme &&
        other.borderColor == borderColor &&
        other.borderWidth == borderWidth &&
        other.fieldHoverBorderWidth == fieldHoverBorderWidth &&
        other.focusBorderWidth == focusBorderWidth &&
        other.errorBorderWidth == errorBorderWidth;
  }

  @override
  int get hashCode => Object.hash(
    borderColor,
    borderWidth,
    fieldHoverBorderWidth,
    focusBorderWidth,
    errorBorderWidth,
  );
}

/// Represents customizable global shadow and elevation color variables.
class ElevationScheme {
  /// Default shadow color.
  final Color? shadowColor;

  /// Small shadow color.
  final Color? smallShadowColor;

  /// Medium shadow color.
  final Color? mediumShadowColor;

  /// Large shadow color.
  final Color? largeShadowColor;

  const ElevationScheme({
    this.shadowColor,
    this.smallShadowColor,
    this.mediumShadowColor,
    this.largeShadowColor,
  });

  ElevationScheme copyWith({
    Color? shadowColor,
    Color? smallShadowColor,
    Color? mediumShadowColor,
    Color? largeShadowColor,
  }) {
    return ElevationScheme(
      shadowColor: shadowColor ?? this.shadowColor,
      smallShadowColor: smallShadowColor ?? this.smallShadowColor,
      mediumShadowColor: mediumShadowColor ?? this.mediumShadowColor,
      largeShadowColor: largeShadowColor ?? this.largeShadowColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ElevationScheme &&
        other.shadowColor == shadowColor &&
        other.smallShadowColor == smallShadowColor &&
        other.mediumShadowColor == mediumShadowColor &&
        other.largeShadowColor == largeShadowColor;
  }

  @override
  int get hashCode => Object.hash(
    shadowColor,
    smallShadowColor,
    mediumShadowColor,
    largeShadowColor,
  );
}

/// Represents customizable global border radius variables.
class RadiusScheme {
  /// Small border radius.
  final Dim? radiusSm;

  /// Medium border radius.
  final Dim? radiusMd;

  /// Large border radius.
  final Dim? radiusLg;

  /// Container shape radius.
  final Dim? shapeRadius;

  const RadiusScheme({
    this.radiusSm,
    this.radiusMd,
    this.radiusLg,
    this.shapeRadius,
  });

  RadiusScheme copyWith({
    Dim? radiusSm,
    Dim? radiusMd,
    Dim? radiusLg,
    Dim? shapeRadius,
  }) {
    return RadiusScheme(
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      shapeRadius: shapeRadius ?? this.shapeRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RadiusScheme &&
        other.radiusSm == radiusSm &&
        other.radiusMd == radiusMd &&
        other.shapeRadius == shapeRadius &&
        other.radiusLg == radiusLg;
  }

  @override
  int get hashCode => Object.hash(radiusSm, radiusMd, radiusLg, shapeRadius);
}

/// Represents customizable variables for Naki components.
class ComponentScheme {
  /// Text max lines.
  final int? textMaxLines;

  /// Input height for `TextField`, `Dropdown`, etc.
  final Dim? inputHeight;

  /// Input text color.
  final Color? inputTextColor;

  /// Label color.
  final Color? labelColor;

  /// Input font size.
  final Dim? fontSizeInput;

  /// Input background color.
  final Color? fieldBackgroundColor;

  /// Input hover border color.
  final Color? fieldHoverColor;

  /// Button background color.
  final Color? buttonBackgroundColor;

  /// Button text color.
  final Color? buttonColor;

  /// Button hover background color.
  final Color? buttonHoverBgColor;

  /// Button height.
  final Dim? buttonHeight;

  /// Button width.
  final Dim? buttonWidth;

  /// Dropdown default trigger height.
  final Dim? dropdownHeight;

  /// Dropdown default trigger width.
  final Dim? dropdownWidth;

  /// Dropdown menu height.
  final Dim? dropdownMenuHeight;

  /// Dropdown menu background color.
  final Color? dropdownMenuBackgroundColor;

  /// Dropdown option font size.
  final Dim? dropdownOptionFontSize;

  /// Dropdown option padding.
  final Dim? dropdownOptionPadding;

  /// Spinner size.
  final Dim? spinnerSize;

  /// Spinner border width.
  final Dim? spinnerBorderWidth;

  /// Spinner track color.
  final Color? spinnerTrackColor;

  /// Spinner color.
  final Color? spinnerColor;

  /// Spinner blade color (for iOS spinner style).
  final Color? spinnerBladeColor;

  /// Spinner surface color (for glassmorphism spinner style).
  final Color? spinnerSurfaceColor;

  /// Slider thumb color.
  final Color? sliderThumbColor;

  /// Slider track color.
  final Color? sliderTrackColor;

  /// Slider thumb size.
  final Dim? sliderThumbSize;

  /// Switch thumb color.
  final Color? switchThumbColor;

  /// Radio button radius.
  final Dim? radioButtonRadius;

  /// Radio button color.
  final Color? radioButtonColor;

  /// Appbar background color.
  final Color? appbarBackgroundColor;

  /// Appbar height.
  final Dim? appbarHeight;

  /// Bottom navbar background color.
  final Color? bottomNavbarBackgroundColor;

  /// Bottom navbar height.
  final Dim? bottomNavbarHeight;

  /// Carousel item extent.
  final Dim? carouselItemExtent;

  /// Carousel gap.
  final Dim? carouselGap;

  /// Table header background color.
  final Color? tableHeaderBackgroundColor;

  /// Table row hover background color.
  final Color? tableRowHoverColor;

  /// Table header border color.
  final Color? tableHeaderBorderColor;

  /// Grid gap.
  final Dim? gridGap;

  /// Snackbar background color.
  final Color? snackbarBackgroundColor;

  /// Snackbar foreground color.
  final Color? snackbarForegroundColor;

  /// Snackbar border radius.
  final Dim? snackbarBorderRadius;

  /// Banner background color.
  final Color? bannerBackgroundColor;

  /// Banner foreground color.
  final Color? bannerForegroundColor;

  /// Banner border radius.
  final Dim? bannerBorderRadius;

  /// Banner border color.
  final Color? bannerBorderColor;

  /// Tooltip background color.
  final Color? tooltipBackgroundColor;

  /// Tooltip text color.
  final Color? tooltipTextColor;

  /// Tooltip border radius.
  final Dim? tooltipBorderRadius;

  /// Tooltip font size.
  final Dim? tooltipFontSize;

  /// Popover background color.
  final Color? popoverBackgroundColor;

  /// Popover text color.
  final Color? popoverTextColor;

  /// Popover border color.
  final Color? popoverBorderColor;

  /// Popover border radius.
  final Dim? popoverBorderRadius;

  /// Dialog background color.
  final Color? dialogBackgroundColor;

  /// Dialog border radius.
  final Dim? dialogBorderRadius;

  /// Dialog barrier backdrop color.
  final Color? dialogBarrierBackgroundColor;

  /// Drawer background color.
  final Color? drawerBackgroundColor;

  /// Drawer width.
  final Dim? drawerWidth;

  /// Drawer barrier backdrop color.
  final Color? drawerBarrierBackgroundColor;

  /// Bottom sheet background color.
  final Color? bottomSheetBackgroundColor;

  /// Bottom sheet max height.
  final Dim? bottomSheetMaxHeight;

  /// Bottom sheet barrier backdrop color.
  final Color? bottomSheetBarrierBackgroundColor;

  const ComponentScheme({
    this.textMaxLines,
    this.inputHeight,
    this.inputTextColor,
    this.labelColor,
    this.fontSizeInput,
    this.fieldBackgroundColor,
    this.fieldHoverColor,
    this.buttonBackgroundColor,
    this.buttonColor,
    this.buttonHeight,
    this.buttonWidth,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownMenuHeight,
    this.dropdownMenuBackgroundColor,
    this.dropdownOptionFontSize,
    this.dropdownOptionPadding,
    this.spinnerSize,
    this.spinnerBorderWidth,
    this.spinnerTrackColor,
    this.spinnerColor,
    this.spinnerBladeColor,
    this.spinnerSurfaceColor,
    this.sliderThumbColor,
    this.sliderTrackColor,
    this.sliderThumbSize,
    this.switchThumbColor,
    this.radioButtonRadius,
    this.radioButtonColor,
    this.appbarBackgroundColor,
    this.appbarHeight,
    this.bottomNavbarBackgroundColor,
    this.bottomNavbarHeight,
    this.carouselItemExtent,
    this.carouselGap,
    this.tableHeaderBackgroundColor,
    this.tableHeaderBorderColor,
    this.tableRowHoverColor,
    this.gridGap,
    this.snackbarBackgroundColor,
    this.snackbarForegroundColor,
    this.snackbarBorderRadius,
    this.bannerBackgroundColor,
    this.bannerForegroundColor,
    this.bannerBorderRadius,
    this.bannerBorderColor,
    this.tooltipBackgroundColor,
    this.tooltipTextColor,
    this.tooltipBorderRadius,
    this.tooltipFontSize,
    this.popoverBackgroundColor,
    this.popoverTextColor,
    this.popoverBorderColor,
    this.popoverBorderRadius,
    this.dialogBackgroundColor,
    this.dialogBorderRadius,
    this.dialogBarrierBackgroundColor,
    this.drawerBackgroundColor,
    this.drawerWidth,
    this.drawerBarrierBackgroundColor,
    this.bottomSheetBackgroundColor,
    this.bottomSheetMaxHeight,
    this.bottomSheetBarrierBackgroundColor,
    this.buttonHoverBgColor,
  });

  ComponentScheme copyWith({
    int? textMaxLines,
    Dim? inputHeight,
    Color? inputTextColor,
    Color? labelColor,
    Dim? fontSizeInput,
    Color? fieldBackgroundColor,
    Color? fieldHoverColor,
    Color? buttonBackgroundColor,
    Color? buttonColor,
    Color? buttonHoverBgColor,
    Dim? buttonHeight,
    Dim? buttonWidth,
    Dim? dropdownHeight,
    Dim? dropdownWidth,
    Dim? dropdownMenuHeight,
    Color? dropdownMenuBackgroundColor,
    Dim? dropdownOptionFontSize,
    Dim? dropdownOptionPadding,
    Dim? spinnerSize,
    Dim? spinnerBorderWidth,
    Color? spinnerTrackColor,
    Color? spinnerColor,
    Color? spinnerBladeColor,
    Color? spinnerSurfaceColor,
    Color? sliderThumbColor,
    Color? sliderTrackColor,
    Dim? sliderThumbSize,
    Color? switchThumbColor,
    Dim? radioButtonRadius,
    Color? radioButtonColor,
    Color? appbarBackgroundColor,
    Dim? appbarHeight,
    Color? bottomNavbarBackgroundColor,
    Dim? bottomNavbarHeight,
    Dim? carouselItemExtent,
    Dim? carouselGap,
    Color? tableHeaderBackgroundColor,
    Color? tableHeaderBorderColor,
    Color? tableRowHoverColor,
    Dim? gridGap,
    Color? snackbarBackgroundColor,
    Color? snackbarForegroundColor,
    Dim? snackbarBorderRadius,
    Color? bannerBackgroundColor,
    Color? bannerForegroundColor,
    Dim? bannerBorderRadius,
    Color? bannerBorderColor,
    Color? tooltipBackgroundColor,
    Color? tooltipTextColor,
    Dim? tooltipBorderRadius,
    Dim? tooltipFontSize,
    Color? popoverBackgroundColor,
    Color? popoverTextColor,
    Color? popoverBorderColor,
    Dim? popoverBorderRadius,
    Color? dialogBackgroundColor,
    Dim? dialogBorderRadius,
    Color? dialogBarrierBackgroundColor,
    Color? drawerBackgroundColor,
    Dim? drawerWidth,
    Color? drawerBarrierBackgroundColor,
    Color? bottomSheetBackgroundColor,
    Dim? bottomSheetMaxHeight,
    Color? bottomSheetBarrierBackgroundColor,
  }) => ComponentScheme(
    textMaxLines: textMaxLines ?? this.textMaxLines,
    inputHeight: inputHeight ?? this.inputHeight,
    inputTextColor: inputTextColor ?? this.inputTextColor,
    labelColor: labelColor ?? this.labelColor,
    fontSizeInput: fontSizeInput ?? this.fontSizeInput,
    fieldBackgroundColor: fieldBackgroundColor ?? this.fieldBackgroundColor,
    fieldHoverColor: fieldHoverColor ?? this.fieldHoverColor,
    buttonBackgroundColor: buttonBackgroundColor ?? this.buttonBackgroundColor,
    buttonColor: buttonColor ?? this.buttonColor,
    buttonHoverBgColor: buttonHoverBgColor ?? this.buttonHoverBgColor,
    buttonHeight: buttonHeight ?? this.buttonHeight,
    buttonWidth: buttonWidth ?? this.buttonWidth,
    dropdownHeight: dropdownHeight ?? this.dropdownHeight,
    dropdownWidth: dropdownWidth ?? this.dropdownWidth,
    dropdownMenuHeight: dropdownMenuHeight ?? this.dropdownMenuHeight,
    dropdownMenuBackgroundColor:
        dropdownMenuBackgroundColor ?? this.dropdownMenuBackgroundColor,
    dropdownOptionFontSize:
        dropdownOptionFontSize ?? this.dropdownOptionFontSize,
    dropdownOptionPadding: dropdownOptionPadding ?? this.dropdownOptionPadding,
    spinnerSize: spinnerSize ?? this.spinnerSize,
    spinnerBorderWidth: spinnerBorderWidth ?? this.spinnerBorderWidth,
    spinnerTrackColor: spinnerTrackColor ?? this.spinnerTrackColor,
    spinnerColor: spinnerColor ?? this.spinnerColor,
    spinnerBladeColor: spinnerBladeColor ?? this.spinnerBladeColor,
    spinnerSurfaceColor: spinnerSurfaceColor ?? this.spinnerSurfaceColor,
    sliderThumbColor: sliderThumbColor ?? this.sliderThumbColor,
    sliderTrackColor: sliderTrackColor ?? this.sliderTrackColor,
    sliderThumbSize: sliderThumbSize ?? this.sliderThumbSize,
    switchThumbColor: switchThumbColor ?? this.switchThumbColor,
    radioButtonRadius: radioButtonRadius ?? this.radioButtonRadius,
    radioButtonColor: radioButtonColor ?? this.radioButtonColor,
    appbarBackgroundColor: appbarBackgroundColor ?? this.appbarBackgroundColor,
    appbarHeight: appbarHeight ?? this.appbarHeight,
    bottomNavbarBackgroundColor:
        bottomNavbarBackgroundColor ?? this.bottomNavbarBackgroundColor,
    bottomNavbarHeight: bottomNavbarHeight ?? this.bottomNavbarHeight,
    carouselItemExtent: carouselItemExtent ?? this.carouselItemExtent,
    carouselGap: carouselGap ?? this.carouselGap,
    tableHeaderBackgroundColor:
        tableHeaderBackgroundColor ?? this.tableHeaderBackgroundColor,
    tableHeaderBorderColor:
        tableHeaderBorderColor ?? this.tableHeaderBorderColor,
    tableRowHoverColor: tableRowHoverColor ?? this.tableRowHoverColor,
    gridGap: gridGap ?? this.gridGap,
    snackbarBackgroundColor:
        snackbarBackgroundColor ?? this.snackbarBackgroundColor,
    snackbarForegroundColor:
        snackbarForegroundColor ?? this.snackbarForegroundColor,
    snackbarBorderRadius: snackbarBorderRadius ?? this.snackbarBorderRadius,
    bannerBackgroundColor: bannerBackgroundColor ?? this.bannerBackgroundColor,
    bannerForegroundColor: bannerForegroundColor ?? this.bannerForegroundColor,
    bannerBorderRadius: bannerBorderRadius ?? this.bannerBorderRadius,
    bannerBorderColor: bannerBorderColor ?? this.bannerBorderColor,
    tooltipBackgroundColor:
        tooltipBackgroundColor ?? this.tooltipBackgroundColor,
    tooltipTextColor: tooltipTextColor ?? this.tooltipTextColor,
    tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
    tooltipFontSize: tooltipFontSize ?? this.tooltipFontSize,
    popoverBackgroundColor:
        popoverBackgroundColor ?? this.popoverBackgroundColor,
    popoverTextColor: popoverTextColor ?? this.popoverTextColor,
    popoverBorderColor: popoverBorderColor ?? this.popoverBorderColor,
    popoverBorderRadius: popoverBorderRadius ?? this.popoverBorderRadius,
    dialogBackgroundColor: dialogBackgroundColor ?? this.dialogBackgroundColor,
    dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
    dialogBarrierBackgroundColor:
        dialogBarrierBackgroundColor ?? this.dialogBarrierBackgroundColor,
    drawerBackgroundColor: drawerBackgroundColor ?? this.drawerBackgroundColor,
    drawerWidth: drawerWidth ?? this.drawerWidth,
    drawerBarrierBackgroundColor:
        drawerBarrierBackgroundColor ?? this.drawerBarrierBackgroundColor,
    bottomSheetBackgroundColor:
        bottomSheetBackgroundColor ?? this.bottomSheetBackgroundColor,
    bottomSheetMaxHeight: bottomSheetMaxHeight ?? this.bottomSheetMaxHeight,
    bottomSheetBarrierBackgroundColor:
        bottomSheetBarrierBackgroundColor ??
        this.bottomSheetBarrierBackgroundColor,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComponentScheme &&
        other.textMaxLines == textMaxLines &&
        other.inputHeight == inputHeight &&
        other.inputTextColor == inputTextColor &&
        other.labelColor == labelColor &&
        other.fontSizeInput == fontSizeInput &&
        other.fieldBackgroundColor == fieldBackgroundColor &&
        other.fieldHoverColor == fieldHoverColor &&
        other.buttonBackgroundColor == buttonBackgroundColor &&
        other.buttonColor == buttonColor &&
        other.buttonHoverBgColor == buttonHoverBgColor &&
        other.buttonHeight == buttonHeight &&
        other.buttonWidth == buttonWidth &&
        other.dropdownHeight == dropdownHeight &&
        other.dropdownWidth == dropdownWidth &&
        other.dropdownMenuHeight == dropdownMenuHeight &&
        other.dropdownMenuBackgroundColor == dropdownMenuBackgroundColor &&
        other.dropdownOptionFontSize == dropdownOptionFontSize &&
        other.dropdownOptionPadding == dropdownOptionPadding &&
        other.spinnerSize == spinnerSize &&
        other.spinnerBorderWidth == spinnerBorderWidth &&
        other.spinnerTrackColor == spinnerTrackColor &&
        other.spinnerColor == spinnerColor &&
        other.spinnerBladeColor == spinnerBladeColor &&
        other.spinnerSurfaceColor == spinnerSurfaceColor &&
        other.sliderThumbColor == sliderThumbColor &&
        other.sliderTrackColor == sliderTrackColor &&
        other.sliderThumbSize == sliderThumbSize &&
        other.switchThumbColor == switchThumbColor &&
        other.radioButtonRadius == radioButtonRadius &&
        other.radioButtonColor == radioButtonColor &&
        other.appbarBackgroundColor == appbarBackgroundColor &&
        other.appbarHeight == appbarHeight &&
        other.bottomNavbarBackgroundColor == bottomNavbarBackgroundColor &&
        other.bottomNavbarHeight == bottomNavbarHeight &&
        other.carouselItemExtent == carouselItemExtent &&
        other.carouselGap == carouselGap &&
        other.tableHeaderBackgroundColor == tableHeaderBackgroundColor &&
        other.tableHeaderBorderColor == tableHeaderBorderColor &&
        other.tableRowHoverColor == tableRowHoverColor &&
        other.gridGap == gridGap &&
        other.snackbarBackgroundColor == snackbarBackgroundColor &&
        other.snackbarForegroundColor == snackbarForegroundColor &&
        other.snackbarBorderRadius == snackbarBorderRadius &&
        other.bannerBackgroundColor == bannerBackgroundColor &&
        other.bannerForegroundColor == bannerForegroundColor &&
        other.bannerBorderRadius == bannerBorderRadius &&
        other.bannerBorderColor == bannerBorderColor &&
        other.tooltipBackgroundColor == tooltipBackgroundColor &&
        other.tooltipTextColor == tooltipTextColor &&
        other.tooltipBorderRadius == tooltipBorderRadius &&
        other.tooltipFontSize == tooltipFontSize &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverTextColor == popoverTextColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderRadius == popoverBorderRadius &&
        other.dialogBackgroundColor == dialogBackgroundColor &&
        other.dialogBorderRadius == dialogBorderRadius &&
        other.dialogBarrierBackgroundColor == dialogBarrierBackgroundColor &&
        other.drawerBackgroundColor == drawerBackgroundColor &&
        other.drawerWidth == drawerWidth &&
        other.drawerBarrierBackgroundColor == drawerBarrierBackgroundColor &&
        other.bottomSheetBackgroundColor == bottomSheetBackgroundColor &&
        other.bottomSheetMaxHeight == bottomSheetMaxHeight &&
        other.bottomSheetBarrierBackgroundColor ==
            bottomSheetBarrierBackgroundColor;
  }

  @override
  int get hashCode => Object.hashAll([
    textMaxLines,
    inputHeight,
    inputTextColor,
    labelColor,
    fontSizeInput,
    fieldBackgroundColor,
    fieldHoverColor,
    buttonBackgroundColor,
    buttonColor,
    buttonHoverBgColor,
    buttonHeight,
    buttonWidth,
    dropdownHeight,
    dropdownWidth,
    dropdownMenuHeight,
    dropdownMenuBackgroundColor,
    dropdownOptionFontSize,
    dropdownOptionPadding,
    spinnerSize,
    spinnerBorderWidth,
    spinnerTrackColor,
    spinnerColor,
    spinnerBladeColor,
    spinnerSurfaceColor,
    sliderThumbColor,
    sliderTrackColor,
    sliderThumbSize,
    switchThumbColor,
    radioButtonRadius,
    radioButtonColor,
    appbarBackgroundColor,
    appbarHeight,
    bottomNavbarBackgroundColor,
    bottomNavbarHeight,
    carouselItemExtent,
    carouselGap,
    tableHeaderBackgroundColor,
    tableRowHoverColor,
    tableHeaderBorderColor,
    gridGap,
    snackbarBackgroundColor,
    snackbarForegroundColor,
    snackbarBorderRadius,
    bannerBackgroundColor,
    bannerForegroundColor,
    bannerBorderRadius,
    bannerBorderColor,
    tooltipBackgroundColor,
    tooltipTextColor,
    tooltipBorderRadius,
    tooltipFontSize,
    popoverBackgroundColor,
    popoverTextColor,
    popoverBorderColor,
    popoverBorderRadius,
    dialogBackgroundColor,
    dialogBorderRadius,
    dialogBarrierBackgroundColor,
    drawerBackgroundColor,
    drawerWidth,
    drawerBarrierBackgroundColor,
    bottomSheetBackgroundColor,
    bottomSheetMaxHeight,
    bottomSheetBarrierBackgroundColor,
  ]);
}

/// Theme data for light mode used in [ThemeConfig].
///
/// Allows customization of colors, typography, spacing, borders, elevation,
/// border radius, shapes, and component-specific token overrides.
class LightThemeData extends _LightModeTokens {
  /// Seed for customizing base and semantic color tokens.
  final ColorSeed? colorSeed;

  /// Seed for customizing font family, sizes, and weights.
  final TypographyScheme? typography;

  /// Seed for customizing global padding and margin spacing tokens.
  final SpacingScheme? spacing;

  /// Seed for customizing border width tokens.
  final BorderScheme? borderWidth;

  /// Seed for customizing shadow and elevation color tokens.
  final ElevationScheme? elevation;

  /// Seed for customizing radius tokens.
  final RadiusScheme? radius;

  /// Seed for customizing component-specific token overrides.
  final ComponentScheme? component;

  /// Custom CSS key-value variables to inject into light mode styles.
  final Map<String, String>? styles;

  const LightThemeData({
    this.colorSeed,
    this.typography,
    this.spacing,
    this.borderWidth,
    this.elevation,
    this.radius,
    this.component,
    this.styles,
  }) : super(styles);

  @override
  String get colorScheme => 'light';

  // ===========================================================================
  // Color Tokens Overrides (String Values)
  // ===========================================================================

  @override
  String get primaryColorValue =>
      colorSeed?.primary?.value ?? super.primaryColorValue;

  @override
  String get secondaryColorValue =>
      colorSeed?.secondary?.value ?? super.secondaryColorValue;

  @override
  String get accentColorValue =>
      colorSeed?.accent?.value ?? super.accentColorValue;

  @override
  String get greenValue => colorSeed?.green?.value ?? super.greenValue;

  @override
  String get yellowValue => colorSeed?.yellow?.value ?? super.yellowValue;

  @override
  String get redValue => colorSeed?.red?.value ?? super.redValue;

  @override
  String get baseTextColorValue =>
      colorSeed?.baseTextColor?.value ?? super.baseTextColorValue;

  @override
  String get placeholderColorValue =>
      colorSeed?.placeholderColor?.value ?? super.placeholderColorValue;

  @override
  String get mutedColorValue =>
      colorSeed?.mutedColor?.value ?? super.mutedColorValue;

  @override
  String get subtitleColorValue =>
      colorSeed?.subtitleColor?.value ?? super.subtitleColorValue;

  @override
  String get selectedItemColorValue =>
      colorSeed?.selectedItemColor?.value ?? super.selectedItemColorValue;

  @override
  String get selectedTextBgColorValue =>
      colorSeed?.selectedTextBackgroundColor?.value ??
      super.selectedTextBgColorValue;

  @override
  String get selectedTextColorValue =>
      colorSeed?.selectedTextColor?.value ?? super.selectedTextColorValue;

  @override
  String get selectedItemBgColorValue =>
      colorSeed?.selectedItemBackgroundColor?.value ??
      super.selectedItemBgColorValue;

  @override
  String get backgroundColorValue =>
      colorSeed?.backgroundColor?.value ?? super.backgroundColorValue;

  @override
  String get borderColorValue =>
      borderWidth?.borderColor?.value ?? super.borderColorValue;

  @override
  String get errorColorValue =>
      colorSeed?.errorColor?.value ?? super.errorColorValue;

  @override
  String get successColorValue =>
      colorSeed?.successColor?.value ?? super.successColorValue;

  @override
  String get warningColorValue =>
      colorSeed?.warningColor?.value ?? super.warningColorValue;

  @override
  String get infoColorValue =>
      colorSeed?.infoColor?.value ?? super.infoColorValue;

  @override
  String get errorWeakColorValue =>
      colorSeed?.errorWeakColor?.value ?? super.errorWeakColorValue;

  @override
  String get successWeakColorValue =>
      colorSeed?.successWeakColor?.value ?? super.successWeakColorValue;

  @override
  String get warningWeakColorValue =>
      colorSeed?.warningWeakColor?.value ?? super.warningWeakColorValue;

  @override
  String get infoWeakColorValue =>
      colorSeed?.infoWeakColor?.value ?? super.infoWeakColorValue;

  @override
  String get surfaceVariantColorValue =>
      colorSeed?.surfaceVariantColor?.value ?? super.surfaceVariantColorValue;

  @override
  String get surfaceMutedColorValue =>
      colorSeed?.surfaceMutedColor?.value ?? super.surfaceMutedColorValue;

  @override
  String get shadowColorValue =>
      elevation?.shadowColor?.value ?? super.shadowColorValue;

  @override
  String get smallShadowColorValue =>
      elevation?.smallShadowColor?.value ?? super.smallShadowColorValue;

  @override
  String get mediumShadowColorValue =>
      elevation?.mediumShadowColor?.value ?? super.mediumShadowColorValue;

  @override
  String get largeShadowColorValue =>
      elevation?.largeShadowColor?.value ?? super.largeShadowColorValue;

  @override
  String get focusBorderColorValue =>
      colorSeed?.focusBorderColor?.value ?? super.focusBorderColorValue;

  @override
  String get disabledBgColorValue =>
      colorSeed?.disabledBackgroundColor?.value ?? super.disabledBgColorValue;

  @override
  String get disabledColorValue =>
      colorSeed?.disabledColor?.value ?? super.disabledColorValue;

  @override
  String get hoverColorValue =>
      colorSeed?.hoverColor?.value ?? super.hoverColorValue;

  // ===========================================================================
  // Border Tokens Overrides
  // ===========================================================================

  @override
  Token get border => borderWidth?.borderWidth != null
      ? Token(
          value:
              '${borderWidth!.borderWidth!.cssText} solid var($borderColor, ${borderColor.value})',
          name: super.border.name,
        )
      : super.border;

  @override
  Token get fieldHoverBorder => borderWidth?.fieldHoverBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.fieldHoverBorderWidth!.cssText} solid var($fieldHoverColor, ${fieldHoverColor.value})',
          name: super.fieldHoverBorder.name,
        )
      : super.fieldHoverBorder;

  @override
  Token get focusBorder => borderWidth?.focusBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.focusBorderWidth!.cssText} solid var($focusBorderColor, ${focusBorderColor.value})',
          name: super.focusBorder.name,
        )
      : super.focusBorder;

  @override
  Token get errorBorder => borderWidth?.errorBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.errorBorderWidth!.cssText} solid var($errorColor, ${errorColor.value})',
          name: super.errorBorder.name,
        )
      : super.errorBorder;

  // ===========================================================================
  // Typography Tokens Overrides
  // ===========================================================================

  @override
  Token get fontFamily =>
      typography?.fontFamily != null && typography!.fontFamily!.isNotEmpty
      ? Token(
          value: typography!.fontFamily!.join(','),
          name: super.fontFamily.name,
        )
      : super.fontFamily;

  @override
  Token get fontSizeSm => typography?.fontSizeSm != null
      ? Token(
          value: typography!.fontSizeSm!.cssText,
          name: super.fontSizeSm.name,
        )
      : super.fontSizeSm;

  @override
  Token get fontSizeMd => typography?.fontSizeMd != null
      ? Token(
          value: typography!.fontSizeMd!.cssText,
          name: super.fontSizeMd.name,
        )
      : super.fontSizeMd;

  @override
  Token get fontSizeLg => typography?.fontSizeLg != null
      ? Token(
          value: typography!.fontSizeLg!.cssText,
          name: super.fontSizeLg.name,
        )
      : super.fontSizeLg;

  @override
  Token get fontSizeXl => typography?.fontSizeXl != null
      ? Token(
          value: typography!.fontSizeXl!.cssText,
          name: super.fontSizeXl.name,
        )
      : super.fontSizeXl;

  @override
  Token get fontSize2xl => typography?.fontSize2xl != null
      ? Token(
          value: typography!.fontSize2xl!.cssText,
          name: super.fontSize2xl.name,
        )
      : super.fontSize2xl;

  @override
  Token get fontSize3xl => typography?.fontSize3xl != null
      ? Token(
          value: typography!.fontSize3xl!.cssText,
          name: super.fontSize3xl.name,
        )
      : super.fontSize3xl;

  @override
  Token get fontSize4xl => typography?.fontSize4xl != null
      ? Token(
          value: typography!.fontSize4xl!.cssText,
          name: super.fontSize4xl.name,
        )
      : super.fontSize4xl;

  @override
  Token get fontSize5xl => typography?.fontSize5xl != null
      ? Token(
          value: typography!.fontSize5xl!.cssText,
          name: super.fontSize5xl.name,
        )
      : super.fontSize5xl;

  @override
  Token get fontSizeError => typography?.fontSizeError != null
      ? Token(
          value: typography!.fontSizeError!.cssText,
          name: super.fontSizeError.name,
        )
      : super.fontSizeError;

  @override
  Token get fontSizeHint => typography?.fontSizeHint != null
      ? Token(
          value: typography!.fontSizeHint!.cssText,
          name: super.fontSizeHint.name,
        )
      : super.fontSizeHint;

  @override
  Token get fontSizeLabel => typography?.fontSizeLabel != null
      ? Token(
          value: typography!.fontSizeLabel!.cssText,
          name: super.fontSizeLabel.name,
        )
      : super.fontSizeLabel;

  @override
  Token get fontSizeSectionHeader => typography?.fontSizeSectionHeader != null
      ? Token(
          value: typography!.fontSizeSectionHeader!.cssText,
          name: super.fontSizeSectionHeader.name,
        )
      : super.fontSizeSectionHeader;

  @override
  Token get fontWeightNormal => typography?.fontWeightNormal != null
      ? Token(
          value: typography!.fontWeightNormal.toString(),
          name: super.fontWeightNormal.name,
        )
      : super.fontWeightNormal;

  @override
  Token get fontWeightMedium => typography?.fontWeightMedium != null
      ? Token(
          value: typography!.fontWeightMedium.toString(),
          name: super.fontWeightMedium.name,
        )
      : super.fontWeightMedium;

  @override
  Token get fontWeightSemiBold => typography?.fontWeightSemiBold != null
      ? Token(
          value: typography!.fontWeightSemiBold.toString(),
          name: super.fontWeightSemiBold.name,
        )
      : super.fontWeightSemiBold;

  @override
  Token get fontWeightBold => typography?.fontWeightBold != null
      ? Token(
          value: typography!.fontWeightBold.toString(),
          name: super.fontWeightBold.name,
        )
      : super.fontWeightBold;

  @override
  Token get fontWeightSectionHeader =>
      typography?.fontWeightSectionHeader != null
      ? Token(
          value: typography!.fontWeightSectionHeader.toString(),
          name: super.fontWeightSectionHeader.name,
        )
      : super.fontWeightSectionHeader;

  // ===========================================================================
  // Spacing Tokens Overrides
  // ===========================================================================

  @override
  Token get paddingSm => spacing?.paddingSm != null
      ? Token(value: spacing!.paddingSm!.cssText, name: super.paddingSm.name)
      : super.paddingSm;

  @override
  Token get paddingMd => spacing?.paddingMd != null
      ? Token(value: spacing!.paddingMd!.cssText, name: super.paddingMd.name)
      : super.paddingMd;

  @override
  Token get paddingLg => spacing?.paddingLg != null
      ? Token(value: spacing!.paddingLg!.cssText, name: super.paddingLg.name)
      : super.paddingLg;

  @override
  Token get marginSm => spacing?.marginSm != null
      ? Token(value: spacing!.marginSm!.cssText, name: super.marginSm.name)
      : super.marginSm;

  @override
  Token get marginMd => spacing?.marginMd != null
      ? Token(value: spacing!.marginMd!.cssText, name: super.marginMd.name)
      : super.marginMd;

  @override
  Token get marginLg => spacing?.marginLg != null
      ? Token(value: spacing!.marginLg!.cssText, name: super.marginLg.name)
      : super.marginLg;

  // ===========================================================================
  // Border Radius Tokens Overrides
  // ===========================================================================

  @override
  Token get radiusSm => radius?.radiusSm != null
      ? Token(value: radius!.radiusSm!.cssText, name: super.radiusSm.name)
      : super.radiusSm;

  @override
  Token get radiusMd => radius?.radiusMd != null
      ? Token(value: radius!.radiusMd!.cssText, name: super.radiusMd.name)
      : super.radiusMd;

  @override
  Token get radiusLg => radius?.radiusLg != null
      ? Token(value: radius!.radiusLg!.cssText, name: super.radiusLg.name)
      : super.radiusLg;

  // ===========================================================================
  // Component Tokens Overrides
  // ===========================================================================

  @override
  Token get textMaxLines => component?.textMaxLines != null
      ? Token(
          value: component!.textMaxLines.toString(),
          name: super.textMaxLines.name,
        )
      : super.textMaxLines;

  @override
  Token get inputHeight => component?.inputHeight != null
      ? Token(
          value: component!.inputHeight!.cssText,
          name: super.inputHeight.name,
        )
      : super.inputHeight;

  @override
  String get inputTextColorValue =>
      component?.inputTextColor?.value ?? super.inputTextColorValue;

  @override
  String get labelColorValue =>
      component?.labelColor?.value ?? super.labelColorValue;

  @override
  Token get fontSizeInput => component?.fontSizeInput != null
      ? Token(
          value: component!.fontSizeInput!.cssText,
          name: super.fontSizeInput.name,
        )
      : super.fontSizeInput;

  @override
  String get fieldBackgroundColorValue =>
      component?.fieldBackgroundColor?.value ?? super.fieldBackgroundColorValue;

  @override
  String get fieldHoverColorValue =>
      component?.fieldHoverColor?.value ?? super.fieldHoverColorValue;

  @override
  String get buttonBackgroundColorValue =>
      component?.buttonBackgroundColor?.value ??
      super.buttonBackgroundColorValue;

  @override
  String get buttonColorValue =>
      component?.buttonColor?.value ?? super.buttonColorValue;

  @override
  String get buttonHoverBgColorValue =>
      component?.buttonHoverBgColor?.value ?? super.buttonHoverBgColorValue;

  @override
  Token get buttonHeight => component?.buttonHeight != null
      ? Token(
          value: component!.buttonHeight!.cssText,
          name: super.buttonHeight.name,
        )
      : super.buttonHeight;

  @override
  Token get buttonWidth => component?.buttonWidth != null
      ? Token(
          value: component!.buttonWidth!.cssText,
          name: super.buttonWidth.name,
        )
      : super.buttonWidth;

  @override
  Token get dropdownHeight => component?.dropdownHeight != null
      ? Token(
          value: component!.dropdownHeight!.cssText,
          name: super.dropdownHeight.name,
        )
      : super.dropdownHeight;

  @override
  Token get dropdownWidth => component?.dropdownWidth != null
      ? Token(
          value: component!.dropdownWidth!.cssText,
          name: super.dropdownWidth.name,
        )
      : super.dropdownWidth;

  @override
  Token get dropdownMenuHeight => component?.dropdownMenuHeight != null
      ? Token(
          value: component!.dropdownMenuHeight!.cssText,
          name: super.dropdownMenuHeight.name,
        )
      : super.dropdownMenuHeight;

  @override
  String get dropdownMenuBgColorValue =>
      component?.dropdownMenuBackgroundColor?.value ??
      super.dropdownMenuBgColorValue;

  @override
  Token get dropdownOptionFontSize => component?.dropdownOptionFontSize != null
      ? Token(
          value: component!.dropdownOptionFontSize!.cssText,
          name: super.dropdownOptionFontSize.name,
        )
      : super.dropdownOptionFontSize;

  @override
  Token get dropdownOptionPadding => component?.dropdownOptionPadding != null
      ? Token(
          value: component!.dropdownOptionPadding!.cssText,
          name: super.dropdownOptionPadding.name,
        )
      : super.dropdownOptionPadding;

  @override
  Token get spinnerSize => component?.spinnerSize != null
      ? Token(
          value: component!.spinnerSize!.cssText,
          name: super.spinnerSize.name,
        )
      : super.spinnerSize;

  @override
  Token get spinnerBorderWidth => component?.spinnerBorderWidth != null
      ? Token(
          value: component!.spinnerBorderWidth!.cssText,
          name: super.spinnerBorderWidth.name,
        )
      : super.spinnerBorderWidth;

  @override
  String get spinnerTrackColorValue =>
      component?.spinnerTrackColor?.value ?? super.spinnerTrackColorValue;

  @override
  String get spinnerSurfaceColorValue =>
      component?.spinnerSurfaceColor?.value ?? super.spinnerSurfaceColorValue;

  @override
  String get sliderThumbColorValue =>
      component?.sliderThumbColor?.value ?? super.sliderThumbColorValue;

  @override
  String get sliderTrackColorValue =>
      component?.sliderTrackColor?.value ?? super.sliderTrackColorValue;

  @override
  Token get sliderThumbSize => component?.sliderThumbSize != null
      ? Token(
          value: component!.sliderThumbSize!.cssText,
          name: super.sliderThumbSize.name,
        )
      : super.sliderThumbSize;

  @override
  String get switchThumbColorValue =>
      component?.switchThumbColor?.value ?? super.switchThumbColorValue;

  @override
  Token get radioBtnRadius => component?.radioButtonRadius != null
      ? Token(
          value: component!.radioButtonRadius!.cssText,
          name: super.radioBtnRadius.name,
        )
      : super.radioBtnRadius;

  @override
  String get radioBtnColorValue =>
      component?.radioButtonColor?.value ?? super.radioBtnColorValue;

  @override
  String get appbarBgColorValue =>
      component?.appbarBackgroundColor?.value ?? super.appbarBgColorValue;

  @override
  Token get appbarHeight => component?.appbarHeight != null
      ? Token(
          value: component!.appbarHeight!.cssText,
          name: super.appbarHeight.name,
        )
      : super.appbarHeight;

  @override
  String get bottomNavbarBgColorValue =>
      component?.bottomNavbarBackgroundColor?.value ??
      super.bottomNavbarBgColorValue;

  @override
  Token get bottomNavbarHeight => component?.bottomNavbarHeight != null
      ? Token(
          value: component!.bottomNavbarHeight!.cssText,
          name: super.bottomNavbarHeight.name,
        )
      : super.bottomNavbarHeight;

  @override
  Token get carouselItemExtent => component?.carouselItemExtent != null
      ? Token(
          value: component!.carouselItemExtent!.cssText,
          name: super.carouselItemExtent.name,
        )
      : super.carouselItemExtent;

  @override
  Token get carouselGap => component?.carouselGap != null
      ? Token(
          value: component!.carouselGap!.cssText,
          name: super.carouselGap.name,
        )
      : super.carouselGap;

  @override
  String get tableHeaderBgValue =>
      component?.tableHeaderBackgroundColor?.value ?? super.tableHeaderBgValue;

  @override
  String get tableRowHoverBgValue =>
      component?.tableRowHoverColor?.value ?? super.tableRowHoverBgValue;

  @override
  Token get gridGap => component?.gridGap != null
      ? Token(value: component!.gridGap!.cssText, name: super.gridGap.name)
      : super.gridGap;

  @override
  String get snackbarBgColorValue =>
      component?.snackbarBackgroundColor?.value ?? super.snackbarBgColorValue;

  @override
  String get snackbarForegroundColorValue =>
      component?.snackbarForegroundColor?.value ??
      super.snackbarForegroundColorValue;

  @override
  Token get snackbarBorderRadius => component?.snackbarBorderRadius != null
      ? Token(
          value: component!.snackbarBorderRadius!.cssText,
          name: super.snackbarBorderRadius.name,
        )
      : super.snackbarBorderRadius;

  @override
  String get bannerBgColorValue =>
      component?.bannerBackgroundColor?.value ?? super.bannerBgColorValue;

  @override
  String get bannerForegroundColorValue =>
      component?.bannerForegroundColor?.value ??
      super.bannerForegroundColorValue;

  @override
  Token get bannerBorderRadius => component?.bannerBorderRadius != null
      ? Token(
          value: component!.bannerBorderRadius!.cssText,
          name: super.bannerBorderRadius.name,
        )
      : super.bannerBorderRadius;

  @override
  String get bannerBorderColorValue =>
      component?.bannerBorderColor?.value ?? super.bannerBorderColorValue;

  @override
  String get tooltipBgColorValue =>
      component?.tooltipBackgroundColor?.value ?? super.tooltipBgColorValue;

  @override
  String get tooltipTextColorValue =>
      component?.tooltipTextColor?.value ?? super.tooltipTextColorValue;

  @override
  Token get tooltipBorderRadius => component?.tooltipBorderRadius != null
      ? Token(
          value: component!.tooltipBorderRadius!.cssText,
          name: super.tooltipBorderRadius.name,
        )
      : super.tooltipBorderRadius;

  @override
  Token get tooltipFontSize => component?.tooltipFontSize != null
      ? Token(
          value: component!.tooltipFontSize!.cssText,
          name: super.tooltipFontSize.name,
        )
      : super.tooltipFontSize;

  @override
  String get popoverBgColorValue =>
      component?.popoverBackgroundColor?.value ?? super.popoverBgColorValue;

  @override
  String get popoverTextColorValue =>
      component?.popoverTextColor?.value ?? super.popoverTextColorValue;

  @override
  String get popoverBorderColorValue =>
      component?.popoverBorderColor?.value ?? super.popoverBorderColorValue;

  @override
  Token get popoverBorderRadius => component?.popoverBorderRadius != null
      ? Token(
          value: component!.popoverBorderRadius!.cssText,
          name: super.popoverBorderRadius.name,
        )
      : super.popoverBorderRadius;

  @override
  String get dialogBgColorValue =>
      component?.dialogBackgroundColor?.value ?? super.dialogBgColorValue;

  @override
  Token get dialogBorderRadius => component?.dialogBorderRadius != null
      ? Token(
          value: component!.dialogBorderRadius!.cssText,
          name: super.dialogBorderRadius.name,
        )
      : super.dialogBorderRadius;

  @override
  String get dialogBarrierBgValue =>
      component?.dialogBarrierBackgroundColor?.value ??
      super.dialogBarrierBgValue;

  @override
  String get drawerBgColorValue =>
      component?.drawerBackgroundColor?.value ?? super.drawerBgColorValue;

  @override
  Token get drawerWidth => component?.drawerWidth != null
      ? Token(
          value: component!.drawerWidth!.cssText,
          name: super.drawerWidth.name,
        )
      : super.drawerWidth;

  @override
  String get drawerBarrierBgValue =>
      component?.drawerBarrierBackgroundColor?.value ??
      super.drawerBarrierBgValue;

  @override
  String get bottomSheetBgColorValue =>
      component?.bottomSheetBackgroundColor?.value ??
      super.bottomSheetBgColorValue;

  @override
  Token get bottomSheetMaxHeight => component?.bottomSheetMaxHeight != null
      ? Token(
          value: component!.bottomSheetMaxHeight!.cssText,
          name: super.bottomSheetMaxHeight.name,
        )
      : super.bottomSheetMaxHeight;

  @override
  String get bottomSheetBarrierBgValue =>
      component?.bottomSheetBarrierBackgroundColor?.value ??
      super.bottomSheetBarrierBgValue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LightThemeData &&
        other.colorSeed == colorSeed &&
        other.typography == typography &&
        other.spacing == spacing &&
        other.borderWidth == borderWidth &&
        other.elevation == elevation &&
        other.radius == radius &&
        other.component == component &&
        other.styles == styles;
  }

  @override
  int get hashCode => Object.hashAll([
    colorSeed,
    typography,
    spacing,
    borderWidth,
    elevation,
    radius,
    component,
    styles,
  ]);
}

/// Theme data for dark mode used in [ThemeConfig].
///
/// Allows customization of colors, typography, spacing, borders, elevation,
/// border radius, shapes, and component-specific token overrides.
class DarkThemeData extends _DarkModeTokens {
  /// Seed for customizing base and semantic color tokens.
  final ColorSeed? colorSeed;

  /// Seed for customizing font family, sizes, and weights.
  final TypographyScheme? typography;

  /// Seed for customizing global padding and margin spacing tokens.
  final SpacingScheme? spacing;

  /// Seed for customizing border width tokens.
  final BorderScheme? borderWidth;

  /// Seed for customizing shadow and elevation color tokens.
  final ElevationScheme? elevation;

  /// Seed for customizing border radius tokens.
  final RadiusScheme? radius;

  /// Seed for customizing component-specific token overrides.
  final ComponentScheme? component;

  /// Custom CSS key-value variables to inject into dark mode styles.
  final Map<String, String>? styles;

  const DarkThemeData({
    this.colorSeed,
    this.typography,
    this.spacing,
    this.borderWidth,
    this.elevation,
    this.radius,
    this.component,
    this.styles,
  }) : super(styles);

  @override
  String get colorScheme => 'dark';

  // ===========================================================================
  // Color Tokens Overrides (String Values)
  // ===========================================================================

  @override
  String get primaryColorValue =>
      colorSeed?.primary?.value ?? super.primaryColorValue;

  @override
  String get secondaryColorValue =>
      colorSeed?.secondary?.value ?? super.secondaryColorValue;

  @override
  String get accentColorValue =>
      colorSeed?.accent?.value ?? super.accentColorValue;

  @override
  String get greenValue => colorSeed?.green?.value ?? super.greenValue;

  @override
  String get yellowValue => colorSeed?.yellow?.value ?? super.yellowValue;

  @override
  String get redValue => colorSeed?.red?.value ?? super.redValue;

  @override
  String get baseTextColorValue =>
      colorSeed?.baseTextColor?.value ?? super.baseTextColorValue;

  @override
  String get placeholderColorValue =>
      colorSeed?.placeholderColor?.value ?? super.placeholderColorValue;

  @override
  String get mutedColorValue =>
      colorSeed?.mutedColor?.value ?? super.mutedColorValue;

  @override
  String get subtitleColorValue =>
      colorSeed?.subtitleColor?.value ?? super.subtitleColorValue;

  @override
  String get selectedItemColorValue =>
      colorSeed?.selectedItemColor?.value ?? super.selectedItemColorValue;

  @override
  String get selectedTextBgColorValue =>
      colorSeed?.selectedTextBackgroundColor?.value ??
      super.selectedTextBgColorValue;

  @override
  String get selectedTextColorValue =>
      colorSeed?.selectedTextColor?.value ?? super.selectedTextColorValue;

  @override
  String get selectedItemBgColorValue =>
      colorSeed?.selectedItemBackgroundColor?.value ??
      super.selectedItemBgColorValue;

  @override
  String get backgroundColorValue =>
      colorSeed?.backgroundColor?.value ?? super.backgroundColorValue;

  @override
  String get borderColorValue =>
      borderWidth?.borderColor?.value ?? super.borderColorValue;

  @override
  String get errorColorValue =>
      colorSeed?.errorColor?.value ?? super.errorColorValue;

  @override
  String get successColorValue =>
      colorSeed?.successColor?.value ?? super.successColorValue;

  @override
  String get warningColorValue =>
      colorSeed?.warningColor?.value ?? super.warningColorValue;

  @override
  String get infoColorValue =>
      colorSeed?.infoColor?.value ?? super.infoColorValue;

  @override
  String get errorWeakColorValue =>
      colorSeed?.errorWeakColor?.value ?? super.errorWeakColorValue;

  @override
  String get successWeakColorValue =>
      colorSeed?.successWeakColor?.value ?? super.successWeakColorValue;

  @override
  String get warningWeakColorValue =>
      colorSeed?.warningWeakColor?.value ?? super.warningWeakColorValue;

  @override
  String get infoWeakColorValue =>
      colorSeed?.infoWeakColor?.value ?? super.infoWeakColorValue;

  @override
  String get surfaceVariantColorValue =>
      colorSeed?.surfaceVariantColor?.value ?? super.surfaceVariantColorValue;

  @override
  String get surfaceMutedColorValue =>
      colorSeed?.surfaceMutedColor?.value ?? super.surfaceMutedColorValue;

  @override
  String get shadowColorValue =>
      elevation?.shadowColor?.value ?? super.shadowColorValue;

  @override
  String get smallShadowColorValue =>
      elevation?.smallShadowColor?.value ?? super.smallShadowColorValue;

  @override
  String get mediumShadowColorValue =>
      elevation?.mediumShadowColor?.value ?? super.mediumShadowColorValue;

  @override
  String get largeShadowColorValue =>
      elevation?.largeShadowColor?.value ?? super.largeShadowColorValue;

  @override
  String get focusBorderColorValue =>
      colorSeed?.focusBorderColor?.value ?? super.focusBorderColorValue;

  @override
  String get hoverColorValue =>
      colorSeed?.hoverColor?.value ?? super.hoverColorValue;

  @override
  String get disabledBgColorValue =>
      colorSeed?.disabledBackgroundColor?.value ?? super.disabledBgColorValue;

  @override
  String get disabledColorValue =>
      colorSeed?.disabledColor?.value ?? super.disabledColorValue;

  // ===========================================================================
  // Border Tokens Overrides
  // ===========================================================================

  @override
  Token get border => borderWidth?.borderWidth != null
      ? Token(
          value:
              '${borderWidth!.borderWidth!.cssText} solid var($borderColor, ${borderColor.value})',
          name: super.border.name,
        )
      : super.border;

  @override
  Token get fieldHoverBorder => borderWidth?.fieldHoverBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.fieldHoverBorderWidth!.cssText} solid var($fieldHoverColor, ${fieldHoverColor.value})',
          name: super.fieldHoverBorder.name,
        )
      : super.fieldHoverBorder;

  @override
  Token get focusBorder => borderWidth?.focusBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.focusBorderWidth!.cssText} solid var($focusBorderColor, ${focusBorderColor.value})',
          name: super.focusBorder.name,
        )
      : super.focusBorder;

  @override
  Token get errorBorder => borderWidth?.errorBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.errorBorderWidth!.cssText} solid var($errorColor, ${errorColor.value})',
          name: super.errorBorder.name,
        )
      : super.errorBorder;

  // ===========================================================================
  // Typography Tokens Overrides
  // ===========================================================================

  @override
  Token get fontFamily =>
      typography?.fontFamily != null && typography!.fontFamily!.isNotEmpty
      ? Token(
          value: typography!.fontFamily!.join(','),
          name: super.fontFamily.name,
        )
      : super.fontFamily;

  @override
  Token get fontSizeSm => typography?.fontSizeSm != null
      ? Token(
          value: typography!.fontSizeSm!.cssText,
          name: super.fontSizeSm.name,
        )
      : super.fontSizeSm;

  @override
  Token get fontSizeMd => typography?.fontSizeMd != null
      ? Token(
          value: typography!.fontSizeMd!.cssText,
          name: super.fontSizeMd.name,
        )
      : super.fontSizeMd;

  @override
  Token get fontSizeLg => typography?.fontSizeLg != null
      ? Token(
          value: typography!.fontSizeLg!.cssText,
          name: super.fontSizeLg.name,
        )
      : super.fontSizeLg;

  @override
  Token get fontSizeXl => typography?.fontSizeXl != null
      ? Token(
          value: typography!.fontSizeXl!.cssText,
          name: super.fontSizeXl.name,
        )
      : super.fontSizeXl;

  @override
  Token get fontSize2xl => typography?.fontSize2xl != null
      ? Token(
          value: typography!.fontSize2xl!.cssText,
          name: super.fontSize2xl.name,
        )
      : super.fontSize2xl;

  @override
  Token get fontSize3xl => typography?.fontSize3xl != null
      ? Token(
          value: typography!.fontSize3xl!.cssText,
          name: super.fontSize3xl.name,
        )
      : super.fontSize3xl;

  @override
  Token get fontSize4xl => typography?.fontSize4xl != null
      ? Token(
          value: typography!.fontSize4xl!.cssText,
          name: super.fontSize4xl.name,
        )
      : super.fontSize4xl;

  @override
  Token get fontSize5xl => typography?.fontSize5xl != null
      ? Token(
          value: typography!.fontSize5xl!.cssText,
          name: super.fontSize5xl.name,
        )
      : super.fontSize5xl;

  @override
  Token get fontSizeError => typography?.fontSizeError != null
      ? Token(
          value: typography!.fontSizeError!.cssText,
          name: super.fontSizeError.name,
        )
      : super.fontSizeError;

  @override
  Token get fontSizeHint => typography?.fontSizeHint != null
      ? Token(
          value: typography!.fontSizeHint!.cssText,
          name: super.fontSizeHint.name,
        )
      : super.fontSizeHint;

  @override
  Token get fontSizeLabel => typography?.fontSizeLabel != null
      ? Token(
          value: typography!.fontSizeLabel!.cssText,
          name: super.fontSizeLabel.name,
        )
      : super.fontSizeLabel;

  @override
  Token get fontSizeSectionHeader => typography?.fontSizeSectionHeader != null
      ? Token(
          value: typography!.fontSizeSectionHeader!.cssText,
          name: super.fontSizeSectionHeader.name,
        )
      : super.fontSizeSectionHeader;

  @override
  Token get fontWeightNormal => typography?.fontWeightNormal != null
      ? Token(
          value: typography!.fontWeightNormal.toString(),
          name: super.fontWeightNormal.name,
        )
      : super.fontWeightNormal;

  @override
  Token get fontWeightMedium => typography?.fontWeightMedium != null
      ? Token(
          value: typography!.fontWeightMedium.toString(),
          name: super.fontWeightMedium.name,
        )
      : super.fontWeightMedium;

  @override
  Token get fontWeightSemiBold => typography?.fontWeightSemiBold != null
      ? Token(
          value: typography!.fontWeightSemiBold.toString(),
          name: super.fontWeightSemiBold.name,
        )
      : super.fontWeightSemiBold;

  @override
  Token get fontWeightBold => typography?.fontWeightBold != null
      ? Token(
          value: typography!.fontWeightBold.toString(),
          name: super.fontWeightBold.name,
        )
      : super.fontWeightBold;

  @override
  Token get fontWeightSectionHeader =>
      typography?.fontWeightSectionHeader != null
      ? Token(
          value: typography!.fontWeightSectionHeader.toString(),
          name: super.fontWeightSectionHeader.name,
        )
      : super.fontWeightSectionHeader;

  // ===========================================================================
  // Spacing Tokens Overrides
  // ===========================================================================

  @override
  Token get paddingSm => spacing?.paddingSm != null
      ? Token(value: spacing!.paddingSm!.cssText, name: super.paddingSm.name)
      : super.paddingSm;

  @override
  Token get paddingMd => spacing?.paddingMd != null
      ? Token(value: spacing!.paddingMd!.cssText, name: super.paddingMd.name)
      : super.paddingMd;

  @override
  Token get paddingLg => spacing?.paddingLg != null
      ? Token(value: spacing!.paddingLg!.cssText, name: super.paddingLg.name)
      : super.paddingLg;

  @override
  Token get marginSm => spacing?.marginSm != null
      ? Token(value: spacing!.marginSm!.cssText, name: super.marginSm.name)
      : super.marginSm;

  @override
  Token get marginMd => spacing?.marginMd != null
      ? Token(value: spacing!.marginMd!.cssText, name: super.marginMd.name)
      : super.marginMd;

  @override
  Token get marginLg => spacing?.marginLg != null
      ? Token(value: spacing!.marginLg!.cssText, name: super.marginLg.name)
      : super.marginLg;

  // ===========================================================================
  // Border Radius Tokens Overrides
  // ===========================================================================

  @override
  Token get radiusSm => radius?.radiusSm != null
      ? Token(value: radius!.radiusSm!.cssText, name: super.radiusSm.name)
      : super.radiusSm;

  @override
  Token get radiusMd => radius?.radiusMd != null
      ? Token(value: radius!.radiusMd!.cssText, name: super.radiusMd.name)
      : super.radiusMd;

  @override
  Token get radiusLg => radius?.radiusLg != null
      ? Token(value: radius!.radiusLg!.cssText, name: super.radiusLg.name)
      : super.radiusLg;

  // ===========================================================================
  // Component Tokens Overrides
  // ===========================================================================

  @override
  Token get textMaxLines => component?.textMaxLines != null
      ? Token(
          value: component!.textMaxLines.toString(),
          name: super.textMaxLines.name,
        )
      : super.textMaxLines;

  @override
  Token get inputHeight => component?.inputHeight != null
      ? Token(
          value: component!.inputHeight!.cssText,
          name: super.inputHeight.name,
        )
      : super.inputHeight;

  @override
  String get inputTextColorValue =>
      component?.inputTextColor?.value ?? super.inputTextColorValue;

  @override
  String get labelColorValue =>
      component?.labelColor?.value ?? super.labelColorValue;

  @override
  Token get fontSizeInput => component?.fontSizeInput != null
      ? Token(
          value: component!.fontSizeInput!.cssText,
          name: super.fontSizeInput.name,
        )
      : super.fontSizeInput;

  @override
  String get fieldBackgroundColorValue =>
      component?.fieldBackgroundColor?.value ?? super.fieldBackgroundColorValue;

  @override
  String get fieldHoverColorValue =>
      component?.fieldHoverColor?.value ?? super.fieldHoverColorValue;

  @override
  String get buttonBackgroundColorValue =>
      component?.buttonBackgroundColor?.value ??
      super.buttonBackgroundColorValue;

  @override
  String get buttonColorValue =>
      component?.buttonColor?.value ?? super.buttonColorValue;

  @override
  String get buttonHoverBgColorValue =>
      component?.buttonHoverBgColor?.value ?? super.buttonHoverBgColorValue;

  @override
  Token get buttonHeight => component?.buttonHeight != null
      ? Token(
          value: component!.buttonHeight!.cssText,
          name: super.buttonHeight.name,
        )
      : super.buttonHeight;

  @override
  Token get buttonWidth => component?.buttonWidth != null
      ? Token(
          value: component!.buttonWidth!.cssText,
          name: super.buttonWidth.name,
        )
      : super.buttonWidth;

  @override
  Token get dropdownHeight => component?.dropdownHeight != null
      ? Token(
          value: component!.dropdownHeight!.cssText,
          name: super.dropdownHeight.name,
        )
      : super.dropdownHeight;

  @override
  Token get dropdownWidth => component?.dropdownWidth != null
      ? Token(
          value: component!.dropdownWidth!.cssText,
          name: super.dropdownWidth.name,
        )
      : super.dropdownWidth;

  @override
  Token get dropdownMenuHeight => component?.dropdownMenuHeight != null
      ? Token(
          value: component!.dropdownMenuHeight!.cssText,
          name: super.dropdownMenuHeight.name,
        )
      : super.dropdownMenuHeight;

  @override
  String get dropdownMenuBgColorValue =>
      component?.dropdownMenuBackgroundColor?.value ??
      super.dropdownMenuBgColorValue;

  @override
  Token get dropdownOptionFontSize => component?.dropdownOptionFontSize != null
      ? Token(
          value: component!.dropdownOptionFontSize!.cssText,
          name: super.dropdownOptionFontSize.name,
        )
      : super.dropdownOptionFontSize;

  @override
  Token get dropdownOptionPadding => component?.dropdownOptionPadding != null
      ? Token(
          value: component!.dropdownOptionPadding!.cssText,
          name: super.dropdownOptionPadding.name,
        )
      : super.dropdownOptionPadding;

  @override
  Token get spinnerSize => component?.spinnerSize != null
      ? Token(
          value: component!.spinnerSize!.cssText,
          name: super.spinnerSize.name,
        )
      : super.spinnerSize;

  @override
  Token get spinnerBorderWidth => component?.spinnerBorderWidth != null
      ? Token(
          value: component!.spinnerBorderWidth!.cssText,
          name: super.spinnerBorderWidth.name,
        )
      : super.spinnerBorderWidth;

  @override
  String get spinnerTrackColorValue =>
      component?.spinnerTrackColor?.value ?? super.spinnerTrackColorValue;

  @override
  String get spinnerSurfaceColorValue =>
      component?.spinnerSurfaceColor?.value ?? super.spinnerSurfaceColorValue;

  @override
  String get sliderThumbColorValue =>
      component?.sliderThumbColor?.value ?? super.sliderThumbColorValue;

  @override
  String get sliderTrackColorValue =>
      component?.sliderTrackColor?.value ?? super.sliderTrackColorValue;

  @override
  Token get sliderThumbSize => component?.sliderThumbSize != null
      ? Token(
          value: component!.sliderThumbSize!.cssText,
          name: super.sliderThumbSize.name,
        )
      : super.sliderThumbSize;

  @override
  String get switchThumbColorValue =>
      component?.switchThumbColor?.value ?? super.switchThumbColorValue;

  @override
  Token get radioBtnRadius => component?.radioButtonRadius != null
      ? Token(
          value: component!.radioButtonRadius!.cssText,
          name: super.radioBtnRadius.name,
        )
      : super.radioBtnRadius;

  @override
  String get radioBtnColorValue =>
      component?.radioButtonColor?.value ?? super.radioBtnColorValue;

  @override
  String get appbarBgColorValue =>
      component?.appbarBackgroundColor?.value ?? super.appbarBgColorValue;

  @override
  Token get appbarHeight => component?.appbarHeight != null
      ? Token(
          value: component!.appbarHeight!.cssText,
          name: super.appbarHeight.name,
        )
      : super.appbarHeight;

  @override
  String get bottomNavbarBgColorValue =>
      component?.bottomNavbarBackgroundColor?.value ??
      super.bottomNavbarBgColorValue;

  @override
  Token get bottomNavbarHeight => component?.bottomNavbarHeight != null
      ? Token(
          value: component!.bottomNavbarHeight!.cssText,
          name: super.bottomNavbarHeight.name,
        )
      : super.bottomNavbarHeight;

  @override
  Token get carouselItemExtent => component?.carouselItemExtent != null
      ? Token(
          value: component!.carouselItemExtent!.cssText,
          name: super.carouselItemExtent.name,
        )
      : super.carouselItemExtent;

  @override
  Token get carouselGap => component?.carouselGap != null
      ? Token(
          value: component!.carouselGap!.cssText,
          name: super.carouselGap.name,
        )
      : super.carouselGap;

  @override
  String get tableHeaderBgValue =>
      component?.tableHeaderBackgroundColor?.value ?? super.tableHeaderBgValue;

  @override
  String get tableRowHoverBgValue =>
      component?.tableRowHoverColor?.value ?? super.tableRowHoverBgValue;

  @override
  Token get gridGap => component?.gridGap != null
      ? Token(value: component!.gridGap!.cssText, name: super.gridGap.name)
      : super.gridGap;

  @override
  String get snackbarBgColorValue =>
      component?.snackbarBackgroundColor?.value ?? super.snackbarBgColorValue;

  @override
  String get snackbarForegroundColorValue =>
      component?.snackbarForegroundColor?.value ??
      super.snackbarForegroundColorValue;

  @override
  Token get snackbarBorderRadius => component?.snackbarBorderRadius != null
      ? Token(
          value: component!.snackbarBorderRadius!.cssText,
          name: super.snackbarBorderRadius.name,
        )
      : super.snackbarBorderRadius;

  @override
  String get bannerBgColorValue =>
      component?.bannerBackgroundColor?.value ?? super.bannerBgColorValue;

  @override
  String get bannerForegroundColorValue =>
      component?.bannerForegroundColor?.value ??
      super.bannerForegroundColorValue;

  @override
  Token get bannerBorderRadius => component?.bannerBorderRadius != null
      ? Token(
          value: component!.bannerBorderRadius!.cssText,
          name: super.bannerBorderRadius.name,
        )
      : super.bannerBorderRadius;

  @override
  String get bannerBorderColorValue =>
      component?.bannerBorderColor?.value ?? super.bannerBorderColorValue;

  @override
  String get tooltipBgColorValue =>
      component?.tooltipBackgroundColor?.value ?? super.tooltipBgColorValue;

  @override
  String get tooltipTextColorValue =>
      component?.tooltipTextColor?.value ?? super.tooltipTextColorValue;

  @override
  Token get tooltipBorderRadius => component?.tooltipBorderRadius != null
      ? Token(
          value: component!.tooltipBorderRadius!.cssText,
          name: super.tooltipBorderRadius.name,
        )
      : super.tooltipBorderRadius;

  @override
  Token get tooltipFontSize => component?.tooltipFontSize != null
      ? Token(
          value: component!.tooltipFontSize!.cssText,
          name: super.tooltipFontSize.name,
        )
      : super.tooltipFontSize;

  @override
  String get popoverBgColorValue =>
      component?.popoverBackgroundColor?.value ?? super.popoverBgColorValue;

  @override
  String get popoverTextColorValue =>
      component?.popoverTextColor?.value ?? super.popoverTextColorValue;

  @override
  String get popoverBorderColorValue =>
      component?.popoverBorderColor?.value ?? super.popoverBorderColorValue;

  @override
  Token get popoverBorderRadius => component?.popoverBorderRadius != null
      ? Token(
          value: component!.popoverBorderRadius!.cssText,
          name: super.popoverBorderRadius.name,
        )
      : super.popoverBorderRadius;

  @override
  String get dialogBgColorValue =>
      component?.dialogBackgroundColor?.value ?? super.dialogBgColorValue;

  @override
  Token get dialogBorderRadius => component?.dialogBorderRadius != null
      ? Token(
          value: component!.dialogBorderRadius!.cssText,
          name: super.dialogBorderRadius.name,
        )
      : super.dialogBorderRadius;

  @override
  String get dialogBarrierBgValue =>
      component?.dialogBarrierBackgroundColor?.value ??
      super.dialogBarrierBgValue;

  @override
  String get drawerBgColorValue =>
      component?.drawerBackgroundColor?.value ?? super.drawerBgColorValue;

  @override
  Token get drawerWidth => component?.drawerWidth != null
      ? Token(
          value: component!.drawerWidth!.cssText,
          name: super.drawerWidth.name,
        )
      : super.drawerWidth;

  @override
  String get drawerBarrierBgValue =>
      component?.drawerBarrierBackgroundColor?.value ??
      super.drawerBarrierBgValue;

  @override
  String get bottomSheetBgColorValue =>
      component?.bottomSheetBackgroundColor?.value ??
      super.bottomSheetBgColorValue;

  @override
  Token get bottomSheetMaxHeight => component?.bottomSheetMaxHeight != null
      ? Token(
          value: component!.bottomSheetMaxHeight!.cssText,
          name: super.bottomSheetMaxHeight.name,
        )
      : super.bottomSheetMaxHeight;

  @override
  String get bottomSheetBarrierBgValue =>
      component?.bottomSheetBarrierBackgroundColor?.value ??
      super.bottomSheetBarrierBgValue;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DarkThemeData &&
        other.colorSeed == colorSeed &&
        other.typography == typography &&
        other.spacing == spacing &&
        other.borderWidth == borderWidth &&
        other.elevation == elevation &&
        other.radius == radius &&
        other.component == component &&
        other.styles == styles;
  }

  @override
  int get hashCode => Object.hashAll([
    colorSeed,
    typography,
    spacing,
    borderWidth,
    elevation,
    radius,
    component,
    styles,
  ]);
}

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
    css('').styles(raw: {'-----default-styles-----': '""'}),

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
