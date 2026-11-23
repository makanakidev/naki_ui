part of 'index.dart';

/// {@template Scaffold}
/// A component that provides a standard page layout structure with
/// an app bar, seo tags, body, modal drawer, persistent
/// sidebar/navigation rail, bottom navigation bar,
/// and floating action button.
///
/// **NOTE**: Scaffold is wrapped in a [MediaQueryProvider].
/// This allows the use of `MediaQueryProvider.of(context)` when a
/// [Builder] component is used inside [Scaffold.body] or its
/// descendants.
///
/// ### Example
/// ```dart
/// Scaffold(
///   appBar: AppBar(
///     title: NakiText('My App'),
///   ),
///   seo: SEO(
///     title: 'My App',
///     description: 'My App Description',
///     keywords: ['shopping', 'fashion', 'electronics', 'home & garden'],
///     robots: ['index', 'follow'],
///     url: 'https://myapp.com',
///     logo: 'https://myapp.com/assets/images/logo.jpeg',
///     socialMediaTitle: 'My App Social Media Title',
///     socialMediaDescription: 'My App Social Media Description',
///     socialMediaBanner: 'https://myapp.com/assets/images/banner.jpeg',
///   ),
///   drawer: Drawer(
///     child: NakiText('Navigation'),
///   ),
///   sideBar: Drawer(
///     modal: false,
///     child: NakiText('Sidebar Navigation'),
///   ),
///   body: NakiText('Hello'),
/// )
/// ```
/// {@endtemplate}
class Scaffold extends StatefulComponent {
  /// App bar to display at the top of the scaffold.
  ///
  /// Typically an [AppBar], but accepts any [Component].
  final Component? appBar;

  /// SEO tags for the page.
  final SEO? seo;

  /// Primary content of the scaffold.
  final Component? body;

  /// Modal drawer to display when opened.
  ///
  /// Typically a [Drawer], but accepts any [Component].
  final Component? drawer;

  /// Additional components (such as script, link) for font loading,
  /// analytics, etc. that are to be added to the application's head.
  final List<Component> head;

  /// Persistent sidebar or navigation rail (non-modal) displayed
  /// beside the [body] content.
  ///
  /// Typically a [Sidebar], but accepts any [Component].
  final Component? sideBar;

  /// Bottom navigation bar to display at the bottom of the scaffold.
  ///
  /// Typically a [BottomNavigationBar], but accepts any [Component].
  final Component? bottomNavigationBar;

  /// Button displayed floating above the body in the
  /// bottom-right corner.
  final Component? floatingActionButton;

  /// Additional CSS classes applied to the scaffold component.
  final String? classes;

  /// Whether the [body] extends behind the [bottomNavigationBar].
  ///
  /// When `false` (the default) the body ends above the bar,
  /// so no content is ever hidden behind it.
  ///
  /// When `true` the body is laid out to the bottom of the scaffold
  /// and content scrolls behind the bar (useful with a floating or
  /// frosted-glass bar).
  final bool extendBody;

  /// {@macro Scaffold}
  const Scaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.sideBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.classes,
    this.seo,
    this.head = const [],
    this.extendBody = false,
  });

  /// Finds the [ScaffoldState] from the closest [Scaffold] ancestor,
  /// or returns `null` if none exists.
  static ScaffoldState? maybeOf(BuildContext context) {
    return ScaffoldScope.of(context)?.state;
  }

  @override
  State<Scaffold> createState() => ScaffoldState();

  static List<StyleRule> get styles => ScaffoldStyles.scaffold;
}

/// State for a [Scaffold].
class ScaffoldState extends State<Scaffold> with NakiStatefulMixin {
  /// Last value of [kViewportInsetTopVar], in pixels.
  int _viewportInset = 0;

  /// Last value of [kViewportInsetBottomVar], in pixels.
  int _viewportInsetBottom = 0;

  CSSStyleDeclaration? get _rootStyle =>
      (document.documentElement as HTMLElement?)?.style;

  late final _drawerController = OverlayController();
  String? _bottomNavbarInset;

  /// Controller managing the scaffold's modal drawer open/close state.
  OverlayController? get drawerController => switch (component.drawer) {
    final Drawer d => d.controller ?? _drawerController,
    _ => null,
  };

  /// Whether the scaffold has an app bar.
  bool get hasAppbar => component.appBar != null;

  /// Whether the scaffold has a modal drawer.
  bool get hasDrawer => component.drawer != null;

  /// Whether the scaffold has a persistent sidebar.
  bool get hasSideBar => component.sideBar != null;

  /// Whether the scaffold has a bottom navigation bar.
  bool get hasBottomNavbar => component.bottomNavigationBar != null;

