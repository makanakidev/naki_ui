// Runs on the VM, where PlatformData resolves to the server implementation.
@TestOn('vm')
library;

import 'package:naki_ui/framework.dart';
import 'package:test/test.dart';

const _agents = {
  'chrome-mac':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  'edge-windows':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0',
  'chrome-android':
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36',
  'safari-mac':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 '
      '(KHTML, like Gecko) Version/26.0 Safari/605.1.15',
  'safari-iphone':
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 '
      'Safari/604.1',
  'chrome-iphone':
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/131.0.6778.73 '
      'Mobile/15E148 Safari/604.1',
  'edge-iphone':
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 EdgiOS/131.0 '
      'Mobile/15E148 Safari/605.1.15',
  'firefox-mac':
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:133.0) '
      'Gecko/20100101 Firefox/133.0',
};

void main() {
  final expected = {
    // name: (isChromium, isWebKit)
    'chrome-mac': (true, false),
    'edge-windows': (true, false),
    'chrome-android': (true, false),
    'safari-mac': (false, true),
    'safari-iphone': (false, true),
    'chrome-iphone': (false, true),
    'edge-iphone': (false, true),
    'firefox-mac': (false, false),
  };

  for (final MapEntry(key: name, value: (chromium, webkit))
      in expected.entries) {
    test('$name engine', () {
      PlatformData.init(userAgent: _agents[name]);
      final platform = PlatformData.current;

      expect(platform.isChromium, chromium, reason: 'isChromium');
      expect(platform.isWebKit, webkit, reason: 'isWebKit');
    });
  }

  tearDown(PlatformData.init);
}
