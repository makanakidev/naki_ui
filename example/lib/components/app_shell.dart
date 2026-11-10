import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'content.dart';
import 'showcase/basics_page.dart';
import 'showcase/forms_page.dart';
import 'showcase/layout_page.dart';
import 'showcase/overlays_page.dart';

const _navItems = [
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_task_alt,
    label: 'Tasks',
  ),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_widgets,
    label: 'Basics',
  ),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_edit_note,
    label: 'Forms',
  ),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_dashboard,
    label: 'Layout',
  ),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_layers,
    label: 'Overlays',
  ),
];

/// App scaffold whose bottom navigation bar drives a [PageView].
class AppShell extends StatefulComponent {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _pageController = PageController();

  final List<BottomNavigationBarType> _navbarTypes = const [
    BottomNavigationBarType.frostedGlass,
    BottomNavigationBarType.liquidGlass,
    BottomNavigationBarType.floating,
    BottomNavigationBarType.fixed,
  ];

  BottomNavigationBarType _currentNavbar = BottomNavigationBarType.frostedGlass;

  int _page = 0;

  /// Page a navigation bar tap is scrolling to, if any.
  int? _targetPage;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _targetPage = index;
    setState(() => _page = index);
    _pageController.animateToPage(index);
  }

  void _onPageChanged(int page) {
    if (_targetPage != null && page != _targetPage) return;
    _targetPage = null;
    if (page != _page) setState(() => _page = page);
  }

  void _showMessage(BuildContext ctx, String message) {
    showSnackbar(
      ctx,
      Snackbar(
        duration: const Duration(seconds: 5),
        position: SnackbarPosition.top,
        content: NakiText(message),
        showCloseIcon: true,
        backgroundColor: ctx.primaryColor,
        foregroundColor: Colors.white,
        closeIconColor: Colors.white.withOpacity(80),
      ),
    );
  }

  void _changeNavbar(BuildContext ctx) {
    final idx = _navbarTypes.indexOf(_currentNavbar);
    setState(
      () => _currentNavbar = idx >= _navbarTypes.length - 1
          ? _navbarTypes.first
          : _navbarTypes[idx + 1],
    );
    _showMessage(ctx, 'Navbar type: ${_currentNavbar.name}');
  }

  @override
  Component build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleText: 'Naki UI',
        actions: [
          Builder(
            builder: (ctx) => Button.text(
              'Change Navbar',
              backgroundColor: Colors.transparent,
              foregroundColor: context.textColor,
              height: const Dim.px(30),
              border: BorderData(
                radius: BorderRadiusData.all(const Dim.px(5)),
                color: context.textColor,
              ),
              onTap: () => _changeNavbar(ctx),
            ),
          ),

          Button.icon(
            context.themeMode == ThemeMode.dark
                ? MaterialIcons.icon_round_light_mode
                : context.themeMode == ThemeMode.light
                ? MaterialIcons.icon_round_dark_mode
                : MaterialIcons.icon_round_brightness_auto,
            padding: EdgeInsets.zero,
            border: const BorderData.only(radius: BorderRadiusData.circular),
            attributes: const {'aria-label': 'Toggle theme mode'},
            onTap: context.toggleTheme,
            size: 28,
          ),
        ],
      ),
      extendBody: _currentNavbar.isElevated,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        children: [
          const Content(),
          const BasicsPage(),
          FormsPage(onMessage: _showMessage),
          const LayoutPage(),
          const OverlaysPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: _currentNavbar,
        selectedIndex: _page,
        onTap: _onNavTap,
        items: _navItems,
      ),
    );
  }
}
