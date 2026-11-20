import 'package:naki_ui/src/styles/css.dart';
import 'package:test/test.dart';

void main() {
  group('safe areas', () {
    test('bottom insets include the measured home indicator', () {
      expect(Css.safeAreaBottom, contains(kViewportInsetBottomVar));
      expect(Css.safeAreaTop, contains(kViewportInsetTopVar));
    });

    test('the app bar keeps its content clear of the side insets', () {
      final inset = Css.nakiScaffoldStyle['appbar-inset']!;

      expect(inset['padding-left'], contains(Css.safeAreaLeft));
      expect(inset['padding-right'], contains(Css.safeAreaRight));
    });

    test('a dialog stays inside all four insets', () {
      final padding = Css.nakiDialogStyle['backdrop']!['padding'];

      for (final inset in [
        Css.safeAreaTop,
        Css.safeAreaRight,
        Css.safeAreaBottom,
        Css.safeAreaLeft,
      ]) {
        expect(padding, contains(inset));
      }
    });

    test('a bottom sheet clears the home indicator and side insets', () {
      final style = Css.nakiBottomSheetStyle;

      expect(style['container']!['padding-bottom'], Css.safeAreaBottom);
      expect(style['backdrop']!['padding'], contains(Css.safeAreaLeft));
    });

    test('a drawer fills the viewport and keeps its content inside', () {
      final wrapper = Css.nakiDrawerStyle['wrapper']!;
      final content = Css.nakiDrawerStyle['content']!;

      expect(wrapper['inset'], '0');
      expect(content['padding-top'], Css.safeAreaTop);
      expect(content['padding-bottom'], Css.safeAreaBottom);
    });

    test('the floating action button clears the side inset', () {
      expect(
        Css.nakiScaffoldStyle['fab']!['right'],
        contains(Css.safeAreaRight),
      );
    });

    test('floating navbars narrow to fit between the side insets', () {
      for (final type in ['floating', 'frosted-glass']) {
        final width = Css.nakiBottomNavBarStyle[type]!['width'];

        expect(width, contains(Css.safeAreaLeft));
        expect(width, contains(Css.safeAreaRight));
      }
    });
  });

  test('Popover content is never wider than the safe area', () {
    final maxWidth = Css.nakiPopoverStyle['popup']!['max-width']!;

    expect(maxWidth, contains(Css.safeAreaLeft));
    expect(maxWidth, contains(Css.safeAreaRight));
  });
}
