import 'dart:math';

import 'package:jaspr/dom.dart' hide Orientation, Padding;
import 'package:jaspr/jaspr.dart';

import '../framework/framework.dart';
import '../framework/inherited.dart';
import '../models/gesture.dart';
import '../models/naki.dart';
import '../models/overlays.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import 'basics.dart' show Column, GestureDetector, Icon, NakiText, Row;
import 'layout.dart' show Padding;
import 'media_query.dart' show MediaQueryProvider;
import 'overlays.dart' show Drawer, Tooltip;

// /////////////////////////////////////////////////////////////////////////////
// SCAFFOLD & NAVIGATION COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

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

  /// A component to display before `title` or `titleText`.
  ///
  /// Usually a button for navigation, menu, etc.
  final Component? leading;

  /// Components to display after `title` or `titleText`.
  ///
  /// Usually buttons for search, settings, etc.
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

  /// Removes app bar shadow when `true`, otherwise shadow is applied.
  final bool? removeShadow;

  /// {@macro AppBar}
  const AppBar({
    super.key,
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
    this.removeShadow,
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
      'box-shadow': ?(removeShadow == true ? 'none' : null),
      ...?gradient?.props,
    };

    return .element(
      key: key,
      tag: 'naki-appbar',
      classes: effectiveClasses,
      attributes: const {'role': 'banner'},
      styles: Styles(raw: effectiveStyles),
      children: [?leading, ?effectiveTitle, ?effectiveActions],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('AppBar', [Rules.nakiAppBarRules]);
}

class _BottomNavBarTile extends StatelessComponent {
  final BottomNavigationBarItem item;
  final BottomNavigationBarType type;
  final BottomNavigationBarLandscapeLayout layout;
  final double iconSize;
  final VoidCallback onTap;
  final bool selected;
  final bool showSelectedLabel;
  final bool showUnselectedLabel;
  final bool enableFeedback;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final double? selectedIconSize;
  final double? unselectedIconSize;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;

  const _BottomNavBarTile({
    super.key,
    required this.item,
    required this.type,
    required this.iconSize,
    required this.onTap,
    required this.layout,
    this.selected = false,
    this.showSelectedLabel = true,
    this.showUnselectedLabel = true,
    this.enableFeedback = false,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    this.selectedIconSize,
    this.unselectedIconSize,
    this.selectedIconColor,
    this.unselectedIconColor,
  });

  @override
  Component build(BuildContext context) {
    final isLandscape =
        MediaQueryProvider.orientation(context) == Orientation.landscape;

    final effectiveSelectedLabelStyle = TextStyle(
      color: context.primaryColor,
    ).combineWith(selectedLabelStyle);

    final effectiveUnselectedLabelStyle = TextStyle(
      color: context.secondaryColor,
    ).combineWith(unselectedLabelStyle);

    final selectedFontSize = effectiveSelectedLabelStyle.fontSize?.value ?? 12;
    final selectedFontColor =
        effectiveSelectedLabelStyle.color ?? context.primaryColor;
    final unselectedFontColor =
        effectiveUnselectedLabelStyle.color ?? context.secondaryColor;

    final _selectedIconSize = selectedIconSize ?? iconSize;
    final _unselectedIconSize = unselectedIconSize ?? iconSize - 2.0;
    final _selectedIconColor = selectedIconColor ?? selectedFontColor;
    final _unselectedIconColor = unselectedIconColor ?? unselectedFontColor;

    final double fontHalf = selectedFontSize / 2.0;
    final double iconDiffHalf =
        max(_selectedIconSize - _unselectedIconSize, 0.0) / 2.0;

    double topPadding;
    double bottomPadding;

    if (!showSelectedLabel && !showUnselectedLabel) {
      // icon-only: symmetric vertical padding
      topPadding = fontHalf;
      bottomPadding = fontHalf;
    } else if (showSelectedLabel && !showUnselectedLabel) {
      // shifting mode: adjust based on item selection
      if (selected) {
        topPadding = fontHalf - iconDiffHalf;
        bottomPadding = fontHalf - iconDiffHalf;
      } else {
        topPadding = fontHalf + iconDiffHalf;
        bottomPadding = fontHalf + iconDiffHalf;
      }
    } else {
      // fixed mode (both label and icon enabled)
      topPadding = fontHalf;
      bottomPadding = fontHalf;
    }

    Component? label = item.label.isNotNullAndEmpty
        ? NakiText(item.label!)
        : item.labelComponent;

    if (!showSelectedLabel && !showUnselectedLabel) {
      // hide label
      label = null;
    } else if (!showUnselectedLabel) {
      // only show selected label
      label = selected ? label : null;
    } else if (!showSelectedLabel) {
      // only show unselected label
      label = !selected ? label : null;
    }

    if (label != null) {
      label = DefaultTextStyle(
        child: label,
        style: selected
            ? effectiveSelectedLabelStyle
            : effectiveUnselectedLabelStyle,
      );

      label = .wrapElement(classes: 'naki-navbar-label', child: label);
    }

    final Component icon = Icon(
      classes: 'naki-navbar-icon',
      item.icon,
      size: selected ? _selectedIconSize : _unselectedIconSize,
      color: selected ? _selectedIconColor : _unselectedIconColor,
    );

    final Component tile =
        isLandscape && layout == BottomNavigationBarLandscapeLayout.linear
        ? Row(spacing: 8, children: [icon, ?label])
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [icon, ?label],
          );

    Component result = GestureDetector(
      semanticLabel: item.tooltip ?? item.label,
      attributes: {'aria-current': ?(selected ? 'page' : null)},
      child: Padding(
        child: tile,
        padding: EdgeInsets.only(
          top: Dim.px(topPadding),
          bottom: Dim.px(bottomPadding),
        ),
      ),
      gestures: Events(
        onClick: (_) {
          if (enableFeedback) {
            hapticFeedback(duration: const Duration(milliseconds: 50));
          }
          onTap();
        },
      ),
    );

    final tooltip = item.tooltip ?? '';
    if (tooltip.isNotEmpty) {
      result = Tooltip(text: tooltip, child: result);
    }

    return .element(
      tag: 'naki-navbartile',
      classes: 'naki-navbar-tile',
      children: [result],
    );
  }
}

