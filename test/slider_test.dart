// The Slider tooltip position has to follow rebuilds, so these tests run in a
// browser: dart test -p chrome test/slider_test.dart
@TestOn('browser')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:universal_web/web.dart' as web;

class _Host extends StatefulComponent {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

_HostState? _host;

class _HostState extends State<_Host> {
  double value = 25;

  void update(double next) => setState(() => value = next);

  @override
  void initState() {
    super.initState();
    _host = this;
  }

  @override
  Component build(BuildContext context) => Slider(
    id: 'volume',
    value: value,
    showValueIndicator: true,
    onChange: update,
  );
}

web.HTMLElement get _tooltip =>
    web.document.getElementById('nsl_volume-tooltip')! as web.HTMLElement;

web.HTMLInputElement get _input =>
    web.document.getElementById('nsl_volume')! as web.HTMLInputElement;

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 50));

String _left() => _tooltip.style.getPropertyValue('left');

void main() {
  testClient('Slider tooltip follows the value', (tester) async {
    tester.pumpComponent(const _Host());
    await _settle();
    expect(_left(), startsWith('calc(25%'));

    // Changed from code, before the DOM input holds the new value.
    _host!.update(75);
    await _settle();
    expect(_left(), startsWith('calc(75%'));

    _input.value = '60';
    _input.dispatchEvent(web.Event('input'));
    await _settle();
    expect(_left(), startsWith('calc(60%'));
    expect(_tooltip.textContent, '60');
  });

  testClient('Slider tooltip visibility is left to CSS', (tester) async {
    tester.pumpComponent(const _Host());
    await _settle();

    _input.dispatchEvent(web.Event('blur'));
    await _settle();
    expect(_tooltip.style.getPropertyValue('opacity'), isEmpty);
  });
}
