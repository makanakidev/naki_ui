import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../framework/inherited.dart' show AppScope;
import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/text_style.dart';
import '../theme/theme.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import 'basics.dart';
import 'layout.dart';
import 'scaffold.dart';
import 'styling.dart';

const String _defaultViewport = 'width=device-width, initial-scale=1.0';
const String _defaultCharset = 'utf-8';
const String _defaultLocale = 'en';
const String _defaultBasePath = '/';

/// A builder that builds a component given a child.
/// The child should typically be part of the returned component tree.
typedef NakiPageBuilder<T extends Component> = T Function(BuildContext context, T? child);

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

  /// Initial location or page to load in the browser.
  ///
  /// If provided, the location must start and end with a slash.
  /// If `null`, the default location [`"/"`] is used.
  final String? initialLocation;

  /// The [pageBuilder] callback has two arguments, the [BuildContext] (as
  /// `context`) and the [home] component (as `child`) if any.
  ///
  /// ### When to use [pageBuilder] vs [home]
  /// - Use [pageBuilder] when the root page itself needs direct access to the
  ///   [BuildContext] established by [NakiApp] (such as reading `context.themeTokens`,
  ///   calling `context.toggleTheme()` in the top-level app bar, or accessing
  ///   [NakiThemeProvider.of]), or when wrapping the page tree in custom inherited
  ///   widgets, providers, or router logic.
  /// - Use [home] when the root component is static or self-contained (e.g. `const Scaffold(...)`)
  ///   and does not need [BuildContext] from [NakiApp] during instantiation.
  ///
  /// If [home] is null, then `child` will be `null`, and it is the
  /// responsibility of the [pageBuilder] to provide the application's
  /// base component that will be rendered.
  ///
  /// Place [NakiApp] inside a `@client` annotated component in order to enable
  /// client-side features like theme toggling and browser APIs.
  ///
  /// ### Example
  /// ```dart
  /// NakiApp(
  ///   pageBuilder: (context, child) {
  ///     return Scaffold(
  ///       appBar: AppBar(
  ///         titleText: 'My App',
  ///         actions: [
  ///           Button.icon(
  ///             context.themeMode == ThemeMode.dark
  ///                 ? MaterialIcons.light_mode
  ///                 : MaterialIcons.dark_mode,
  ///             onTap: context.toggleTheme,
  ///           ),
  ///         ],
  ///       ),
  ///       body: child ?? const NakiText('Hello'),
  ///     );
  ///   },
  /// )
  /// ```
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

  /// Additional components (such as script, link, etc.) for fonts,
  /// analytics, etc. that are to be added to the application's head.
  final List<Component> head;

  /// The [builder] callback has two arguments, the [BuildContext] (as
  /// `context`) and the [Router] (as `child`) if any.
  ///
  /// For example, from the [BuildContext] passed to this method;
  /// [NakiThemeProvider.of], [DefaultTextStyle.of], etc, works in both
  /// server and client environments.
  ///
  /// If no routes are provided, the `child` will be `null`, and it is the
  /// responsibility of the [builder] to provide the application's routing
  /// machinery.
  ///
  /// If [routes] is provided, then `child` is not null, and the returned value
  /// must be included as a child of the component tree below the builder as in
  /// the example below.
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
  ///   builder: (context, router) {
  ///     if (router != null) {
  ///       return router;
  ///       // NOTE: router must be included to enable routing.
  ///       // router can be returned directly, or wrapped in a component
  ///       // such as providers, builders, etc.
  ///     } else {
  ///       return NakiContainer();
  ///     }
  ///   },
  /// );
  /// ```
  ///
  /// If [routes] is null, [NakiApp] will have no [Router] and the routing
  /// related properties (i.e. [navigatorKey], [routes]) are ignored.
  ///
  /// Unless [routes] is provided, either implicitly from [builder] being
  /// `null` or by [builder] explicitly including the [Router] component,
  /// navigation will not work.
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
  /// If this is changed, a new [Router] will be created, losing all the
  /// application state in the process.
  ///
  /// The [Router] is only built if [routes] is not null; if it is
  /// null or empty, [navigatorKey] will be ignored.
  final GlobalStateKey<RouterState>? navigatorKey;

  /// The component displayed first when the application is loaded.
  ///
  /// ### When to use [home] vs [pageBuilder]
  /// - Use [home] when your root view is a pre-instantiated or `const` component
  ///   (e.g., `home: const MyHomeScreen()`) that does not need direct access
  ///   to [NakiApp]'s internal [BuildContext] during instantiation. Descendant
  ///   components inside [home] will still have full access to `context.themeTokens`
  ///   and theme methods in their own `build` methods.
  /// - Use [pageBuilder] when the root view itself needs immediate access to
  ///   [NakiApp]'s [BuildContext] (such as calling `context.toggleTheme()` in
  ///   a root app bar, reading `context.themeTokens`, or wrapping the application
  ///   in custom inherited components or providers).
  final Component? home;

  /// The application's top-level routing configuration.
  ///
  /// If the application only has one page, you can specify it using
  /// [builder] and ignore this property totally.
  ///
  /// If a route is requested that is not specified in this property,
  /// then [errorPage] will be shown (if any), otherwise the default
  /// [PageNotFound] will be rendered.
  ///
  /// The [Router] component is only built if routes are provided; if they
  /// are not, then [builder] must be provided.
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

  /// {@macro NakiApp}
  NakiApp({
    super.key,
    this.metaTags = const {},
    this.head = const [],
    this.cacheThemeMode = false,
    this.themeMode = ThemeMode.system,
    this.initialLocation,
    this.charset,
    this.viewport,
    this.locale,
    this.home,
    this.pageBuilder,
    this.fontFamily,
    this.favicon,
    this.seo,
    this.title,
    this.textStyle,
    this.lightTheme,
    this.darkTheme,
    this.scrollBarConfiguration,
  }) : assert(
         home != null || pageBuilder != null,
         'Either home or pageBuilder must be provided',
       ),
       assert(
         initialLocation == null || initialLocation.startsWith('/'),
         'initialLocation must start with a leading slash "/"',
       ),
       routes = null,
       navigatorKey = null,
       builder = null,
       errorPage = null;

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
    this.initialLocation,
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
         initialLocation == null || initialLocation.startsWith('/'),
         'initialLocation must start with a leading slash "/"',
       ),
       assert(
         (routes != null && routes.isNotEmpty) || builder != null,
         'Either routes or builder must be provided',
       ),
       home = null,
       pageBuilder = null;

  @override
  State<NakiApp> createState() => _NakiAppState();
}