/// {@template BottomNavigationBar}
/// A component that renders a bottom navigation bar.
///
/// Usually used with [Scaffold.bottomNavigationBar].
///
/// ### Example
/// ```dart
/// BottomNavigationBar(
///   selectedIndex: 0,
///   onTap: (index) {},
///   items: [
///     BottomNavigationBarItem(
///       icon: Icons.home,
///       label: 'Home',
///     ),
///     BottomNavigationBarItem(
///       icon: Icons.search,
///       label: 'Search',
///     ),
///     BottomNavigationBarItem(
///       icon: Icons.person,
///       label: 'Profile',
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class BottomNavigationBar extends StatefulComponent {
  /// Navigation items or children displayed in the bottom navigation bar.
  final List<BottomNavigationBarItem> items;

  /// Which layout to use for the bottom navigation bar when device is in
  /// landscape orientation.
  final BottomNavigationBarLandscapeLayout? landscapeLayout;

  /// Type of the bottom navigation bar.
  final BottomNavigationBarType? type;

  /// The index of the currently selected item.
  final int selectedIndex;

  /// Width of the bottom navigation bar.
  final Dim? width;

  /// Height of the bottom navigation bar.
  final Dim? height;

  /// Background color of the bottom navigation bar.
  final Color? backgroundColor;

  /// Background gradient of the bottom navigation bar.
  ///
  /// ### Example
  /// ```dart
  /// BottomNavigationBar(
  ///   items: [...],
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.blue]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Color of selected icons.
  final Color? selectedIconColor;

  /// Color of unselected icons.
  final Color? unSelectedIconColor;

  /// Size of selected icons.
  final double selectedIconSize;

  /// Size of unselected icons.
  final double unSelectedIconSize;

  /// Style of selected labels.
  final TextStyle? selectedLabelStyle;

  /// Style of unselected labels.
  final TextStyle? unSelectedLabelStyle;

  /// Size of selected labels.
  final double selectedLabelFontSize;

  /// Size of unselected labels.
  final double unSelectedLabelFontSize;

  /// Whether to show selected labels.
  final bool showSelectedLabels;

  /// Whether to show unselected labels.
  final bool showUnSelectedLabels;

  /// Whether to enable haptic feedback on tap.
  ///
  /// NOTE: Only has effect on non-iOS platforms.
  final bool enableFeedback;

  /// Additional CSS classes applied to the bottom navigation bar component.
  final String? classes;

  /// Removes bottom navigation bar shadow when `true`.
  final bool removeShadow;

  /// Called when one of the [items] is pressed with its index.
  final ValueChanged<int>? onTap;

  /// {@macro BottomNavigationBar}
  const BottomNavigationBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.selectedIconSize = 24.0,
    this.unSelectedIconSize = 20.0,
    this.selectedLabelFontSize = 12.0,
    this.unSelectedLabelFontSize = 10.0,
    this.showSelectedLabels = true,
    this.showUnSelectedLabels = true,
    this.enableFeedback = false,
    this.removeShadow = false,
    this.type,
    this.height,
    this.width,
    this.landscapeLayout,
    this.backgroundColor,
    this.gradient,
    this.selectedIconColor,
    this.unSelectedIconColor,
    this.selectedLabelStyle,
    this.unSelectedLabelStyle,
    this.classes,
    this.onTap,
  }) : assert(
         items.length >= 2,
         'BottomNavigationBar must have at least 2 items',
       );

  @override
  State<BottomNavigationBar> createState() => _BottomNavigationBarState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('BottomNavBar', [Rules.nakiBottomNavBarRules]);
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  late int _currentIndex;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    assert(
      component.items.any(
        (item) => item.label != null || item.labelComponent != null,
      ),
      'BottomNavigationBar items must have at least a label or labelComponent',
    );

    _currentIndex = component.selectedIndex;
  }

  @override
  void didUpdateComponent(BottomNavigationBar oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.selectedIndex != component.selectedIndex) {
      _currentIndex = component.selectedIndex;
    }
  }

  void _handleTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    component.onTap?.call(index);
  }

  @override
  Component build(BuildContext context) {
    final effectiveStyles = {
      Tokens.current.bottomNavbarBgColor.name:
          ?component.backgroundColor?.value,
      Tokens.current.bottomNavbarHeight.name: ?component.height?.cssText,
      'width': ?component.width?.cssText,
      'box-shadow': ?(component.removeShadow ? 'none' : null),
      ...?component.gradient?.props,
    };

    final effectiveType =
        component.type ??
        (component.items.length <= 3
            ? BottomNavigationBarType.fixed
            : BottomNavigationBarType.floating);

    final effectiveLayout =
        component.landscapeLayout ?? BottomNavigationBarLandscapeLayout.spread;

    final unselectedLabelStyle = TextStyle(
      fontSize: Dim.px(component.unSelectedLabelFontSize),
      color: component.unSelectedIconColor,
    ).combineWith(component.unSelectedLabelStyle);

    final selectedLabelStyle = TextStyle(
      fontSize: Dim.px(component.selectedLabelFontSize),
      color: component.selectedIconColor,
    ).combineWith(component.selectedLabelStyle);

    const baseClass = 'naki-bottom-navbar';
    final effectiveClasses = joinClasses([
      effectiveLayout.className,
      effectiveType.className,
      ?component.classes,
      baseClass,
    ]);

    return .element(
      key: component.key,
      tag: 'naki-bottom-navbar',
      classes: effectiveClasses,
      attributes: const {
        'role': 'navigation',
        'aria-label': 'Bottom navigation',
      },
      styles: Styles(raw: effectiveStyles),
      children: [
        for (int i = 0; i < component.items.length; i++)
          _BottomNavBarTile(
            key: component.items[i].key,
            item: component.items[i],
            type: effectiveType,
            layout: effectiveLayout,
            iconSize: component.selectedIconSize,
            selected: _currentIndex == i,
            showSelectedLabel: component.showSelectedLabels,
            showUnselectedLabel: component.showUnSelectedLabels,
            enableFeedback: component.enableFeedback,
            selectedLabelStyle: selectedLabelStyle,
            unselectedLabelStyle: unselectedLabelStyle,
            selectedIconSize: component.selectedIconSize,
            selectedIconColor: component.selectedIconColor,
            unselectedIconSize: component.unSelectedIconSize,
            unselectedIconColor: component.unSelectedIconColor,
            onTap: () => _handleTap(i),
          ),
      ],
    );
  }
}

