import 'dart:async';
import 'dart:math';

import 'package:jaspr/dom.dart' hide Orientation, Padding;
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

import '../framework/framework.dart';
import '../framework/inherited.dart';
import '../framework/lifecycle.dart';
import '../models/gesture.dart';
import '../models/naki.dart';
import '../models/overlays.dart';
import '../models/styling.dart';
import '../stub/index.dart';
import '../styles/css.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/constants.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

import 'basics.dart' show Button, Column, GestureDetector, Icon, NakiText, Row;
import 'layout.dart' show Padding;
import 'media_query.dart' show MediaQueryProvider;
import 'overlays.dart' show Drawer, Sidebar, Tooltip;

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

    final defaultUnselectedColor = type.isGlass
        ? context.mutedColor
        : context.secondaryColor;

    final effectiveUnselectedLabelStyle = TextStyle(
      color: defaultUnselectedColor,
    ).combineWith(unselectedLabelStyle);

    final selectedFontSize = effectiveSelectedLabelStyle.fontSize?.value ?? 12;
    final selectedFontColor =
        effectiveSelectedLabelStyle.color ?? context.primaryColor;
    final unselectedFontColor =
        effectiveUnselectedLabelStyle.color ?? defaultUnselectedColor;

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

      label = span(classes: 'naki-navbar-label', [label]);
    }

    final Component icon = Icon(
      classes: 'naki-navbar-icon',
      item.icon,
      size: selected ? _selectedIconSize : _unselectedIconSize,
      color: selected ? _selectedIconColor : _unselectedIconColor,
    );

    final Component tile =
        isLandscape && layout == BottomNavigationBarLandscapeLayout.linear
        ? Row(
            spacing: 5,
            mainAxisSize: MainAxisSize.min,
            children: [icon, ?label],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
            hapticFeedback(duration: const Duration(milliseconds: 30));
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
    this.unSelectedIconSize = 24.0,
    this.selectedLabelFontSize = 12.0,
    this.unSelectedLabelFontSize = 12.0,
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
  static List<StyleRule> get styles => NakiStyleRegistry.once('BottomNavBar', [
    Rules.nakiBottomNavBarRules,
  ]);
}

/// Measured sizes of a liquid glass bar and its selection droplet.
class _RefractionSize {
  final int barWidth;
  final int barHeight;
  final int dropletWidth;
  final int dropletHeight;

  const _RefractionSize({
    required this.barWidth,
    required this.barHeight,
    required this.dropletWidth,
    required this.dropletHeight,
  });

  @override
  bool operator ==(Object other) =>
      other is _RefractionSize &&
      other.barWidth == barWidth &&
      other.barHeight == barHeight &&
      other.dropletWidth == dropletWidth &&
      other.dropletHeight == dropletHeight;

  @override
  int get hashCode =>
      Object.hash(barWidth, barHeight, dropletWidth, dropletHeight);
}

/// Builds a displacement map for a pill of [width] by [height].
///
/// Red encodes horizontal and blue vertical displacement. The neutral gray
/// center leaves the middle untouched, so only the [bezel] bends content.
String _refractionMap(int width, int height, int bezel) {
  final radius = height / 2;
  final innerRadius = radius - bezel;

  return '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="$width" height="$height">'
      '<defs>'
      '<linearGradient id="r" x1="1" x2="0">'
      '<stop offset="0" stop-color="#000"/>'
      '<stop offset="1" stop-color="#f00"/>'
      '</linearGradient>'
      '<linearGradient id="b" x2="0" y2="1">'
      '<stop offset="0" stop-color="#000"/>'
      '<stop offset="1" stop-color="#00f"/>'
      '</linearGradient>'
      '</defs>'
      '<rect width="$width" height="$height" fill="#000"/>'
      '<rect width="$width" height="$height" rx="$radius" fill="url(#r)"/>'
      '<rect width="$width" height="$height" rx="$radius" fill="url(#b)" '
      'style="mix-blend-mode:difference"/>'
      '<rect x="$bezel" y="$bezel" width="${width - bezel * 2}" '
      'height="${height - bezel * 2}" rx="$innerRadius" fill="#808080" '
      'fill-opacity=".97" style="filter:blur(${bezel / 2}px)"/>'
      '</svg>';
}

