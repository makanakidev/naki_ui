import 'dart:async';
import 'dart:math' as math;
import 'package:jaspr/dom.dart' hide AspectRatio;
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' hide Document;

import '../framework/framework.dart';
import '../models/naki.dart' show ScrollBarConfiguration;
import '../models/scrolling.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../theme/tokens.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

import 'basics.dart' show Column, Row;
import 'layout.dart' show AspectRatio;
import 'styling.dart' show Heading, SubHeading;

const _defaultLoadMoreItemCount = 20;
const _defaultLoadMoreDelay = 100;
const _defaultLoadMoreThreshold = 200.0;

// /////////////////////////////////////////////////////////////////////////////
// SCROLLING COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template ScrollBarWrapper}
/// A component that adds scrollbar styling to its child.
///
/// This is used by components like [SingleChildScrollView], [ListView],
/// [GridView], [PageView], [CarouselView], [Table], [StaggeredView], and other
/// scrollable components to add scrollbar styling to their children.
///
/// ### Example
/// ```dart
/// ScrollBarWrapper(
///   selector: '.my-list',
///   configuration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 8,
///     radius: 4,
///   ),
///   child: ListView(
///     physics: const BouncingScrollPhysics(),
///     children: [
///       NakiText('Item 1'),
///       NakiText('Item 2'),
///     ],
///   ),
/// )
/// ```
/// {@endtemplate}
class ScrollBarWrapper extends StatelessComponent {
  /// The selector for the scrollbar. This can be an id, class,
  /// or any valid CSS selector.
  final String selector;

  /// The scrollbar configuration.
  /// If `null`, no scrollbar will be added.
  final ScrollBarConfiguration? configuration;

  /// The child component.
  final Component child;

  /// {@macro ScrollBarWrapper}
  const ScrollBarWrapper({
    super.key,
    required this.selector,
    this.configuration,
    required this.child,
  });

  @override
  Component build(BuildContext context) {
    return configuration == null
        ? child
        : .fragment([
            Document.head(
              children: [
                StyleRules(
                  Rules.buildScrollbarRules(selector, configuration!),
                  id: selector.withoutSymbols,
                ),
              ],
            ),
            child,
          ]);
  }
}

/// {@template SingleChildScrollView}
/// A component that renders a scroll view component in which a
/// single scrollable child component can be scrolled.
///
/// Supports customizable scroll physics (such as [BouncingScrollPhysics],
/// [ClampingScrollPhysics], or [NeverScrollableScrollPhysics]) and
/// scrollbar styling via [ScrollBarConfiguration].
///
/// ### Example
/// ```dart
/// SingleChildScrollView(
///   direction: ScrollDirection.vertical,
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   child: Column(children: [...], scrollable: false),
/// )
/// ```
/// See also:
///   - [ListView] for creating a list view
///   - [GridView] for creating a grid
///   - [PageView] for creating a page view
///   - [CarouselView] for creating a carousel
///   - [Table] for creating a table
///   - [StaggeredView] for creating a staggered view
/// {@endtemplate}
class SingleChildScrollView extends StatefulComponent {
  /// This is the component that will be scrolled. If [Row] or [Column] is used as a
  /// child component, ensure `scrollable: false` to prevent unexpected behavior.
  final Component child;

  /// The axis along which the scroll view scrolls (default: [ScrollDirection.vertical]).
  final ScrollDirection direction;

  /// Whether the scroll view scrolls in the reading direction.
  final bool reverse;

  /// Insets around [child].
  final EdgeInsets? padding;

  /// Scroll controller to manage or observe scroll activity.
  final ScrollController? controller;

  /// Scroll physics to control scroll behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the single child scroll view.
  final String? classes;

  /// {@macro SingleChildScrollView}
  const SingleChildScrollView({
    super.key,
    required this.child,
    this.direction = ScrollDirection.vertical,
    this.reverse = false,
    this.padding,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.classes,
  });

  @override
  State<SingleChildScrollView> createState() => _SingleChildScrollViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'SingleChildScrollView',
    [Rules.nakiSingleChildScrollViewRules],
  );
}

class _SingleChildScrollViewState extends State<SingleChildScrollView>
    with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'scrollview');

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(
    SingleChildScrollView oldComponent,
  ) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    assert(
      (component.child is! Row && component.child is! Column) ||
          (component.child is Row && !(component.child as Row).scrollable) ||
          (component.child is Column &&
              !(component.child as Column).scrollable),
      'SingleChildScrollView child cannot be scrollable',
    );

    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      'width': '100%',
      'height': '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-singlechild-scrollview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-scrollview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [component.child],
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template ListView}
/// A component that displays a scrollable, linear list of components.
///
/// Supports customizable scroll physics (e.g. [BouncingScrollPhysics],
/// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]) and scrollbar
/// styling via [ScrollBarConfiguration].
///
/// ### Example
/// ```dart
/// ListView(
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     NakiText('Item 1'),
///     NakiText('Item 2'),
///   ],
/// )
/// ```
///
/// See also:
/// - [ListView.builder] for lazy loading of list items.
/// - [ListView.separated] for list view with separators.
/// - [GridView] for grid layout.
/// - [SingleChildScrollView] for basic scrollable component.
/// {@endtemplate}
class ListView extends StatefulComponent {
  /// Scroll direction (horizontal or vertical).
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Components to display in the list view.
  final List<Component> children;

  /// Scroll controller to observe or control scroll activity.
  final ScrollController? controller;

  /// Scroll physics to control scroll behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// By default, the list view will try to fill the entire available
  /// space and might not scroll if the content is smaller than the viewport.
  ///
  /// When [shrinkWrap] is `true`, the list view will only take the space
  /// required to display its content.
  ///
  /// This can be useful for performance optimization in some cases.
  final bool shrinkWrap;

  /// Insets around [children].
  final EdgeInsets? padding;

  /// The fixed width or height of each component in [children].
  ///
  /// If [direction] is `vertical`, [itemExtent] is the fixed height of
  /// each component. If [direction] is `horizontal`, [itemExtent] is
  /// the fixed width of each component.
  ///
  /// When provided, the list view will calculate the scroll position more
  /// efficiently and, in some cases, improve rendering performance.
  final Dim? itemExtent;

  /// Additional CSS classes applied to the list view component.
  final String? classes;

  /// {@macro ListView}
  const ListView({
    super.key,
    required this.children,
    this.direction = ScrollDirection.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.padding,
    this.itemExtent,
    this.classes,
  });

  /// Creates a list view whose items are generated on demand.
  ///
  /// Supports scroll physics (e.g. [BouncingScrollPhysics]) and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// ListView.builder(
  ///   itemCount: 100,
  ///   physics: const ClampingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#6750a4'),
  ///     trackColor: Color('#e7e0ec'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   itemBuilder: (context, index) => NakiText('Item $index'),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the list.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether items are rendered in reverse order.
  /// * [shrinkWrap]: Whether the list sizes itself to its contents.
  /// * [itemExtent]: Optional fixed extent (height/width) for all items.
  /// * [padding]: Insets around the scroll view content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the list view
  ///   component.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of components appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory ListView.builder({
    Key? key,
    required int itemCount,
    required Component Function(
      BuildContext context,
      int index,
    )
    itemBuilder,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    Dim? itemExtent,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _ListViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
      scrollBarConfiguration: scrollBarConfig,
    );
  }

  /// Creates a list view whose items are separated by custom components.
  ///
  /// Supports scroll physics (e.g. [BouncingScrollPhysics]) and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// ListView.separated(
  ///   itemCount: 50,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   separatorBuilder: (context, index) => const Divider(),
  ///   itemBuilder: (context, index) => NakiText('Item $index'),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the list.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [separatorBuilder]: Builder function returning the separator after
  ///   each component except the last.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether items are rendered in reverse order.
  /// * [shrinkWrap]: Whether the list sizes itself to its contents.
  /// * [padding]: Insets around the scroll view content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the list view
  ///   component.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of components appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory ListView.separated({
    Key? key,
    required int itemCount,
    required Component Function(
      BuildContext context,
      int index,
    )
    itemBuilder,
    required Component Function(
      BuildContext context,
      int index,
    )
    separatorBuilder,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _ListViewSeparated(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      padding: padding,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
      scrollBarConfiguration: scrollBarConfig,
    );
  }

  @override
  State<ListView> createState() => _ListViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('ListView', [
    Rules.nakiListViewRules,
  ]);
}

