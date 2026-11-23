part of 'index.dart';

/// {@template NakiFragment}
/// A component that renders its [children] directly under
/// its parent without inserting any HTML wrapper element.
///
/// Unlike Jaspr's built-in `Component.fragment`, [NakiFragment]
/// tracks its own render children on the client DOM so nested
/// fragments, child reordering, removals, and replacements work
/// without hitting fragment parent/sibling assertions.
/// {@endtemplate}
class NakiFragment extends Component {
  /// Child components rendered directly under the parent.
  final List<Component> children;

  /// {@macro NakiFragment}
  const NakiFragment(this.children, {super.key});

  const NakiFragment._empty() : children = const [];

  @override
  Element createElement() => _NakiFragmentElement(this);
}

class _NakiFragmentElement extends MultiChildRenderObjectElement {
  _NakiFragmentElement(NakiFragment super.component);

  @override
  List<Component> buildChildren() => (component as NakiFragment).children;

  @override
  RenderObject createRenderObject() {
    final renderObject = createNakiRenderFragment(
      parentRenderObjectElement!.renderObject,
    );
    assert(renderObject.parent == parentRenderObjectElement!.renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(RenderFragment fragment) {}
}
