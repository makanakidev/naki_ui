@TestOn('vm')
library;

import 'package:naki_ui/src/framework/overlay_stack.dart';
import 'package:test/test.dart';

void main() {
  group('NakiOverlayStack', () {
    test('treats any owner as top-most when empty', () {
      final owner = Object();
      expect(NakiOverlayStack.isTop(owner), isTrue);
    });

    test('tracks most recently pushed overlay as top-most', () {
      final first = Object();
      final second = Object();

      NakiOverlayStack.push(first);
      expect(NakiOverlayStack.isTop(first), isTrue);

      NakiOverlayStack.push(second);
      expect(NakiOverlayStack.isTop(first), isFalse);
      expect(NakiOverlayStack.isTop(second), isTrue);

      NakiOverlayStack.remove(second);
      expect(NakiOverlayStack.isTop(first), isTrue);

      NakiOverlayStack.remove(first);
    });

    test('re-pushing moves owner to the top without duplicates', () {
      final first = Object();
      final second = Object();

      NakiOverlayStack.push(first);
      NakiOverlayStack.push(second);
      NakiOverlayStack.push(first);

      expect(NakiOverlayStack.isTop(first), isTrue);
      expect(NakiOverlayStack.isTop(second), isFalse);

      NakiOverlayStack.remove(first);
      expect(NakiOverlayStack.isTop(second), isTrue);

      NakiOverlayStack.remove(second);
    });

    test('removing an unknown owner is a safe no-op', () {
      final registered = Object();
      final unknown = Object();

      NakiOverlayStack.push(registered);
      NakiOverlayStack.remove(unknown);
      expect(NakiOverlayStack.isTop(registered), isTrue);

      NakiOverlayStack.remove(registered);
    });
  });
}
