@TestOn('browser')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart' hide Element;
import 'package:naki_ui/naki_ui.dart';

Future<void> _settle([int ms = 60]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  group('Navigator browser DOM', () {
    testClient('standalone Navigator with home handles push and pop', (
      tester,
    ) async {
      late BuildContext homeCtx;
      late BuildContext pushedCtx;
      var homeMounts = 0;

      tester.pumpComponent(
        Navigator(
          routes: {
            '/first': (context) {
              pushedCtx = context;
              return const NakiText('First');
            },
          },
          home: Builder(
            builder: (context) {
              homeCtx = context;
              homeMounts++;
              return const NakiText('Home');
            },
          ),
        ),
      );
      await _settle();
      expect(homeMounts, 1);

      final f1 = Navigator.pushNamed<String>(homeCtx, '/first');
      await _settle();

      Navigator.pop(pushedCtx, 'done');
      await _settle();
      expect(await f1, 'done');
    });

    testClient('standalone Navigator with null home handles push and pop', (
      tester,
    ) async {
      late NavigatorState nav;

      tester.pumpComponent(
        Navigator(
          routes: {
            '/first': (_) => const NakiText('First'),
            '/second': (_) => const NakiText('Second'),
          },
          home: null,
        ),
      );
      await _settle();

      final element = tester.binding.rootElement!;
      void findNav(Element el) {
        if (el is StatefulElement && el.state is NavigatorState) {
          nav = el.state as NavigatorState;
          return;
        }
        el.visitChildren(findNav);
      }

      findNav(element);

      final f1 = nav.pushNamed<String>('/first');
      await _settle();
      final f2 = nav.pushNamed<String>('/second');
      await _settle();
      nav.pop('two');
      await _settle();
      expect(await f2, 'two');
      expect(nav.canPop(), isFalse);
      // Root route on null-home Navigator remains mounted.
      expect(f1, isA<Future<String?>>());
    });

    testClient('rootNavigator push and pop inside NakiApp + nested Navigator', (
      tester,
    ) async {
      late BuildContext nestedCtx;
      late BuildContext rootRouteCtx;

      tester.pumpComponent(
        NakiApp(
          home: Scaffold(
            body: Navigator(
              home: Builder(
                builder: (context) {
                  nestedCtx = context;
                  return const NakiText('Nested Home');
                },
              ),
            ),
          ),
        ),
      );
      await _settle();

      final rootNav = Navigator.of(nestedCtx, rootNavigator: true);
      final future = rootNav.push<String>(
        NakiPageRoute(
          builder: (context) {
            rootRouteCtx = context;
            return const NakiText('Root Pushed');
          },
        ),
      );
      await _settle();

      Navigator.pop(rootRouteCtx, 'root-ok');
      await _settle();
      expect(await future, 'root-ok');
    });
  });
}
