part of 'index.dart';

/// {@template Expanded}
/// A component that expands the child of a [Row] or [Column]
/// to fill the available space along the main axis.
///
/// This is equivalent to [Flexible] with [FlexFit.tight].
///
/// ### Example
/// ```dart
/// Row(
///   children: [
///     Expanded(
///       flex: 1,
///       child: NakiText('Expanded Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Expanded extends Flexible {
  /// {@macro Expanded}
  const Expanded({
    super.key,
    required super.child,
    super.flex = 1,
    super.classes,
  }) : super(fit: FlexFit.tight);
}
