@TestOn('vm')
library;

import 'package:jaspr_test/jaspr_test.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';

void main() {
  group('ResponsiveLayout', () {
    testComponents('renders child for a single breakpoint', (tester) async {
      tester.pumpComponent(
        ResponsiveLayout(
          breakpoint: BreakPoint.mobile,
          child: const NakiText('Mobile only'),
        ),
      );
      await tester.pump();

      expect(find.text('Mobile only'), findsOneComponent);
    });

    testComponents('renders all configured breakpoint slots', (tester) async {
      tester.pumpComponent(
        const ResponsiveLayout(
          mobile: NakiText('Phone view'),
          tablet: NakiText('Tablet view'),
          desktop: NakiText('Desktop view'),
        ),
      );
      await tester.pump();

      expect(find.text('Phone view'), findsOneComponent);
      expect(find.text('Tablet view'), findsOneComponent);
      expect(find.text('Desktop view'), findsOneComponent);
    });

    testComponents(
      'deprecated ResponsiveBuilder forwards to ResponsiveLayout',
      (
        tester,
      ) async {
        tester.pumpComponent(
          // ignore: deprecated_member_use_from_same_package
          const ResponsiveBuilder(
            mobile: NakiText('Legacy mobile'),
            desktop: NakiText('Legacy desktop'),
          ),
        );
        await tester.pump();

        expect(find.text('Legacy mobile'), findsOneComponent);
        expect(find.text('Legacy desktop'), findsOneComponent);
      },
    );
  });
}