/// {@template Scaffold}
/// A component that provides a standard page layout structure with
/// an app bar, seo tags, body, modal drawer, persistent sidebar/navigation
/// rail, bottom navigation bar, and floating action button.
///
/// > **NOTE**: Scaffold is wrapped in a [MediaQueryProvider]. This allows the
/// > use of `MediaQueryProvider.of(context)` when a [Builder] component is used
/// > inside [Scaffold.body] or its descendants.
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
  /// Typically an instance of [AppBar], but accepts any [Component].
  final Component? appBar;

  /// SEO tags for the page.
  final SEO? seo;

  /// Primary content of the scaffold.
  final Component? body;

  /// Modal drawer to display when opened.
  ///
  /// Typically an instance of [Drawer], but accepts any [Component].
  final Component? drawer;

  /// Additional components (such as script, link) for font loading,
  /// analytics, etc. that are to be added to the application's head.
  final List<Component> head;

  /// Persistent sidebar or navigation rail (non-modal) displayed
  /// beside the [body] content.
  final Component? sideBar;

  /// Bottom navigation bar to display at the bottom of the scaffold.
  ///
  /// Typically an instance of [BottomNavigationBar], but accepts any [Component].
  final Component? bottomNavigationBar;

  /// Button displayed floating above the body in the bottom-right corner.
  final Component? floatingActionButton;

  /// Additional CSS classes applied to the scaffold component.
  final String? classes;

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
  });

  /// Finds the [ScaffoldState] from the closest [Scaffold] ancestor,
  /// or returns `null` if none exists.
  static ScaffoldState? maybeOf(BuildContext context) {
    return ScaffoldScope.of(context)?.state;
  }

  @override
  State<Scaffold> createState() => ScaffoldState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Scaffold', [Rules.nakiScaffoldRules]);
}

