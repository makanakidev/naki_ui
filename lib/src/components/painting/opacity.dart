part of 'index.dart';

/// {@template Opacity}
/// A component that makes its child partially or fully transparent.
///
/// ### Example
/// ```dart
/// Opacity(
///   opacity: 0.5,
///   child: NakiText('Half transparent'),
/// )
/// ```
/// {@endtemplate}
class Opacity extends StatelessComponent {
  /// The component to make transparent.
  final Component child;

  /// Opacity level between 0.0 (fully transparent)
  /// and 1.0 (fully opaque).
  final double opacity;

  /// CSS Classes applied to the opacity container.
  final String? classes;

  /// {@macro Opacity}
  const Opacity({
    super.key,
    required this.opacity,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    return .element(
      tag: 'naki-opacity',
      key: key,
      classes: classes,
      styles: Styles(raw: {'opacity': opacity.clamp(0.0, 1.0).toCleanString}),
      children: [child],
    );
  }
}
