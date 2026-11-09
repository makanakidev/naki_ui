@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/src/styles/css.dart';
import 'package:naki_ui/src/styles/rules.dart';
import 'package:naki_ui/src/utilities/enums.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 80));

const _targetBox = div(
  styles: Styles(raw: {'width': '60px', 'height': '30px'}),
  [],
);

const _tipBox = div(
  styles: Styles(raw: {'width': '150px', 'height': '40px'}),
  [],
);

/// A viewport-pinned box holding a tooltip.
Component _pinned({
  required Map<String, String> offset,
  TooltipPosition position = TooltipPosition.top,
}) => div(
  styles: Styles(raw: {'position': 'fixed', ...offset}),
  [
    Tooltip(position: position, content: _tipBox, child: _targetBox),
  ],
);

web.HTMLElement get _tip =>
    web.document.querySelector('.naki-tooltip-content')! as web.HTMLElement;

web.DOMRect get _target =>
    web.document.querySelector('.naki-tooltip')!.getBoundingClientRect();

/// Hovers the target, as the browser would.
Future<void> _hover() async {
  web.document
      .querySelector('.naki-tooltip-target')!
      .dispatchEvent(web.MouseEvent('mouseenter'));
  await _settle();
}

String _var(String name) => _tip.style.getPropertyValue(name);

double _px(String name) => double.parse(_var(name).replaceAll('px', ''));

void main() {
  final styles = web.document.createElement('style');

  setUpAll(() {
    // tests don't get the rules a server render would inline
    styles.textContent = Rules.nakiTooltipRules.toCss();
    web.document.head!.append(styles);
  });

  tearDownAll(() => styles.remove());

  testClient('stays at its position when it fits', (tester) async {
    tester.pumpComponent(
      _pinned(offset: const {'top': '200px', 'left': '200px'}),
    );
    await _settle();
    await _hover();

    expect(_tip.getBoundingClientRect().bottom, closeTo(_target.top - 8, 1));
    expect(_tip.style.getPropertyValue('translate'), isEmpty);
  });

  testClient('flips below a target at the top edge and turns its arrow', (
    tester,
  ) async {
    tester.pumpComponent(
      _pinned(offset: const {'top': '10px', 'left': '200px'}),
    );
    await _settle();
    await _hover();

    expect(_tip.getBoundingClientRect().top, closeTo(_target.bottom + 8, 1));
    expect(_var(kTooltipArrowRotateVar), '180deg');

    // up past the whole tip, padding included, and the arrow's own length
    final height = _tip.getBoundingClientRect().height;
    expect(_px(kTooltipArrowYVar), closeTo(-(height + 5), 0.5));
  });

  testClient('flips a left tooltip at the left edge', (tester) async {
    tester.pumpComponent(
      _pinned(
        position: TooltipPosition.left,
        offset: const {'top': '200px', 'left': '10px'},
      ),
    );
    await _settle();
    await _hover();

    expect(_tip.getBoundingClientRect().left, closeTo(_target.right + 8, 1));

    final width = _tip.getBoundingClientRect().width;
    expect(_px(kTooltipArrowXVar), closeTo(-(width + 5), 0.5));
  });

  testClient('slides off the left edge with its arrow on the target', (
    tester,
  ) async {
    tester.pumpComponent(
      _pinned(offset: const {'top': '200px', 'left': '10px'}),
    );
    await _settle();
    await _hover();

    final tip = _tip.getBoundingClientRect();

    expect(tip.left, closeTo(8, 1));
    expect(tip.bottom, closeTo(_target.top - 8, 1));

    final tipCenter = (tip.left + tip.right) / 2;
    final targetCenter = (_target.left + _target.right) / 2;

    expect(tipCenter + _px(kTooltipArrowXVar), closeTo(targetCenter, 1));
  });
}
