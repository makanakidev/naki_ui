@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/src/styles/rules.dart';
import 'package:naki_ui/src/utilities/enums.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 80));

const _triggerBox = div(
  styles: Styles(raw: {'width': '60px', 'height': '30px'}),
  [],
);

const _contentBox = div(
  styles: Styles(raw: {'width': '200px', 'height': '120px'}),
  [],
);

/// A viewport-pinned box holding a popover.
Component _pinned({
  required Map<String, String> offset,
  PopoverPosition position = PopoverPosition.bottomLeft,
  bool? visible = true,
  VoidCallback? onClose,
  Component content = _contentBox,
}) => div(
  styles: Styles(raw: {'position': 'fixed', ...offset}),
  [
    Popover(
      position: position,
      visible: visible,
      onClose: onClose,
      content: content,
      child: _triggerBox,
    ),
  ],
);

web.Element _node(String selector) => web.document.querySelector(selector)!;

web.DOMRect _rect(String selector) => _node(selector).getBoundingClientRect();

void _click(web.Element element) => (element as web.HTMLElement).click();

void _pointer(String type, web.Element element) => element.dispatchEvent(
  web.PointerEvent(type, web.PointerEventInit(bubbles: true)),
);

/// A finger lifting off [element] and the click that follows.
void _tap(web.Element element) {
  _pointer('pointerup', element);
  _click(element);
}

bool _hidden() =>
    web.window.getComputedStyle(_node('.naki-popover-content')).visibility ==
    'hidden';

bool _canFocus() => _node('.naki-popover-trigger').hasAttribute('canfocus');

class _Opener extends StatefulComponent {
  const _Opener();

  @override
  State<_Opener> createState() => _OpenerState();
}

class _OpenerState extends State<_Opener> {
  bool _open = false;

  @override
  Component build(BuildContext context) => Popover(
    visible: _open,
    onClose: () => setState(() => _open = false),
    content: _contentBox,
    child: button(
      id: 'opener',
      onClick: () => setState(() => _open = true),
      const [],
    ),
  );
}

