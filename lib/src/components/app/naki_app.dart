part of 'index.dart';

/// {@template NakiApp}
/// [NakiApp] is the root component of a Jaspr application.
///
/// It provides app-wide configuration including theme management
/// ([NakiThemeProvider]), global text styling ([DefaultTextStyle]),
/// HTML `<head>` metadata (title, SEO, favicon, viewport, charset),
/// safe area layout ([SafeArea]), and routing ([Router]).
///
/// > **NOTE**: [NakiApp] must be placed inside a `@client` annotated
/// > component to access Web APIs and call [NakiThemeProvider.of],
/// > [DefaultTextStyle.of], [RouterState.push], etc.
///
/// ### Application Without Routing:
/// ```dart
/// class MyApp extends StatelessComponent {
///   const MyApp({super.key});
///
///   @override
///   Component build(BuildContext context) {
///     return NakiApp(
///       title: 'My Application',
///       themeMode: ThemeMode.system,
///       home: const HomePage(),
///     );
///   }
/// }
/// ```
///
/// ### Application With Routing:
/// ```dart
/// class MyApp extends StatelessComponent {
///   const MyApp({super.key});
///
///   @override
///   Component build(BuildContext context) {
///     return NakiApp.router(
///       title: 'My Routed App',
///       themeMode: ThemeMode.dark,
///       routes: [
///         Route(
///           path: '/',
///           name: 'home',
///           builder: (context, state) => const HomePage(),
///         ),
///         Route(
///           path: '/settings',
///           name: 'settings',
///           builder: (context, state) => const SettingsPage(),
///         ),
///       ],
///     );
///   }
/// }
/// ```
/// {@endtemplate}
class NakiApp extends StatefulComponent {
  /// A one-line description used by the browser to identify the application.
  ///
  /// [SEO.title] takes precedence over [title] if provided.
  final String? title;

  /// This configures the application's initial localisation.
  ///
  /// If [locale] is `null`, the default locale value [`en`] is used.
  final String? locale;

  /// Default style for all texts in the application.
  final TextStyle? textStyle;

  /// The base path for the application.
  ///
  /// If provided, the path must start with a slash. If `null`, the default
  /// path is "/".
  final String? basePath;

  /// Deprecated builder for the [home] page.
  ///
  /// Use [home] for the root component and [builder] to wrap
  /// the root [Navigator] instead.
  @Deprecated('This will be removed in v2.0.0. Use builder instead.')
  final NakiPageBuilder<Component>? pageBuilder;

  /// This configures the application's charset (default: 'utf-8').
  final String? charset;

  /// This configures the application's viewport
  /// (default: 'width=device-width, initial-scale=1.0').
  final String? viewport;

  /// SEO configuration for the application.
  final SEO? seo;

  /// Additional meta tags to be added to the application's head.
  final Map<String, String> metaTags;

  /// Additional components (such as script, link) for font loading,
  /// analytics, etc. that are to be added to the application's head.
  final List<Component> head;

  /// The [builder] callback has two arguments: the [BuildContext] (as
  /// `context`) and the application [Navigator] wrapping [home] or [Router]
  /// (or an empty [SizedBox] when neither [home] nor [routes] is provided
  /// on [NakiApp] and [NakiApp.router] constructors respectively).
  ///
  /// Any [InheritedComponent] or provider returned by [builder] becomes an
  /// ancestor of [home], [routes], pushed [NakiRoute]s, and overlay portals.
  ///
  /// For example, from the [BuildContext] passed to this method,
  /// [NakiThemeProvider.of] and [DefaultTextStyle.of] work in both
  /// server and client environments.
  ///
  /// `child` is non-null and must be included in the returned subtree to
  /// preserve navigation and overlays.
  ///
  /// ### Example
  /// ```dart
  /// NakiApp.router(
  ///   routes: [
  ///     Route(
  ///       path: '/',
  ///       name: 'home',
  ///       builder: (context, state) => const HomePage(),
  ///     ),
  ///   ],
  ///   builder: (context, child) {
  ///     return MyAuthScope(child: child!);
  ///   },
  /// );
  /// ```
  final NakiPageBuilder<Component>? builder;

  /// Component displayed when a route is not found in [routes].
  ///
  /// When `null`, the default [PageNotFound] will be rendered.
  final Component? errorPage;

  /// A global state key to use when building the [Router].
  ///
  /// If [navigatorKey] is specified, the [RouterState] can be directly
  /// accessed without first obtaining it from a [BuildContext] via
  /// [Router.of].
  ///
  /// From [navigatorKey], use the [GlobalStateKey.currentState] getter.
  ///
  /// If this is changed, a new [Router] will be created, losing all
  /// the application state in the process.
  ///
  /// The [Router] is only built if [routes] is not `null`; if
  /// it is `null` or empty, [navigatorKey] will be ignored.
  final GlobalStateKey<RouterState>? navigatorKey;

