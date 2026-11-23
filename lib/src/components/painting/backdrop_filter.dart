part of 'index.dart';

/// {@template BackdropFilter}
/// A component that applies a backdrop filter to the area
/// behind its child.
///
/// This component is useful for creating frosted glass
/// effects and other cool visual effects.
///
/// ### Example
/// ```dart
/// BackdropFilter(
///   filter: const BlurFilter(8)
///       .and(const ContrastFilter(100))
///       .and(const GrayscaleFilter(100)),
///   child: Container(
///     size: SizeConstraints(
///       width: Dim.px(100),
///       height: Dim.px(100),
///     ),
///     decoration: BoxDecoration(backgroundColor: Colors.red),
///     child: NakiText('I am behind the filter'),
///   ),
/// )
/// ```
/// {@endtemplate}
class BackdropFilter extends StatelessComponent {
  /// Component that will be displayed with the backdrop
  /// filter applied behind it.
  final Component child;

  /// Filters to apply to the backdrop.
  /// This is used to create effects like blur, contrast,
  /// grayscale, etc.
  ///
  /// Accepts a cascading [Filter], a standalone filter
  /// (e.g., [BlurFilter], [BrightnessFilter],
  /// [ContrastFilter]), or filters composed
  /// via [Filter.and].
  ///
  /// ### Example
  /// ```dart
  /// BackdropFilter(
  ///   filter: const BlurFilter(8).and(const ContrastFilter(100)),
  ///   ...,
  /// )
  /// ```
  final Filter filter;

  /// Optional CSS classes applied to the backdrop filter component.
  final String? classes;

  /// {@macro BackdropFilter}
  const BackdropFilter({
    super.key,
    required this.filter,
    required this.child,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    return .element(
      tag: 'naki-backdrop',
      key: key,
      classes: classes,
      styles: Styles(raw: {'display': 'block', ...filter.props}),
      children: [child],
    );
  }
}
