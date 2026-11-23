part of 'index.dart';

/// {@template SingleChildScrollView}
/// A component that renders a scroll view component in which a
/// single scrollable child component can be scrolled.
///
/// Supports customizable scroll physics (such as [BouncingScrollPhysics],
/// [ClampingScrollPhysics], or [NeverScrollableScrollPhysics])
/// and scrollbar styling via [ScrollBarConfiguration].
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
  /// This is the component that will be scrolled.
  /// If [Row] or [Column] is used as a child component, ensure
  /// `scrollable: false` to prevent unexpected behavior.
  final Component child;

  /// The axis along which the scroll view scrolls
  /// (default: [ScrollDirection.vertical]).
  final ScrollDirection direction;

  /// Whether the scroll view scrolls in the reading direction.
  final bool reverse;

  /// Insets around [child].
  final EdgeInsets? padding;

  /// Scroll controller to manage or observe scroll activity.
  final ScrollController? controller;

  /// Scroll physics to control scroll behavior
  /// (e.g. [BouncingScrollPhysics], [ClampingScrollPhysics],
  /// [NeverScrollableScrollPhysics]).
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

  static List<StyleRule> get styles => ScrollingStyles.singleChildScrollView;
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
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
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
  void didUpdateComponent(SingleChildScrollView oldComponent) {
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
      'min-height': '0',
      'min-width': '0',
      ...Css.scrollPadding(component.padding, vertical: !isHoriz),
      ...?component.physics?.props(component.direction),
    };

    const baseClass = 'naki-singlechild-scrollview';
    final effectiveClasses = joinClasses([
      ?component.classes,
      if (!isHoriz) ...[kInsetOwnerClass, kFillScrollClass],
      baseClass,
    ]);

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