/// State for a [Scaffold].
class ScaffoldState extends State<Scaffold> with NakiStatefulMixin {
  late final _drawerController = OverlayController();

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

  /// Returns the computed height of the app bar.
  String? get appBarHeight => switch (component.appBar) {
    final AppBar bar => bar.height?.cssText,
    _ => null,
  };

  /// Returns the computed height of the bottom navigation bar.
  String? get bottomNavbarHeight => switch (component.bottomNavigationBar) {
    final BottomNavigationBar bar => bar.height?.cssText,
    _ => null,
  };

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

  /// Returns SEO meta tags for the scaffold
  List<Component> get seoTags {
    final seo = component.seo;
    if (seo == null) return const <Component>[];

    final base = seo.url ?? context.binding.basePath;
    final pageUrl = normaliseLink(base);
    final logoUrl = normaliseLink(seo.logo ?? '', base);
    final pageTitle = seo.title ?? '';

    final smTitle = seo.socialMediaTitle ?? pageTitle;
    final smDesc = seo.socialMediaDescription ?? seo.description ?? '';
    final smImg = normaliseLink(seo.socialMediaBanner ?? logoUrl, base);

    final isValidLogo = logoUrl.isNotEmpty && logoUrl.startsWith('http');
    final isValidSmImg = smImg.isNotEmpty && smImg.startsWith('http');
    final isValidPageUrl = pageUrl.isNotEmpty && pageUrl.startsWith('http');

    return [
      if (isValidPageUrl) link(href: pageUrl, rel: 'canonical'),

      if (seo.description.isNotNullAndEmpty)
        meta(name: 'description', content: seo.description),

      if (seo.keywords != null && seo.keywords!.isNotEmpty)
        meta(name: 'keywords', content: seo.keywords!.join(', ')),

      if (seo.robots != null && seo.robots!.isNotEmpty)
        meta(name: 'robots', content: seo.robots!.join(', ')),

      // Open Graph Tags
      ...[
        if (pageTitle.isNotEmpty) ...[
          meta(
            attributes: const {'property': 'og:title'},
            content: pageTitle,
            id: 'ogtitle',
          ),
          meta(
            attributes: const {'property': 'og:site_name'},
            content: pageTitle,
            id: 'ogsitename',
          ),
        ],

        if (seo.description.isNotNullAndEmpty)
          meta(
            attributes: const {'property': 'og:description'},
            content: seo.description,
            id: 'ogdesc',
          ),

        const meta(
          attributes: {'property': 'og:type'},
          content: 'website',
          id: 'ogtype',
        ),

        if (isValidPageUrl)
          meta(
            attributes: const {'property': 'og:url'},
            content: pageUrl,
            id: 'ogurl',
          ),

        if (isValidLogo) ...[
          meta(
            attributes: const {'property': 'og:image'},
            content: logoUrl,
            id: 'ogimg',
          ),

          if (pageTitle.isNotEmpty)
            meta(
              attributes: const {'property': 'og:image:alt'},
              content: pageTitle,
              id: 'ogimgalt',
            ),
        ],
      ],

      // Social Media Graph Tags
      if (smTitle.isNotEmpty) ...[
        if (smTitle.isNotEmpty) meta(name: 'twitter:title', content: smTitle),
        if (smDesc.isNotEmpty)
          meta(name: 'twitter:description', content: smDesc),

        if (isValidSmImg) ...[
          meta(name: 'twitter:image', content: smImg),
          if (smTitle.isNotEmpty)
            meta(name: 'twitter:image:alt', content: smTitle),
          const meta(name: 'twitter:card', content: 'summary_large_image'),
        ],
      ],
    ];
  }

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-scaffold';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final drawer = component.drawer;
    final sideBar = component.sideBar;