  /// Whether the scaffold has a floating action button.
  bool get hasFloatingActionButton => component.floatingActionButton != null;

  /// Whether the drawer is currently open.
  bool get isDrawerOpen => drawerController?.isOpen ?? false;

  /// Opens the scaffold's drawer.
  void openDrawer() => drawerController?.open();

  /// Closes the scaffold's drawer.
  void closeDrawer() => drawerController?.close();

  /// Toggles the scaffold's drawer open or closed.
  void toggleDrawer() => drawerController?.toggle();

  @override
  void didUpdateComponent(covariant Scaffold oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.extendBody != component.extendBody ||
        oldComponent.appBar != component.appBar ||
        oldComponent.bottomNavigationBar != component.bottomNavigationBar ||
        oldComponent.body != component.body ||
        oldComponent.sideBar != component.sideBar) {
      refreshAfterRender();
    }
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final observer = BrowserLifecycleListeners();
    observer.whenResized = (height, width, orientation) {
      _syncViewportInset();
      _syncInsets();
    };

    final viewport = window.visualViewport;
    final viewportSubscriptions = [
      if (viewport != null) ...[
        EventStreamProviders.resizeEvent
            .forTarget(viewport)
            .listen((_) => _syncViewportInset()),
        EventStreamProviders.scrollEvent
            .forTarget(viewport)
            .listen((_) => _syncViewportInset()),
      ],
    ];

    observer.register();

