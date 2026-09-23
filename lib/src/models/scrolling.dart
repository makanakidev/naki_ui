import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import '../utilities/constants.dart';
import '../utilities/enums.dart';
import '../utilities/helpers.dart' show onComponentRendered;

import 'animation.dart';
import 'styling.dart';

/// Controls a scrollable component, allowing programmatic
/// scrolling and listening to scroll notifications.
class ScrollController {
  /// Direction of scrolling (horizontal or vertical).
  final ScrollDirection direction;

  /// Creates a new [ScrollController].
  ScrollController({
    double initialScrollOffset = 0.0,
    this.direction = ScrollDirection.vertical,
  }) : _offset = initialScrollOffset;

  double _offset = 0.0;
  HTMLElement? _attachedElement;
  StreamSubscription<Event>? _subscription;

  /// Stores all scroll position listener callbacks.
  final List<VoidCallback> _listeners = [];

  /// The current scroll offset in pixels based on [direction].
  double get offset {
    if (_attachedElement != null) {
      _offset = (direction == ScrollDirection.vertical
          ? _attachedElement!.scrollTop
          : _attachedElement!.scrollLeft);
    }
    return _offset;
  }

  /// Alias for current scroll position based on [direction].
  double get position => offset;

  /// Returns true if the controller is attached to an HTML DOM element.
  bool get hasClients => _attachedElement != null;

  /// Minimum scroll extent (usually 0.0).
  double get minScrollExtent => 0.0;

  /// Returns true if the controller is at the
  /// start of the scrollable component.
  bool get isAtStart => offset <= minScrollExtent;

  /// Returns true if the controller has reached
  /// the end of the scrollable component.
  bool get hasReachedEnd => offset >= maxScrollExtent;

  /// Maximum scroll extent based on [direction]
  /// (scrollHeight/clientHeight or scrollWidth/clientWidth).
  double get maxScrollExtent {
    if (_attachedElement == null) return 0.0;

    if (direction == ScrollDirection.vertical) {
      return (_attachedElement!.scrollHeight - _attachedElement!.clientHeight)
          .toDouble();
    } else {
      return (_attachedElement!.scrollWidth - _attachedElement!.clientWidth)
          .toDouble();
    }
  }

  /// Helper method to check whether an element is a scrollable container.
  static bool isElementScrollable(HTMLElement? element) {
    if (element == null || kIsServer) return false;

    final style = window.getComputedStyle(element);
    final overflowY = style.overflowY;
    final overflowX = style.overflowX;
    final overflow = style.overflow;

    return overflow == 'auto' ||
        overflow == 'scroll' ||
        overflowY == 'auto' ||
        overflowY == 'scroll' ||
        overflowX == 'auto' ||
        overflowX == 'scroll' ||
        element.scrollHeight > element.clientHeight ||
        element.scrollWidth > element.clientWidth;
  }

  /// Whether the attached element is a scrollable container.
  bool get isScrollable => isElementScrollable(_attachedElement);

  /// Attaches the controller to a rendered HTML element.
  void attach(HTMLElement element) {
    detach();

    if (!isElementScrollable(element)) {
      throw StateError(
        'Only scrollable components like Row, Column, ListView, GridView, '
        'or the like can be attached to a ScrollController.',
      );
    }

    // store the scrollable element
    _attachedElement = element;

    // update scroll position to initial offset
    if (direction == ScrollDirection.vertical) {
      _attachedElement!.scrollTop = _offset;
    } else {
      _attachedElement!.scrollLeft = _offset;
    }

    // listen to scroll events
    _subscription = EventStreamProviders.scrollEvent
        .forTarget(_attachedElement!)
        .listen((_) {
          _offset = (direction == ScrollDirection.vertical
              ? _attachedElement!.scrollTop
              : _attachedElement!.scrollLeft);
          notifyListeners();
        });
  }

  /// Detaches the controller from the HTML element.
  void detach() {
    if (_attachedElement == null) return;
    _subscription?.cancel();
    _subscription = null;
    _attachedElement = null;
  }