class _ListViewState extends State<ListView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'listview');

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(ListView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';
    final extent = component.itemExtent;

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
      '--naki-listview-item-extent-h': ?(!isHoriz && extent != null
          ? extent.cssText
          : null),
      '--naki-listview-item-extent-w': ?(isHoriz && extent != null
          ? extent.cssText
          : null),
    };

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-listview',
      key: _key,
      id: _id,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: component.children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _ListViewBuilder extends ListView {
  /// Number of items to render.
  final int itemCount;

  /// Function that builds an item for the given index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Initial number of items built during SSR and hydration. When null, all
  /// items are built eagerly for backward compatibility.
  final int? initialItemCount;

  /// Number of additional items appended near the scroll boundary.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the scroll container
  /// that triggers loading the next batch of [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user scrolls to
  /// within `200` pixels of the scroll container's edge, additional items will
  /// be built and rendered automatically.
  final double loadMoreThreshold;

  const _ListViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    this.initialItemCount,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.itemExtent,
    super.classes,
    super.scrollBarConfiguration,
    super.children = const [],
  }) : assert(
         itemCount > 0,
         'itemCount must be greater than 0',
       ),
       assert(
         initialItemCount == null || initialItemCount > 0,
         'initialItemCount must be greater than 0',
       ),
       assert(
         loadMoreItemCount > 0,
         'loadMoreItemCount must be greater than 0',
       ),
       assert(
         loadMoreThreshold > 0,
         'loadMoreThreshold must be greater than 0',
       );

  @override
  State<ListView> createState() => _ListViewBuilderState();
}

