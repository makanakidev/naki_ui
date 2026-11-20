part of 'index.dart';

/// {@template SegmentedInput}
/// A component designed for OTP (One-Time Password) and PIN
/// entry with configurable segment count, spacing, shapes, and styles.
///
/// Each segment accepts input (single character or digit), auto-advances focus
/// upon typing, handles backspace/delete navigation, supports multi-character
/// pasting, and allows optional text obscuring.
///
/// ### Example
/// ```dart
/// SegmentedInput(
///   id: 'otp-input',
///   length: 6,
///   type: SegmentedInputType.number,
///   onChanged: (value) => print('OTP value: $value'),
///   onCompleted: (value) => print('Completed OTP: $value'),
/// )
/// ```
/// {@endtemplate}
class SegmentedInput extends StatefulComponent {
  /// Unique identifier of the segmented input field.
  final String? id;

  /// Total number of input segments (e.g. 4 or 6 for PIN/OTP).
  final int length;

  /// Input type restriction for each segment
  /// ([SegmentedInputType.number], [SegmentedInputType.text],
  /// or [SegmentedInputType.password]).
  final SegmentedInputType type;

  /// Whether the input characters should be visually obscured.
  final bool obscureText;

  /// Obscure character displayed when [obscureText] is `true`.
  final String obscureCharacter;

  /// The initial character sequence displayed when the segmented
  /// input component first mounts. Subsequent rebuilds with a new
  /// [initialValue] will not overwrite user input.
  ///
  /// To control the value dynamically across rebuilds, use
  /// [value] instead.
  final String? initialValue;

  /// The character sequence explicitly controlling the displayed value
  /// of the segmented input.
  ///
  /// Whenever [value] changes on component rebuild, the displayed input
  /// updates to mirror the new value (ideal for resetting or
  /// programmatically updating the field).
  final String? value;

  /// Callback fired whenever any segment value changes.
  final ValueChanged<String>? onChanged;

  /// Callback fired when all segments have been filled.
  final ValueChanged<String>? onCompleted;

  /// Callback fired when the user submits the input (e.g., via Enter key).
  final ValueChanged<String>? onSubmit;

  /// Callback that returns an error message if input value is invalid,
  /// or `null` otherwise.
  final FieldValidator<String>? validator;

  /// Whether the segmented input is read-only.
  final bool readOnly;

  /// Whether the segmented input does not allow user input.
  final bool disable;

  /// Whether the segmented input automatically gains focus
  /// when the component is fully built and rendered.
  final bool autoFocus;

  /// Whether the segmented input is required in form validation.
  final bool required;

  /// When [autoValidate] is enabled and [validator] returns an error
  /// message, the validation message will be displayed on typing,
  /// submitting, or when the segmented input loses focus.
  ///
  /// Note: [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// Style applied to each segment.
  final SegmentedInputStyle? style;

  /// Decoration configuration for label, helper text, and error text.
  final InputDecoration? decoration;

  /// Additional CSS classes applied to the segmented input.
  final String? classes;

  /// {@macro SegmentedInput}
  const SegmentedInput({
    super.key,
    this.id,
    this.length = 6,
    this.type = SegmentedInputType.number,
    this.obscureText = false,
    this.obscureCharacter = '•',
    this.readOnly = false,
    this.disable = false,
    this.autoFocus = false,
    this.required = false,
    this.autoValidate = false,
    this.initialValue,
    this.value,
    this.onChanged,
    this.onCompleted,
    this.onSubmit,
    this.validator,
    this.style,
    this.decoration,
    this.classes,
  }) : assert(length > 0, 'length must be greater than 0'),
       assert(
         !autoValidate || validator != null,
         'validator is required when autoValidate is true',
       );

  @override
  State<SegmentedInput> createState() => _SegmentedInputState();

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('SegmentedInput', [
        ...Rules.nakiSegmentedInputRules,
        Rules.nakiFormFieldRules,
        Rules.nakiHelperRules,
        Rules.nakiErrorRules,
      ]);
}