  /// Adds a scroll position listener callback.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a scroll position listener callback.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners.
  void notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  /// Jumps the scroll position to the top of the scrollable component.
  ///
  /// In a vertical scroll component this will scroll to the `top` of the
  /// scrollable component. In a horizontal scroll component this will scroll
  /// to the `left end` of the scrollable component.
  ///
  /// If the scrollable component's children are in reversed order, this
  /// method will scroll to the `bottom` or `right end` of the scrollable
  /// component based on scroll direction.
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.scrollToTop();
  /// ```
  void scrollToTop() => jumpTo(0.0);

  /// Jumps the scroll position to the end of the scrollable component.
  ///
  /// In a vertical scroll component this will scroll to the `bottom` of the
  /// scrollable component. In a horizontal scroll component this will scroll
  /// to the `right end` of the scrollable component.
  ///
  /// If the scrollable component's children are in reversed order, this
  /// method will scroll to the `top` or `left end` of the scrollable component
  /// based on scroll direction.
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.scrollToEnd();
  /// ```
  void scrollToEnd() => jumpTo(maxScrollExtent);

  /// Jumps the scroll position immediately to [value] in pixels.
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.jumpTo(100.0);
  /// ```
  void jumpTo(double value) {
    if (_attachedElement == null) return;

    // update scroll offset
    _offset = value;

    // update scroll position
    if (direction == ScrollDirection.vertical) {
      _attachedElement!.scrollTop = value;
    } else {
      _attachedElement!.scrollLeft = value;
    }

    // notify listeners of scroll position changes
    notifyListeners();
  }