class _ListViewBuilderState extends State<_ListViewBuilder>
    with NakiStatefulMixin {
  late String _id;
  late int _renderedItemCount;

  bool _isLazy = false;
  bool _isLoadingMore = false;

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'listview-builder');
    _isLazy = component.initialItemCount != null;
    _renderedItemCount = _initialRenderedCount();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = component.controller;
    controller?.attach(element);

    final subscription = _isLazy
        ? EventStreamProviders.scrollEvent
              .forTarget(element)
              .listen((_) => _loadMoreIfNeeded(element))
        : null;

    if (_isLazy) onComponentRendered(() => _loadMoreIfNeeded(element));

    return () {
      subscription?.cancel();
      controller?.detach();
    };
  }

  @override
  void didUpdateComponent(_ListViewBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction ||
        oldComponent.initialItemCount != component.initialItemCount) {
      refreshAfterRender();
    }

    if (oldComponent.itemCount != component.itemCount ||
        oldComponent.initialItemCount != component.initialItemCount) {
      _renderedItemCount = math.min(
        component.itemCount,
        oldComponent.initialItemCount == component.initialItemCount
            ? _renderedItemCount
            : _initialRenderedCount(),
      );
    }

    _isLazy = component.initialItemCount != null;
  }

  /// Returns the initial number of items to render
  int _initialRenderedCount() => component.initialItemCount == null
      ? component.itemCount
      : math.min(
          component.itemCount,
          component.initialItemCount!,
        );

  /// Loads more items if needed
  void _loadMoreIfNeeded(HTMLElement element) {
    if (!mounted ||
        !_isLazy ||
        _isLoadingMore ||
        _renderedItemCount >= component.itemCount) {
      return;
    }

    final isVert = component.direction == ScrollDirection.vertical;
    final double remaining;

    if (component.reverse) {
      remaining = (isVert ? element.scrollTop : element.scrollLeft).toDouble();
    } else {
      remaining =
          (isVert
                  ? element.scrollHeight -
                        element.scrollTop -
                        element.clientHeight
                  : element.scrollWidth -
                        element.scrollLeft -
                        element.clientWidth)
              .toDouble();
    }

    if (remaining > component.loadMoreThreshold) return;

    _isLoadingMore = true;

    final oldScrollExtent = isVert ? element.scrollHeight : element.scrollWidth;
    final oldScrollOffset = isVert ? element.scrollTop : element.scrollLeft;

    Future.delayed(
      const Duration(milliseconds: _defaultLoadMoreDelay),
      () {
        if (!mounted) return;

        setState(() {
          _renderedItemCount = math.min(
            component.itemCount,
            _renderedItemCount + component.loadMoreItemCount,
          );

          _isLoadingMore = false;
        });

        onComponentRendered(() {
          if (component.reverse && mounted) {
            final newScrollExtent = isVert
                ? element.scrollHeight
                : element.scrollWidth;

            final delta = newScrollExtent - oldScrollExtent;

            if (delta > 0) {
              if (isVert) {
                element.scrollTop = oldScrollOffset + delta;
              } else {
                element.scrollLeft = oldScrollOffset + delta;
              }
            }
          }
          _loadMoreIfNeeded(element);
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    final List<Component> items = [];
    for (int i = 0; i < _renderedItemCount; i++) {
      items.add(component.itemBuilder(context, i));
    }

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-listview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _ListViewSeparated extends ListView {
  /// Number of items to render.
  final int itemCount;

  /// Function that builds an item for the given index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Function that builds a separator for the given index. This could
  /// be used to add spaces, dividers, or any component between items
  /// at certain intervals or indices.
  ///
  /// The separator is not built for the last item.
  final Component Function(BuildContext context, int index) separatorBuilder;

  /// Initial number of items to render.
  final int? initialItemCount;

  /// Number of additional items appended near the scroll boundary.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the scroll container
  /// that triggers loading the next batch of [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user scrolls to
  /// within `200` pixels of the scroll container's edge, additional items will
  /// be built and rendered automatically.
  final double loadMoreThreshold;

  const _ListViewSeparated({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    this.initialItemCount,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.shrinkWrap,
    super.padding,
    super.scrollBarConfiguration,
    super.classes,
    super.children = const [],
  }) : assert(
         itemCount > 0,
         'itemCount must be greater than 0',
       ),
       assert(
         initialItemCount == null || initialItemCount > 0,
         'initialItemCount must be greater than 0',
       ),
       assert(
         loadMoreItemCount > 0,
         'loadMoreItemCount must be greater than 0',
       ),
       assert(
         loadMoreThreshold > 0,
         'loadMoreThreshold must be greater than 0',
       );

  @override
  State<ListView> createState() => _ListViewSeparatedState();
}

class _ListViewSeparatedState extends State<_ListViewSeparated>
    with NakiStatefulMixin {
  late String _id;
  late int _renderedItemCount;

  bool _isLazy = false;
  bool _isLoadingMore = false;

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'listview-separated');
    _isLazy = component.initialItemCount != null;
    _renderedItemCount = _initialRenderedCount();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = component.controller;
    controller?.attach(element);

    final subscription = _isLazy
        ? EventStreamProviders.scrollEvent
              .forTarget(element)
              .listen((_) => _loadMoreIfNeeded(element))
        : null;

    if (_isLazy) onComponentRendered(() => _loadMoreIfNeeded(element));

    return () {
      subscription?.cancel();
      controller?.detach();
    };
  }

  @override
  void didUpdateComponent(_ListViewSeparated oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction ||
        oldComponent.initialItemCount != component.initialItemCount) {
      refreshAfterRender();
    }

    if (oldComponent.itemCount != component.itemCount ||
        oldComponent.initialItemCount != component.initialItemCount) {
      _renderedItemCount = math.min(
        component.itemCount,
        oldComponent.initialItemCount == component.initialItemCount
            ? _renderedItemCount
            : _initialRenderedCount(),
      );
    }

    _isLazy = component.initialItemCount != null;
  }

  /// Returns the initial number of items to render
  int _initialRenderedCount() => component.initialItemCount == null
      ? component.itemCount
      : math.min(
          component.itemCount,
          component.initialItemCount!,
        );

  /// Loads more items if needed
  void _loadMoreIfNeeded(HTMLElement element) {
    if (!mounted ||
        !_isLazy ||
        _isLoadingMore ||
        _renderedItemCount >= component.itemCount) {
      return;
    }

    final isVert = component.direction == ScrollDirection.vertical;
    final double remaining;

    if (component.reverse) {
      remaining = (isVert ? element.scrollTop : element.scrollLeft).toDouble();
    } else {
      remaining =
          (isVert
                  ? element.scrollHeight -
                        element.scrollTop -
                        element.clientHeight
                  : element.scrollWidth -
                        element.scrollLeft -
                        element.clientWidth)
              .toDouble();
    }

    if (remaining > component.loadMoreThreshold) return;

    _isLoadingMore = true;

    final oldScrollExtent = isVert ? element.scrollHeight : element.scrollWidth;
    final oldScrollOffset = isVert ? element.scrollTop : element.scrollLeft;

    Future.delayed(
      const Duration(milliseconds: _defaultLoadMoreDelay),
      () {
        if (!mounted) return;

        setState(() {
          _renderedItemCount = math.min(
            component.itemCount,
            _renderedItemCount + component.loadMoreItemCount,
          );

          _isLoadingMore = false;
        });

        onComponentRendered(() {
          if (component.reverse && mounted) {
            final newScrollExtent = isVert
                ? element.scrollHeight
                : element.scrollWidth;

            final delta = newScrollExtent - oldScrollExtent;

            if (delta > 0) {
              if (isVert) {
                element.scrollTop = oldScrollOffset + delta;
              } else {
                element.scrollLeft = oldScrollOffset + delta;
              }
            }
          }

          _loadMoreIfNeeded(element);
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';
    final List<Component> items = [];

    final effectiveStyles = {
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-listview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    for (int i = 0; i < _renderedItemCount; i++) {
      items.add(component.itemBuilder(context, i));
      if (i < component.itemCount - 1) {
        items.add(component.separatorBuilder(context, i));
      }
    }

    final Component child = .element(
      tag: 'naki-listview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template GridView}
/// A component that displays a scrollable, 2D array of components
/// in a grid layout.
///
/// Supports customizable scroll physics (e.g. [BouncingScrollPhysics],
/// [ClampingScrollPhysics]) and custom scrollbar styling via [ScrollBarConfiguration].
///
/// ### Example
/// ```dart
/// GridView(
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     Container(child: NakiText('Card 1')),
///     Container(child: NakiText('Card 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [GridView.count] for grid with fixed number of columns.
/// - [GridView.extent] for grid with fixed max column size.
/// - [GridView.builder] for grid with lazy loading.
/// {@endtemplate}
class GridView extends StatefulComponent {
  /// Components to display in the grid.
  final List<Component> children;

  /// Grid delegate for determining column/row sizing.
  final SliverGridDelegate? gridDelegate;

  /// Scroll direction.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Scroll controller to observe and control scrolling.
  final ScrollController? controller;

  /// Scroll physics for determining how the grid scrolls (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// When `true`, the grid will only take up as much space
  /// as its contents require. Otherwise, it will take
  /// up all available space in its parent.
  final bool shrinkWrap;

  /// Insets around [children].
  final EdgeInsets? padding;

  /// Additional CSS classes applied to the grid component.
  final String? classes;

  /// Whether to automatically expand the last component across unfilled columns
  /// (noticable when the number of [children] is not a multiple of the
  /// cross axis count defined in [gridDelegate]).
  ///
  /// For example:
  /// - 2 columns and 1 component: the component will expand across the
  ///   unfilled column to fill the row.
  /// - 3 columns and 2 components: the last component will expand across the
  ///   unfilled column to fill the row.
  /// - 3 columns and 3 components: the last component will not expand.
  final bool expandLastItem;

  /// {@macro GridView}
  const GridView({
    super.key,
    required this.children,
    this.gridDelegate,
    this.direction = ScrollDirection.vertical,
    this.reverse = false,
    this.shrinkWrap = false,
    this.expandLastItem = false,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.padding,
    this.classes,
  });

  /// Creates a grid layout with a fixed column count.
  ///
  /// Supports scroll physics via [physics] and scrollbar configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.count(
  ///   2,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [
  ///     Container(child: NakiText('Card 1')),
  ///     Container(child: NakiText('Card 2')),
  ///   ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [crossAxisCount]: Fixed number of columns in the cross ScrollDirection.
  /// * [mainAxisSpacing]: Spacing between components along the scroll ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between components along the cross ScrollDirection.
  /// * [childAspectRatio]: Aspect ratio of each of the grid's [children].
  /// * [mainAxisExtent]: Optional fixed main-axis height/width, based on
  ///   [direction], overriding [childAspectRatio].
  /// * [children]: List of components in the grid.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid component.
  factory GridView.count(
    int crossAxisCount, {
    Key? key,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    AspectRatioType childAspectRatio = AspectRatioType.ratio1_1,
    Dim? mainAxisExtent,
    List<Component> children = const [],
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
  }) {
    return GridView(
      key: key,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      scrollBarConfiguration: scrollBarConfig,
      padding: padding,
      classes: classes,
      children: children,
    );
  }

  /// Creates a grid layout with maximum width extent.
  ///
  /// Supports scroll physics via [physics] and scrollbar configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.extent(
  ///   Dim.px(200),
  ///   physics: const ClampingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [ ... ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [maxCrossAxisExtent]: Maximum height/width of each component in the
  ///   cross axis relative to [direction].
  /// * [mainAxisSpacing]: Spacing between components along the scroll ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between components along the cross ScrollDirection.
  /// * [childAspectRatio]: Aspect ratio of each of the grid's [children].
  /// * [mainAxisExtent]: Optional fixed main-axis height/width, based on
  ///   [direction], overriding [childAspectRatio].
  /// * [children]: List of components in the grid.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid component.
  factory GridView.extent(
    Dim maxCrossAxisExtent, {
    Key? key,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    AspectRatioType childAspectRatio = AspectRatioType.ratio1_1,
    Dim? mainAxisExtent,
    List<Component> children = const [],
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
  }) {
    return GridView(
      key: key,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      scrollBarConfiguration: scrollBarConfig,
      padding: padding,
      classes: classes,
      children: children,
    );
  }

  /// Creates a grid layout dynamically built with a builder.
  ///
  /// Supports scroll physics via [physics] and scrollbar configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// GridView.builder(
  ///   itemCount: 40,
  ///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   itemBuilder: (context, index) => Container(child: NakiText('Item $index')),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of components in the grid.
  /// * [itemBuilder]: Builder function returning the component for a
  ///   given index.
  /// * [gridDelegate]: Delegate controlling grid layout and geometry.
  /// * [direction]: Main scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [shrinkWrap]: Whether the grid sizes itself to its contents.
  /// * [expandLastItem]: Whether to expand the last component across
  ///   unfilled columns.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing bounce and deceleration.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [padding]: Insets around the grid content.
  /// * [classes]: Additional CSS class names applied to the grid component.
  /// * [initialItemCount]: Initial batch size rendered for lazy loading.
  /// * [loadMoreItemCount]: Number of items appended per lazy batch.
  /// * [loadMoreThreshold]: Scroll distance in pixels from the edge
  ///   triggering the next batch.
  factory GridView.builder({
    Key? key,
    required int itemCount,
    required Component Function(
      BuildContext context,
      int index,
    )
    itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollDirection direction = ScrollDirection.vertical,
    bool reverse = false,
    bool shrinkWrap = false,
    bool expandLastItem = false,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    EdgeInsets? padding,
    String? classes,
    int? initialItemCount,
    int loadMoreItemCount = _defaultLoadMoreItemCount,
    double loadMoreThreshold = _defaultLoadMoreThreshold,
  }) {
    return _GridViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      shrinkWrap: shrinkWrap,
      expandLastItem: expandLastItem,
      padding: padding,
      classes: classes,
      initialItemCount: initialItemCount,
      loadMoreItemCount: loadMoreItemCount,
      loadMoreThreshold: loadMoreThreshold,
    );
  }

  @override
  State<GridView> createState() => _GridViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('GridView', [
    Rules.nakiGridViewRules,
  ]);
}

class _GridViewState extends State<GridView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'gridview');

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(GridView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';

    String? crossAxisTemplate;
    String? gapStyle;
    Dim? mainAxisExtent;
    int? crossAxisCount;

    AspectRatioType childAspect = AspectRatioType.ratio1_1;
    final delegate = component.gridDelegate;

    if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
      crossAxisCount = delegate.crossAxisCount;
      crossAxisTemplate = 'repeat($crossAxisCount, 1fr)';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
    } else if (delegate is SliverGridDelegateWithMaxCrossAxisExtent) {
      crossAxisTemplate =
          'repeat(auto-fill, minmax(${delegate.maxCrossAxisExtent.cssText}, 1fr))';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
    }

    final effectiveStyles = <String, String>{
      Tokens.current.gridGap.name: ?gapStyle,
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      if (isHoriz) ...{
        'grid-auto-flow': 'column',
        'grid-template-rows': ?crossAxisTemplate,
      } else
        'grid-template-columns': ?crossAxisTemplate,
      if (mainAxisExtent != null)
        (isHoriz ? 'grid-auto-columns' : 'grid-auto-rows'):
            mainAxisExtent.cssText,
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    bool isRowPartiallyFilled = false;
    List<Component> children = [];
    final totalCount = component.children.length;

    if (crossAxisCount != null && crossAxisCount > 0) {
      isRowPartiallyFilled = (totalCount % crossAxisCount) != 0;
    }

    for (int i = 0; i < totalCount; i++) {
      final c = component.children[i];
      final isLast = i == totalCount - 1;

      final tile = c is GridTile ? c : null;
      final child = tile != null ? tile.child : c;
      final colSpan = tile?.columnSpan;
      final rowSpan = tile?.rowSpan;

      final spanLast =
          isLast && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = spanLast || (tile?.fullWidth ?? false);

      final hasGridSpan = isFullWidth || colSpan != null || rowSpan != null;

      final tileStyles = hasGridSpan
          ? {
              if (isFullWidth)
                'grid-column': '1 / -1'
              else if (colSpan != null)
                'grid-column': 'span $colSpan',
              if (rowSpan != null) 'grid-row': 'span $rowSpan',
            }
          : null;

      final effectiveChild = mainAxisExtent == null
          ? AspectRatio(
              child: child,
              aspectRatio: childAspect,
            )
          : child;

      children.add(
        .wrapElement(
          styles: Styles(raw: tileStyles),
          child: effectiveChild,
        ),
      );
    }

    if (component.reverse) children = children.reversed.toList();

    const baseClass = 'naki-gridview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-gridview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _GridViewBuilder extends GridView {
  /// The total number of items in the grid.
  final int itemCount;

  /// Builder function to create components for each index.
  final Component Function(BuildContext context, int index) itemBuilder;

  /// Initial number of items to render.
  final int? initialItemCount;

  /// Number of items to load at a time when loading more.
  final int loadMoreItemCount;

  /// Scroll distance or offset (in pixels) from the end of the grid container
  /// that triggers loading the next batch of [loadMoreItemCount] items.
  ///
  /// For example, a threshold of `200` means that when the user scrolls to
  /// within `200` pixels of the grid container's edge, additional items will
  /// be built and rendered automatically.
  final double loadMoreThreshold;

  const _GridViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.initialItemCount,
    required this.loadMoreItemCount,
    required this.loadMoreThreshold,
    required super.gridDelegate,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.scrollBarConfiguration,
    super.shrinkWrap,
    super.expandLastItem,
    super.padding,
    super.classes,
    super.children = const [],
  }) : assert(
         itemCount > 0,
         'itemCount must be greater than 0',
       ),
       assert(
         initialItemCount == null || initialItemCount > 0,
         'initialItemCount must be greater than 0',
       ),
       assert(
         loadMoreItemCount > 0,
         'loadMoreItemCount must be greater than 0',
       ),
       assert(
         loadMoreThreshold > 0,
         'loadMoreThreshold must be greater than 0',
       );

  @override
  State<GridView> createState() => _GridViewBuilderState();
}

class _GridViewBuilderState extends State<_GridViewBuilder>
    with NakiStatefulMixin {
  late String _id;
  late int _renderedItemCount;

  bool _isLazy = false;
  bool _isLoadingMore = false;

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _isLazy = component.initialItemCount != null;
    _id = nakiDomId(context, 'gridview_builder');
    _renderedItemCount = _initialRenderedCount();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = component.controller;
    controller?.attach(element);

    final subscription = _isLazy
        ? EventStreamProviders.scrollEvent
              .forTarget(element)
              .listen((_) => _loadMoreIfNeeded(element))
        : null;

    if (_isLazy) onComponentRendered(() => _loadMoreIfNeeded(element));

    return () {
      subscription?.cancel();
      controller?.detach();
    };
  }

  @override
  void didUpdateComponent(_GridViewBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction ||
        oldComponent.initialItemCount != component.initialItemCount) {
      refreshAfterRender();
    }

    if (oldComponent.itemCount != component.itemCount ||
        oldComponent.initialItemCount != component.initialItemCount) {
      _renderedItemCount = math.min(
        component.itemCount,
        oldComponent.initialItemCount == component.initialItemCount
            ? _renderedItemCount
            : _initialRenderedCount(),
      );
    }

    _isLazy = component.initialItemCount != null;
  }

  /// Returns the initial number of items to render
  int _initialRenderedCount() => component.initialItemCount == null
      ? component.itemCount
      : math.min(
          component.itemCount,
          component.initialItemCount!,
        );

  /// Loads more items if needed
  void _loadMoreIfNeeded(HTMLElement element) {
    if (!mounted ||
        !_isLazy ||
        _isLoadingMore ||
        _renderedItemCount >= component.itemCount) {
      return;
    }

    final isVert = component.direction == ScrollDirection.vertical;
    final double remaining;

    if (component.reverse) {
      remaining = (isVert ? element.scrollTop : element.scrollLeft).toDouble();
    } else {
      remaining =
          (isVert
                  ? element.scrollHeight -
                        element.scrollTop -
                        element.clientHeight
                  : element.scrollWidth -
                        element.scrollLeft -
                        element.clientWidth)
              .toDouble();
    }

    if (remaining > component.loadMoreThreshold) return;

    _isLoadingMore = true;

    final oldScrollExtent = isVert ? element.scrollHeight : element.scrollWidth;
    final oldScrollOffset = isVert ? element.scrollTop : element.scrollLeft;

    Future.delayed(
      const Duration(milliseconds: _defaultLoadMoreDelay),
      () {
        if (!mounted) return;

        setState(() {
          _renderedItemCount = math.min(
            component.itemCount,
            _renderedItemCount + component.loadMoreItemCount,
          );

          _isLoadingMore = false;
        });

        onComponentRendered(() {
          if (component.reverse && mounted) {
            final newScrollExtent = isVert
                ? element.scrollHeight
                : element.scrollWidth;

            final delta = newScrollExtent - oldScrollExtent;

            if (delta > 0) {
              if (isVert) {
                element.scrollTop = oldScrollOffset + delta;
              } else {
                element.scrollLeft = oldScrollOffset + delta;
              }
            }
          }

          _loadMoreIfNeeded(element);
        });
      },
    );
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;
    final overflowX = isHoriz ? 'auto' : 'hidden';
    final overflowY = !isHoriz ? 'auto' : 'hidden';

    String? crossAxisTemplate;
    String? gapStyle;
    Dim? mainAxisExtent;
    int? crossAxisCount;

    AspectRatioType childAspect = AspectRatioType.ratio1_1;
    final delegate = component.gridDelegate;

    if (delegate is SliverGridDelegateWithFixedCrossAxisCount) {
      crossAxisCount = delegate.crossAxisCount;
      crossAxisTemplate = 'repeat($crossAxisCount, 1fr)';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
    } else if (delegate is SliverGridDelegateWithMaxCrossAxisExtent) {
      crossAxisTemplate =
          'repeat(auto-fill, minmax(${delegate.maxCrossAxisExtent.cssText}, 1fr))';
      gapStyle =
          '${delegate.mainAxisSpacing.cssText} ${delegate.crossAxisSpacing.cssText}';

      childAspect = delegate.childAspectRatio;
      mainAxisExtent = delegate.mainAxisExtent;
    }

    final effectiveStyles = <String, String>{
      Tokens.current.gridGap.name: ?gapStyle,
      'overflow-x': overflowX,
      'overflow-y': overflowY,
      if (isHoriz) ...{
        'grid-auto-flow': 'column',
        'grid-template-rows': ?crossAxisTemplate,
      } else
        'grid-template-columns': ?crossAxisTemplate,
      if (mainAxisExtent != null)
        (isHoriz ? 'grid-auto-columns' : 'grid-auto-rows'):
            mainAxisExtent.cssText,
      if (component.shrinkWrap)
        (isHoriz ? 'width' : 'height'): 'fit-content'
      else
        (isHoriz ? 'width' : 'height'): '100%',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    bool isRowPartiallyFilled = false;
    List<Component> items = [];

    if (crossAxisCount != null && crossAxisCount > 0) {
      isRowPartiallyFilled = (component.itemCount % crossAxisCount) != 0;
    }

    for (int i = 0; i < _renderedItemCount; i++) {
      final c = component.itemBuilder(context, i);
      final isLastOfTotal = i == component.itemCount - 1;

      final tile = c is GridTile ? c : null;
      final child = tile != null ? tile.child : c;
      final colSpan = tile?.columnSpan;
      final rowSpan = tile?.rowSpan;

      final isSpanLast =
          isLastOfTotal && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = isSpanLast || (tile?.fullWidth ?? false);
      final hasGridSpan = isFullWidth || colSpan != null || rowSpan != null;

      final tileStyles = hasGridSpan
          ? {
              if (isFullWidth)
                'grid-column': '1 / -1'
              else if (colSpan != null)
                'grid-column': 'span $colSpan',
              if (rowSpan != null) 'grid-row': 'span $rowSpan',
            }
          : null;

      final effectiveChild = mainAxisExtent == null
          ? AspectRatio(
              child: child,
              aspectRatio: childAspect,
            )
          : child;

      items.add(
        .wrapElement(
          styles: Styles(raw: tileStyles),
          child: effectiveChild,
        ),
      );
    }

    if (component.reverse) items = items.reversed.toList();

    const baseClass = 'naki-gridview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-gridview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template GridTile}
/// A component that specifies column/row spanning properties
/// for an item in a [GridView].
///
/// ### Example
/// ```dart
/// GridTile(
///   columnSpan: 2,
///   child: NakiText('Spans 2 columns'),
/// )
/// ```
/// {@endtemplate}
class GridTile extends StatelessComponent {
  /// The inner component inside the tile.
  final Component child;

  /// Number of columns this tile spans.
  final int? columnSpan;

  /// Number of rows this tile spans.
  final int? rowSpan;

  /// Whether this tile spans the full width of the grid.
  final bool fullWidth;

  /// {@macro GridTile}
  const GridTile({
    super.key,
    required this.child,
    this.fullWidth = false,
    this.columnSpan,
    this.rowSpan,
  });

  @override
  Component build(BuildContext context) => child;
}

/// {@template PageView}
/// A component that displays a scrollable list that works page by page.
///
/// Supports page snapping, page navigation controller, customizable
/// scroll physics via [physics], and custom scrollbar styling via
/// [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// final controller = PageController();
///
/// PageView(
///   controller: controller,
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 4,
///     radius: 2,
///   ),
///   onPageChanged: (page) => print('Page: $page'),
///   children: [
///     Page1(),
///     Page2(),
///   ],
/// )
/// ```
///
/// See also:
/// - [PageView.builder] for dynamic page building.
/// - [GridView] for grid layout.
/// - [ListView] for list layout.
/// - [SingleChildScrollView] for basic scrollable layout.
/// - [Table] for tabular data layout.
/// {@endtemplate}
class PageView extends StatefulComponent {
  /// Components to display.
  final List<Component> children;

  /// Direction of scrolling.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Page controller for page navigation.
  final PageController? controller;

  /// Scroll physics for controlling scroll behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Whether page snapping is enabled (default: `true`).
  ///
  /// When `true`, the page view will snap to the nearest
  /// page after scrolling stops.
  final bool pageSnapping;

  /// Callback executed when the page changes after scrolling.
  final ValueChanged<int>? onPageChanged;

  /// Additional CSS classes applied to the page view component.
  final String? classes;

  /// {@macro PageView}
  const PageView({
    super.key,
    required this.children,
    this.direction = ScrollDirection.horizontal,
    this.reverse = false,
    this.pageSnapping = true,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.onPageChanged,
    this.classes,
  });

  /// Builds a [PageView] dynamically with an item builder.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// PageView.builder(
  ///   itemCount: 10,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     height: 4,
  ///   ),
  ///   itemBuilder: (context, index) => PageCard(index: index),
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [itemCount]: Total number of pages.
  /// * [itemBuilder]: Builder function returning the page component for
  ///   a given index.
  /// * [direction]: Direction in which pages scroll.
  /// * [reverse]: Whether pages are rendered in reverse order.
  /// * [controller]: Controller for page navigation and viewport tracking.
  /// * [physics]: Scroll physics governing swipe behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [pageSnapping]: Whether pages snap to page boundaries.
  /// * [onPageChanged]: Callback invoked when the active page index changes.
  /// * [classes]: Additional CSS class names applied to the page view component.
  factory PageView.builder({
    Key? key,
    required int itemCount,
    required Component Function(
      BuildContext context,
      int index,
    )
    itemBuilder,
    ScrollDirection direction = ScrollDirection.horizontal,
    bool reverse = false,
    bool pageSnapping = true,
    PageController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    ValueChanged<int>? onPageChanged,
    String? classes,
  }) {
    return _PageViewBuilder(
      key: key,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      direction: direction,
      reverse: reverse,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      pageSnapping: pageSnapping,
      onPageChanged: onPageChanged,
      classes: classes,
    );
  }

  @override
  State<PageView> createState() => _PageViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('PageView', [
    Rules.nakiPageViewRules,
  ]);
}

class _PageViewState extends State<PageView> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'pageview');

  int _currentPage = 0;
  PageController? _internalController;

  /// The page controller used by this component
  PageController get _effectiveController =>
      component.controller ??
      (_internalController ??= PageController(
        direction: component.direction,
      ));

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void didUpdateComponent(PageView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      if (oldComponent.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }

      refreshAfterRender();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = _effectiveController;
    controller.attach(element);

    void controllerListener() {
      final index = controller.page.round();
      if (index != _currentPage) {
        _currentPage = index;
        component.onPageChanged?.call(index);
      }
    }

    controller.addListener(controllerListener);

    return () {
      controller.removeListener(controllerListener);
      controller.detach();
    };
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      'scroll-snap-type': component.pageSnapping
          ? '${isHoriz ? 'x' : 'y'} mandatory'
          : 'none',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-pageview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-pageview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: component.children,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

class _PageViewBuilder extends PageView {
  /// Number of items to display.
  final int itemCount;

  /// Item builder function.
  final Component Function(BuildContext context, int index) itemBuilder;

  const _PageViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    super.direction,
    super.reverse,
    super.controller,
    super.physics,
    super.scrollBarConfiguration,
    super.pageSnapping,
    super.onPageChanged,
    super.classes,
    super.children = const [],
  });

  @override
  State<PageView> createState() => _PageViewBuilderState();
}

class _PageViewBuilderState extends State<_PageViewBuilder>
    with NakiStatefulMixin {
  late final String _id = nakiDomId(
    context,
    'pageview-builder',
  );

  int _currentPage = 0;
  PageController? _internalController;

  /// The page controller used by this component
  PageController get _effectiveController =>
      component.controller ??
      (_internalController ??= PageController(
        direction: component.direction,
      ));

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  void didUpdateComponent(_PageViewBuilder oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      if (oldComponent.controller == null) {
        _internalController?.dispose();
        _internalController = null;
      }

      refreshAfterRender();
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element == null) return null;

    final controller = _effectiveController;
    controller.attach(element);

    void controllerListener() {
      final index = controller.page.round();
      if (index != _currentPage) {
        _currentPage = index;
        component.onPageChanged?.call(index);
      }
    }

    controller.addListener(controllerListener);

    return () {
      controller.removeListener(controllerListener);
      controller.detach();
    };
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      'scroll-snap-type': component.pageSnapping
          ? '${isHoriz ? 'x' : 'y'} mandatory'
          : 'none',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    final List<Component> pages = [];
    for (int i = 0; i < component.itemCount; i++) {
      pages.add(component.itemBuilder(context, i));
    }

    const baseClass = 'naki-pageview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-pageview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: pages,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template CarouselView}
/// A component that presents items horizontally or vertically in a
/// scrollable carousel.
///
/// Supports item snapping, customizable scroll physics via [physics],
/// and custom scrollbar styling via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// CarouselView(
///   itemExtent: const Dim.px(280),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 4,
///     radius: 2,
///   ),
///   children: [
///     Container(child: NakiText('Card 1')),
///     Container(child: NakiText('Card 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [CarouselView.weighted] for a carousel with flex weights.
/// - [PageView] for a page-based scrolling layout.
/// - [GridView] for a grid-based scrolling layout.
/// - [ListView] for a list-based scrolling layout.
/// - [SingleChildScrollView] for basic scrollable layout.
/// - [Table] for tabular data layout.
/// {@endtemplate}
class CarouselView extends StatefulComponent {
  /// Components in the carousel.
  final List<Component> children;

  /// The size of each component along the scroll direction
  /// (default: `Dim.px(280)`).
  final Dim itemExtent;

  /// Relative flex weights assigned to components in the carousel.
  ///
  /// When provided, [children] will be sized based on their relative weight.
  ///
  /// ### Example
  /// ```dart
  /// CarouselView(
  ///   flexWeights: [1, 2, 3],
  ///   itemExtent: Dim.px(100),
  ///   ...
  /// )
  /// ```
  ///
  /// When `null`, [children] will be sized based on [itemExtent].
  final List<int>? flexWeights;

  /// Scroll direction.
  final ScrollDirection direction;

  /// Reverse scroll direction.
  final bool reverse;

  /// Enable scroll snap snapping (default: `true`).
  ///
  /// When `true`, [children] will snap to the nearest position.
  final bool itemSnapping;

  /// Scroll controller for observing and controlling scrolling.
  final ScrollController? controller;

  /// Callback invoked when a component in [children] is tapped/clicked.
  final ValueChanged<int>? onTap;

  /// Scroll physics for customizing scrolling behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the carousel component.
  final String? classes;

  /// {@macro CarouselView}
  const CarouselView({
    super.key,
    required this.children,
    this.itemExtent = const Dim.px(280),
    this.direction = ScrollDirection.horizontal,
    this.reverse = false,
    this.itemSnapping = true,
    this.controller,
    this.onTap,
    this.physics,
    this.flexWeights,
    this.scrollBarConfiguration,
    this.classes,
  });

  /// Creates a carousel with flex weights assigned to items.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// configuration via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// CarouselView.weighted(
  ///   flexWeights: const [1, 2, 1],
  ///   itemExtent: const Dim.px(160),
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     height: 4,
  ///   ),
  ///   children: [
  ///     Card(child: NakiText('Small')),
  ///     Card(child: NakiText('Featured')),
  ///     Card(child: NakiText('Small')),
  ///   ],
  /// )
  /// ```
  ///
  /// ### Parameters
  /// * [flexWeights]: Relative flex weights determining item sizing ratios.
  /// * [itemExtent]: Base extent (width/height) of each component in the
  ///   carousel based on [direction].
  /// * [children]: Components to display in the carousel.
  /// * [direction]: Scroll axis direction.
  /// * [reverse]: Whether components are rendered in reverse order.
  /// * [itemSnapping]: Whether components snap into alignment on scroll end.
  /// * [controller]: Controller for programmatic scrolling.
  /// * [physics]: Scroll physics governing inertia and snap behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [onTap]: Callback invoked with the index of the tapped component.
  /// * [classes]: Additional CSS class names applied to the carousel component.
  factory CarouselView.weighted({
    Key? key,
    required List<int> flexWeights,
    required Dim itemExtent,
    required List<Component> children,
    ScrollDirection direction = ScrollDirection.horizontal,
    bool reverse = false,
    bool itemSnapping = true,
    ScrollController? controller,
    ScrollPhysics? physics,
    ValueChanged<int>? onTap,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
  }) {
    return CarouselView(
      key: key,
      children: children,
      itemExtent: itemExtent,
      flexWeights: flexWeights,
      direction: direction,
      reverse: reverse,
      itemSnapping: itemSnapping,
      controller: controller,
      physics: physics,
      onTap: onTap,
      scrollBarConfiguration: scrollBarConfig,
      classes: classes,
    );
  }

  @override
  State<CarouselView> createState() => _CarouselViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('CarouselView', [
    Rules.nakiCarouselRules,
  ]);
}

class _CarouselViewState extends State<CarouselView> with NakiStatefulMixin {
  late final String _id = nakiDomId(
    context,
    'carousel-view',
  );

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(CarouselView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      'scroll-snap-type': component.itemSnapping
          ? '${isHoriz ? 'x' : 'y'} mandatory'
          : 'none',
      'flex-direction': isHoriz
          ? (component.reverse ? 'row-reverse' : 'row')
          : (component.reverse ? 'column-reverse' : 'column'),
      ...?component.physics?.props(component.direction),
    };

    final List<Component> items = [];
    final weights = component.flexWeights ?? [];
    final hasWeights = weights.isNotEmpty;

    for (int i = 0; i < component.children.length; i++) {
      final child = component.children[i];
      final weight = (hasWeights && i < weights.length) ? weights[i] : null;

      final itemExtentCss = weight != null
          ? 'calc(${component.itemExtent.cssText} * $weight)'
          : component.itemExtent.cssText;

      items.add(
        div(
          classes: 'naki-carousel-item',
          styles: Styles(
            raw: {
              isHoriz ? 'width' : 'height': itemExtentCss,
              'flex-grow': ?weight?.toString(),
              'cursor': component.onTap != null ? 'pointer' : 'default',
            },
          ),
          attributes: component.onTap != null
              ? {'role': 'button', 'tabindex': '0'}
              : null,
          events: component.onTap == null
              ? null
              : {
                  'click': (_) => component.onTap!.call(i),
                  'keydown': (event) {
                    final key = (event as KeyboardEvent).key;
                    if (key == 'Enter' || key == ' ') {
                      event.preventDefault();
                      component.onTap!.call(i);
                    }
                  },
                },
          [child],
        ),
      );
    }

    const baseClass = 'naki-carouselview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-carouselview',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template Table}
/// A component that displays rows, columns, borders, and custom
/// cell layouts in a tabular view.
///
/// Supports horizontal scrolling when content exceeds the table container,
/// with custom scrollbar styling via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// Table(
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 6,
///     radius: 3,
///   ),
///   headers: [NakiText('Name'), NakiText('Age')],
///   rows: [
///     TableRow(children: [NakiText('Alice'), NakiText('30')]),
///     TableRow(children: [NakiText('Bob'), NakiText('25')]),
///   ],
/// )
/// ```
/// {@endtemplate}
class Table extends StatelessComponent {
  /// Header cell components.
  /// This could be any component that can have styles applied to it.
  final List<Component> headers;

  /// The default alignment of header cells.
  final TableHeaderCellAlignment? headerAlignment;

  /// List of table rows.
  final List<TableRow> rows;

  /// Border configuration defining both the outer boundaries and interior
  /// cell dividers of the table.
  ///
  /// Controls:
  /// * Outer borders around the table container
  ///   ([TableBorder.top], [TableBorder.right], [TableBorder.bottom],
  ///   [TableBorder.left]).
  /// * Interior dividers between adjacent row and column cells
  ///   ([TableBorder.horizontalInside], [TableBorder.verticalInside]).
  /// * Corner rounding of the table container ([TableBorder.borderRadius]).
  ///
  /// ### Example
  /// ```dart
  /// Table(
  ///   border: TableBorder.all(
  ///     color: Colors.slate.shade300,
  ///     width: Dim.px(1),
  ///     borderRadius: BorderRadiusData.circular(Radius.px(8)),
  ///   ),
  ///   headers: [NakiText('Name'), NakiText('Role')],
  ///   rows: [
  ///     TableRow(children: [NakiText('Jane'), NakiText('Admin')]),
  ///   ],
  /// )
  /// ```
  final TableBorder? border;

  /// Column width behavior specifications per column index (0-indexed).
  ///
  /// Available column width options:
  /// * [FixedColumnWidth]: Sets a fixed size
  ///   (e.g. `FixedColumnWidth(Dim.px(150))`).
  /// * [FlexColumnWidth]: Automatically stretches to fill remaining table space.
  /// * [FractionColumnWidth]: Sizes the column as a fraction of the table
  ///   width (e.g. `FractionColumnWidth(0.3)` for 30%).
  /// * [IntrinsicColumnWidth]: Sizes the column to fit its widest content
  ///   (`max-content`).
  ///
  /// Any column index omitted from this map defaults to `auto`.
  ///
  /// ### Example
  /// ```dart
  /// Table(
  ///   columnWidths: {
  ///     0: FixedColumnWidth(Dim.px(80)),
  ///     1: FlexColumnWidth(),
  ///     2: FractionColumnWidth(0.25),
  ///   },
  ///   headers: [
  ///     NakiText('ID'),
  ///     NakiText('Description'),
  ///     NakiText('Status'),
  ///   ],
  ///   rows: [
  ///     TableRow(
  ///       children: [
  ///         NakiText('#1'),
  ///         NakiText('Setup Jaspr'),
  ///         NakiText('Done'),
  ///       ],
  ///     ),
  ///   ],
  /// )
  /// ```
  final Map<int, TableColumnWidth>? columnWidths;

  /// Scroll bar configuration for the table's scrollable container.
  /// When provided, renders styled scrollbars; when `null`, the scrollbar is hidden.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Background color of header cells.
  final Color? headerBackgroundColor;

  /// Color applied to the horizontal border of header cells.
  final Color headerBorderColor;

  /// Background color of row cells when hovered.
  final Color? rowHoverColor;

  /// Title text displayed when the table has no rows.
  final String emptyStateTitle;

  /// Subtitle or descriptive text displayed below [emptyStateTitle]
  /// when the table has no rows.
  final String emptyStateSubtitle;

  /// Custom component displayed when the table has no rows, overriding
  /// [emptyStateTitle] and [emptyStateSubtitle].
  final Component? emptyStateContent;

  /// Additional CSS classes applied to the table component.
  final String? classes;

  /// {@macro Table}
  const Table({
    super.key,
    this.headers = const [],
    this.rows = const [],
    this.headerBorderColor = Colors.transparent,
    this.emptyStateTitle = 'No data available',
    this.emptyStateSubtitle = '',
    this.border,
    this.columnWidths,
    this.headerAlignment,
    this.headerBackgroundColor,
    this.scrollBarConfiguration,
    this.rowHoverColor,
    this.classes,
    this.emptyStateContent,
  });

  @override
  Component build(BuildContext context) {
    final _id = nakiDomId(context, 'table');

    final List<th> headCells = [];
    final List<tr> bodyRows = [];
    final List<col> colGroup = [];

    Component emptyState =
        emptyStateContent ??
        Column(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Heading(emptyStateTitle, level: 3),
            if (emptyStateSubtitle.isNotEmpty) SubHeading(emptyStateSubtitle),
          ],
        );

    emptyState = .wrapElement(
      classes: 'naki-table__empty',
      child: emptyState,
    );

    emptyState = tr([
      td(colspan: headers.length, id: 'no-data', [
        emptyState,
      ]),
    ]);

    // Column widths
    if (columnWidths != null && columnWidths!.isNotEmpty) {
      final maxColIndex = columnWidths!.keys.fold(
        0,
        (max, k) => k > max ? k : max,
      );

      for (int i = 0; i <= maxColIndex; i++) {
        final width = columnWidths!.containsKey(i)
            ? columnWidths![i]!.cssWidth
            : null;

        colGroup.add(
          col(styles: Styles(raw: {'width': ?width})),
        );
      }
    }

    // Header
    if (headers.isNotEmpty) {
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i];
        final alignment = headerAlignment?.name;
        headCells.add(
          th(
            styles: Styles(raw: {'text-align': ?alignment}),
            [h],
          ),
        );
      }
    }

    // Rows
    if (rows.isNotEmpty) {
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        final List<Component> rowCells = [];

        for (int i = 0; i < row.children.length; i++) {
          final cell = row.children[i];
          final alignment = row.alignment?.name;
          rowCells.add(
            td(
              styles: Styles(
                raw: {
                  'text-align': ?alignment,
                  if (border != null && i < row.children.length - 1)
                    'border-right': border!.verticalInside.value,
                  if (border != null && rowIndex < rows.length - 1)
                    'border-bottom': border!.horizontalInside.value,
                },
              ),
              [cell],
            ),
          );
        }

        bodyRows.add(
          tr(
            id: row.id,
            classes: row.classes,
            attributes: row.onClick == null
                ? null
                : const {'role': 'button', 'tabindex': '0'},
            events: row.onClick == null
                ? null
                : {
                    'click': (_) => row.onClick!.call(),
                    'keydown': (event) {
                      final key = (event as KeyboardEvent).key;
                      if (key == 'Enter' || key == ' ') {
                        event.preventDefault();
                        row.onClick!.call();
                      }
                    },
                  },
            rowCells,
          ),
        );
      }
    }

    const baseClass = 'naki-table';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      Tokens.current.tableHeaderBg.name: ?headerBackgroundColor?.value,
      Tokens.current.tableRowHoverBg.name: ?rowHoverColor?.value,
      Tokens.current.tableHeaderBorderColor.name: headerBorderColor.value,
      ...?border?.props,
    };

    final Component child = .element(
      key: key,
      id: _id,
      tag: 'naki-table',
      styles: Styles(raw: effectiveStyles),
      children: [
        table(classes: effectiveClasses, [
          if (colGroup.isNotEmpty) colgroup(colGroup),
          if (headers.isNotEmpty) thead([tr(headCells)]),
          tbody(rows.isEmpty ? [emptyState] : bodyRows),
        ]),
      ],
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: scrollBarConfiguration,
      child: child,
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Table', [
    Rules.nakiTableRules,
  ]);
}

/// {@template StaggeredView}
/// A component that arranges its children in a staggered
/// grid / masonry layout.
///
/// Supports custom [crossAxisCount], [mainAxisSpacing], [crossAxisSpacing],
/// customizable scroll physics via [physics], and custom scrollbar styling
/// via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// StaggeredView(
///   crossAxisCount: 2,
///   mainAxisSpacing: const Dim.px(16),
///   crossAxisSpacing: const Dim.px(16),
///   physics: const BouncingScrollPhysics(),
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     width: 6,
///     radius: 3,
///   ),
///   children: [
///     Container(child: NakiText('Item 1')),
///     Container(child: NakiText('Item 2')),
///   ],
/// )
/// ```
///
/// See also:
/// - [StaggeredView.count] for staggered grid with a fixed number of columns.
/// - [GridView] for a non-staggered grid layout.
/// - [ListView] for a vertical list layout.
/// - [SingleChildScrollView] for a simple scrollable component.
/// {@endtemplate}
class StaggeredView extends StatefulComponent {
  /// Components in the staggered grid.
  final List<Component> children;

  /// Number of columns in the cross axis (default: 2).
  final int crossAxisCount;

  /// Spacing between components in the main axis (default: Dim.px(16)).
  final Dim mainAxisSpacing;

  /// Spacing between columns in the cross axis (default: Dim.px(16)).
  final Dim crossAxisSpacing;

  /// Main scroll axis direction (default: [ScrollDirection.vertical]).
  final ScrollDirection direction;

  /// Padding around the staggered grid content area.
  final EdgeInsets? padding;

  /// Scroll controller for programmatic scrolling.
  final ScrollController? controller;

  /// Scroll physics for customizing scrolling behavior (e.g. [BouncingScrollPhysics],
  /// [ClampingScrollPhysics], [NeverScrollableScrollPhysics]).
  final ScrollPhysics? physics;

  /// Scroll bar configuration. When provided, renders styled scrollbars.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Additional CSS classes applied to the staggered view component.
  final String? classes;

  /// Whether to automatically span the last item across unfilled columns.
  final bool expandLastItem;

  /// {@macro StaggeredView}
  const StaggeredView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.direction = ScrollDirection.vertical,
    this.expandLastItem = false,
    this.padding,
    this.controller,
    this.physics,
    this.scrollBarConfiguration,
    this.classes,
  }) : assert(
         crossAxisCount > 0,
         'crossAxisCount must be greater than 0',
       );

  /// Creates a staggered grid view with a fixed number of columns.
  ///
  /// Supports customizable scroll physics via [physics] and scrollbar
  /// styling via [scrollBarConfig].
  ///
  /// ### Example
  /// ```dart
  /// StaggeredView.count(
  ///   2,
  ///   physics: const BouncingScrollPhysics(),
  ///   scrollBarConfig: const ScrollBarConfiguration(
  ///     thumbColor: Color('#888888'),
  ///     trackColor: Color('#f0f0f0'),
  ///     width: 6,
  ///     radius: 3,
  ///   ),
  ///   children: [
  ///     Container(child: NakiText('Item 1')),
  ///     Container(child: NakiText('Item 2')),
  ///   ],
  /// )
  /// ### Parameters
  /// * [crossAxisCount]: Fixed number of columns in the cross ScrollDirection.
  /// * [children]: List of child components inside the staggered view.
  /// * [mainAxisSpacing]: Spacing between components along the main ScrollDirection.
  /// * [crossAxisSpacing]: Spacing between columns along the cross ScrollDirection.
  /// * [direction]: Main scroll axis direction.
  /// * [expandLastItem]: Whether to expand the last item across unfilled columns.
  /// * [padding]: Insets around the staggered grid content.
  /// * [controller]: Controller for programmatic scroll operations.
  /// * [physics]: Scroll physics governing scroll behavior.
  /// * [scrollBarConfig]: Scroll bar configuration.
  /// * [classes]: Additional CSS class names applied to the staggered
  ///   view component.
  factory StaggeredView.count(
    int crossAxisCount, {
    Key? key,
    required List<Component> children,
    Dim mainAxisSpacing = const Dim.px(16),
    Dim crossAxisSpacing = const Dim.px(16),
    ScrollDirection direction = ScrollDirection.vertical,
    bool expandLastItem = false,
    EdgeInsets? padding,
    ScrollController? controller,
    ScrollPhysics? physics,
    ScrollBarConfiguration? scrollBarConfig,
    String? classes,
  }) {
    return StaggeredView(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      direction: direction,
      expandLastItem: expandLastItem,
      padding: padding,
      controller: controller,
      physics: physics,
      scrollBarConfiguration: scrollBarConfig,
      classes: classes,
    );
  }

  @override
  State<StaggeredView> createState() => _StaggeredViewState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('StaggeredView', [
    Rules.nakiStaggeredRules,
  ]);
}

