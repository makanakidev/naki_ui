import 'package:jaspr/client.dart';
import 'package:universal_web/web.dart' as web;

/// Creates the platform-appropriate [RenderFragment] for [parent].
RenderFragment createNakiRenderFragment(RenderObject parent) {
  if (parent is DomRenderObject) return _NakiDomRenderFragment(parent);
  return parent.createChildRenderFragment();
}

/// A client DOM [RenderFragment] that supports arbitrary
/// nesting, reordering, removal, and replacement of child
/// render objects without hitting Jaspr's fragment
/// parent/sibling assertions.
class _NakiDomRenderFragment extends DomRenderFragment {
  _NakiDomRenderFragment(DomRenderObject super.parent);

  final List<DomRenderObject> _children = <DomRenderObject>[];

  DomRenderObject? get _attachTargetObject {
    DomRenderObject? current = this;
    while (current is DomRenderFragment) {
      if (!current.isAttached) return current;
      current = current.parent;
    }
    return current;
  }

  web.Node? _firstNodeOf(DomRenderObject child) {
    if (child is DomRenderFragment) return child.firstChildNode;
    return child.node;
  }

  web.Node? _lastNodeOf(DomRenderObject child) {
    if (child is DomRenderFragment) return child.lastChildNode;
    return child.node;
  }

  void _collectNodes(DomRenderObject child, List<web.Node> out) {
    if (child is _NakiDomRenderFragment) {
      for (final nested in child._children) {
        _collectNodes(nested, out);
      }
      return;
    }

    if (child is DomRenderFragment) {
      final first = child.firstChildNode;
      final last = child.lastChildNode;
      if (first == null || last == null) return;

      web.Node? current = first;
      while (current != null) {
        out.add(current);
        if (identical(current, last)) break;
        current = current.nextSibling;
      }
      return;
    }

    out.add(child.node);
  }

  void _unlinkChild(DomRenderObject child) {
    final index = _children.indexOf(child);
    if (index == -1) return;

    _children.removeAt(index);

    final prev = child.previousSibling;
    final next = child.nextSibling;

    prev?.nextSibling = next;
    next?.previousSibling = prev;
    child.previousSibling = null;
    child.nextSibling = null;
  }

  int _insertInChildren(DomRenderObject child, DomRenderObject? after) {
    _unlinkChild(child);

    final insertIndex = after == null
        ? 0
        : switch (_children.indexOf(after)) {
            -1 => _children.length,
            final idx => idx + 1,
          };

    _children.insert(insertIndex, child);

    final prev = insertIndex > 0 ? _children[insertIndex - 1] : null;
    final next = insertIndex + 1 < _children.length
        ? _children[insertIndex + 1]
        : null;

    child.previousSibling = prev;
    child.nextSibling = next;
    prev?.nextSibling = child;
    next?.previousSibling = child;

    return insertIndex;
  }

  web.Node? _resolveAfterNode(
    int insertIndex,
    web.Node targetNode,
    web.Node? existingFirstNode,
  ) {
    for (var i = insertIndex - 1; i >= 0; i--) {
      final node = _lastNodeOf(_children[i]);
      if (node != null) return node;
    }

    if (!isAttached) return null;

    if (parent case final MultiChildDomRenderObject parentMulti) {
      final anchor = parentMulti.getRealNodeOf(previousSibling);
      if (anchor != null) return anchor;
    }

    if (existingFirstNode != null &&
        existingFirstNode.parentNode == targetNode) {
      return existingFirstNode.previousSibling;
    }

    return null;
  }

  @override
  web.Node? get firstChildNode {
    for (final child in _children) {
      final node = _firstNodeOf(child);
      if (node != null) return node;
    }
    return null;
  }

  @override
  web.Node? get lastChildNode {
    for (var i = _children.length - 1; i >= 0; i--) {
      final node = _lastNodeOf(_children[i]);
      if (node != null) return node;
    }
    return null;
  }

  @override
  void attach(DomRenderObject child, {DomRenderObject? after}) {
    child.parent = this;

    final existingFirstNode = firstChildNode;
    final insertIndex = _insertInChildren(child, after);

    final targetNode = attachTargetNode;
    final afterNode = _resolveAfterNode(
      insertIndex,
      targetNode,
      existingFirstNode,
    );

    if (child case DomRenderFragment(isAttached: true)) {
      child.move(this, targetNode, afterNode);
      return;
    }

    final childNode = child.node;
    final beforeNode = afterNode == null
        ? targetNode.childNodes.item(0)
        : afterNode.nextSibling;

    try {
      if (childNode.previousSibling != afterNode ||
          childNode.parentNode != targetNode) {
        if (!identical(childNode, beforeNode)) {
          targetNode.insertBefore(childNode, beforeNode);
        }
      }
    } finally {
      child.finalize();
    }
  }

  @override
  void move(DomRenderObject parent, web.Node targetNode, web.Node? afterNode) {
    if (!isAttached) return;

    final nodes = <web.Node>[];
    _collectNodes(this, nodes);
    if (nodes.isEmpty) return;

    web.Node? beforeNode = afterNode == null
        ? targetNode.childNodes.item(0)
        : afterNode.nextSibling;

    for (var i = nodes.length - 1; i >= 0; i--) {
      final nodeToMove = nodes[i];
      if (!identical(nodeToMove, beforeNode)) {
        targetNode.insertBefore(nodeToMove, beforeNode);
      }
      beforeNode = nodeToMove;
    }
  }

  @override
  void removeChildren(DomRenderObject parent) {
    if (!isAttached) return;

    final nodes = <web.Node>[];
    _collectNodes(this, nodes);

    final targetNode = attachTargetNode;
    web.Node? beforeNode;

    for (var i = nodes.length - 1; i >= 0; i--) {
      final currentNode = nodes[i];
      if (currentNode.parentNode == targetNode) {
        node.insertBefore(currentNode, beforeNode);
      }
      beforeNode = currentNode;
    }

    isAttached = false;
  }

  @override
  void remove(DomRenderObject child) {
    _unlinkChild(child);

    if (child case DomRenderFragment(isAttached: true)) {
      if (child is _NakiDomRenderFragment) {
        child.removeChildren(this);
      } else {
        final target = _attachTargetObject;
        if (target != null && target is! DomRenderFragment) {
          child.parent = target;
          child.removeChildren(target);
        } else {
          child.removeChildren(this);
        }
      }
    } else {
      final targetNode = attachTargetNode;
      final childNode = child.node;
      if (childNode.parentNode == targetNode) {
        targetNode.removeChild(childNode);
      }
    }

    child.previousSibling = null;
    child.nextSibling = null;
    child.parent = null;
  }

  @override
  void finalize() {
    isAttached = true;
  }
}
