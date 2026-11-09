@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/src/models/overlays.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 80));

void _click(String selector) =>
    (web.document.querySelector(selector)! as web.HTMLElement).click();

void main() {
  testClient('tapping the content leaves it open', (tester) async {
    final controller = OverlayController()..open();

    tester.pumpComponent(
      Drawer(
        controller: controller,
        child: const div(classes: 'menu', []),
      ),
    );
    await _settle();

    _click('.menu');
    await _settle();
    expect(controller.isOpen, isTrue);

    _click('.naki-drawer-content');
    await _settle();
    expect(controller.isOpen, isTrue);
  });

  testClient('tapping the barrier closes it', (tester) async {
    final controller = OverlayController()..open();

    tester.pumpComponent(
      Drawer(
        controller: controller,
        child: const div(classes: 'menu', []),
      ),
    );
    await _settle();

    _click('.naki-drawer');
    await _settle();

    expect(controller.isOpen, isFalse);
  });
}