class _StaggeredViewState extends State<StaggeredView> with NakiStatefulMixin {
  late final String _id = nakiDomId(
    context,
    'staggered-view',
  );

  /// Returns the component's global key
  GlobalNodeKey<HTMLElement>? get _key =>
      component.key is GlobalNodeKey<HTMLElement>
      ? component.key as GlobalNodeKey<HTMLElement>
      : null;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    final element =
        _key?.currentNode ?? document.getElementById(_id) as HTMLElement?;

    if (element != null && component.controller != null) {
      final controller = component.controller!;
      controller.attach(element);
      return controller.detach;
    }

    return null;
  }

  @override
  void didUpdateComponent(StaggeredView oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.controller != component.controller ||
        oldComponent.direction != component.direction) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final isHoriz = component.direction == ScrollDirection.horizontal;

    final effectiveStyles = {
      if (!isHoriz) ...{
        'display': 'block',
        'column-count': component.crossAxisCount.toString(),
        'column-gap': component.crossAxisSpacing.cssText,
      } else ...{
        'display': 'grid',
        'grid-auto-flow': 'column',
        'grid-template-rows':
            'repeat(${component.crossAxisCount}, max-content)',
        'column-gap': component.mainAxisSpacing.cssText,
        'row-gap': component.crossAxisSpacing.cssText,
        'width': 'max-content',
      },
      'overflow-x': isHoriz ? 'auto' : 'hidden',
      'overflow-y': !isHoriz ? 'auto' : 'hidden',
      ...?component.padding?.pProps,
      ...?component.physics?.props(component.direction),
    };

    final crossAxisCount = component.crossAxisCount;
    final totalChildren = component.children.length;
    final isRowPartiallyFilled = (totalChildren % crossAxisCount) != 0;
    final List<Component> items = [];

    for (int i = 0; i < totalChildren; i++) {
      final c = component.children[i];
      final isLast = i == totalChildren - 1;

      final tile = c is StaggeredTile ? c : null;
      final child = tile != null ? tile.child : c;

      final isSpanLast =
          isLast && component.expandLastItem && isRowPartiallyFilled;
      final isFullWidth = isSpanLast || (tile?.fullWidth ?? false);

      items.add(
        .wrapElement(
          classes: 'naki-staggered-item',
          styles: Styles(
            raw: {
              if (isFullWidth) 'column-span': 'all',
              if (!isHoriz) 'margin-bottom': component.mainAxisSpacing.cssText,
              if (isHoriz) 'margin-right': component.mainAxisSpacing.cssText,
            },
          ),
          child: child,
        ),
      );
    }

    const baseClass = 'naki-staggeredview';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final Component child = .element(
      tag: 'naki-staggered-view',
      id: _id,
      key: component.key,
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: items,
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: component.scrollBarConfiguration,
      child: child,
    );
  }
}

/// {@template StaggeredTile}
/// A component that specifies column spanning properties
/// for an item in a [StaggeredView].
///
/// ### Example
/// ```dart
/// StaggeredTile(
///   fullWidth: true,
///   child: Banner(primary: NakiText('Full width banner')),
/// )
/// ```
/// {@endtemplate}
class StaggeredTile extends StatelessComponent {
  /// The inner component inside the tile.
  final Component child;

  /// Whether this tile spans all columns in the staggered view.
  final bool fullWidth;

  /// {@macro StaggeredTile}
  const StaggeredTile({
    super.key,
    required this.child,
    this.fullWidth = false,
  });

  @override
  Component build(BuildContext context) => child;
}