  /// Animates the scroll position smoothly to [value] in pixels.
  ///
  /// If [duration] is `zero`, animation will be ignored.
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.animateTo(100.0);
  /// ```
  void animateTo(
    double value, {
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    if (_attachedElement == null) return;

    // jump immediately if duration is zero
    if (duration == Duration.zero) {
      jumpTo(value);
      return;
    }

    // calculate starting offset and change
    final startOffset = offset;
    final change = value - startOffset;

    // setup animation variables
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final totalDurationMs = duration.inMilliseconds;

    void step() {
      if (_attachedElement == null) return;

      // calculate animation progress
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final progress = (elapsed / totalDurationMs).clamp(
        0.0,
        1.0,
      );

      // calculate easing progress
      final easedProgress = curve.build(progress);

      // calculate current scroll position
      final current = startOffset + change * easedProgress;

      // update scroll position
      if (direction == ScrollDirection.vertical) {
        _attachedElement!.scrollTop = current;
      } else {
        _attachedElement!.scrollLeft = current;
      }

      // update scroll offset
      _offset = current;

      // notify listeners of scroll position changes
      notifyListeners();

      // continue animation if not done
      if (progress < 1.0) onComponentRendered(step);
    }

    // start animation
    step();
  }

  /// Jumps immediately to a specific item [index] given a fixed
  /// [itemExtent] in pixels.
  ///
  /// {@template ItemExtent}
  /// - if scroll direction is `vertical`, [itemExtent] is the computed
  ///   `height` of an item in the scrollable component's children.
  /// - if scroll direction is `horizontal`, [itemExtent] is the computed
  ///   `width` of an item in the scrollable component's children.
  /// {@endtemplate}
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.jumpToIndex(
  ///   5,
  ///   itemExtent: 100.0,
  /// );
  /// ```
  void jumpToIndex(
    int index, {
    required double itemExtent,
  }) {
    jumpTo(index * itemExtent);
  }

  /// Animates smoothly to a specific item [index] given a fixed
  /// [itemExtent] in pixels.
  ///
  /// Animation will be ignored when [duration] is `zero`.
  ///
  /// {@macro ItemExtent}
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.animateToIndex(
  ///   5,
  ///   itemExtent: 100.0,
  ///   duration: const Duration(milliseconds: 300),
  ///   curve: Curves.easeInOut,
  /// );
  /// ```
  void animateToIndex(
    int index, {
    required double itemExtent,
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    animateTo(
      index * itemExtent,
      duration: duration,
      curve: curve,
    );
  }

  /// Scrolls to a specific component inside the scrollable component.
  ///
  /// The component to scroll to, identified by a unique [id], should be a
  /// child of the scrollable component and **not** a scrollable
  /// component itself.
  ///
  /// Animation will be ignored when [duration] is `zero`.
  ///
  /// ### Example
  /// ```dart
  /// final scrollController = ScrollController();
  /// scrollController.scrollToComponent('some-id');
  /// ```
  void scrollToComponent(
    String id, {
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    if (_attachedElement == null) return;

    final target = _attachedElement!.querySelector('#$id') as HTMLElement?;

    if (target != null) {
      double targetOffset;

      // get target and container positions
      final containerRect = _attachedElement!.getBoundingClientRect();
      final targetRect = target.getBoundingClientRect();

      // calculate target offset
      if (direction == ScrollDirection.vertical) {
        final relativeTop = targetRect.top - containerRect.top;
        targetOffset = _attachedElement!.scrollTop + relativeTop;
      } else {
        final relativeLeft = targetRect.left - containerRect.left;
        targetOffset = _attachedElement!.scrollLeft + relativeLeft;
      }

      // animate to target offset
      animateTo(
        targetOffset,
        duration: duration,
        curve: curve,
      );
    }
  }

  /// Disposes resources used by the controller.
  void dispose() {
    detach();
    _listeners.clear();
  }
}

/// A controller for a [PageView], enabling page-by-page navigation.
class PageController extends ScrollController {
  /// The page to show when first creating the scroll view.
  final int initialPage;

  /// The fraction of the viewport that each page should occupy (default 1.0).
  final double viewportFraction;

  /// Creates a new [PageController].
  PageController({
    this.initialPage = 0,
    this.viewportFraction = 1.0,
    super.direction = ScrollDirection.horizontal,
  }) : super(initialScrollOffset: 0.0);

  @override
  void attach(HTMLElement element) {
    super.attach(element);
    if (initialPage > 0) {
      onComponentRendered(() => jumpToPage(initialPage));
    }
  }

  /// Returns the current page index.
  double get page {
    if (_attachedElement == null) return initialPage.toDouble();

    final isHoriz = direction == ScrollDirection.horizontal;

    // calculate page size based on scroll direction and viewport fraction
    final pageSize =
        (isHoriz
            ? _attachedElement!.clientWidth
            : _attachedElement!.clientHeight) *
        viewportFraction;

    // avoid division by zero
    if (pageSize <= 0) return initialPage.toDouble();

    // get current scroll offset
    final currentOffset = isHoriz
        ? _attachedElement!.scrollLeft
        : _attachedElement!.scrollTop;

    // calculate current page index
    return currentOffset / pageSize;
  }

  /// Animates smoothly to the specified [page] index.
  ///
  /// Note that animation is ignored when [duration] is `zero`, and the page
  /// index is not checked to be within the range of the scroll view's pages.
  ///
  /// ### Example
  /// ```dart
  /// final controller = PageController();
  /// controller.animateToPage(
  ///   2,
  ///   duration: const Duration(milliseconds: 500),
  ///   curve: Curves.easeIn,
  /// );
  /// ```
  void animateToPage(
    int page, {
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    if (_attachedElement == null) return;

    final isHoriz = direction == ScrollDirection.horizontal;

    // calculate page size
    final pageSize =
        (isHoriz
            ? _attachedElement!.clientWidth
            : _attachedElement!.clientHeight) *
        viewportFraction;

    // calculate target scroll offset
    final targetOffset = page * pageSize;

    // jump immediately if duration is zero
    if (duration == Duration.zero) {
      jumpToPage(page);
      return;
    }

    // calculate starting offset and change
    final startOffset = isHoriz
        ? _attachedElement!.scrollLeft
        : _attachedElement!.scrollTop;

    // calculate change in scroll offset
    final change = targetOffset - startOffset;

    // setup animation variables
    final startTime = DateTime.now().millisecondsSinceEpoch;
    final totalDurationMs = duration.inMilliseconds;

    void step() {
      if (_attachedElement == null) return;

      // calculate animation progress
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final progress = (elapsed / totalDurationMs).clamp(
        0.0,
        1.0,
      );

      // calculate easing progress
      final easedProgress = curve.build(progress);

      // calculate current scroll position
      final current = startOffset + change * easedProgress;

      // update scroll position
      if (isHoriz) {
        _attachedElement!.scrollLeft = current;
      } else {
        _attachedElement!.scrollTop = current;
      }

      // notify listeners of scroll position changes
      notifyListeners();

      // continue animation if not done
      if (progress < 1.0) onComponentRendered(step);
    }

    // start animation
    step();
  }

  /// Jumps immediately to the specified [page] index.
  ///
  /// Note that the page index is not checked to be within the range of the
  /// scroll view's pages.
  ///
  /// ### Example
  /// ```dart
  /// final controller = PageController();
  /// controller.jumpToPage(2);
  /// ```
  void jumpToPage(int page) {
    if (_attachedElement == null) return;

    final isHoriz = direction == ScrollDirection.horizontal;

    // calculate page size
    final pageSize =
        (isHoriz
            ? _attachedElement!.clientWidth
            : _attachedElement!.clientHeight) *
        viewportFraction;

    // calculate target scroll offset
    final targetOffset = page * pageSize;

    // update scroll position
    if (isHoriz) {
      _attachedElement!.scrollLeft = targetOffset;
    } else {
      _attachedElement!.scrollTop = targetOffset;
    }

    // notify listeners of scroll position changes
    notifyListeners();
  }

  /// Navigates to the next page.
  void nextPage({
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    animateToPage(
      page.round() + 1,
      duration: duration,
      curve: curve,
    );
  }

  /// Navigates to the previous page.
  void previousPage({
    Duration duration = const Duration(milliseconds: 300),
    Curves curve = Curves.easeInOut,
  }) {
    animateToPage(
      (page.round() - 1).clamp(0, double.infinity).toInt(),
      duration: duration,
      curve: curve,
    );
  }
}

/// Defines scrolling physics rules for scroll views.
abstract class ScrollPhysics {
  /// Creates a new [ScrollPhysics] configuration.
  const ScrollPhysics();

  /// Gets the physics type enumeration.
  ScrollPhysicsType get type;

  /// Returns CSS properties corresponding to this physics rule.
  Map<String, String> props(ScrollDirection direction) {
    final isHoriz = direction == ScrollDirection.horizontal;

    switch (type) {
      case ScrollPhysicsType.neverScrollable:
        return {'overflow': 'hidden'};
      case ScrollPhysicsType.bouncing:
        return {
          'overflow-x': isHoriz ? 'auto' : 'hidden',
          'overflow-y': !isHoriz ? 'auto' : 'hidden',
          'overscroll-behavior': 'auto',
          '-webkit-overflow-scrolling': 'touch',
        };
      case ScrollPhysicsType.clamping:
        return {
          'overflow-x': isHoriz ? 'auto' : 'hidden',
          'overflow-y': !isHoriz ? 'auto' : 'hidden',
          'overscroll-behavior-${isHoriz ? 'x' : 'y'}': 'none',
        };
      case ScrollPhysicsType.snapping:
        return {
          'overflow-x': isHoriz ? 'auto' : 'hidden',
          'overflow-y': !isHoriz ? 'auto' : 'hidden',
          'scroll-snap-type': isHoriz ? 'x mandatory' : 'y mandatory',
        };
      case ScrollPhysicsType.adaptive:
        return {
          'overflow-x': isHoriz ? 'scroll' : 'hidden',
          'overflow-y': !isHoriz ? 'scroll' : 'hidden',
        };
    }
  }
}

/// Scroll physics that prevents user scrolling.
class NeverScrollableScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that prevents user scrolling.
  const NeverScrollableScrollPhysics();

  @override
  ScrollPhysicsType get type => ScrollPhysicsType.neverScrollable;
}

/// Scroll physics that allows bounce effect at boundaries (iOS-style).
class BouncingScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that allows bounce effect
  /// at boundaries (iOS-style).
  const BouncingScrollPhysics();

  @override
  ScrollPhysicsType get type => ScrollPhysicsType.bouncing;
}

/// Scroll physics that clamps content strictly inside
/// boundaries (Android-style).
class ClampingScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that clamps content strictly inside
  /// boundaries (Android-style).
  const ClampingScrollPhysics();

  @override
  ScrollPhysicsType get type => ScrollPhysicsType.clamping;
}

/// Scroll physics that always allows scrolling even if content fits.
class AlwaysScrollableScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that always allows scrolling
  /// even if content fits.
  const AlwaysScrollableScrollPhysics();

  @override
  ScrollPhysicsType get type => ScrollPhysicsType.adaptive;
}

/// Scroll physics that snaps scrolling to the nearest item.
class SnappingScrollPhysics extends ScrollPhysics {
  /// Creates a scroll physics that snaps scrolling to the nearest item.
  const SnappingScrollPhysics();

  @override
  ScrollPhysicsType get type => ScrollPhysicsType.snapping;
}

/// Controls the layout of tiles in a `GridView`.
abstract class SliverGridDelegate {
  /// Abstract const constructor.
  const SliverGridDelegate();
}

/// Creates grid layouts with a fixed number of tiles in the cross ScrollDirection.
class SliverGridDelegateWithFixedCrossAxisCount extends SliverGridDelegate {
  /// Number of columns/rows in the cross ScrollDirection.
  final int crossAxisCount;

  /// Logical spacing between items along the main ScrollDirection.
  final Dim mainAxisSpacing;

  /// Logical spacing between items along the cross ScrollDirection.
  final Dim crossAxisSpacing;

  /// Ratio of the cross-axis to the main-axis extent of each child.
  final AspectRatioType childAspectRatio;

  /// Main axis size of child (overrides [childAspectRatio] if specified).
  ///
  /// - If scroll direction is `vertical`, this is the `height` of each item.
  /// - If scroll direction is `horizontal`, this is the `width` of each item.
  ///
  /// Note: This property
  final Dim? mainAxisExtent;

  /// Creates a [SliverGridDelegateWithFixedCrossAxisCount].
  const SliverGridDelegateWithFixedCrossAxisCount({
    required this.crossAxisCount,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.childAspectRatio = AspectRatioType.ratio1_1,
    this.mainAxisExtent,
  }) : assert(
         crossAxisCount > 0,
         'crossAxisCount must be greater than 0',
       );
}

/// Creates grid layouts with tiles that each have a maximum cross-axis extent.
class SliverGridDelegateWithMaxCrossAxisExtent extends SliverGridDelegate {
  /// Maximum extent of tiles in the cross ScrollDirection.
  ///
  /// - If scroll direction is `vertical`, this is the `max-width` of each item.
  /// - If scroll direction is `horizontal`, this is the `max-height` of each item.
  final Dim maxCrossAxisExtent;

  /// Logical spacing between items along the main ScrollDirection.
  final Dim mainAxisSpacing;

  /// Logical spacing between items along the cross ScrollDirection.
  final Dim crossAxisSpacing;

  /// Ratio of the cross-axis to the main-axis extent of each child.
  final AspectRatioType childAspectRatio;

  /// Main axis size of child (overrides [childAspectRatio] if specified).
  ///
  /// - If scroll direction is `vertical`, this is the `height` of each item.
  /// - If scroll direction is `horizontal`, this is the `width` of each item.
  final Dim? mainAxisExtent;

  /// Creates a [SliverGridDelegateWithMaxCrossAxisExtent] that creates grid
  /// layouts with tiles each having a maximum cross-axis extent.
  const SliverGridDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = const Dim.px(16),
    this.crossAxisSpacing = const Dim.px(16),
    this.childAspectRatio = AspectRatioType.ratio1_1,
    this.mainAxisExtent,
  });
}

/// Base class for specifying column width behavior in a TableView component.
abstract class TableColumnWidth {
  /// Base const constructor.
  const TableColumnWidth();

