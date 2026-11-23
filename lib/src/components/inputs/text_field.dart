part of 'index.dart';

/// {@template TextField}
/// A component for forms which supports single and multi-line input.
///
/// It can be customized with input type, helper text, label,
/// placeholder, validation pattern, auto-validation,
/// and other useful properties.
///
/// ### Example
/// ```dart
/// TextField(
///   id: 'username',
///   type: InputType.text,
///   initialValue: 'naki_design',
///   decoration: InputDecoration(
///     labelText: 'Username',
///     placeholderText: 'Enter username',
///     helperText: 'Username can include letters, numbers, and underscores',
///   ),
///   onTyping: (value) {
///     print('Typing: $value');
///   },
///   onSubmit: (value) {
///     print('Submitted: $value');
///   },
///   disable: false,
///   required: true,
///   isMultiline: false,
///   expand: false,
///   classes: 'custom-textfield',
///   height: Dim.px(45),
///   width: Dim.px(300),
///   validator: (value) {
///     if (value.length < 5) {
///       return 'Username must be at least 5 characters';
///     }
///     return null;
///   },
/// )
/// ```
/// {@endtemplate}
class TextField extends StatelessComponent with NakiStatelessMixin {
  /// Unique identifier of the text field.
  /// No other component should have the same id.
  final String id;

  /// Supported input types: `text`, `number`,
  /// `email`, `url`, `password`, `tel`, `search`.
  final InputType type;

  /// Initial value of the text field.
  final String? initialValue;

  /// Input container width.
  final Dim? width;

  /// Input container height.
  final Dim? height;

  /// Icon shown at the left edge of the input field.
  final Component? leadingIcon;

  /// Icon shown at the right edge of the input field.
  final Component? trailingIcon;

  /// Callback function invoked when the user types into the field.
  final ValueChanged<String>? onTyping;

  /// Callback function invoked when the user submits the field
  /// (e.g., by pressing `Enter` key).
  final ValueChanged<String>? onSubmit;

  /// Function that returns an error message if the text
  /// field value is invalid, or `null` otherwise.
  final FieldValidator<String>? validator;

  /// When `true`, the text field is not editable.
  final bool readOnly;

  /// When `true`, the text field cannot be edited.
  final bool disable;

  /// When `true`, the text field spell-checking is enabled.
  final bool enableSpellCheck;

  /// Additional CSS classes applied to the text field.
  final String? classes;

  /// Additional native input attributes like ARIA metadata.
  final Map<String, String>? attributes;

  /// Additional input event configurations.
  final InputEvents? events;

  /// Maximum number of characters allowed.
  final int? maxLength;

  /// Minimum number of characters allowed.
  final int? minLength;

  /// The pattern used to validate the text field value.
  final ValidationPattern? pattern;

  /// Minimum numeric value allowed
  /// (applies to [InputType.number] only).
  final int? minValueAllowed;

  /// Maximum numeric value allowed
  /// (applies to [InputType.number] and [InputType.range] only).
  final int? maxValueAllowed;

  /// When `true`, the text field is required in
  /// [FormBuilder] validation.
  final bool required;

  /// When `true`, the text field will enable multi-line input.
  final bool isMultiline;

  /// Number of visible text lines when [isMultiline] is true.
  final int? visibleLines;

  /// Autofill type applied to the text field for
  /// native auto completion.
  final Autofill? autofill;

  /// When [autoValidate] is enabled and [validator] returns an
  /// error message, the text field will display validation message
  /// on typing, submitting, or when the field loses focus.
  ///
  /// [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// When `true`, the text field will auto focus.
  final bool autoFocus;

  /// When `true`, the text field will expand to fill the
  /// full width of its parent container.
  final bool expand;

  /// Text field background color.
  final Color? backgroundColor;

  /// Text field decoration configuration.
  final InputDecoration? decoration;

  /// {@macro TextField}
  TextField({
    required this.id,
    required this.type,
    super.key,
    this.disable = false,
    this.required = false,
    this.isMultiline = false,
    this.visibleLines = 3,
    this.expand = false,
    this.autoValidate = false,
    this.autoFocus = false,
    this.readOnly = false,
    this.enableSpellCheck = false,
    this.autofill,
    this.initialValue,
    this.onTyping,
    this.onSubmit,
    this.maxLength,
    this.minLength,
    this.pattern,
    this.minValueAllowed,
    this.maxValueAllowed,
    this.classes,
    this.attributes,
    this.events,
    this.width,
    this.height,
    this.validator,
    this.backgroundColor,
    this.leadingIcon,
    this.trailingIcon,
    this.decoration,
  }) : assert(
         kInputTypes.contains(type.name),
         'Unsupported input type: ${type.name}',
       ),
       assert(id.trim() != '', 'id must be provided'),
       assert(
         !autoValidate || validator != null,
         'validator must be provided when autoValidate is true',
       );

