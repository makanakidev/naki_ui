part of 'theme.dart';

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

  /// Returns the current theme mode.
  ///
  /// Returns [ThemeMode.system] for backward compatibility if no
  /// [NakiThemeProvider] is in the component tree.
  static ThemeMode modeOf(BuildContext context) =>
      of(context)?.mode ?? ThemeMode.system;

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
        styles.addAll(Rules.buildScrollbarRules(':root', scrollBarConfig));
      }

      // default style rules
      styles.addAll(baseStyles);

      // custom style rules
      styles.addAll(_config?.styles ?? []);
    }

    // Set custom theme styles if tokens are provided
    if (hasCustomTokens) {
      // scroll bar styles
      if (scrollBarConfig != null) {
        styles.addAll(Rules.buildScrollbarRules(':root', scrollBarConfig));
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

      // custom style rules
      styles.addAll(_config?.styles ?? []);
    }

    final themedContent = InheritedTheme(
      mode: _mode,
      tokens: _tokens,
      brightness: _brightness,
      systemBrightness: _systemBrightness,
      configuration: _config,
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

  /// Theme configuration used to create this theme.
  final ThemeConfig? configuration;

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
    this.configuration,
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
