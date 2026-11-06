// Scroll views add the Scaffold insets to their padding, so these tests read
// the rendered styles: dart test -p chrome test/scaffold_insets_test.dart
@TestOn('browser')
library;

import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
import 'package:universal_web/web.dart' as web;

const _insetClass = 'naki-inset-owner';

web.HTMLElement _element(String selector) =>
    web.document.querySelector(selector)! as web.HTMLElement;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  group('scroll view insets', () {
    testClient('a vertical list adds them to its padding', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const ListView(
            padding: EdgeInsets.symmetric(vertical: Dim.px(24)),
            children: [NakiText('Item')],
          ),
        ),
      );
      await _settle();

      final list = _element('.naki-listview');
      final style = list.getAttribute('style')!;

      expect(list.classList.contains(_insetClass), isTrue);
      expect(style, contains('--naki-body-inset-top'));
      expect(style, contains('--naki-body-inset-bottom'));
      expect(style, contains('24px'));
    });

    testClient('they work without explicit padding', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const SingleChildScrollView(child: NakiText('Body')),
        ),
      );
      await _settle();

      final view = _element('.naki-singlechild-scrollview');

      expect(view.classList.contains(_insetClass), isTrue);
      expect(view.getAttribute('style'), contains('--naki-body-inset-top'));
    });

    testClient('a page view owns them for its pages', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const PageView(children: [NakiText('Page')]),
        ),
      );
      await _settle();

      expect(
        _element('.naki-pageview').classList.contains(_insetClass),
        isTrue,
      );
    });

    testClient('a scrollable column owns them', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Column(
            scrollable: true,
            children: [NakiText('Item')],
          ),
        ),
      );
      await _settle();

      final column = _element('.naki-column');

      expect(column.classList.contains(_insetClass), isTrue);
      expect(column.getAttribute('style'), contains('--naki-body-inset-top'));
    });

    testClient('marks views that take their parent height', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Row(
            children: [
              Expanded(child: ListView(children: [NakiText('Fills')])),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  classes: 'shrink',
                  children: [NakiText('Shrinks')],
                ),
              ),
            ],
          ),
        ),
      );
      await _settle();

      final lists = web.document.querySelectorAll('.naki-listview');
      final fills = lists.item(0)! as web.Element;
      final shrinks = lists.item(1)! as web.Element;

      expect(fills.classList.contains('naki-fill-scroll'), isTrue);
      expect(shrinks.classList.contains('naki-fill-scroll'), isFalse);
    });

    testClient('vertical staggered columns sit inside the scroller', (
      tester,
    ) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => StaggeredView.count(
            2,
            children: const [NakiText('A'), NakiText('B')],
          ),
        ),
      );
      await _settle();

      final view = _element('.naki-staggeredview');

      expect(view.getAttribute('style'), isNot(contains('column-count')));
      expect(
        _element('.naki-staggered-columns').getAttribute('style'),
        contains('column-count: 2'),
      );
    });

    testClient('a scrollable row leaves them to the body', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const Row(
            scrollable: true,
            children: [NakiText('Item')],
          ),
        ),
      );
      await _settle();

      final row = _element('.naki-row');

      expect(row.classList.contains(_insetClass), isFalse);
      expect(row.getAttribute('style'), isNot(contains('--naki-body-inset')));
    });

    testClient('a horizontal view leaves them alone', (tester) async {
      tester.pumpComponent(
        NakiThemeProvider(
          builder: (_) => const SingleChildScrollView(
            direction: ScrollDirection.horizontal,
            child: NakiText('Body'),
          ),
        ),
      );
      await _settle();

      final view = _element('.naki-singlechild-scrollview');

      expect(view.classList.contains(_insetClass), isFalse);
      expect(view.getAttribute('style'), isNot(contains('--naki-body-inset')));
    });
  });
}
