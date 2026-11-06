import 'package:naki_ui/theme.dart';
import 'package:test/test.dart';

void main() {
  group('TextStyle text-wrap', () {
    test('wraps when maxLines clamps', () {
      expect(const TextStyle(maxLines: 2).props['text-wrap'], 'wrap');
      expect(const TextStyle(maxLines: 1).props['text-wrap'], 'wrap');
    });

    test('softWrap false wins over maxLines', () {
      final props = const TextStyle(maxLines: 2, softWrap: false).props;
      expect(props['text-wrap'], 'nowrap');
    });

    test('is left to inherit by default', () {
      expect(const TextStyle().props.containsKey('text-wrap'), isFalse);
    });

    test('softWrap false disables wrapping', () {
      expect(const TextStyle(softWrap: false).props['text-wrap'], 'nowrap');
    });

    test('maxLines 0 does not clamp', () {
      expect(
        const TextStyle(maxLines: 0).props.containsKey('text-wrap'),
        isFalse,
      );
    });
  });
}