    // Ensure non-modal mode if Drawer is passed as sideBar
    final effectiveSideBar = hasSideBar
        ? (sideBar is Drawer && sideBar.modal
              ? sideBar.copyWith(modal: false)
              : sideBar)
        : null;

    final Component bodyContent = hasSideBar
        ? main_(classes: 'naki-scaffold-layout', [
            .wrapElement(
              classes: 'naki-scaffold-sidebar',
              child: effectiveSideBar!,
            ),

            if (component.body != null)
              div(classes: 'naki-scaffold-body', [component.body!]),
          ])
        : (component.body != null
              ? main_(classes: 'naki-scaffold-body', [component.body!])
              : const .empty());

    return ScaffoldScope(
      state: this,
      child: MediaQueryProvider(
        builder: (context) {
          return .element(
            key: component.key,
            tag: 'naki-scaffold',
            classes: effectiveClasses,
            children: [
              // Head components with SEO meta tags
              Document.head(children: [...component.head, ...seoTags]),

              // App bar
              if (component.appBar != null)
                .wrapElement(
                  classes: 'naki-scaffold-appbar',
                  child: component.appBar!,
                ),

              // Body content
              bodyContent,

              // Floating action button
              if (component.floatingActionButton != null)
                .wrapElement(
                  classes: 'naki-scaffold-fab',
                  child: component.floatingActionButton!,
                ),

              // Bottom navigation bar
              if (component.bottomNavigationBar != null)
                .wrapElement(
                  classes: 'naki-scaffold-bottom-navbar',
                  child: component.bottomNavigationBar!,
                ),

              // Modal Drawer
              if (drawer != null)
                drawer is Drawer
                    ? drawer.copyWith(controller: drawerController)
                    : drawer,
            ],
          );
        },
      ),
    );
  }
}
