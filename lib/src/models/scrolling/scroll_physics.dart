part of 'index.dart';

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