void main() {
  final styles = web.document.createElement('style');

  setUpAll(() {
    // tests don't get the rules a server render would inline
    styles.textContent = Rules.nakiPopoverRules
        .map((rule) => rule.toCss())
        .join();
    web.document.head!.append(styles);
  });

  tearDownAll(() => styles.remove());

  group('placement', () {
    testClient('stays where its position puts it when it fits', (tester) async {
      tester.pumpComponent(
        _pinned(offset: const {'top': '40px', 'left': '40px'}),
      );
      await _settle();

      final content = _rect('.naki-popover-content');
      final anchor = _rect('.naki-popover');

      expect(content.top, closeTo(anchor.bottom + 8, 1));
      expect(content.left, closeTo(anchor.left, 1));
    });

    testClient('flips above a trigger at the bottom edge', (tester) async {
      tester.pumpComponent(
        _pinned(offset: const {'bottom': '10px', 'left': '40px'}),
      );
      await _settle();

      final content = _rect('.naki-popover-content');

      expect(content.bottom, closeTo(_rect('.naki-popover').top - 8, 1));
    });

    testClient('slides off the right edge and keeps its side', (tester) async {
      tester.pumpComponent(
        _pinned(offset: const {'top': '40px', 'right': '10px'}),
      );
      await _settle();

      final content = _rect('.naki-popover-content');
      final viewport = web.document.documentElement!.clientWidth;

      expect(content.right, closeTo(viewport - 8, 1));
      expect(content.top, closeTo(_rect('.naki-popover').bottom + 8, 1));
    });

    testClient('flips a left popover at the left edge', (tester) async {
      tester.pumpComponent(
        _pinned(
          position: PopoverPosition.left,
          offset: const {'top': '200px', 'left': '10px'},
        ),
      );
      await _settle();

      final content = _rect('.naki-popover-content');

      expect(content.left, closeTo(_rect('.naki-popover').right + 8, 1));
    });

    testClient('sets nothing while closed', (tester) async {
      tester.pumpComponent(
        _pinned(
          offset: const {'bottom': '10px', 'left': '40px'},
          visible: false,
        ),
      );
      await _settle();

      final content = _node('.naki-popover-content') as web.HTMLElement;

      expect(content.style.getPropertyValue('translate'), isEmpty);
    });
    testClient('keeps its placement when the page scrolls', (tester) async {
      tester.pumpComponent(
        _pinned(offset: const {'bottom': '10px', 'left': '40px'}),
      );
      await _settle();

      final content = _node('.naki-popover-content') as web.HTMLElement;
      final placed = content.style.getPropertyValue('translate');
      expect(placed, isNotEmpty);

      // the trigger has room below now, but scrolling must not move it there
      (_node('.naki-popover').parentElement! as web.HTMLElement).style.bottom =
          '400px';
      web.window.dispatchEvent(web.Event('scroll'));
      await _settle();

      expect(content.style.getPropertyValue('translate'), placed);
    });
  });

  group('clicking outside', () {
    const offset = {'top': '40px', 'left': '40px'};

    testClient('anywhere else closes it once', (tester) async {
      var closed = 0;
      tester.pumpComponent(_pinned(offset: offset, onClose: () => closed++));
      await _settle();

      _tap(web.document.body!);

      expect(closed, 1);
    });

    testClient('on an element above it closes it', (tester) async {
      var closed = 0;
      tester.pumpComponent(_pinned(offset: offset, onClose: () => closed++));
      await _settle();

      final above = web.document.createElement('div');
      web.document.body!.append(above);
      _tap(above);
      above.remove();

      expect(closed, 1);
    });

    testClient('on the trigger leaves it to the trigger', (tester) async {
      var closed = 0;
      tester.pumpComponent(_pinned(offset: offset, onClose: () => closed++));
      await _settle();

      _tap(_node('.naki-popover-trigger div'));

      expect(closed, 0);
    });

    testClient('a scrolling touch leaves it open', (tester) async {
      var closed = 0;
      tester.pumpComponent(_pinned(offset: offset, onClose: () => closed++));
      await _settle();

      _pointer('pointerdown', web.document.body!);
      _pointer('pointercancel', web.document.body!);

      expect(closed, 0);
    });

    testClient('scrolling the page closes it', (tester) async {
      var closed = 0;
      tester.pumpComponent(_pinned(offset: offset, onClose: () => closed++));
      await _settle();

      web.document.dispatchEvent(web.Event('scroll'));

      expect(closed, 1);
    });

    testClient('scrolling its content leaves it open', (tester) async {
      var closed = 0;
      tester.pumpComponent(
        _pinned(
          offset: offset,
          onClose: () => closed++,
          content: const div(
            id: 'list',
            styles: Styles(raw: {'height': '40px', 'overflow': 'auto'}),
            [
              div(styles: Styles(raw: {'height': '400px'}), []),
            ],
          ),
        ),
      );
      await _settle();

      _node('#list').dispatchEvent(web.Event('scroll'));

      expect(closed, 0);
    });

    testClient('adds no layer that blocks scrolling', (tester) async {
      tester.pumpComponent(_pinned(offset: offset));
      await _settle();

      expect(web.document.querySelector('.naki-popover-barrier'), isNull);
    });

    testClient('inside the content leaves it open', (tester) async {
      var closed = 0;
      tester.pumpComponent(
        _pinned(
          offset: offset,
          onClose: () => closed++,
          content: const button(id: 'inside', []),
        ),
      );
      await _settle();

      _tap(_node('#inside'));

      expect(closed, 0);
    });

    testClient('does not count the click that opened it', (tester) async {
      tester.pumpComponent(const _Opener());
      await _settle();

      _click(_node('#opener'));
      await _settle();

      expect(_node('.naki-popover').getAttribute('aria-expanded'), 'true');

      _tap(web.document.body!);
      await _settle();

      expect(_node('.naki-popover').getAttribute('aria-expanded'), 'false');
    });

    testClient('stops listening once closed', (tester) async {
      var closed = 0;
      tester.pumpComponent(
        _pinned(offset: offset, visible: false, onClose: () => closed++),
      );
      await _settle();

      _tap(web.document.body!);

      expect(closed, 0);
    });
  });

  group('closing', () {
    testClient('stays where it was and at its size', (tester) async {
      tester.pumpComponent(
        const div(
          styles: Styles(raw: {'position': 'fixed', 'bottom': '10px'}),
          [_Opener()],
        ),
      );
      await _settle();

      _click(_node('#opener'));
      await _settle();

      final open = _rect('.naki-popover-content');

      _tap(web.document.body!);
      await Future<void>.delayed(const Duration(milliseconds: 40));

      final closing = _rect('.naki-popover-content');

      expect(closing.top, closeTo(open.top, 1));
      expect(closing.height, closeTo(open.height, 1));

      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(_hidden(), isTrue);
    });
  });

  group('hover and focus', () {
    const offset = {'top': '40px', 'left': '40px'};

    testClient('show it when nothing controls it', (tester) async {
      tester.pumpComponent(_pinned(offset: offset, visible: null));
      await _settle();

      expect(_canFocus(), isTrue);
    });

    testClient('hide it on a press outside', (tester) async {
      var closed = 0;
      tester.pumpComponent(
        div(
          styles: const Styles(raw: {'position': 'fixed', ...offset}),
          [
            Popover(
              onClose: () => closed++,
              content: _contentBox,
              child: const button(id: 'hover', []),
            ),
          ],
        ),
      );
      await _settle();

      (_node('#hover') as web.HTMLElement).focus();
      await _settle();

      expect(_hidden(), isFalse);

      web.document.body!.dispatchEvent(
        web.PointerEvent('pointerdown', web.PointerEventInit(bubbles: true)),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(_canFocus(), isFalse);
      expect(_hidden(), isTrue);
      expect(closed, 1);

      // the trigger brings it back
      (_node('#hover') as web.HTMLElement).focus();
      await _settle();

      expect(_canFocus(), isTrue);
      expect(_hidden(), isFalse);
    });

    testClient('are ignored while the parent keeps it closed', (tester) async {
      tester.pumpComponent(_pinned(offset: offset, visible: false));
      await _settle();

      expect(_canFocus(), isFalse);
    });

    testClient('are ignored while the parent keeps it open', (tester) async {
      tester.pumpComponent(_pinned(offset: offset));
      await _settle();

      expect(_canFocus(), isFalse);
    });
  });
}