  /// Returns the CSS width string corresponding to this column width rule.
  String get cssWidth;
}

/// Column width that expands based on flex factor.
class FlexColumnWidth extends TableColumnWidth {
  /// Creates a column width that expands based on flex factor.
  const FlexColumnWidth();

  @override
  String get cssWidth => 'auto';
}

/// Column width fixed to a specific size.
class FixedColumnWidth extends TableColumnWidth {
  /// The fixed width.
  final Dim width;

  /// Creates a column width fixed to a specific size.
  const FixedColumnWidth(this.width);

  @override
  String get cssWidth => width.cssText;
}

/// Column width based on the intrinsic content width.
class IntrinsicColumnWidth extends TableColumnWidth {
  /// Creates a column width based on the intrinsic content width.
  const IntrinsicColumnWidth();

  @override
  String get cssWidth => 'max-content';
}

/// Column width calculated as a fraction of the total table width.
class FractionColumnWidth extends TableColumnWidth {
  /// Fraction value between 0.0 and 1.0.
  final double value;

  /// Creates a column width calculated as a fraction of the total table width.
  const FractionColumnWidth(this.value);

  @override
  String get cssWidth => '${(value.clamp(0, 1.0)) * 100}%';
}

/// Defines horizontal and vertical borders of a [Table] component.
class TableBorder {
  /// Top border of the table's outer boundary.
  final BorderSideData top;

