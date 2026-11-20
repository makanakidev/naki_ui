part of 'index.dart';

/// {@template RotatedBox}
/// A component that rotates its child by integral numbers of quarter turns.
///
/// ### Example
/// ```dart
/// RotatedBox(
///   quarterTurns: 1,
///   child: NakiText('I am rotated'),
/// )
/// ```
/// {@endtemplate}
class RotatedBox extends StatelessComponent {
  /// The component to display inside the rotated box.
  final Component child;

  /// Number of quarter turns (90 degree increments) to rotate.
  final int quarterTurns;

  /// Optional CSS classes applied to the rotated box component.
  final String? classes;

  /// {@macro RotatedBox}
  const RotatedBox({
    super.key,
    required this.quarterTurns,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-rotatedbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final degrees = (quarterTurns % 4) * 90;

    return .element(
      tag: 'naki-rotatedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {'display': 'inline-block', 'transform': 'rotate(${degrees}deg)'},
      ),
      children: [child],
    );
  }
}