class _SegmentedInputState extends State<SegmentedInput>
    with NakiStatefulMixin {
  late String _fieldId;

  List<String> _segmentValues = [];
  List<GlobalNodeKey<HTMLInputElement>> _segmentKeys = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void dispose() {
    NakiDebounce.cancel('validate_$_fieldId');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fieldId = nakiDomId(context, 'nsi', id: component.id);
    _initValues();
  }

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (component.autoFocus) _focusSegment(0);
    return null;
  }

  @override
  void didUpdateComponent(SegmentedInput oldcomponent) {
    super.didUpdateComponent(oldcomponent);

    if (component.length != oldcomponent.length) {
      _initValues();
    } else if (component.value != oldcomponent.value &&
        component.value != null) {
      _setFullValue(component.value!);
    }
  }

  /// Whether to validate the input (when autoValidate or required is true)
  bool get shouldValidate => component.autoValidate || component.required;

  /// Initializes segment values from component value or initialValue.
  /// Note: Subsequent updates to the segment's value will not overwrite
  /// user input, so for such cases [_setFullValue] is invoked.
  void _initValues() {
    final initial = component.value ?? component.initialValue ?? '';
    final previousKeys = _segmentKeys;

    _segmentKeys = List.generate(
      component.length,
      (index) => index < previousKeys.length
          ? previousKeys[index]
          : GlobalNodeKey<HTMLInputElement>(),
    );

    _segmentValues = List.generate(component.length, (i) {
      if (i < initial.length) return _sanitizeChar(initial[i]);
      return '';
    });
  }

  /// Updates segment values from an external source.
  /// A typical scenario is when the segment's value is updated
  /// from the parent component to reset the whole field.
  void _setFullValue(String val) {
    for (int i = 0; i < component.length; i++) {
      if (i < val.length) {
        _segmentValues[i] = _sanitizeChar(val[i]);
      } else {
        _segmentValues[i] = '';
      }
    }

    setState(() {});
  }

  /// Sanitizes character according to input type
  String _sanitizeChar(String char) {
    if (char.isEmpty) return '';

    if (component.type == SegmentedInputType.number) {
      return RegExp(r'[0-9]').hasMatch(char) ? char : '';
    }

    return char.substring(0, 1);
  }

  /// Concatenated value of all segments
  String get _fullValue => _segmentValues.join().trim();

  /// Whether all segment inputs are filled
  bool get _isComplete =>
      _segmentValues.every((val) => val.isNotEmpty) &&
      _segmentValues.length == component.length;

  /// Focuses segment input at specified index
  void _focusSegment(int index) {
    if (index >= 0 && index < component.length && kIsWeb) {
      final elem = _segmentKeys[index].currentNode;
      elem?.focus();
      elem?.select();
    }
  }

  /// Shows custom validation error message if validation fails
  void _showError() {
    if (kIsWeb && (component.validator != null || component.required)) {
      final error = component.required && _fullValue.isEmpty
          ? 'This field is required'
          : component.validator?.call(_fullValue) ?? '';

      // show validation message when autoValidate enabled
      if (shouldValidate) {
        showValidationError(_fieldId, error, isSegmentedInput: true);
      }

      // set validation constraint for browser validity
      final firstInput = _segmentKeys.firstOrNull?.currentNode;
      firstInput?.setCustomValidity(error);
    }
  }

  /// Handles invalid event when parent form is submitted
  void _handleInvalid(Event event) {
    if (kIsWeb && shouldValidate) {
      event.preventDefault();
      _showError();
    }
  }

  /// Validates input value with debouncing
  void _validate() {
    NakiDebounce.run(
      'validate_$_fieldId',
      const Duration(milliseconds: 1000),
      _showError,
    );
  }

  /// Triggers change, validation, and completion callbacks
  void _notifyChange() {
    _validate();
    if (_isComplete) component.onCompleted?.call(_fullValue);
    component.onChanged?.call(_fullValue);
  }

  /// Handles user input in a segment field and advances focus.
  /// Also distributes multi-character inputs (e.g., from OS SMS autofill).
  void _handleInput(int index, dynamic value) {
    if (component.disable || component.readOnly) return;

    final strVal = value.toString();

    if (strVal.isEmpty) {
      setState(() => _segmentValues[index] = '');
      _notifyChange();
      return;
    }

    // distribute OS SMS or browser autofill
    if (strVal.length > 1) {
      final cleanChars = <String>[];

      for (int i = 0; i < strVal.length; i++) {
        final sanitized = _sanitizeChar(strVal[i]);
        if (sanitized.isNotEmpty) cleanChars.add(sanitized);
      }

      if (cleanChars.isNotEmpty) {
        for (
          int i = 0;
          i < cleanChars.length && (index + i) < component.length;
          i++
        ) {
          setState(() => _segmentValues[index + i] = cleanChars[i]);
        }

        _notifyChange();

        final nextFocus = (index + cleanChars.length) < component.length
            ? index + cleanChars.length
            : component.length - 1;
        _focusSegment(nextFocus);

        return;
      }
    }

    // single-character input
    final sanitized = _sanitizeChar(strVal);
    setState(() => _segmentValues[index] = sanitized);

    _notifyChange();

    if (sanitized.isNotEmpty && index < component.length - 1) {
      _focusSegment(index + 1);
    }
  }

  /// Handles keydown events for backspace, navigation, and submission
  void _handleKeyDown(int index, KeyboardEvent event) {
    if (component.disable || component.readOnly || kIsServer) return;

    final key = event.key;

    // backspace key
    if (key == 'Backspace') {
      if (_segmentValues[index].isNotEmpty) {
        setState(() => _segmentValues[index] = '');
        _notifyChange();
      } else if (index > 0) {
        setState(() => _segmentValues[index - 1] = '');
        _focusSegment(index - 1);
        _notifyChange();
      }
      return;
    }

    // left arrow key navigation
    if (key == 'ArrowLeft') {
      _focusSegment(index - 1);
      return;
    }

    // right arrow key navigation
    if (key == 'ArrowRight') {
      _focusSegment(index + 1);
      return;
    }

    // enter key submission
    if (key == 'Enter' && _isComplete) {
      component.onSubmit?.call(_fullValue);
    }
  }

  /// Handles clipboard paste event across segment inputs
  void _handlePaste(int startIndex, Event event) {
    if (component.disable || component.readOnly || kIsServer) return;

    final clipboardEvent = event as ClipboardEvent;
    final pastedData = clipboardEvent.clipboardData?.getData('text') ?? '';
    if (pastedData.isEmpty) return;

    event.preventDefault();

    final cleanChars = <String>[];

    for (int i = 0; i < pastedData.length; i++) {
      final sanitized = _sanitizeChar(pastedData[i]);
      if (sanitized.isNotEmpty) cleanChars.add(sanitized);
    }

    if (cleanChars.isEmpty) return;

    for (
      int i = 0;
      i < cleanChars.length && (startIndex + i) < component.length;
      i++
    ) {
      setState(() => _segmentValues[startIndex + i] = cleanChars[i]);
    }

    _notifyChange();

    final nextFocus = (startIndex + cleanChars.length) < component.length
        ? startIndex + cleanChars.length
        : component.length - 1;

    _focusSegment(nextFocus);
  }

  @override
  Component build(BuildContext context) {
    final decoration = component.decoration;
    final style = component.style;

    final labelText = decoration?.labelText ?? '';
    final helperText = decoration?.helperText ?? '';

    final labelStyle = decoration?.labelStyle;
    final helperStyle = decoration?.helperStyle;
    final errorStyle = decoration?.errorStyle;

    final shape = style?.shape ?? SegmentedInputShape.box;
    final gap = style?.gap?.cssText;
    final width = style?.segmentWidth?.cssText;
    final height = style?.segmentHeight?.cssText;
    final fontSize =
        style?.textStyle?.fontSize?.cssText ??
        decoration?.inputStyle?.fontSize?.cssText;

    final hoverColor = style?.hoverBorderColor ?? decoration?.hoverBorderColor;
    final focusColor = style?.focusBorderColor ?? decoration?.focusBorderColor;
    final errorColor = style?.errorBorderColor ?? decoration?.errorStyle?.color;
    final inputColor =
        style?.textStyle?.color?.value ?? decoration?.inputStyle?.color?.value;

    final borderProps = component.style?.border?.props;
    final radiusProps = component.style?.borderRadius?.props;
    final paddingProps = component.style?.padding?.pProps;
    final marginProps =
        component.style?.margin?.mProps ?? component.decoration?.margin?.mProps;

    final allowHover =
        hoverColor != null && !component.disable && !component.readOnly;
    final allowFocus =
        focusColor != null && !component.disable && !component.readOnly;

    const baseClass = 'naki-segmented-input';
    final effectiveSegmentClasses = 'input-segment shape-${shape.name}';
    final effectiveContainerClasses = joinClasses([
      ?component.classes,
      baseClass,
    ]);

    final effectiveContainerStyles = {
      Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
      Tokens.current.focusBorderColor.name: ?focusColor?.value,
      Tokens.current.errorColor.name: ?errorColor?.value,
      Tokens.current.fontSizeHint.name: ?helperStyle?.fontSize?.cssText,
      Tokens.current.mutedColor.name: ?helperStyle?.color?.value,
      Tokens.current.fontSizeError.name: ?errorStyle?.fontSize?.cssText,
      Tokens.current.errorColor.name: ?errorStyle?.color?.value,
      ...?marginProps,
    };

    final effectiveInputStyles = {
      'width': ?width,
      'height': ?height,
      'font-size': ?fontSize,
      'color': ?inputColor,
      'font-weight': ?component.style?.textStyle?.fontWeight?.value,
      ...?borderProps,
      ...?radiusProps,
      ...?paddingProps,
    };

    final effectiveType =
        ((component.obscureText ||
                component.type == SegmentedInputType.password) &&
            component.obscureCharacter.length == 1)
        ? InputType.password
        : InputType.text;

    return .element(
      tag: 'naki-segmentedfield',
      id: '${_fieldId}__segmentedfield',
      classes: 'naki-form-field',
      styles: Styles(raw: effectiveContainerStyles),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(labelText, fieldId: '${_fieldId}_0', style: labelStyle),

        // Segments
        div(
          key: component.key,
          classes: effectiveContainerClasses,
          styles: Styles(raw: {'gap': ?gap}),
          List.generate(component.length, (i) {
            final value = _segmentValues[i];
            final isFilled = value.isNotEmpty;

            final bgColor = isFilled
                ? component.style?.filledBackgroundColor?.value
                : component.style?.backgroundColor?.value;

            final obscure = effectiveType == InputType.password && isFilled;
            final displayedValue = obscure ? component.obscureCharacter : value;

            return input(
              key: _segmentKeys[i],
              id: '${_fieldId}_$i',
              name: '${_fieldId}_$i',
              classes:
                  '$effectiveSegmentClasses${isFilled ? ' is-filled' : ''}',
              styles: Styles(
                raw: {...effectiveInputStyles, 'background-color': ?bgColor},
              ),
              type: effectiveType,
              disabled: component.disable,
              value: displayedValue,
              attributes: {
                'maxlength': '1',
                'autocomplete': i == 0
                    ? Autofill.oneTimeCode.value
                    : Autofill.off.value,
                'inputmode': component.type == SegmentedInputType.number
                    ? 'numeric'
                    : 'text',
                'pattern': ?(component.type == SegmentedInputType.number
                    ? ValidationPattern.digitsOnly.value
                    : null),
                'aria-label': 'Segment ${i + 1} of ${component.length}',
                'readonly': ?(component.readOnly ? '' : null),
                'required': ?(component.required && i == 0 ? '' : null),
                'hvr': ?(allowHover ? '' : null),
                'fcs': ?(allowFocus ? '' : null),
              },
              onInput: (val) => _handleInput(i, val),
              events: InputEvents(
                onKeyDown: (e) => _handleKeyDown(i, e),
                onPaste: (e) => _handlePaste(i, e),
                onFocusOut: (_) => _validate(),
                onInvalid: _handleInvalid,
              ).toMap,
            );
          }),
        ),

        // Helper / Hint
        if (helperText.isNotEmpty)
          p(classes: 'naki-helper', styles: Styles(raw: helperStyle?.props), [
            .text(helperText),
          ]),
      ],
    );
  }
}
