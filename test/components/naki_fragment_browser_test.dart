@TestOn('browser')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/client_test.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:universal_web/web.dart' as web;

Future<void> _settle([int ms = 40]) =>
    Future<void>.delayed(Duration(milliseconds: ms));

List<String> _childIds(String hostId) {
  final host = web.document.getElementById(hostId)!;
  return [
    for (var i = 0; i < host.children.length; i++) host.children.item(i)!.id,
  ];
}

class _FragmentHarness extends StatefulComponent {
  const _FragmentHarness({required this.onReady});

  final void Function(_FragmentHarnessState state) onReady;

  @override
  State<_FragmentHarness> createState() => _FragmentHarnessState();
}

class _FragmentHarnessState extends State<_FragmentHarness> {
  List<Component> children = [];

  @override
  void initState() {
    super.initState();
    component.onReady(this);
  }

  void setChildren(List<Component> next) {
    setState(() => children = next);
  }

  @override
  Component build(BuildContext context) {
    return div(id: 'frag-host', [
      const div(id: 'before', []),
      NakiFragment(children),
      const div(id: 'after', []),
    ]);
  }
}

void main() {
  group('NakiFragment browser DOM', () {
    testClient(
      'NakiFragment and deprecated FragmentScope render direct DOM children with no wrapper',
      (tester) async {
        tester.pumpComponent(
          const div(id: 'scope-host', [
            NakiFragment([
              div(id: 'one', []),
              NakiFragment([
                div(id: 'two', []),
                // ignore: deprecated_member_use_from_same_package
                FragmentScope([
                  div(id: 'three', []),
                ]),
              ]),
            ]),
          ]),
        );
        await _settle();

        expect(web.document.querySelector('naki-fragment'), isNull);
        expect(_childIds('scope-host'), ['one', 'two', 'three']);
      },
    );

    testClient(
      'supports deep nesting, reordering, removal, and replacing cleanly',
      (tester) async {
        late _FragmentHarnessState harness;

        tester.pumpComponent(_FragmentHarness(onReady: (s) => harness = s));
        await _settle();
        expect(_childIds('frag-host'), ['before', 'after']);

        // 1. Nested fragments (including empty fragment)
        // + built-in Fragment.
        harness.setChildren([
          const NakiFragment(
            key: ValueKey('g1'),
            [
              div(id: 'a', []),
              NakiFragment(key: ValueKey('empty'), []),
              NakiFragment(
                key: ValueKey('g1-inner'),
                [div(id: 'b', [])],
              ),
            ],
          ),
          const Component.fragment(
            key: ValueKey('jaspr-frag'),
            [div(id: 'c', [])],
          ),
          const div(id: 'd', []),
        ]);
        await _settle();
        expect(_childIds('frag-host'), ['before', 'a', 'b', 'c', 'd', 'after']);

        // 2. Reorder nested fragments and built-in/plain children.
        harness.setChildren([
          const div(id: 'd', []),
          const NakiFragment(
            key: ValueKey('g1'),
            [
              NakiFragment(key: ValueKey('empty'), []),
              NakiFragment(
                key: ValueKey('g1-inner'),
                [div(id: 'b', [])],
              ),
              div(id: 'a', []),
            ],
          ),
          const Component.fragment(
            key: ValueKey('jaspr-frag'),
            [div(id: 'c', [])],
          ),
        ]);
        await _settle();
        expect(_childIds('frag-host'), ['before', 'd', 'b', 'a', 'c', 'after']);

        // 3. Replace a nested NakiFragment and
        // built-in Fragment cleanly.
        harness.setChildren([
          const div(id: 'd', []),
          const div(id: 'replaced', []),
          const NakiFragment(
            key: ValueKey('g2'),
            [div(id: 'e', []), div(id: 'f', [])],
          ),
        ]);
        await _settle();
        expect(
          _childIds('frag-host'),
          ['before', 'd', 'replaced', 'e', 'f', 'after'],
        );

        // 4. Remove all children back to empty, then repopulate.
        harness.setChildren(const []);
        await _settle();
        expect(_childIds('frag-host'), ['before', 'after']);

        harness.setChildren([
          const NakiFragment([
            NakiFragment([div(id: 'final', [])]),
          ]),
        ]);
        await _settle();
        expect(_childIds('frag-host'), ['before', 'final', 'after']);
      },
    );

    testClient(
      'NakiFragment inside built-in Component.fragment unmounts cleanly',
      (tester) async {
        var useFragment = true;

        Component buildTree() => div(id: 'outer-host', [
          Component.fragment([
            const div(id: 'lead', []),
            if (useFragment)
              const NakiFragment([
                NakiFragment([div(id: 'x', []), div(id: 'y', [])]),
              ])
            else
              const div(id: 'z', []),
          ]),
        ]);

        tester.pumpComponent(Builder(builder: (_) => buildTree()));
        await _settle();
        expect(_childIds('outer-host'), ['lead', 'x', 'y']);

        useFragment = false;
        tester.pumpComponent(Builder(builder: (_) => buildTree()));
        await _settle();
        expect(_childIds('outer-host'), ['lead', 'z']);
      },
    );
  });
}