  /// Right border of the table's outer boundary.
  final BorderSideData right;

  /// Bottom border of the table's outer boundary.
  final BorderSideData bottom;

  /// Left border of the table's outer boundary.
  final BorderSideData left;

  /// Border applied horizontally between rows (rendered as
  /// the bottom border of each cell, excluding the final row).
  final BorderSideData horizontalInside;

  /// Border applied vertically between columns (rendered as
  /// the right border of each cell, excluding the final column).
  final BorderSideData verticalInside;

  /// Border radius of the table.
  final BorderRadiusData? borderRadius;

  /// Creates a [TableBorder] with distinct side borders.
  const TableBorder({
    this.top = BorderSideData.none,
    this.right = BorderSideData.none,
    this.bottom = BorderSideData.none,
    this.left = BorderSideData.none,
    this.horizontalInside = BorderSideData.none,
    this.verticalInside = BorderSideData.none,
    this.borderRadius,
  });

  /// Creates a [TableBorder] where all sides share
  /// the same border properties.
  factory TableBorder.all({
    Dim width = const Dim.px(1),
    BorderStyle style = BorderStyle.solid,
    Color? color,
    BorderRadiusData? borderRadius,
  }) {
    final side = BorderSideData(
      color: color,
      width: width,
      style: style,
    );
    return TableBorder(
      top: side,
      right: side,
      bottom: side,
      left: side,
      horizontalInside: side,
      verticalInside: side,
      borderRadius: borderRadius,
    );
  }

  /// Creates a [TableBorder] with symmetric outer/inner borders.
  factory TableBorder.symmetric({
    BorderSideData inside = BorderSideData.none,
    BorderSideData outside = BorderSideData.none,
  }) {
    return TableBorder(
      top: outside,
      right: outside,
      bottom: outside,
      left: outside,
      horizontalInside: inside,
      verticalInside: inside,
    );
  }

  /// Returns the CSS border style map for this TableBorder instance.
  Map<String, String> get props {
    return {
      'border-top': top.value,
      'border-right': right.value,
      'border-bottom': bottom.value,
      'border-left': left.value,
      ...?borderRadius?.props,
    };
  }
}

/// A row of cells within a TableView component.
class TableRow {
  /// Unique identifier for the row.
  final String? id;

  /// Child cell components in the row (e.g. NakiText).
  final List<Component> children;

  /// Alignment of cells in the row.
  final TableRowCellAlignment? alignment;

  /// Additional CSS classes applied to the row.
  final String? classes;

  /// Callback function that is invoked when the row is clicked.
  final VoidCallback? onClick;

  /// Creates a [TableRow].
  const TableRow({
    this.id,
    required this.children,
    this.alignment,
    this.classes,
    this.onClick,
  });
}
