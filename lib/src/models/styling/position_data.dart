part of 'index.dart';

/// Position properties of a component.
class PositionData implements NakiStylable {
  /// The top position of the component.
  final Dim? top;

  /// The right position of the component.
  final Dim? right;

  /// The bottom position of the component.
  final Dim? bottom;

  /// The left position of the component.
  final Dim? left;

  /// The z-index of the component.
  final int? zIndex;

  /// The visibility of the component.
  final Visibility? visibility;

  /// The overflow of the component.
  final Overflow? overflow;

  /// Additional CSS properties (e.g. transform, scale).
  final Map<String, String>? extra;

  /// Create a new position.
  const PositionData({
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.zIndex,
    this.visibility,
    this.overflow,
    this.extra,
  });

  /// Center position.
  static const center = PositionData(
    top: Dim.percent(50),
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, -50%)'},
  );

  /// Top center position.
  static const topCenter = PositionData(
    top: Dim.zero,
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, 0%)'},
  );

  /// Top left position.
  static const topLeft = PositionData(top: Dim.zero, left: Dim.zero);

  /// Top right position.
  static const topRight = PositionData(
    top: Dim.zero,
    right: Dim.zero,
    extra: {'transform': 'translate(0%, 0%)'},
  );

  /// Bottom center position.
  static const bottomCenter = PositionData(
    bottom: Dim.zero,
    left: Dim.percent(50),
    extra: {'transform': 'translate(-50%, 0%)'},
  );

  /// Bottom left position.
  static const bottomLeft = PositionData(bottom: Dim.zero, left: Dim.zero);

  /// Bottom right position.
  static const bottomRight = PositionData(
    bottom: Dim.zero,
    right: Dim.zero,
    extra: {'transform': 'translate(0%, 0%)'},
  );

  /// Copy position attributes.
  PositionData copyWith({
    Dim? top,
    Dim? right,
    Dim? bottom,
    Dim? left,
    int? zIndex,
    Visibility? visibility,
    Overflow? overflow,
    Map<String, String>? extra,
  }) => PositionData(
    top: top ?? this.top,
    right: right ?? this.right,
    bottom: bottom ?? this.bottom,
    left: left ?? this.left,
    zIndex: zIndex ?? this.zIndex,
    visibility: visibility ?? this.visibility,
    overflow: overflow ?? this.overflow,
    extra: (this.extra ?? {}).combine(extra ?? {}),
  );

  /// Converts position attributes to a CSS style map.
  @override
  Map<String, String> get props => {
    'top': ?top?.cssText,
    'right': ?right?.cssText,
    'bottom': ?bottom?.cssText,
    'left': ?left?.cssText,
    'z-index': ?zIndex?.toCleanString,
    'visibility': ?visibility?.value,
    ...?overflow?.styles,
    ...?extra,
  };

  @override
  String get cssText => props.cssText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PositionData &&
          runtimeType == other.runtimeType &&
          top == other.top &&
          right == other.right &&
          bottom == other.bottom &&
          left == other.left &&
          zIndex == other.zIndex &&
          visibility == other.visibility &&
          overflow == other.overflow &&
          mapEquals(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    top,
    right,
    bottom,
    left,
    zIndex,
    visibility,
    overflow,
    extra == null ? null : Object.hashAll(extra!.entries),
  ]);
}