  /// The component displayed first when the application is loaded.
  ///
  /// ### When to use [home] vs [builder]
  /// - Use [home] when your root view is a pre-instantiated or `const` component
  ///   (e.g., `home: const MyHomeScreen()`) that does not need direct access
  ///   to [NakiApp]'s internal [BuildContext] during instantiation. Descendant
  ///   components inside [home] will still have full access to
  ///   `context.themeTokens` and theme methods in their own `build` methods.
  /// - Use [builder] to wrap the root [Navigator] with providers or inherited
  ///   components above [home]. When [home] is omitted, [builder] receives a
  ///   [Navigator] wrapping an empty [SizedBox].
  final Component? home;

  /// The application's top-level routing configuration.
  ///
  /// If the application only has one page, you can use the default
  /// [NakiApp] constructor with [home] instead.
  ///
  /// If a route is requested that is not specified in this property,
  /// then [errorPage] will be shown (if any), otherwise the default
  /// [PageNotFound] will be rendered.
  ///
  /// The [Router] component is only built if [routes] is provided; if `null`
  /// or empty, [builder] receives a [Navigator] wrapping an empty [SizedBox].
  final List<RouteBase>? routes;

  /// Application theme mode (default is [ThemeMode.system]).
  ///
  /// This determines which design tokens are applicable for use
  /// in Naki components, such as [AppBar], [Container], etc.
  ///
  /// The available values are:
  /// - `light` - the light mode theme
  /// - `dark` - the dark mode theme
  /// - `system` - the system theme
  final ThemeMode themeMode;

  /// Light mode theme configuration.
  ///
  /// When `null`, the default light mode configuration is used.
  final LightThemeData? lightTheme;

  /// Dark mode theme configuration.
  ///
  /// When `null`, the default dark mode configuration is used.
  final DarkThemeData? darkTheme;

  /// Enables theme mode caching and restoration.
  ///
  /// When `true`, the theme mode is persisted in local storage and restored
  /// automatically on page loads. Theme mode restoration works across both
  /// server and client environments.
  final bool cacheThemeMode;

  /// The [fontFamily] property overrides the browser-default font
  /// family for all texts in the application.
  ///
  /// To ensure fonts are displayed properly, include the necessary
  /// font loading components in the [head] property.
  final List<String>? fontFamily;

  /// Icon displayed in the browser tab and link previews for branding purposes.
  ///
  /// [favicon] can be a remote URL (e.g. "https://pinkbyte.com/favicon.png"),
  /// an SVG string, a local file path, or a base64 encoded image data.
  final String? favicon;

  /// Scroll bar configuration.
  ///
  /// [NakiApp] scroll bar configuration will be used by all components that use
  /// scroll bar, unless the component has its own scroll bar configuration.
  ///
  /// If `null`, scroll bar will be disabled.
  final ScrollBarConfiguration? scrollBarConfiguration;

  final bool _isRouter;

  /// {@macro NakiApp}
  NakiApp({
    super.key,
    this.metaTags = const {},
    this.head = const [],
    this.cacheThemeMode = false,
    this.themeMode = ThemeMode.system,
    this.basePath,
    this.charset,
    this.viewport,
    this.locale,
    this.home,
    @Deprecated('This will be removed in v2.0.0. Use builder instead.')
    this.pageBuilder,
    this.builder,
    this.fontFamily,
    this.favicon,
    this.seo,
    this.title,
    this.textStyle,
    this.lightTheme,
    this.darkTheme,
    this.scrollBarConfiguration,
  }) : assert(
         // ignore: deprecated_member_use_from_same_package
         home != null || builder != null || pageBuilder != null,
         'Either home, builder, or pageBuilder must be provided',
       ),
       assert(
         basePath == null || basePath.startsWith('/'),
         'basePath must start with a leading slash "/"',
       ),
       routes = null,
       navigatorKey = null,
       errorPage = null,
       _isRouter = false;

