// BottomNavigationBar only rebuilds on the web, so these tests run in a
// browser: dart test -p chrome test/bottom_nav_test.dart
@TestOn('browser')
library;

import 'package:jaspr/dom.dart' show Color;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

const _items = [
  BottomNavigationBarItem(icon: MaterialIcons.icon_round_home, label: 'Home'),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_search,
    label: 'Search',
  ),
  BottomNavigationBarItem(
    icon: MaterialIcons.icon_round_settings,
    label: 'Settings',
  ),
];

web.HTMLElement get _bar =>
    web.document.querySelector('.naki-bottombar')! as web.HTMLElement;

web.Element? get _indicator =>
    web.document.querySelector('.naki-navbar-indicator');

String _index() => _bar.style.getPropertyValue('--naki-navbar-index');

web.HTMLElement _action(int index) =>
    web.document
            .querySelectorAll('.naki-navbar-tile .naki-gesture-detector')
            .item(index)!
        as web.HTMLElement;

web.Element? get _refraction =>
    web.document.querySelector('.naki-navbar-refraction');

String _tile(int index) => _action(index).outerHTML.toString();

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  void pumpBar(
    ClientTester tester, {
    BottomNavigationBarType type = BottomNavigationBarType.frostedGlass,
    int selectedIndex = 0,
    Color? unSelectedIconColor,
    ValueChanged<int>? onTap,
  }) {
    tester.pumpComponent(
      NakiThemeProvider(
        builder: (_) => BottomNavigationBar(
          type: type,
          items: _items,
          selectedIndex: selectedIndex,
          unSelectedIconColor: unSelectedIconColor,
          onTap: onTap,
        ),
      ),
    );
  }

  group('BottomNavigationBar liquid glass', () {
    testClient('refracts the bar and droplet in Chromium', (tester) async {
      pumpBar(tester, type: BottomNavigationBarType.liquidGlass);

      for (var i = 0; i < 40 && _refraction == null; i++) {
        await _settle();
      }

      final filters = web.document.querySelectorAll(
        '.naki-navbar-refraction filter',
      );
      final bar = filters.item(0)! as web.Element;
      final droplet = filters.item(1)! as web.Element;

      expect(filters.length, 2);
      expect(
        _bar.style.getPropertyValue('--naki-navbar-refraction'),
        'url(#${bar.id})',
      );
      expect(
        _bar.style.getPropertyValue('--naki-navbar-droplet-refraction'),
        'url(#${droplet.id})',
      );
      expect(bar.querySelector('feImage')!.namespaceURI, contains('svg'));
    });

    testClient('keeps the frosted glass styles and droplet', (tester) async {
      pumpBar(
        tester,
        type: BottomNavigationBarType.liquidGlass,
        selectedIndex: 1,
      );
      await _settle();

      expect(_bar.classList.contains('navbar__frosted-glass'), isTrue);
      expect(_bar.classList.contains('navbar__liquid-glass'), isTrue);
      expect(_index(), '1');
      expect(_tile(0), contains('--naki-muted-color'));
    });
  });

  group('BottomNavigationBar frosted glass', () {
    testClient('renders the indicator on the selected tile', (tester) async {
      pumpBar(tester, selectedIndex: 2);
      await _settle();

      expect(_index(), '2');
      expect(_bar.style.getPropertyValue('--naki-navbar-count'), '3');
      expect(_indicator!.getAttribute('aria-hidden'), 'true');
      expect(_action(2).getAttribute('aria-current'), 'page');
      expect(_action(0).hasAttribute('aria-current'), isFalse);
    });

    testClient('moves the indicator when a tile is tapped', (tester) async {
      int? tapped;
      pumpBar(tester, onTap: (index) => tapped = index);
      await _settle();

      _action(1).click();
      await _settle();

      expect(tapped, 1);
      expect(_index(), '1');
      expect(_action(1).getAttribute('aria-current'), 'page');
    });

    testClient('unselected tiles default to the muted color', (tester) async {
      pumpBar(tester);
      await _settle();

      expect(_tile(1), contains('--naki-muted-color'));
      expect(_tile(0), isNot(contains('--naki-muted-color')));
    });

    testClient('unSelectedIconColor overrides the muted color', (tester) async {
      pumpBar(tester, unSelectedIconColor: const Color('#ff0000'));
      await _settle();

      expect(_tile(1), isNot(contains('--naki-muted-color')));
    });

    testClient('other types keep the secondary color', (tester) async {
      pumpBar(tester, type: BottomNavigationBarType.floating);
      await _settle();

      expect(_tile(1), contains('--naki-secondary-color'));
    });

    testClient('frosted glass has no refraction filter', (tester) async {
      pumpBar(tester);
      await _settle();

      expect(_refraction, isNull);
      expect(_bar.style.getPropertyValue('--naki-navbar-refraction'), isEmpty);
    });

    testClient('only the frosted type has an indicator', (tester) async {
      pumpBar(tester, type: BottomNavigationBarType.floating);
      await _settle();

      expect(_indicator, isNull);
      expect(_index(), isEmpty);
    });
  });
}
