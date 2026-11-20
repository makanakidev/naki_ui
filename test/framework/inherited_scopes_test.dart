@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/src/framework/inherited/index.dart';

void main() {
  group('FlexScope', () {
    testComponents('exposes scrollable flag to descendants', (tester) async {
      FlexScope? foundAbsent;
      FlexScope? foundScrollable;

      tester.pumpComponent(
        Builder(
          builder: (context) {
            foundAbsent = FlexScope.of(context);
            return FlexScope(
              scrollable: true,
              child: Builder(
                builder: (innerContext) {
                  foundScrollable = FlexScope.of(innerContext);
                  return const div([]);
                },
              ),
            );
          },
        ),
      );
      await tester.pump();

      expect(foundAbsent, isNull);
      expect(foundScrollable, isNotNull);
      expect(foundScrollable!.scrollable, isTrue);
    });
  });

  group('StackScope', () {
    testComponents('is discoverable by descendants', (tester) async {
      StackScope? foundAbsent;
      StackScope? foundPresent;

      tester.pumpComponent(
        Builder(
          builder: (context) {
            foundAbsent = StackScope.of(context);
            return StackScope(
              child: Builder(
                builder: (innerContext) {
                  foundPresent = StackScope.of(innerContext);
                  return const div([]);
                },
              ),
            );
          },
        ),
      );
      await tester.pump();

      expect(foundAbsent, isNull);
      expect(foundPresent, isNotNull);
    });
  });

  group('NakiDomIdRegistry', () {
    testComponents('allocates stable ids per owner context and prefix', (
      tester,
    ) async {
      final registry = NakiDomIdRegistry();
      String? firstId;
      String? repeatedId;
      String? otherPrefixId;
      String? siblingId;

      tester.pumpComponent(
        NakiDomIdScope(
          registry: registry,
          child: div([
            Builder(
              builder: (context) {
                firstId = registry.resolve(context, 'input');
                repeatedId = registry.resolve(context, 'input');
                otherPrefixId = registry.resolve(context, 'label');
                return const div([]);
              },
            ),
            Builder(
              builder: (context) {
                siblingId = registry.resolve(context, 'input');
                return const div([]);
              },
            ),
          ]),
        ),
      );
      await tester.pump();

      expect(firstId, isNotNull);
      expect(repeatedId, firstId);
      expect(otherPrefixId, isNot(equals(firstId)));
      expect(otherPrefixId, startsWith('label_nakidom_'));
      expect(siblingId, isNot(equals(firstId)));
      expect(siblingId, startsWith('input_nakidom_'));
    });
  });
}
