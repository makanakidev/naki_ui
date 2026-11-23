part of 'index.dart';

/// {@template Spinner}
/// A component that renders a loading spinner with an optional
/// iOS-style or glassmorphism effect.
///
/// ### Example
/// ```dart
/// Spinner(
///   thickness: Dim.px(4),
///   color: Colors.red,
///   trackColor: Colors.black,
/// )
/// ```
///
/// See also:
/// - [Spinner.ios] constructor for iOS-style spinner.
/// - [Spinner.glass] constructor for glassmorphism-style spinner.
/// {@endtemplate}
class Spinner extends StatelessComponent {
  /// Size (diameter) of the spinner (default: Dim.px(24)).
  final Dim size;

  /// Color of the spinner's track.
  final Color? trackColor;

  /// Width of the spinner's stroke in pixels.
  final double thickness;

  /// Color of the spinner.
  final Color? color;

  /// Color of the spinner's glass surface. When provided,
  /// a glassmorphism effect is applied behind the spinner
  /// using this color. [Spinner.glass] falls back to the
  /// theme's spinner surface color.
  ///
  /// NOTE: [ios] must be `false` to use this property.
  final Color? surfaceColor;

  /// Whether [Spinner.glass] created this spinner.
  final bool _glass;

  /// Additional CSS classes applied to the spinner.
  final String? classes;

  /// Accessible label announced while the spinner is active.
  final String semanticLabel;

  /// Whether to render an iOS-style spinner.
  ///
  /// NOTE: [surfaceColor] must be `null` to use this property.
  final bool ios;

  /// {@macro Spinner}
  const Spinner({
    super.key,
    this.size = const Dim.px(24),
    this.thickness = 4.0,
    this.ios = false,
    this.color,
    this.trackColor,
    this.surfaceColor,
    this.classes,
    this.semanticLabel = 'Loading',
  }) : _glass = false;

  /// Creates an iOS-style spinner.
  const Spinner.ios({
    super.key,
    this.size = const Dim.px(24),
    this.thickness = 2.0,
    this.color,
    this.classes,
    this.semanticLabel = 'Loading',
  }) : ios = true,
       trackColor = null,
       surfaceColor = null,
       _glass = false;

  /// Creates a glassmorphism-style spinner.
  ///
  /// [size] is the diameter of the arc. The glass disc adds 8px on each side.
  const Spinner.glass({
    super.key,
    this.surfaceColor,
    this.size = const Dim.px(24),
    this.thickness = 4.0,
    this.color,
    this.trackColor,
    this.classes,
    this.semanticLabel = 'Loading',
  }) : ios = false,
       _glass = true;

  @override
  Component build(BuildContext context) {
    final iosSpinner = ios && surfaceColor == null ? 'ios' : null;
    final glassSpinner = (_glass || surfaceColor != null) && !ios
        ? 'glass'
        : null;

    const baseClass = 'naki-spinner';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      Tokens.current.spinnerSize.name: size.cssText,
      Tokens.current.spinnerBorderWidth.name: thickness.toPx,
      Tokens.current.spinnerColor.name: ?color?.value,
      Tokens.current.spinnerBladeColor.name: ?color?.value,
      Tokens.current.spinnerTrackColor.name: ?trackColor?.value,
      Tokens.current.spinnerSurfaceColor.name: ?surfaceColor
          ?.withOpacity(0.4)
          .value,
    };

    final spinnerBlades = iosSpinner != null
        ? List<Component>.generate(12, (index) {
            return const span(classes: 'spinner-blade', []);
          })
        : null;

    return .element(
      key: key,
      tag: 'naki-spinner',
      classes: effectiveClasses,
      attributes: {
        'role': 'status',
        'aria-live': 'polite',
        'aria-label': semanticLabel,
        'data-type': iosSpinner ?? glassSpinner ?? 'rounded',
      },
      styles: Styles(raw: effectiveStyles),
      children: [...?spinnerBlades],
    );
  }

  static List<StyleRule> get styles => BasicsStyles.spinner;
}
