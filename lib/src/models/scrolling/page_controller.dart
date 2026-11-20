part of 'index.dart';

/// A controller for a [PageView], enabling page-by-page navigation.
class PageController extends ScrollController {
  /// The page to show when first creating the scroll view.
  final int initialPage;

  /// The fraction of the viewport that each page should occupy (default 1.0).
  final double viewportFraction;

  /// Marks a page view whose controller is animating it.
  static const _animatingAttribute = 'data-animating';

  /// Identifies the latest [animateToPage] call.
  int _animation = 0;

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

    // jump immediately if duration is zero or the user prefers less motion
    if (duration == Duration.zero ||
        window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
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

    final element = _attachedElement!;

    // a newer animation takes over from this one
    final animation = ++_animation;

    void step() {
      if (_attachedElement == null || animation != _animation) return;

      // scroll snapping would pull every frame back to the nearest page, and
      // a rebuild clears attributes it did not set, so this is set every frame
      element.setAttribute(_animatingAttribute, '');

      // calculate animation progress
      final elapsed = DateTime.now().millisecondsSinceEpoch - startTime;
      final progress = (elapsed / totalDurationMs).clamp(0.0, 1.0);

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
      if (progress < 1.0) {
        onComponentRendered(step);
      } else {
        element.removeAttribute(_animatingAttribute);
      }
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
    animateToPage(page.round() + 1, duration: duration, curve: curve);
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