    return () {
      observer.dispose();
      for (final subscription in viewportSubscriptions) {
        subscription.cancel();
      }
      _rootStyle?.removeProperty(kViewportInsetTopVar);
      _rootStyle?.removeProperty(kViewportInsetBottomVar);
      _viewportInset = 0;
      _viewportInsetBottom = 0;
    };
  }

  HTMLElement? _scaffoldBody(HTMLElement wrapper) =>
      wrapper.parentElement?.querySelector(
            ':scope > .naki-scaffold-body, '
            ':scope > .naki-scaffold-layout > .naki-scaffold-body',
          )
          as HTMLElement?;

  /// Moves the page content out from under Safari's status bar and
  /// address pill, and the bars off its home indicator, while its
  /// toolbar is hidden.
  void _syncViewportInset() {
    final viewport = window.visualViewport;
    final scaffold = getVisibleElement('.naki-scaffold');
    if (viewport == null || scaffold == null) return;

    final pageHeight = scaffold.getBoundingClientRect().height;
    final viewportUnits = viewportUnitHeights();

    final hidden = isToolbarHidden(
      pageHeight: pageHeight,
      smallHeight: viewportUnits.small,
      largeHeight: viewportUnits.large,
      scale: viewport.scale,
    );

    final inset = hiddenViewportInset(
      hidden: hidden,
      pageHeight: pageHeight,
      innerHeight: window.innerHeight,
      offsetTop: viewport.offsetTop,
    );

    final bottom = hiddenToolbarBottomInset(
      hidden: hidden,
      iPhone: PlatformData.current.isIphone,
      screenWidth: window.screen.width,
      screenHeight: window.screen.height,
      landscape: window.innerWidth > window.innerHeight,
    );

    if (inset == _viewportInset && bottom == _viewportInsetBottom) return;

    _viewportInset = inset;
    _viewportInsetBottom = bottom;
    _rootStyle?.setProperty(kViewportInsetTopVar, '${inset}px');
    _rootStyle?.setProperty(kViewportInsetBottomVar, '${bottom}px');

    // the bars have moved
    _syncInsets();
  }

  void _syncInsets() {
    final wrapper = getVisibleElement('.naki-navbar-wrapper');
    final appBar = getVisibleElement('.naki-appbar-wrapper .naki-appbar');
    final bottombar = getVisibleElement('.naki-navbar-wrapper .naki-bottombar');

    if (appBar != null) {
      final height = appBar.getBoundingClientRect().height.roundDown.toPx;
      // top offset applied in snackbar and body
      document.body?.style.setProperty(
        Tokens.current.appbarOffset.name,
        height,
      );
    }

    if (bottombar != null) {
      final rect = bottombar.getBoundingClientRect();
      final body = _scaffoldBody(wrapper!);
      final bodyBottom = body?.getBoundingClientRect().bottom;

      var offset = 0.0;
      var inset = 0.0;

      if (rect.top > 0) {
        offset = max(offset, window.innerHeight - rect.top);
        if (bodyBottom != null) inset = max(inset, bodyBottom - rect.top);

        // bottom offset applied in snackbar
        document.body?.style.setProperty(
          Tokens.current.bottomNavbarOffset.name,
          offset.roundDown.toPx,
        );
      }

      // don't apply bottom inset if navbar is
      // not floating or body is not extending
      if ((rect.x == 0 && rect.left == 0) || !component.extendBody) {
        _bottomNavbarInset = null;
        wrapper.style.removeProperty(Tokens.current.bottomNavbarInset.name);
        body?.style.removeProperty(Tokens.current.bottomNavbarInset.name);
        return;
      }

      // apply bottom inset to body
      final bottomInset = inset.roundDown.toPx;
      if (bottomInset != _bottomNavbarInset) {
        _bottomNavbarInset = bottomInset;

        wrapper.style.setProperty(
          Tokens.current.bottomNavbarInset.name,
          bottomInset,
        );

        body?.style.setProperty(
          Tokens.current.bottomNavbarInset.name,
          bottomInset,
        );
      }
    }
  }

  /// Returns SEO meta tags for the scaffold
  List<Component> get seoTags => seoTagBuilder(
    component.seo,
    context: context,
  );

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-scaffold';
    final effectiveClasses = joinClasses([
      ?component.classes,
      baseClass,
    ]);

    final drawer = component.drawer;
    final sideBar = component.sideBar;

    final hasAppScope = AppScope.of(context) != null;
    final hasParentScaffold = ScaffoldScope.of(context) != null;
    final isStandalone = !hasAppScope && !hasParentScaffold;

    // ensures non-modal mode if Drawer is passed as sideBar
    final effectiveSideBar = hasSideBar
        ? (sideBar is Drawer && sideBar.modal
              ? sideBar.copyWith(modal: false)
              : sideBar)
        : null;

    final pageTitle = component.seo?.title ?? '';
    final Component? headComponent;

    if (kIsServer) {
      final headChildren = [...component.head, ...seoTags];

      headComponent = headChildren.isNotEmpty || pageTitle.isNotEmpty
          ? Document.head(
              title: pageTitle.isEmpty ? null : pageTitle,
              children: headChildren,
            )
          : null;
    } else {
      final seo = component.seo ?? const SEO(),
          desc = seo.description ?? '',
          keywords = seo.keywords ?? [],
          robots = seo.robots ?? [];

      final clientMeta = <String, String>{
        if (desc.isNotEmpty) 'description': desc,
        if (keywords.isNotEmpty) 'keywords': keywords.join(', '),
        if (robots.isNotEmpty) 'robots': robots.join(', '),
      };

      headComponent =
          pageTitle.isNotEmpty ||
              clientMeta.isNotEmpty ||
              component.head.isNotEmpty
          ? Document.head(
              title: pageTitle.isEmpty ? null : pageTitle,
              meta: clientMeta,
              children: component.head,
            )
          : null;
    }

    final Component scaffoldComponent = MediaQueryProvider(
      builder: (_) {
        final bodyClass = joinClasses([
          if (component.extendBody) 'extended-body',
          'naki-scaffold-body',
        ]);

        final bodyStyles = Styles(
          raw: {
            Tokens.current.bottomNavbarInset.name: ?_bottomNavbarInset,
          },
        );

        final Component mainContent = hasSideBar
            ? main_(classes: 'naki-scaffold-layout', [
                div(classes: 'naki-scaffold-sidebar', [effectiveSideBar!]),

                if (component.body != null)
                  div(
                    classes: bodyClass,
                    styles: bodyStyles,
                    [component.body!],
                  ),
              ])
            : (component.body != null
                  ? main_(
                      classes: bodyClass,
                      styles: bodyStyles,
                      [component.body!],
                    )
                  : const SizedBox());

        return .element(
          key: component.key,
          tag: 'naki-scaffold',
          classes: effectiveClasses,
          children: [
            // Head component
            ?headComponent,

            // App bar
            if (component.appBar != null)
              span(classes: 'naki-appbar-wrapper', [
                component.appBar!,
              ]),

            // Main content
            mainContent,

            // Floating action button
            if (component.floatingActionButton != null)
              span(classes: 'naki-scaffold-fab', [
                component.floatingActionButton!,
              ]),

            // Bottom navigation bar
            if (component.bottomNavigationBar != null)
              span(
                classes: 'naki-navbar-wrapper',
                [
                  component.bottomNavigationBar!,
                ],
              ),

            // Drawer
            if (drawer != null)
              drawer is Drawer
                  ? drawer.copyWith(controller: drawerController)
                  : drawer,
          ],
        );
      },
    );

    return ScaffoldScope(
      state: this,
      child: isStandalone
          ? Navigator(home: scaffoldComponent)
          : scaffoldComponent,
    );
  }
}
