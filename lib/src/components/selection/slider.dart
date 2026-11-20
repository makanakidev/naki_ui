part of 'index.dart';

/// {@template Slider}
/// A component that displays a range slider, with support for custom
/// ranges, snapping divisions, custom track and thumb colors,
/// and an optional value indicator.
///
/// ### Example
/// ```dart
/// Slider(
///   value: 45,
///   minValue: 0,
///   maxValue: 100,
///   divisions: 10,
///   showValueIndicator: true,
///   expand: true,
///   onChange: (value) {
///     print('Slider value: $value');
///   },
/// )
/// ```
/// {@endtemplate}
class Slider extends StatelessComponent {
  /// Width of the slider track.
  final Dim? width;

  /// Unique identifier of the slider.
  final String id;

  /// Name used when the slider participates in a native form.
  final String? name;

  /// The height of the slider.
  final Dim height;

  /// Custom color applied to the slider track.
  final Color? color;

  /// Custom color applied to the slider thumb.
  final Color? thumbColor;

  /// The current value of the slider.
  final double value;

  /// Whether to display a floating value indicator tooltip when the
  /// user interacts with the slider.
  final bool showValueIndicator;

  /// The minimum selectable value for the slider.
  final double minValue;

  /// The maximum selectable value for the slider.
  final double maxValue;

  /// The number of discrete intervals between [minValue] and [maxValue]
  /// to snap the value to.
  ///
  /// When `null`, the slider is continuous otherwise it snaps
  /// to the nearest division.
  final int? divisions;

  /// Callback invoked when the slider value changes.
  final ValueChanged<double>? onChange;

  /// Whether user interaction with the slider is allowed.
  final bool enable;

  /// Additional CSS classes applied to the slider component.
  final String? classes;

  /// Accessible name announced by screen readers (e.g. `'Volume'`).
  final String? semanticLabel;

  /// {@macro Slider}
  const Slider({
    super.key,
    required this.id,
    this.value = 0,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.enable = true,
    this.showValueIndicator = false,
    this.height = const Dim.px(20),
    this.width,
    this.name,
    this.onChange,
    this.divisions,
    this.classes,
    this.thumbColor,
    this.color,
    this.semanticLabel,
  }) : assert(id != '', 'id cannot be empty'),
       assert(minValue < maxValue, 'maxValue must be greater than minValue'),
       assert(
         value >= minValue && value <= maxValue,
         'value must be between minValue and maxValue',
       ),
       assert(
         divisions == null || divisions >= 1,
         'divisions must be at least 1',
       );

  @override
  Component build(BuildContext context) {
    final String _id = 'nsl_$id';
    final showTooltip = enable && showValueIndicator;

    // Offset from the track position to the thumb center, which travels
    // half a thumb less than the track at each end.
    final double percent = (value - minValue) * 100 / (maxValue - minValue);
    final String thumbSize =
        'var(${Tokens.current.sliderThumbSize.name}, 24px)';
    final String position =
        'calc($percent% + $thumbSize * ${0.5 - percent / 100})';

    const String baseClass = 'naki-slider';
    final String effectiveClasses = joinClasses([?classes, baseClass]);

    final _style = {
      Tokens.current.sliderThumbColor.name: ?thumbColor?.value,
      Tokens.current.sliderTrackColor.name: ?color?.value,
    };

    return .element(
      tag: 'naki-slider',
      styles: Styles(
        raw: {
          Tokens.current.sliderThumbSize.name: height.cssText,
          'width': ?width?.cssText,
        },
      ),
      children: [
        // Input
        input<double>(
          id: _id,
          key: key,
          name: name,
          type: InputType.range,
          classes: effectiveClasses,
          styles: Styles(raw: _style),
          disabled: !enable,
          value: value.toCleanString,
          attributes: {
            'min': minValue.toCleanString,
            'max': maxValue.toCleanString,
            'step': divisions == null
                ? 'any'
                : ((maxValue - minValue) / divisions!).toCleanString,
            'aria-label': ?semanticLabel,
          },
          onInput: enable
              ? (value) {
                  onChange?.call(value);
                }
              : null,
        ),

        // active track
        .element(
          tag: 'span',
          classes: 'naki-slider-active-track',
          styles: Styles(raw: {'width': position}),
        ),

        // Tooltip
        if (showTooltip)
          .element(
            tag: 'output',
            classes: 'slider-tooltip',
            id: '$_id-tooltip',
            attributes: {'for': _id},
            styles: Styles(raw: {'left': position}),
            children: [.text('${value.roundDown}')],
          ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Slider', [Rules.nakiSliderRules]);
}
