@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/naki_ui.dart';

void main() {
  group('NakiFragment & deprecated FragmentScope (VM)', () {
    testComponents('NakiFragment renders children without wrapper element', (
      tester,
    ) async {
      tester.pumpComponent(
        const div(
          id: 'host',
          [
            NakiFragment([
              span([.text('First')]),
              NakiFragment([
                span([.text('Nested')]),
              ]),
            ]),
          ],
        ),
      );
      await tester.pump();

      expect(find.tag('naki-fragment'), findsNothing);
      expect(find.text('First'), findsOneComponent);
      expect(find.text('Nested'), findsOneComponent);
    });

    testComponents('deprecated FragmentScope forwards to NakiFragment', (
      tester,
    ) async {
      tester.pumpComponent(
        const div(
          id: 'host',
          [
            // ignore: deprecated_member_use_from_same_package
            FragmentScope([
              span([.text('Legacy')]),
            ]),
          ],
        ),
      );
      await tester.pump();

      expect(find.tag('naki-fragment'), findsNothing);
      expect(find.text('Legacy'), findsOneComponent);
    });

    testComponents('NakiFragment supports empty -> populated -> reordered', (
      tester,
    ) async {
      var items = <String>[];

      tester.pumpComponent(
        Builder(
          builder: (_) => div([
            NakiFragment([
              for (final item in items)
                span(key: ValueKey(item), [.text(item)]),
            ]),
          ]),
        ),
      );
      await tester.pump();

      expect(find.tag('span'), findsNothing);

      items = ['A', 'B', 'C'];
      tester.pumpComponent(
        Builder(
          builder: (_) => div([
            NakiFragment([
              for (final item in items)
                span(key: ValueKey(item), [.text(item)]),
            ]),
          ]),
        ),
      );
      await tester.pump();

      expect(find.text('A'), findsOneComponent);
      expect(find.text('B'), findsOneComponent);
      expect(find.text('C'), findsOneComponent);
    });
  });
}