  /// Creates a [NakiApp] that uses [Router] component to configure the
  /// application's navigation system with support for two routing types:
  /// <u>server-rendered multi-page routing (MPA)</u> and
  /// <u>client-side single-page routing (SPA)</u>.
  ///
  /// - If **multi-page routing** is required, a "real" page load
  /// is performed when navigating to a new route, i.e. the browser
  /// requests the new page using its url from the server.
  ///
  /// - If **single-page routing** is required, routing happens purely
  /// on the client without any request to the server.
  ///
  /// Usually you would choose `multi-page routing` for more "traditional"
  /// websites with multiple pages, and `single-page routing` for more
  /// self-contained app-like websites (web apps i.e. SPAs).
  ///
  /// **NOTE: [NakiApp.router] constructor must be a descendant of a
  /// `@client` annotated component if single-page routing is required.**
  ///
  /// ### Example when `single-page routing` is required:
  /// ```dart
  /// @client // NOTE: mandatory for single-page client-side routing
  /// class SinglePageApp extends StatelessComponent {
  ///   const SinglePageApp({super.key});
  ///
  ///   @override
  ///   Component build() {
  ///     return NakiApp.router(
  ///       routes: [
  ///         Route(
  ///           path: '/',
  ///           name: 'home',
  ///           builder: (context, state) => const HomePage(),
  ///         ),
  ///       ],
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// ### Example when `multi-page server-side routing` is required:
  /// ```dart
  /// class MultiPageApp extends StatelessComponent {
  ///   const MultiPageApp({super.key});
  ///
  ///   @override
  ///   Component build() {
  ///     return NakiApp.router(
  ///       routes: [
  ///         Route(
  ///           path: '/',
  ///           name: 'home',
  ///           builder: (context, state) => const HomePage(),
  ///         ),
  ///       ],
  ///     );
  ///   }
  /// }
  /// ```
  ///
  /// {@macro NakiApp.router}
  NakiApp.router({
    super.key,
    this.metaTags = const {},
    this.head = const [],
    this.cacheThemeMode = false,
    this.themeMode = ThemeMode.system,
    this.charset,
    this.viewport,
    this.locale,
    this.basePath,
    this.routes,
    this.builder,
    this.fontFamily,
    this.favicon,
    this.seo,
    this.title,
    this.textStyle,
    this.errorPage,
    this.navigatorKey,
    this.lightTheme,
    this.darkTheme,
    this.scrollBarConfiguration,
  }) : assert(
         basePath == null || basePath.startsWith('/'),
         'basePath must start with a leading slash "/"',
       ),
       assert(
         (routes != null && routes.isNotEmpty) || builder != null,
         'Either routes or builder must be provided',
       ),
       home = null,
       pageBuilder = null,
       _isRouter = true;

  @override
  State<NakiApp> createState() => _NakiAppState();
}

class _NakiAppState extends State<NakiApp> {
  late ThemeConfig _themeConfig;

  bool get _useRouter => component._isRouter;

  @override
  void initState() {
    super.initState();
    _syncThemeConfig();
  }

  void _syncThemeConfig() {
    _themeConfig = ThemeConfig(
      lightThemeData: component.lightTheme,
      darkThemeData: component.darkTheme,
      cacheThemeMode: component.cacheThemeMode,
      initialMode: component.themeMode,
      scrollBarConfiguration: component.scrollBarConfiguration,
    );
  }

