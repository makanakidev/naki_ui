@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/src/models/overlays/index.dart'
    show OverlayEntryScope, OverlayResultController;

void main() {
  group('Navigator imperative routes', () {
    testComponents('push and pop complete future with typed result', (
      tester,
    ) async {
      late BuildContext homeCtx;
      late BuildContext pushedCtx;

      tester.pumpComponent(
        Navigator(
          home: Builder(
            builder: (context) {
              homeCtx = context;
              return const span([.text('Home Page')]);
            },
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Home Page'), findsOneComponent);
      expect(Navigator.canPop(homeCtx), isFalse);

      final resultFuture = Navigator.push<String>(
        homeCtx,
        NakiPageRoute(
          settings: const NakiRouteSettings(name: '/details', arguments: 42),
          builder: (context) {
            pushedCtx = context;
            final route = NakiRoute.of<String>(context);
            return span([.text('Details ${route?.settings.arguments}')]);
          },
        ),
      );
      await tester.pump();

      expect(find.text('Details 42'), findsOneComponent);
      expect(Navigator.canPop(pushedCtx), isTrue);

      Navigator.pop(pushedCtx, 'done');
      await tester.pump();

      expect(await resultFuture, 'done');
      expect(find.text('Home Page'), findsOneComponent);
    });

    testComponents('pushNamed, pushReplacementNamed, and popUntil work', (
      tester,
    ) async {
      late BuildContext rootCtx;
      BuildContext? leafCtx;

      tester.pumpComponent(
        Navigator(
          home: Builder(
            builder: (context) {
              rootCtx = context;
              return const span([.text('Root')]);
            },
          ),
          routes: {
            '/first': (context) => const span([.text('First')]),
            '/second': (context) {
              leafCtx = context;
              final args = NakiRoute.maybeOf(context)?.settings.arguments;
              return span([.text('Second $args')]);
            },
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/third') {
              return NakiPageRoute<int>(
                settings: settings,
                builder: (context) {
                  leafCtx = context;
                  return const span([.text('Third')]);
                },
              );
            }
            return null;
          },
        ),
      );
      await tester.pump();

      final firstFuture = Navigator.pushNamed<String>(rootCtx, '/first');
      await tester.pump();
      expect(find.text('First'), findsOneComponent);

      final secondFuture = Navigator.pushReplacementNamed<String, String>(
        rootCtx,
        '/second',
        result: 'replaced',
        arguments: 'arg1',
      );
      await tester.pump();
      expect(await firstFuture, 'replaced');
      expect(find.text('Second arg1'), findsOneComponent);

      final thirdFuture = Navigator.pushNamed<int>(leafCtx!, '/third');
      await tester.pump();
      expect(find.text('Third'), findsOneComponent);

      Navigator.popUntil(leafCtx!, Navigator.withName('/second'));
      await tester.pump();
      expect(await thirdFuture, isNull);
      expect(find.text('Second arg1'), findsOneComponent);

      expect(await Navigator.maybePop(leafCtx!, 'ok'), isTrue);
      await tester.pump();
      expect(await secondFuture, 'ok');
      expect(find.text('Root'), findsOneComponent);
      expect(await Navigator.maybePop(rootCtx), isFalse);
    });

    testComponents('Navigator.pop inside OverlayEntryScope closes overlay first', (
      tester,
    ) async {
      final controller = OverlayResultController<String>();
      late BuildContext overlayCtx;
      late BuildContext homeCtx;

      tester.pumpComponent(
        Navigator(
          home: Builder(
            builder: (context) {
              homeCtx = context;
              return OverlayEntryScope(
                controller: controller,
                child: Builder(
                  builder: (inner) {
                    overlayCtx = inner;
                    return const span([.text('Overlay Content')]);
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(controller.isOpen, isTrue);
      expect(Navigator.canPop(overlayCtx), isTrue);

      Navigator.pop(overlayCtx, 'picked');

      expect(controller.isOpen, isFalse);
      expect(controller.result, 'picked');
      expect(Navigator.canPop(homeCtx), isFalse);
    });

    testComponents('rootNavigator: true resolves outermost Navigator', (
      tester,
    ) async {
      late BuildContext innerCtx;
      late NavigatorState rootNav;
      late NavigatorState nestedNav;

      tester.pumpComponent(
        Navigator(
          home: Builder(
            builder: (outerCtx) {
              rootNav = Navigator.of(outerCtx);
              return Navigator(
                home: Builder(
                  builder: (context) {
                    innerCtx = context;
                    nestedNav = Navigator.of(context);
                    return const div([]);
                  },
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();

      expect(identical(Navigator.of(innerCtx), nestedNav), isTrue);
      expect(
        identical(Navigator.of(innerCtx, rootNavigator: true), rootNav),
        isTrue,
      );
      expect(identical(rootNav, nestedNav), isFalse);
    });
  });
}
