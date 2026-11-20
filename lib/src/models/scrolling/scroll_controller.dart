part of 'index.dart';

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

    // Elements with `overflow: hidden` (e.g. NeverScrollableScrollPhysics,
    // or shrink-wrapped content that does not overflow yet) can still be
    // scrolled programmatically.

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
      final progress = (elapsed / totalDurationMs).clamp(0.0, 1.0);

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
  void jumpToIndex(int index, {required double itemExtent}) {
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
    animateTo(index * itemExtent, duration: duration, curve: curve);
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
      animateTo(targetOffset, duration: duration, curve: curve);
    }
  }

  /// Disposes resources used by the controller.
  void dispose() {
    detach();
    _listeners.clear();
  }
}
