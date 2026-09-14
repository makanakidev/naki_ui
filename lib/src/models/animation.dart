/// Ease-in-out animation curve.
///
/// Starts slowly, accelerates through the middle, and
/// decelerates towards the end.
///
/// Example:
/// ```dart
/// Curves.easeInOut.build(0.5); // returns the value at 50% completion
/// ```
class _EaseInOutCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    if (t < 0.5) return 2 * t * t;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Linear animation curve.
///
/// Progresses at a uniform speed with a constant rate of change.
///
/// Example:
/// ```dart
/// Curves.linear.build(0.5); // returns 0.5 at 50% completion
/// ```
class _LinearCurve {
  static double build(double t) => t.clamp(0.0, 1.0);
}

/// Ease-in animation curve.
///
/// Starts slowly and accelerates quadratically towards the end.
///
/// Example:
/// ```dart
/// Curves.easeIn.build(0.5); // returns the value at 50% completion
/// ```
class _EaseInCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return 2 * t * t;
  }
}

/// Ease-out animation curve.
///
/// Starts at higher speed and decelerates quadratically towards the end.
///
/// Example:
/// ```dart
/// Curves.easeOut.build(0.5); // returns the value at 50% completion
/// ```
class _EaseOutCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Ease-in-out-back animation curve.
///
/// Accelerates through the beginning and decelerates towards the end.
///
/// Example:
/// ```dart
/// Curves.easeInOutBack.build(0.5); // returns the value at 50% completion
/// ```
class _EaseInOutBackCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Ease-out-back animation curve.
///
/// Decelerates towards the end of the transition.
///
/// Example:
/// ```dart
/// Curves.easeOutBack.build(0.5); // returns the value at 50% completion
/// ```
class _EaseOutBackCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Bounce-in animation curve.
///
/// Animation curve for bounce-in transitions.
///
/// Example:
/// ```dart
/// Curves.bounceIn.build(0.5); // returns the value at 50% completion
/// ```
class _BounceInCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Bounce-out animation curve.
///
/// Animation curve for bounce-out transitions.
///
/// Example:
/// ```dart
/// Curves.bounceOut.build(0.5); // returns the value at 50% completion
/// ```
class _BounceOutCurve {
  static double build(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    return -1 + (4 - 2 * t) * t;
  }
}

/// Standard animation curves.
enum Curves {
  /// Standard ease-in-out curve.
  ///
  /// Starts slowly, accelerates through the middle,
  /// and decelerates towards the end.
  easeInOut._('ease-in-out'),

  /// Standard linear curve.
  ///
  /// Progresses at a uniform speed with a constant rate of change.
  linear._('linear'),

  /// Standard ease-in curve.
  ///
  /// Starts slowly and accelerates quadratically towards the end.
  easeIn._('ease-in'),

  /// Standard ease-out curve.
  ///
  /// Starts at higher speed and decelerates quadratically towards the end.
  easeOut._('ease-out'),

  /// Standard ease-in-out-back curve.
  ///
  /// Starts slowly, accelerates through the middle,
  /// and decelerates towards the end.
  easeInOutBack._('ease-in-out-back'),

  /// Standard ease-out-back curve.
  ///
  /// Starts at higher speed and decelerates quadratically towards the end.
  easeOutBack._('ease-out-back'),

  /// Standard bounce-in curve.
  ///
  /// Starts slowly and accelerates quadratically towards the end.
  bounceIn._('bounce-in'),

  /// Standard bounce-out curve.
  ///
  /// Starts at higher speed and decelerates quadratically towards the end.
  bounceOut._('bounce-out')
  ;

  final String type;
  const Curves._(this.type);

  /// Returns the value of the curve at the given progress.
  ///
  /// [t] is the progress of the animation, ranging from
  /// 0.0 (start) to 1.0 (end).
  double build(double t) {
    switch (type) {
      case 'ease-in-out':
        return _EaseInOutCurve.build(t);
      case 'linear':
        return _LinearCurve.build(t);
      case 'ease-in':
        return _EaseInCurve.build(t);
      case 'ease-out':
        return _EaseOutCurve.build(t);
      case 'ease-in-out-back':
        return _EaseInOutBackCurve.build(t);
      case 'ease-out-back':
        return _EaseOutBackCurve.build(t);
      case 'bounce-in':
        return _BounceInCurve.build(t);
      case 'bounce-out':
        return _BounceOutCurve.build(t);
      default:
        throw UnimplementedError(
          'Unknown curve type: $type',
        );
    }
  }
}