  @override
  void didUpdateComponent(NakiApp oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.lightTheme != component.lightTheme ||
        oldComponent.darkTheme != component.darkTheme ||
        oldComponent.cacheThemeMode != component.cacheThemeMode ||
        oldComponent.themeMode != component.themeMode ||
        oldComponent.scrollBarConfiguration !=
            component.scrollBarConfiguration) {
      _syncThemeConfig();
    }
  }

  /// Wraps [child] in a [Navigator] so that pushed routes
  /// and overlays share the theme and text style
  /// context of the application.
  Component _withNavigator(Component child) => Navigator(
    home: child,
    routerKey: _useRouter ? component.navigatorKey : null,
  );

  /// Wraps [buildChild] in a [NakiThemeProvider] and
  /// [DefaultTextStyle] so that the application has
  /// a theme and text style context.
  Component _withThemeAndTextStyle(
    ComponentBuilder buildChild,
  ) {
    return NakiThemeProvider.fromConfig(
      configuration: _themeConfig,
      builder: (themeCtx) {
        final textStyles = component.textStyle;
        if (textStyles == null) return buildChild(themeCtx);

        return DefaultTextStyle(
          style: textStyles,
          child: Builder(builder: buildChild),
        );
      },
    );
  }

  /// Builds the application's body, wrapping the content
  /// in a [Navigator] and [NakiThemeProvider]. If [NakiApp.builder]
  /// is provided, it is called with the [context] and [Navigator]
  /// and its result is used as the application's body.
  Component _wrapWithBuilder(
    BuildContext context,
    Component? content, {
    required Component missingFallback,
  }) {
    final navigator = _withNavigator(
      content ??
          (component.builder != null ? const SizedBox() : missingFallback),
    );

    return component.builder?.call(context, navigator) ?? navigator;
  }

  Component get _appBody {
    // When NakiApp.router() is used
    if (_useRouter) {
      final _routes = component.routes ?? [];
      final router = _routes.isNotEmpty
          ? Router(
              routes: _routes,
              key: component.navigatorKey,
              errorBuilder: (_, state) =>
                  component.errorPage ??
                  PageNotFound(errorText: state.error?.toString()),
            )
          : null;

      return _withThemeAndTextStyle(
        (ctx) => _wrapWithBuilder(
          ctx,
          router,
          missingFallback: const PageNotFound(
            errorTitle: 'Unable to build application home',
            errorText: 'No routes or builder provided',
          ),
        ),
      );
    }

    // When NakiApp() is used
    return _withThemeAndTextStyle((ctx) {
      // ignore: deprecated_member_use_from_same_package
      final legacyPageBuilder = component.pageBuilder;
      final page = legacyPageBuilder != null
          ? legacyPageBuilder(ctx, component.home)
          : component.home;

      return _wrapWithBuilder(
        ctx,
        page,
        missingFallback: const PageNotFound(
          errorTitle: 'Unable to build application page',
          errorText: 'No home component or builder provided',
        ),
      );
    });
  }

  String? get fontFamily {
    return component.fontFamily
        ?.map(
          (f) => f.contains(' ') && !f.startsWith('"') && !f.startsWith("'")
              ? '"$f"'
              : f,
        )
        .join(', ');
  }

  (String, String)? get favicon {
    final favico = component.favicon ?? '';
    String? type;

    if (favico.isNotEmpty) {
      if (favico.endsWith('.svg')) {
        type = 'image/svg+xml';
      } else if (favico.endsWith('.ico')) {
        type = 'image/x-icon';
      } else if (favico.endsWith('.gif')) {
        type = 'image/gif';
      } else {
        type = 'image/png';
      }
    }

    return type == null ? null : (favico, type);
  }

  String get normalisedBasePath {
    String base = component.basePath ?? context.binding.basePath;
    if (base.isEmpty) return _defaultBasePath;

    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';

    return base;
  }

  List<Component> get seoTags => seoTagBuilder(
    component.seo,
    context: context,
    defaultTitle: component.title,
  );

  String get mergedViewport {
    final viewport = (component.viewport ?? '').split(',');
    if (viewport.isEmpty) return _defaultViewport;

    final defaultViewportItems = _defaultViewport.split(', ');
    final viewportItems = viewport.map((v) => v.trim()).toList();

    final map = <String, String>{};
    final mergedViewport = {...defaultViewportItems, ...viewportItems}.toSet();

    for (final v in mergedViewport) {
      if (!v.contains('=')) continue;
      final split = v.split('=');
      map[split.first] = split.last;
    }

    return map.isEmpty
        ? _defaultViewport
        : map.entries.map((e) => '${e.key}=${e.value}').join(', ');
  }

  @override
  Component build(BuildContext context) {
    final fontFamilyVar = Tokens.current.fontFamily.name;
    final fontFamilyCSS = css('body').styles(raw: {fontFamilyVar: ?fontFamily});
    final effectiveTitle = component.seo?.title ?? component.title ?? '';

    final themeScript = themeSwitchingScript(
      component.themeMode.name,
      component.cacheThemeMode,
    );

    return AppScope(
      child: NakiFragment([
        Document.head(
          children: [
            .element(
              tag: 'meta',
              attributes: {'charset': component.charset ?? _defaultCharset},
            ),
          ],
        ),

        // meta tags
        Document.head(
          title: effectiveTitle.isEmpty ? null : effectiveTitle,
          meta: {
            'viewport': mergedViewport,
            'designed-with': 'https://pub.dev/packages/naki_ui',
            'mobile-web-app-capable': 'yes',
            'apple-mobile-web-app-capable': 'yes',
            'apple-touch-fullscreen': 'yes',
            ...component.metaTags,
          },
          children: [
            // html lang
            Document.html(
              attributes: {'lang': component.locale ?? _defaultLocale},
            ),

            // base path
            .element(tag: 'base', attributes: {'href': normalisedBasePath}),

            // default theme tokens
            StyleRules(ThemeConfig.defaultStyles, id: 'tokens'),

            // theme script
            script(content: themeScript, id: 'nts'),

            // icon
            if (favicon case (final href, final type))
              link(href: href, rel: 'icon', type: type),

            // seo tags
            ...seoTags,

            // set font family
            if (fontFamily.isNotNullAndEmpty)
              StyleRules(
                [fontFamilyCSS],
                attributes: const {'type': 'text/css'},
              ),

            // additional head components
            ...component.head,
          ],
        ),

        // app body (includes the overlay region)
        _appBody,
      ]),
    );
  }
}