  /// Returns the input element node
  HTMLElement? get inputNode => key is GlobalNodeKey<HTMLElement>
      ? (key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById(id) as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (autoFocus && inputNode != null) {
      if (isMultiline) {
        (inputNode as HTMLTextAreaElement).focus();
      } else {
        (inputNode as HTMLInputElement).focus();
      }
    }

    if (!_hasValidation) return null;

    final field = NakiFormField(validate: _showError, reset: _resetValidation);
    NakiFormFields.register(id, field);

    return () {
      NakiDebounce.cancel('validate_$id');
      NakiFormFields.unregister(id, field);
    };
  }

  /// Whether the field has Dart-side validation rules.
  bool get _hasValidation => validator != null || required;

  /// Whether to display validation messages for the field.
  bool get _shouldValidate => autoValidate || required || validator != null;

  /// Current value of the text field
  String? get currentValue {
    if (kIsServer || inputNode == null) return null;

    return isMultiline
        ? (inputNode as HTMLTextAreaElement).value.trim()
        : (inputNode as HTMLInputElement).value.trim();
  }

  /// Computes the error for the current value: `required`, then
  /// [validator], then any native constraint (pattern, type, length, ...).
  String _computeError() {
    final value = currentValue ?? '';

    final custom = required && value.isEmpty
        ? 'This field is required'
        : validator?.call(value) ?? '';
    if (custom.isNotEmpty) return custom;

    _setValidity('');
    return _nativeValidationMessage;
  }

  /// The browser's validation message for native constraints.
  String get _nativeValidationMessage {
    final node = inputNode;
    if (node == null) return '';

    return isMultiline
        ? (node as HTMLTextAreaElement).validationMessage
        : (node as HTMLInputElement).validationMessage;
  }

  /// Validates the field, shows its error and updates native validity.
  void _showError() {
    if (!kIsWeb) return;

    NakiDebounce.cancel('validate_$id');

    final error = _computeError();
    if (_shouldValidate) showValidationError(id, error);

    _setValidity(error == _nativeValidationMessage ? '' : error);
  }

  /// Clears custom validity and any visible error.
  void _resetValidation() {
    NakiDebounce.cancel('validate_$id');
    _setValidity('');
    removeValidationError(id);
  }

  /// Sets validation constraint for native validity
  /// (signalling an error if [error] is not empty)
  void _setValidity(String error) {
    if (inputNode != null) {
      if (isMultiline) {
        (inputNode as HTMLTextAreaElement).setCustomValidity(error);
      } else {
        (inputNode as HTMLInputElement).setCustomValidity(error);
      }
    }
  }

  /// Handles invalid event when parent form is submitted
  void _invalid(Event event) {
    if (kIsWeb && _shouldValidate) {
      event.preventDefault();
      _showError();
    }
  }

  /// Validates user input
  void _validate() {
    if (!kIsWeb) return;

    final hasVisibleError = document.getElementById('${id}_validation') != null;

    if (hasVisibleError) {
      _showError();
    } else if (autoValidate) {
      NakiDebounce.run(
        'validate_$id',
        const Duration(milliseconds: 500),
        _showError,
      );
    } else if (_hasValidation) {
      final error = _computeError();
      _setValidity(error == _nativeValidationMessage ? '' : error);
    }
  }

  /// Handles input changes
  void _handleInput(dynamic value) {
    onTyping?.call(value.toString().trim());
    _validate();
  }

  /// Handles submit action on enter key press
  void _handleSubmit(KeyboardEvent event) {
    if (event.key != 'Enter' || isMultiline || event.isComposing) return;

    if (onSubmit != null) {
      onSubmit!.call(currentValue ?? '');
      _validate();
    }

    final node = inputNode;
    final handled = node != null && NakiFormFields.focusNextOrSubmit(node);
    if (handled || onSubmit != null) event.preventDefault();
  }