class _NakiAppState extends State<NakiApp> {
  late ThemeConfig _themeConfig;

  bool get _useRouter => (component.routes ?? []).isNotEmpty || component.builder != null;

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
        oldComponent.scrollBarConfiguration != component.scrollBarConfiguration) {
      _syncThemeConfig();
    }
  }

  Component get appBase {
    final textStyles = component.textStyle;
    final homeChild = component.home;

    Component? base;
    Router? router;

    // build router app
    if (_useRouter) {
      final _routes = component.routes ?? [];

      if (_routes.isNotEmpty) {
        router = Router(
          routes: _routes,
          key: component.navigatorKey,
          errorBuilder: (_, state) =>
              component.errorPage ??
              PageNotFound(
                errorText: state.error?.toString(),
              ),
        );
      }

      base = NakiThemeProvider.fromConfig(
        builder: (themeCtx) {
          Component? effectiveChild = router;

          if (textStyles != null) {
            return DefaultTextStyle(
              style: textStyles,
              child: Builder(
                builder: (styleCtx) {
                  if (component.builder != null) {
                    effectiveChild = component.builder!(
                      styleCtx,
                      effectiveChild,
                    );
                  }

                  return effectiveChild ??
                      const PageNotFound(
                        errorTitle: 'Unable to apply text style',
                        errorText: 'No routes or builder provided',
                      );
                },
              ),
            );
          }

          if (component.builder != null) {
            effectiveChild = component.builder!(
              themeCtx,
              effectiveChild,
            );
          }

          return effectiveChild ??
              const PageNotFound(
                errorTitle: 'Unable to build application router',
                errorText: 'No routes or builder provided',
              );
        },
        configuration: _themeConfig,
      );

      return base;
    }

    // build regular app
    base = NakiThemeProvider.fromConfig(
      builder: (themeCtx) {
        Component? effectiveChild = homeChild;

        if (textStyles != null) {
          return DefaultTextStyle(
            style: textStyles,
            child: Builder(
              builder: (styleCtx) {
                if (component.pageBuilder != null) {
                  effectiveChild = component.pageBuilder!(
                    styleCtx,
                    effectiveChild,
                  );
                }

                return effectiveChild ??
                    const PageNotFound(
                      errorTitle: 'Unable to apply text style',
                      errorText: 'No home component or builder provided',
                    );
              },
            ),
          );
        }

        if (component.pageBuilder != null) {
          effectiveChild = component.pageBuilder!(
            themeCtx,
            effectiveChild,
          );
        }

        return effectiveChild ??
            const PageNotFound(
              errorTitle: 'Unable to build application page',
              errorText: 'No home component or builder provided',
            );
      },
      configuration: _themeConfig,
    );

    return base;
  }

  String? get fontFamily {
    return component.fontFamily
        ?.map(
          (f) => f.contains(' ') && !f.startsWith('"') && !f.startsWith("'") ? '"$f"' : f,
        )
        .join(', ');
  }

  (String, String)? get favicon {
    final favico = _absoluteUrl(component.favicon ?? '');
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

  String get normalizedBase {
    var base = component.initialLocation ?? _defaultBasePath;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  String _absoluteUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/') && component.seo?.url != null) {
      final origin = component.seo!.url!.replaceFirst(
        RegExp(r'/+$'),
        '',
      );
      return '$origin$value';
    }

    return value;
  }

  List<Component> get seoTags {
    final seo = component.seo;
    if (seo == null) return [];

    final pageUrl = _absoluteUrl(seo.url ?? '');
    final imageUrl = _absoluteUrl(seo.logo ?? '');
    final title = seo.title ?? component.title ?? '';

    final smTitle = seo.socialMediaTitle ?? title;
    final smDesc = seo.socialMediaDescription ?? seo.description ?? '';
    final smImg = _absoluteUrl(
      seo.socialMediaBanner ?? imageUrl,
    );

    return [
      if (pageUrl.isNotEmpty) link(href: pageUrl, rel: 'canonical'),

      if (seo.description.isNotNullAndEmpty) meta(name: 'description', content: seo.description),

      if (seo.keywords != null && seo.keywords!.isNotEmpty)
        meta(
          name: 'keywords',
          content: seo.keywords!.join(', '),
        ),

      if (seo.robots != null && seo.robots!.isNotEmpty)
        meta(
          name: 'robots',
          content: seo.robots!.join(', '),
        ),

      if (title.isNotEmpty)
        meta(
          attributes: const {'property': 'og:title'},
          content: title,
        ),

      if (title.isNotEmpty)
        meta(
          attributes: const {'property': 'og:site_name'},
          content: title,
        ),

      if (seo.description.isNotNullAndEmpty)
        meta(
          attributes: const {'property': 'og:description'},
          content: seo.description,
        ),

      const meta(
        attributes: {'property': 'og:type'},
        content: 'website',
      ),

      if (pageUrl.isNotEmpty)
        meta(
          attributes: const {'property': 'og:url'},
          content: pageUrl,
        ),

      if (imageUrl.isNotEmpty)
        meta(
          attributes: const {'property': 'og:image'},
          content: imageUrl,
        ),

      if (title.isNotEmpty)
        meta(
          attributes: const {'property': 'og:image:alt'},
          content: title,
        ),

      if (smImg.isNotEmpty) ...[
        if (smTitle.isNotEmpty) meta(name: 'twitter:title', content: smTitle),

        if (smDesc.isNotEmpty)
          meta(
            name: 'twitter:description',
            content: smDesc,
          ),

        meta(
          attributes: const {'name': 'twitter:image'},
          content: smImg,
        ),

        if (smTitle.isNotEmpty) meta(name: 'twitter:image:alt', content: smTitle),

        const meta(
          name: 'twitter:card',
          content: 'summary_large_image',
        ),
      ],
    ];
  }

  @override
  Component build(BuildContext context) {
    final fontFamilyVar = Tokens.current.fontFamily.name;
    final fontFamilyCSS = css(
      'html',
    ).styles(raw: {fontFamilyVar: ?fontFamily});
    final effectiveTitle = component.seo?.title ?? component.title ?? '';

    final themeScript = themeSwitchingScript(
      component.themeMode.name,
      component.cacheThemeMode,
    );

    return AppScope(
      child: .fragment([
        Document.html(
          attributes: {
            'lang': component.locale ?? _defaultLocale,
          },
        ),

        // app meta tags
        Document.head(
          title: effectiveTitle.isEmpty ? null : effectiveTitle,
          meta: {
            'viewport': component.viewport ?? _defaultViewport,
            'naki-ui': 'https://naki-ui.web.app',
            'charset': component.charset ?? _defaultCharset,
            ...component.metaTags,
          },
          children: [
            // base path
            if (normalizedBase.isNotEmpty)
              .element(
                tag: 'base',
                attributes: {'href': normalizedBase},
              ),

            // default theme tokens
            .wrapElement(
              id: 'tokens',
              child: Style(
                styles: ThemeConfig.defaultStyles,
              ),
            ),

            // theme caching
            script(content: themeScript, id: 'ntc'),

            // icon
            if (favicon case (final href, final type)) link(href: href, rel: 'icon', type: type),

            // seo tags
            ...seoTags,

            // set font family
            if (fontFamily.isNotNullAndEmpty) Style(styles: [fontFamilyCSS]),

            // custom head components
            ...component.head,
          ],
        ),

        // app body
        appBase,
      ]),
    );
  }
}

/// Default Naki 404 page.
class PageNotFound extends StatelessComponent {
  final String? errorTitle;
  final String? errorText;

  const PageNotFound({
    super.key,
    this.errorText,
    this.errorTitle,
  });

  @override
  Component build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15,
        children: [
          const SizedBox.height(Dim.px(30)),

          Heading(
            errorTitle ?? 'Page Not Found',
            style: const TextStyle(
              fontSize: Dim.px(40),
              textAlign: TextAlign.center,
            ),
          ),

          SubHeading(
            errorText ?? 'The page you are looking for does not exist.',
            style: const TextStyle(
              fontSize: Dim.px(20),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox.height(Dim.px(40)),
        ],
      ),
    );
  }
}