/// A filter that bends the [bezel] of a [width] by [height] pill.
Component _refractionFilter({
  required String id,
  required int width,
  required int height,
  required int strength,
  required int bezel,
}) {
  final map = Uri.encodeComponent(_refractionMap(width, height, bezel));

  return .element(
    tag: 'filter',
    attributes: {
      'id': id,
      'x': '0',
      'y': '0',
      'width': '$width',
      'height': '$height',
      'filterUnits': 'userSpaceOnUse',
      'primitiveUnits': 'userSpaceOnUse',
      'color-interpolation-filters': 'sRGB',
    },
    children: [
      .element(
        tag: 'feImage',
        attributes: {
          'href': 'data:image/svg+xml,$map',
          'x': '0',
          'y': '0',
          'width': '$width',
          'height': '$height',
          'preserveAspectRatio': 'none',
          'result': 'map',
        },
      ),
      .element(
        tag: 'feDisplacementMap',
        attributes: {
          'in': 'SourceGraphic',
          'in2': 'map',
          'scale': '-$strength',
          'xChannelSelector': 'R',
          'yChannelSelector': 'B',
          'result': 'bent',
        },
      ),
      const .element(
        tag: 'feGaussianBlur',
        attributes: {'in': 'bent', 'stdDeviation': '1'},
      ),
    ],
  );
}

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  static int _nextRefractionId = 0;

  late int _currentIndex;

  final _indicatorKey = GlobalNodeKey<HTMLElement>();
  final _refractionId = 'naki-refraction-${_nextRefractionId++}';

  BrowserLifecycleListeners? _refractionObserver;
  _RefractionSize? _refractionSize;

  BottomNavigationBarType get _effectiveType =>
      component.type ?? BottomNavigationBarType.fixed;

  String get _dropletRefractionId => '$_refractionId-droplet';

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
    _syncRefraction(true);
  }

  @override
  void didUpdateComponent(BottomNavigationBar oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.selectedIndex != component.selectedIndex) {
      _currentIndex = component.selectedIndex;
    }
    _syncRefraction();
  }

  @override
  void dispose() {
    _refractionObserver?.dispose();
    super.dispose();
  }

  /// Checks if the browser supports [BottomNavigationBarType.liquidGlass].
  bool get supportsLiquidRefraction {
    if (!kIsWeb) return false;

    final hasBackdrop =
        CSS.supports('backdrop-filter', 'blur(10px)') ||
        CSS.supports('-webkit-backdrop-filter', 'blur(10px)');
    if (!hasBackdrop) return false;

    final ua = window.navigator.userAgent;
    final isChromium = ua.contains('Chrome/') || ua.contains('Chromium/');
    final isEdge = ua.contains('Edg/');

    return isChromium || isEdge;
  }

  /// Measures the bar for a [BottomNavigationBarType.liquidGlass] filter.
  ///
  /// The filter only runs on the client-side, so server-rendered markup and
  /// browsers that don't support liquid glass keep the frosted glass bar.
  void _syncRefraction([bool init = false]) {
    if (!kIsWeb) return;

    if (_effectiveType != BottomNavigationBarType.liquidGlass) {
      _refractionObserver?.dispose();
      _refractionObserver = null;
      _refractionSize = null;
      return;
    }

    if (_refractionObserver != null) return;

    if (!supportsLiquidRefraction) return;

    if (init) context.binding.addPostFrameCallback(_measureRefraction);

    _refractionObserver = BrowserLifecycleListeners()
      ..observeComponentSize(
        (_, _, _) => _measureRefraction(),
        key: _indicatorKey,
      )
      ..register();
  }

  void _measureRefraction() {
    final droplet = _indicatorKey.currentNode;
    final bar = droplet?.parentElement;
    if (droplet == null || bar == null) return;

    final barBox = bar.getBoundingClientRect();
    final dropletBox = droplet.getBoundingClientRect();

    final size = _RefractionSize(
      barWidth: barBox.width.round(),
      barHeight: barBox.height.round(),
      dropletWidth: dropletBox.width.round(),
      dropletHeight: dropletBox.height.round(),
    );

    if (size != _refractionSize) setState(() => _refractionSize = size);
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

    final effectiveType = _effectiveType;
    final isGlass = effectiveType.isGlass;

    final refraction =
        context.themeTokens.bottomNavbarGlassRefractionValue / 100;
    final refractionSize = refraction > 0 ? _refractionSize : null;

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

    const baseClass = 'naki-bottombar';
    final effectiveClasses = joinClasses([
      effectiveLayout.className,
      effectiveType.className,
      ?component.classes,
      baseClass,
    ]);

    return .element(
      key: component.key,
      tag: 'naki-bottombar',
      classes: effectiveClasses,
      attributes: {
        'role': 'navigation',
        'aria-label': 'Bottom navigation',
        'data-refracted': ?(refractionSize != null ? '' : null),
      },
      styles: Styles(
        raw: {
          ...effectiveStyles,
          if (isGlass) ...{
            kNavbarIndexVar: '$_currentIndex',
            kNavbarCountVar: '${component.items.length}',
          },
          if (refractionSize != null) ...{
            kNavbarRefractionVar: 'url(#$_refractionId)',
            kNavbarDropletRefractionVar: 'url(#$_dropletRefractionId)',
          },
        },
      ),
      children: [
        if (refractionSize != null)
          .element(
            tag: 'svg',
            classes: 'naki-navbar-refraction',
            attributes: const {'aria-hidden': 'true'},
            children: [
              _refractionFilter(
                id: _refractionId,
                width: refractionSize.barWidth,
                height: refractionSize.barHeight,
                strength: (26 * refraction).round(),
                bezel: 12,
              ),
              _refractionFilter(
                id: _dropletRefractionId,
                width: refractionSize.dropletWidth,
                height: refractionSize.dropletHeight,
                strength: (34 * refraction).round(),
                bezel: 14,
              ),
            ],
          ),

        if (isGlass)
          .element(
            key: _indicatorKey,
            tag: 'naki-navbar-indicator',
            classes: 'naki-navbar-indicator',
            attributes: const {'aria-hidden': 'true'},
          ),

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

  /// Button displayed floating above the body in the bottom-right corner.
  final Component? floatingActionButton;

  /// Additional CSS classes applied to the scaffold component.
  final String? classes;

  /// Whether the [body] extends behind the [bottomNavigationBar].
  ///
  /// When `false` (the default) the body ends above the bar, so no content
  /// is ever hidden behind it.
  ///
  /// When `true` the body is laid out to the bottom of the scaffold and
  /// content scrolls behind the bar (useful with a floating or frosted-glass
  /// bar).
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

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Scaffold', [Rules.nakiScaffoldRules]);
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
    _syncViewportInset();

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

  /// Moves the page content out from under Safari's status bar and address
  /// pill, and the bars off its home indicator, while its toolbar is hidden.
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
      iPhone: PlatformData().isIphone,
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

        body?.style.removeProperty(Tokens.current.bottomNavbarInset.name);
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
                  : const .empty());

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
          ? OverlayHost(child: scaffoldComponent)
          : scaffoldComponent,
    );
  }
}