  @override
  Component build(BuildContext context) {
    final iconsWrapperId = nakiDomId(context, 'iconsWrapper');
    final hasIcon = leadingIcon != null || trailingIcon != null;

    final effectiveWidth = expand ? const Dim.percent(100) : width;
    final baseClass = 'naki-${isMultiline ? 'textarea' : 'input'}';
    final effectiveClasses = joinClasses([?classes, 'naki-form-field']);

    final labelText = decoration?.labelText ?? '';
    final placeholderText = decoration?.placeholderText;
    final helperText = decoration?.helperText ?? '';

    final border = decoration?.border;
    final margin = decoration?.margin;
    final padding = decoration?.padding;

    final hoverColor = decoration?.hoverBorderColor;
    final focusColor = decoration?.focusBorderColor;
    final placeholderColor = decoration?.placeholderColor;

    final inputTextStyle = decoration?.inputStyle;
    final errorStyle = decoration?.errorStyle;
    final helperStyle = decoration?.helperStyle;
    final labelStyle = decoration?.labelStyle;

    final allowHover = hoverColor != null && !disable && !readOnly;
    final allowFocus = focusColor != null && !disable && !readOnly;

    void _focusIconsWrapper(bool isFocus) {
      final wrapper = document.getElementById(iconsWrapperId) as HTMLElement?;
      if (wrapper != null && allowFocus) {
        isFocus
            ? wrapper.setAttribute('data-focused', '')
            : wrapper.removeAttribute('data-focused');
      }
    }

    final defaultEvents = InputEvents(
      onInvalid: _invalid,
      onKeyDown: _handleSubmit,
      onFocusIn: (_) => _focusIconsWrapper(true),
      onFocusOut: (_) {
        _focusIconsWrapper(false);
        _validate();
      },
    );

    final effectiveEvents = events?.merge(defaultEvents) ?? defaultEvents;

    final effectiveInputStyles = {
      'width': ?effectiveWidth?.cssText,
      if (hasIcon) ...{'border': 'none', 'border-radius': '0'},
      if (!hasIcon) ...?border?.props,
      ...?padding?.pProps,
    };

    Component inputArea = isMultiline
        ? textarea(
            key: key,
            id: id,
            name: id,
            classes: hasIcon ? null : baseClass,
            styles: Styles(raw: effectiveInputStyles),
            disabled: disable,
            required: required,
            placeholder: placeholderText,
            readonly: readOnly,
            wrap: TextWrap.soft,
            rows: visibleLines,
            spellCheck: enableSpellCheck
                ? SpellCheck.isTrue
                : SpellCheck.isFalse,
            attributes: {
              'pattern': ?pattern?.value,
              'autocomplete': ?autofill?.value,
              'maxlength': ?maxLength?.toString(),
              'minlength': ?minLength?.toString(),
              'hvr': ?(allowHover && !hasIcon ? '' : null),
              'fcs': ?(allowFocus && !hasIcon ? '' : null),
              'autofocus': ?(autoFocus ? '' : null),
              'aria-label': ?(labelText.isNotEmpty ? labelText : null),
              ...?attributes,
            },
            onInput: _handleInput,
            events: effectiveEvents.toMap,
            [if (initialValue.isNotNullAndEmpty) .text(initialValue!)],
          )
        : input(
            key: key,
            id: id,
            name: id,
            classes: hasIcon ? null : baseClass,
            styles: Styles(raw: effectiveInputStyles),
            type: type,
            disabled: disable,
            attributes: {
              'required': ?(required ? '' : null),
              'placeholder': ?placeholderText,
              'pattern': ?pattern?.value,
              'readonly': ?(readOnly ? '' : null),
              'maxlength': ?maxLength?.toString(),
              'minlength': ?minLength?.toString(),
              'min': ?minValueAllowed?.toCleanString,
              'max': ?maxValueAllowed?.toCleanString,
              'autocomplete': ?autofill?.value,
              'spellcheck': enableSpellCheck ? 'true' : 'false',
              'hvr': ?(allowHover && !hasIcon ? '' : null),
              'fcs': ?(allowFocus && !hasIcon ? '' : null),
              'autofocus': ?(autoFocus ? '' : null),
              'inputmode': ?(type == InputType.number || type == InputType.tel
                  ? 'numeric'
                  : null),
              'aria-label': ?(labelText.isNotEmpty ? labelText : null),
              ...?attributes,
            },
            value: initialValue,
            onInput: _handleInput,
            events: effectiveEvents.toMap,
          );

    if (hasIcon) {
      inputArea = .wrapElement(
        id: iconsWrapperId,
        attributes: {
          'hvr': ?(allowHover ? '' : null),
          'fcs': ?(allowFocus ? '' : null),
          'disabled': ?(disable ? '' : null),
          'has-icon': '',
        },
        child: Container(
          classes: baseClass,
          height: height,
          width: effectiveWidth,
          decoration: BoxDecoration(
            border: border,
            backgroundColor: backgroundColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ?leadingIcon,
              Expanded(child: inputArea),
              ?trailingIcon,
            ],
          ),
        ),
      );
    }

    return .element(
      tag: 'naki-textfield',
      id: '${id}__textfield',
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          Tokens.current.inputHeight.name: ?height?.cssText,
          Tokens.current.inputTextColor.name: ?inputTextStyle?.color?.value,
          Tokens.current.fieldBackgroundColor.name: ?backgroundColor?.value,
          Tokens.current.fontSizeInput.name: ?inputTextStyle?.fontSize?.cssText,
          Tokens.current.errorColor.name: ?errorStyle?.color?.value,
          Tokens.current.fontSizeError.name: ?errorStyle?.fontSize?.cssText,
          Tokens.current.fontSizeHint.name: ?helperStyle?.fontSize?.cssText,
          Tokens.current.mutedColor.name: ?helperStyle?.color?.value,
          Tokens.current.placeholderColor.name: ?placeholderColor?.value,
          Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
          Tokens.current.focusBorderColor.name: ?focusColor?.value,
          if (expand) 'width': '100%',
          ...?margin?.mProps,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(labelText, fieldId: id, style: labelStyle),

        // Helper text
        if (helperText.isNotEmpty)
          p(classes: 'naki-helper', styles: Styles(raw: helperStyle?.props), [
            .text(helperText),
          ]),

        // Input
        inputArea,
      ],
    );
  }

  static List<StyleRule> get styles => InputsStyles.textField;
}
