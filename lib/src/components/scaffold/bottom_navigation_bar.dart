part of 'index.dart';

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

// Both use a soft gradient that reaches deep into the glass, so the whole bar
// bends the content behind it, pulling it in from past the edge.

/// Glass of a liquid glass bar. It peaks at a 13px bend.
const _barGlass = RefractionShape(
  bezel: 12,
  thickness: 13,
);

/// Glass of a liquid glass selection droplet. It peaks at a 17px bend.
const _dropletGlass = RefractionShape(
  bezel: 14,
  thickness: 17,
);

class _BottomNavigationBarState extends State<BottomNavigationBar> {
  static int _nextRefractionId = 0;

  late int _currentIndex;

  final _indicatorKey = GlobalNodeKey<HTMLElement>();
  final _refractionId = 'naki-refraction-${_nextRefractionId++}';

  BrowserLifecycleListeners? _refractionObserver;

  /// Sizes of the bar and droplet the current bake is for.
  (int, int, int, int)? _measured;

  /// Counts bakes, so a bake that finishes after a newer one is dropped.
  int _bakes = 0;

  ({BakedRefraction bar, BakedRefraction droplet})? _refraction;

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
    _bakes++;
    super.dispose();
  }

  /// Only Chromium runs an SVG filter inside `backdrop-filter`. Other engines
  /// ignore the `url()`, so the bar stays frosted there.
  bool get supportsLiquidRefraction => PlatformData.current.isChromium;

  /// Measures the bar for a [BottomNavigationBarType.liquidGlass] filter.
  ///
  /// The filter only runs on the client-side, so server-rendered markup and
  /// browsers that don't support liquid glass keep the frosted glass bar.
  void _syncRefraction([bool init = false]) {
    if (!kIsWeb) return;

    if (_effectiveType != BottomNavigationBarType.liquidGlass) {
      _refractionObserver?.dispose();
      _refractionObserver = null;
      _measured = null;
      _refraction = null;
      _bakes++;
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

  Future<void> _measureRefraction() async {
    final droplet = _indicatorKey.currentNode;
    final bar = droplet?.parentElement;
    if (droplet == null || bar == null) return;

    final barBox = bar.getBoundingClientRect();
    final dropletBox = droplet.getBoundingClientRect();

    final size = (
      barBox.width.round(),
      barBox.height.round(),
      dropletBox.width.round(),
      dropletBox.height.round(),
    );

    if (size == _measured) return;
    _measured = size;

    final run = ++_bakes;
    final (barWidth, barHeight, dropletWidth, dropletHeight) = size;

    final [barGlass, dropletGlass] = await Future.wait([
      bakeRefraction(
        width: barWidth.toDouble(),
        height: barHeight.toDouble(),
        radius: barHeight / 2,
        shape: _barGlass,
      ),
      bakeRefraction(
        width: dropletWidth.toDouble(),
        height: dropletHeight.toDouble(),
        radius: dropletHeight / 2,
        shape: _dropletGlass,
      ),
    ]);

    if (run != _bakes) return;

    setState(() => _refraction = (bar: barGlass, droplet: dropletGlass));
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
      kNavbarShadowVar: ?(component.removeShadow ? '0 0 transparent' : null),
      ...?component.gradient?.props,
    };

    final effectiveType = _effectiveType;
    final isGlass = effectiveType.isGlass;

    final refraction =
        context.themeTokens.bottomNavbarGlassRefractionValue / 100;
    final refracted = refraction > 0 ? _refraction : null;

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
        'data-refracted': ?(refracted != null ? '' : null),
      },
      styles: Styles(
        raw: {
          ...effectiveStyles,
          if (isGlass) ...{
            kNavbarIndexVar: '$_currentIndex',
            kNavbarCountVar: '${component.items.length}',
          },
          if (refracted != null) ...{
            kNavbarRefractionVar: 'url(#$_refractionId)',
            kNavbarDropletRefractionVar: 'url(#$_dropletRefractionId)',
          },
        },
      ),
      children: [
        if (refracted != null)
          .element(
            tag: 'svg',
            classes: 'naki-navbar-refraction',
            attributes: const {'aria-hidden': 'true'},
            children: [
              RefractionFilter(
                id: _refractionId,
                baked: refracted.bar,
                strength: refraction,
                blur: 1,
              ),
              RefractionFilter(
                id: _dropletRefractionId,
                baked: refracted.droplet,
                strength: refraction,
                blur: 1,
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
