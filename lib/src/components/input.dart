import 'dart:async';

import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart' hide Table;

import '../framework/framework.dart';
import '../framework/inherited.dart';
import '../framework/overlay_stack.dart';
import '../models/gesture.dart';
import '../models/naki.dart';
import '../models/scrolling.dart' show TableRow;
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart' show Tokens;
import '../utilities/constants.dart';
import '../utilities/debounce.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';

import 'basics.dart';
import 'layout.dart';
import 'overlays.dart';
import 'scrolling.dart';
import 'selection.dart';

// event handlers argument types based on InputType:
//  - `bool` for checkbox and radio
//  - `double` for number and range
//  - `List<File>` for file
//  - `Color` for color
//  - `String` for others

/// Signature for callbacks that validate form field.
typedef FieldValidator<T> = String? Function(T value);

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

// /////////////////////////////////////////////////////////////////////////////
// INPUT COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Label}
/// A component that serves as a label for form fields.
///
/// It has a default bottom margin of 12px. To override or remove
/// the bottom margin, modify [TextStyle.margin] property in [style].
/// {@endtemplate}
class Label extends StatelessComponent {
  /// The displayed text.
  final String text;

  /// Unique identifier of the field that the label represents.
  final String? fieldId;

  /// Custom styles applied to the label.
  final TextStyle? style;

  /// {@macro Label}
  const Label(this.text, {super.key, this.fieldId, this.style});

  @override
  Component build(BuildContext context) {
    return .element(
      key: key,
      tag: fieldId.isNotNullAndEmpty ? 'label' : 'span',
      classes: 'naki-label',
      styles: Styles(raw: style?.props),
      attributes: {'for': ?fieldId},
      children: [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Label', [Rules.nakiLabelRules]);
}

/// {@template TextField}
/// A component for forms which supports single and multi-line input.
///
/// It can be customized with input type, helper text, label, placeholder,
/// validation pattern, auto-validation, and other useful properties.
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

  /// Function that returns an error message if the text field value is
  /// invalid, or `null` otherwise.
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

  /// Minimum numeric value allowed (applies to [InputType.number] only).
  final int? minValueAllowed;

  /// Maximum numeric value allowed
  /// (applies to [InputType.number] and [InputType.range] only).
  final int? maxValueAllowed;

  /// When `true`, the text field is required in [FormBuilder] validation.
  final bool required;

  /// When `true`, the text field will enable multi-line input.
  final bool isMultiline;

  /// Number of visible text lines when [isMultiline] is true.
  final int? visibleLines;

  /// Autofill type applied to the text field for native auto completion.
  final Autofill? autofill;

  /// When [autoValidate] is enabled and [validator] returns an error
  /// message, the text field will display validation message on
  /// typing, submitting, or when the field loses focus.
  ///
  /// [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// When `true`, the text field will auto focus.
  final bool autoFocus;

  /// When `true`, the text field will expand to fill the full
  /// width of its parent container.
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
    final effectiveWidth = expand ? null : width;

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
      if (wrapper == null || !allowFocus) return;

      if (isFocus) {
        wrapper.setAttribute('data-focused', '');
      } else {
        wrapper.removeAttribute('data-focused');
      }
    }

    final defaultEvents = InputEvents(
      onInvalid: _invalid,
      onKeyDown: _handleSubmit,
      onFocusIn: hasIcon ? (_) => _focusIconsWrapper(true) : null,
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

    if (expand) {
      inputArea = Expanded(child: inputArea);
      if (!hasIcon)
        inputArea = Row(mainAxisSize: MainAxisSize.min, children: [inputArea]);
    }

    if (hasIcon) {
      inputArea = .wrapElement(
        id: iconsWrapperId,
        classes: baseClass,
        attributes: {
          'hvr': ?(allowHover ? '' : null),
          'fcs': ?(allowFocus ? '' : null),
          'disabled': ?(disable ? '' : null),
          'has-icon': '',
        },
        child: Card.filled(
          decoration: BoxDecoration(border: border),
          height: height,
          width: effectiveWidth,
          color: backgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [?leadingIcon, inputArea, ?trailingIcon],
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
          ...?margin?.mProps,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(labelText, fieldId: id, style: labelStyle),

        // Input
        inputArea,

        // Helper text
        if (helperText.isNotEmpty)
          p(classes: 'naki-helper', styles: Styles(raw: helperStyle?.props), [
            .text(helperText),
          ]),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('TextField', [
    Rules.nakiInputRules,
    Rules.nakiFormFieldRules,
    Rules.nakiTextareaRules,
    Rules.nakiHelperRules,
    Rules.nakiErrorRules,
  ]);
}

/// {@template FormBuilder}
/// A component for building forms with validation and styling.
///
/// ### Example
/// ```dart
/// final formKey = GlobalNodeKey<HTMLFormElement>();
///
/// FormBuilder(
///   key: formKey,
///   name: 'my_form',
///   spacing: 16,
///   children: [
///     TextField(
///       id: 'field1',
///       type: InputType.text,
///       decoration: InputDecoration(labelText: 'Field 1'),
///     ),
///     TextField(
///       id: 'field2',
///       type: InputType.text,
///       decoration: InputDecoration(labelText: 'Field 2'),
///     ),
///   ],
/// );
/// ```
/// {@endtemplate}
class FormBuilder extends StatelessComponent {
  /// Unique name of the form. No other form should have the same name.
  final String? name;

  /// Children of the form (e.g., [TextField], [Button], etc).
  final List<Component> children;

  /// Additional CSS classes applied to the form.
  final String? classes;

  /// Layout direction of the form children (default: [Direction.vertical]).
  final Direction direction;

  /// Additional attributes applied to the form.
  final Map<String, String>? attributes;

  /// Space in pixels between [children] components.
  final double? spacing;

  /// If `true`, the native browser form validation is disabled when a descendant
  /// button with type `submit` is clicked allowing for more explicit control
  /// over the validation process.
  ///
  /// Otherwise, the browser blocks form submission and shows validation
  /// errors when a descendant button with type `submit` is clicked and form
  /// fields are not valid.
  final bool bypassValidation;

  /// Key used to identify and control the form.
  final GlobalNodeKey<HTMLFormElement> formKey;

  /// Called when the form is submitted (e.g. by a `submit` button or by
  /// pressing `Enter` in a field) and all fields pass validation.
  ///
  /// Unless [action] is set, the native submission is always prevented, so
  /// field values (including passwords) never end up in the page URL.
  final FutureOr<void> Function()? onSubmit;

  /// URL that processes a native form submission.
  ///
  /// When `null` (default) the form never navigates and only [onSubmit] runs.
  final String? action;

  /// HTTP method used for a native submission to [action]
  /// (default: [FormMethod.post]).
  final FormMethod method;

  /// Whether native validation is skipped (also honours the deprecated
  /// `autoValidate` flag).
  final bool _skipValidation;

  /// {@macro FormBuilder}
  FormBuilder({
    required this.formKey,
    required this.children,
    this.direction = Direction.vertical,
    this.bypassValidation = false,
    @Deprecated(
      'Use bypassValidation instead. autoValidate will be removed in 1.1.',
    )
    bool autoValidate = false,
    this.method = FormMethod.post,
    this.onSubmit,
    this.action,
    this.spacing,
    this.classes,
    this.name,
    this.attributes,
  }) : _skipValidation = bypassValidation || autoValidate,
       assert(children.isNotEmpty, 'FormBuilder must have at least one child');

  /// Validates registered fields before submission.
  void _handleSubmit(Event event) {
    final formElement = event.currentTarget as HTMLFormElement?;
    final isNative = action != null;

    if (formElement != null && !_skipValidation) {
      NakiFormFields.validateWithin(formElement);
      if (!formElement.reportValidity()) {
        event.preventDefault();
        return;
      }
    }

    if (!isNative) event.preventDefault();
    onSubmit?.call();
  }

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-form';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveSyles = {
      'flex-direction': direction == Direction.horizontal ? 'row' : 'column',
      'gap': ?spacing?.toPx,
    };

    return FormScope(
      child: form(
        key: formKey,
        name: name,
        action: action,
        method: method,
        classes: effectiveClasses,
        noValidate: _skipValidation,
        attributes: attributes,
        events: {'submit': _handleSubmit},
        styles: Styles(raw: effectiveSyles),
        children,
      ),
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('FormBuilder', [Rules.nakiFormRules]);
}

/// {@template AutoCompleteField}
/// A component with live-filtering dropdown — the user types,
/// picks from [options], and [onSelected] fires.
///
/// ### Example
/// ```dart
/// AutoCompleteField(
///   id: 'autocomplete-field',
///   options: ['Apple', 'Banana', 'Cherry', 'Date', 'Fig'],
///   onSelected: (value) {
///     print('Selected: $value');
///   },
/// )
/// ```
/// {@endtemplate}
class AutoCompleteField extends StatefulComponent {
  /// Unique identifier of the autocomplete field.
  final String? id;

  /// Initial value of the autocomplete field.
  final String? initialValue;

  /// Options to display in the autocomplete dropdown list.
  final List<String> options;

  /// Autocomplete field height.
  final Dim? height;

  /// Autocomplete field width.
  final Dim? width;

  /// Maximum height of the dropdown container.
  final Dim? dropdownMaxHeight;

  /// Background color of the dropdown container.
  final Color? dropdownBackgroundColor;

  /// Style applied to the dropdown options.
  ///
  /// Note: Only `fontSize` and `padding` are supported.
  final TextStyle? optionStyle;

  /// Function called when an option is selected.
  final ValueChanged<String> onSelected;

  /// Decoration of the autocomplete field.
  final InputDecoration? decoration;

  /// When [autoValidate] is enabled and [validator] returns an error
  /// message, the autocomplete field will display the validation message on
  /// typing, submitting, or when the autocomplete field loses focus.
  ///
  /// Note: [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// Whether the autocomplete field is required in form validation.
  final bool required;

  /// When `true`, the autocomplete field will be automatically
  /// focused after being rendered in client environment.
  final bool autoFocus;

  /// Callback that returns an error message if the autocomplete field's
  /// value is invalid, or `null` otherwise.
  final FieldValidator<String>? validator;

  /// When `true`, the autocomplete field will not accept user input.
  final bool disable;

  /// Additional CSS classes applied to the autocomplete field.
  final String? classes;

  /// {@macro AutoCompleteField}
  AutoCompleteField({
    super.key,
    required this.options,
    required this.onSelected,
    this.disable = false,
    this.autoValidate = false,
    this.required = false,
    this.autoFocus = false,
    this.id,
    this.decoration,
    this.initialValue,
    this.height,
    this.width,
    this.validator,
    this.classes,
    this.optionStyle,
    this.dropdownBackgroundColor,
    this.dropdownMaxHeight,
  }) : assert(options.isNotEmpty, 'options must have at least 1 option'),
       assert(
         !autoValidate || validator != null,
         'validator is required when autoValidate is true',
       );

  @override
  State<AutoCompleteField> createState() => _AutoCompleteFieldState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'AutoCompleteField',
    Rules.nakiAutoCompleteFieldRules,
  );
}

class _AutoCompleteFieldState extends State<AutoCompleteField>
    with NakiStatefulMixin {
  late String _id;

  final _filteredOptions = ValueNotifier<List<String>>([]);
  int? _activeOptionIndex;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'nac', id: component.id);
  }

  @override
  void dispose() {
    NakiDebounce.cancel('autocomplete_$_id');
    _filteredOptions.dispose();
    super.dispose();
  }

  /// Returns the input element node
  HTMLInputElement? get inputNode =>
      component.key is GlobalNodeKey<HTMLInputElement>
      ? (component.key as GlobalNodeKey<HTMLInputElement>).currentNode
      : document.getElementById(_id) as HTMLInputElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (component.autoFocus) inputNode?.focus();
    return null;
  }

  /// Handles typing
  void _onTyping(String value) {
    // clear the filtered options when input is empty
    if (value.isEmpty) {
      NakiDebounce.cancel('autocomplete_$_id');

      setState(() {
        _activeOptionIndex = null;
        _filteredOptions.value = [];
      });

      return;
    }

    // prevent excessive filtering
    NakiDebounce.run(
      'autocomplete_$_id',
      const Duration(milliseconds: 150),
      () {
        final filtered = component.options
            .where((o) => o.toLowerCase().contains(value.toLowerCase()))
            .toList();

        setState(() {
          if (filtered.isEmpty) _activeOptionIndex = null;
          _filteredOptions.value = filtered;
        });
      },
    );
  }

  /// Handles option selection
  void _onSelect(String value) {
    // clear filtered options
    setState(() {
      _filteredOptions.value = [];
      _activeOptionIndex = null;
    });

    // update input value
    inputNode?.value = value;

    // invoke callback
    component.onSelected.call(value);
  }

  /// Handles keyboard events
  void _handleKeyDown(KeyboardEvent event) {
    final options = _filteredOptions.value;

    if (event.key == 'Escape') {
      setState(() {
        _activeOptionIndex = null;
        _filteredOptions.value = [];
      });

      return;
    }

    if (options.isEmpty) return;

    if (event.key == 'ArrowDown' || event.key == 'ArrowUp') {
      event.preventDefault();

      final delta = event.key == 'ArrowDown' ? 1 : -1;
      final current = _activeOptionIndex ?? (delta > 0 ? -1 : 0);

      setState(() => _activeOptionIndex = (current + delta) % options.length);
      return;
    }

    if (event.key == 'Enter' && _activeOptionIndex != null) {
      event.preventDefault();
      _onSelect(options[_activeOptionIndex!]);
    }
  }

  @override
  Component build(BuildContext context) {
    // Dropdown container style properties
    final dropdownHeight = component.dropdownMaxHeight?.cssText;
    final dropdownBgColor = component.dropdownBackgroundColor?.value;

    // Options style properties
    final optionsStyle = component.optionStyle;
    final optionFontSize = optionsStyle?.fontSize?.cssText;
    final optionPadding = optionsStyle?.padding?.pProps.cssText;

    return .element(
      tag: 'naki-autocomplete',
      id: '${_id}__autocomplete',
      children: [
        // Text field
        TextField(
          key: component.key,
          id: _id,
          initialValue: component.initialValue,
          decoration: component.decoration,
          autoValidate: component.autoValidate,
          required: component.required,
          validator: component.validator,
          disable: component.disable,
          classes: component.classes,
          type: InputType.text,
          height: component.height,
          width: component.width,
          backgroundColor: component.dropdownBackgroundColor,
          attributes: {
            'role': 'combobox',
            'aria-autocomplete': 'list',
            'aria-haspopup': 'listbox',
            'aria-expanded': _filteredOptions.value.isNotEmpty.toString(),
            'aria-controls': '${_id}_options',
            if (_activeOptionIndex != null)
              'aria-activedescendant': '${_id}_option_${_activeOptionIndex!}',
          },
          events: InputEvents(onKeyDown: _handleKeyDown),
          onTyping: _onTyping,
        ),

        // Dropdown container
        _filteredOptions.rebuild((filteredOptions) {
          if (filteredOptions.isEmpty) return const .empty();

          return section(
            id: '${_id}_options',
            classes: 'naki-autocomplete-menu',
            attributes: const {'role': 'listbox'},
            styles: Styles(
              raw: {
                Tokens.current.dropdownMenuHeight.name: ?dropdownHeight,
                Tokens.current.dropdownMenuBgColor.name: ?dropdownBgColor,
                Tokens.current.dropdownOptionPadding.name: ?optionPadding,
                Tokens.current.dropdownOptionFontSize.name: ?optionFontSize,
              },
            ),
            filteredOptions.indexed
                .map(
                  (entry) => div(
                    id: '${_id}_option_${entry.$1}',
                    classes: 'naki-autocomplete-option',
                    attributes: {
                      'role': 'option',
                      'aria-selected': (_activeOptionIndex == entry.$1)
                          .toString(),
                    },
                    events: Events(onClick: (_) => _onSelect(entry.$2)).toMap,
                    [.text(entry.$2)],
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}

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

/// {@template Calendar}
/// A component that enables selection of date, time, both, or a date range
/// with built-in validation, customization and styling options.
///
/// ### Example
/// ```dart
/// Calendar(
///  id: 'calendar_1',
///  type: CalendarType.both,
///  onSelected: (date) {
///    print(date);
/// },
///  validator: (date) {
///    if (date == null) return 'Please select a date';
///    return null;
///  },
///  autoValidate: true,
///  height: Dim.px(40),
///  width: Dim.px(350),
///  decoration: InputDecoration(
///    labelText: 'Select a date',
///    helperText: 'Used for analytics and reporting only.',
///  ),
/// )
/// ```
/// {@endtemplate}
class Calendar extends StatefulComponent {
  /// Unique identifier of the calendar component.
  final String id;

  /// Calendar type (default: [CalendarType.date]).
  final CalendarType type;

  /// Initial value of the calendar based on [type].
  /// - If [type] is [CalendarType.time], [initialValue] will be used to
  /// initialize the time picker.
  /// - If [type] is [CalendarType.date], [initialValue] will be used to
  /// initialize the date picker.
  /// - If [type] is [CalendarType.both], [initialValue] will be used to
  /// initialize both the date and time pickers.
  final DateTime? initialValue;

  /// Initial date range values of the calendar.
  /// When [type] is [CalendarType.range], [initialRange] will be used to
  /// initialize the date picker.
  ///
  /// Dates can be in any order and their time is ignored. The earliest and
  /// latest dates set the range, so a `[start, end]` list and the list emitted
  /// by [onSelectedRange] are both accepted. A single date is a one-day range.
  final List<DateTime> initialRange;

  /// Text displayed in the header of the date or time picker.
  /// Overridden by `labelText` if provided in [decoration].
  final String? title;

  /// Minimum allowed date or time values for the calendar.
  final DateTime? minimum;

  /// The maximum allowed date or time values for the calendar.
  final DateTime? maximum;

  /// Callback invoked when a date or time is selected.
  /// This is not called when [type] is [CalendarType.range].
  final ValueChanged<DateTime>? onSelected;

  /// Callback invoked when a range of date is selected, with every day from
  /// the start date through the end date in ascending order.
  final ValueChanged<List<DateTime>>? onSelectedRange;

  /// Callback that returns an error message if the selected
  /// date or time is invalid, or `null` otherwise.
  ///
  /// **NOTE:** Use [rangeValidator] to validate the whole range when [type]
  /// is [CalendarType.range].
  final FieldValidator<DateTime?>? validator;

  /// Callback that returns an error message if the selected date range is
  /// invalid, or `null` otherwise.
  ///
  /// This receives every day in the range, or `null` if nothing is selected.
  /// It runs only when [type] is [CalendarType.range].
  final FieldValidator<List<DateTime>?>? rangeValidator;

  /// Whether the calendar component is read-only (default: `false`).
  ///
  /// When `true`, the calendar date or time pickers will be displayed
  /// and not interactive.
  final bool readOnly;

  /// Custom component such as text or icon, which opens and closes
  /// the calendar dialog.
  ///
  /// If not provided, a [Button.iconText] component is used.
  final Component? child;

  /// Whether the calendar component is disabled (default: `false`).
  ///
  /// When `true`, the [child] component will not be interactive.
  final bool disable;

  /// Whether the calendar component automatically gains focus
  /// after it is rendered in the client-side.
  ///
  /// When [child] is not provided and [autoFocus] is enabled, the default
  /// trigger component will be focused.
  ///
  /// This will not work if the calendar is inside a hidden
  /// component such as a dialog.
  final bool autoFocus;

  /// Whether the calendar component is required for form validation.
  final bool required;

  /// When [autoValidate] is enabled and [validator] returns an
  /// error message, the validation message will be displayed
  /// when a selection occurs or when the form is submitted.
  ///
  /// Note: [validator] or [rangeValidator] must be provided when
  /// [autoValidate] is true.
  final bool autoValidate;

  /// Calendar background color.
  final Color? backgroundColor;

  /// Width of the calendar [child]. Ignored when [child] is provided.
  final Dim? width;

  /// Height of the calendar [child]. Ignored when [child] is provided.
  final Dim? height;

  /// Decoration configuration for placeholder, label, helper text,
  /// error text, and the default calendar trigger.
  final InputDecoration? decoration;

  /// Additional CSS classes applied to the calendar component.
  final String? classes;

  /// {@macro Calendar}
  Calendar({
    super.key,
    required this.id,
    required this.type,
    this.readOnly = false,
    this.disable = false,
    this.autoFocus = false,
    this.required = false,
    this.autoValidate = false,
    this.initialRange = const [],
    this.onSelected,
    this.onSelectedRange,
    this.child,
    this.initialValue,
    this.title,
    this.validator,
    this.rangeValidator,
    this.decoration,
    this.classes,
    this.backgroundColor,
    this.width,
    this.height,
    this.minimum,
    this.maximum,
  }) : assert(id != '', 'id must not be empty'),
       assert(
         minimum == null || maximum == null || !minimum.isAfter(maximum),
         'minimum must not be after maximum',
       ),
       assert(
         initialValue == null ||
             minimum == null ||
             !initialValue.isBefore(minimum),
         'initialValue must not be before minimum',
       ),
       assert(
         initialValue == null ||
             maximum == null ||
             !initialValue.isAfter(maximum),
         'initialValue must not be after maximum',
       ),
       assert(
         minimum == null ||
             !initialRange.any((date) => date.isBeforeDay(minimum)),
         'initialRange must not be before minimum',
       ),
       assert(
         maximum == null ||
             !initialRange.any((date) => maximum.isBeforeDay(date)),
         'initialRange must not be after maximum',
       ),
       assert(
         !autoValidate || validator != null || rangeValidator != null,
         'validator or rangeValidator is required when autoValidate is true',
       );

  @override
  State<Calendar> createState() => _CalendarState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Calendar', [
    ...Rules.nakiCalendarRules,
    Rules.nakiFormFieldRules,
    Rules.nakiHelperRules,
    Rules.nakiErrorRules,
  ]);
}

class _CalendarState extends State<Calendar> with NakiStatefulMixin {
  late DateTime _visibleDate, _minDate, _maxDate;

  final _dialogKey = GlobalNodeKey<HTMLElement>();
  late final String _calendarId = nakiDomId(context, 'ncp', id: component.id);

  bool _pickTime = false;
  bool _pickDate = false;
  bool _showYear = false;

  List<DateTime> _selectedDates = [];
  List<DateTime> _committedDates = [];

  Duration? _selectedTime;
  Duration? _committedTime;

  List<int> _years = [];
  bool _requestedOpen = false;
  bool _skipFocusRestore = false;

  HTMLElement? _previousFocus;
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;
  StreamSubscription<Event>? _resizeSubscription;
  String? _triggerText;

  static _CalendarState? _openCalendar;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _initCalendar();
  }

  @override
  void didUpdateComponent(Calendar oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.type != component.type ||
        oldComponent.initialValue != component.initialValue ||
        !_listEquals(oldComponent.initialRange, component.initialRange) ||
        oldComponent.minimum != component.minimum ||
        oldComponent.maximum != component.maximum) {
      _initCalendar();
    }
  }

  /// Returns the calendar element node
  HTMLElement? get calendarNode => component.key is GlobalNodeKey<HTMLElement>
      ? (component.key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById('${_calendarId}__calendar') as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (component.autoFocus && component.child == null) {
      final triggerId = '${_calendarId}_default_trigger';
      (document.getElementById(triggerId) as HTMLButtonElement?)?.focus();
    }

    // listener that checks if an outside click occurred
    final clickSubscription = EventStreamProviders.clickEvent
        .forTarget(window)
        .listen((event) {
          if (!_pickTime && !_pickDate) return;

          final target = event.target as Node?;
          if (target == null) return;

          // ignore targets that were unmounted during click handling
          if (!target.isConnected) return;

          // ignore clicks inside the calendar
          if (calendarNode != null && calendarNode!.contains(target)) return;

          // if dropdown menu is open, let dropdown handle closing
          final dropdownMenu =
              calendarNode?.querySelector('naki-dropdown[open]')
                  as HTMLElement? ??
              document.querySelector('naki-dropdown[open]') as HTMLElement?;

          if (dropdownMenu != null) return;

          if (_showYear) {
            setState(() => _showYear = false);
            return;
          }

          if (_isRange) {
            _dismissPicker();
            return;
          }

          setState(() {
            _pickTime = false;
            _pickDate = false;
          });
        });

    return clickSubscription.cancel;
  }

  /// Initializes the calendar
  void _initCalendar() {
    final now = DateTime.now();
    final type = component.type;
    final initialDates = _initialDates;

    _pickTime = false;
    _pickDate = false;
    _showYear = false;

    _visibleDate = initialDates.firstOrNull ?? now;
    _selectedDates = initialDates;

    if (type == CalendarType.time) {
      _selectedDates = [now];
      _selectedTime = Duration(
        hours: _visibleDate.hour,
        minutes: _visibleDate.minute,
      );
    }

    if (type == CalendarType.both) {
      _selectedTime = Duration(
        hours: _visibleDate.hour,
        minutes: _visibleDate.minute,
      );
    }

    _minDate =
        component.minimum ??
        _visibleDate.subtract(const Duration(days: 100 * 365));
    _maxDate =
        component.maximum ??
        (initialDates.lastOrNull ?? _visibleDate).add(
          const Duration(days: 10 * 365),
        );

    final minYear = _minDate.year;
    final maxYear = _maxDate.year;
    final count = maxYear >= minYear ? (maxYear - minYear) + 1 : 0;

    _years = List.generate(count, (i) => minYear + i);
    _committedDates = [..._selectedDates];
    _committedTime = _selectedTime;

    _updateTriggerText();
  }

  bool get _isRange => component.type == CalendarType.range;

  /// Whether a range has a start date but no end date yet.
  ///
  /// [_selectedDates] holds `[start]` until a range is complete, then
  /// `[start, end]`, which are the same date for a one-day range.
  bool get _isRangePending => _isRange && _selectedDates.length == 1;

  /// Whether a complete range spans more than one day.
  bool get _isMultiDayRange =>
      _isRange &&
      _selectedDates.length == 2 &&
      _selectedDates.first != _selectedDates.last;

  /// Dates the calendar starts with and resets to.
  List<DateTime> get _initialDates {
    if (!_isRange) return [?component.initialValue];

    final dates = [for (final date in component.initialRange) _dateOnly(date)]
      ..sort();

    return dates.isEmpty ? [] : [dates.first, dates.last];
  }

  /// Every day in the selected range, in ascending order
  List<DateTime> get _rangeDays =>
      _selectedDates.first.daysThrough(_selectedDates.last);

  /// Whether to validate the input (when autoValidate or required is true)
  bool get _shouldValidate => component.autoValidate || component.required;

  void _updateTriggerText() {
    if (currentValue != null && component.child == null) {
      _triggerText = _displayedValue(currentValue!);
    }
  }

  /// Builds the calendar month component
  CalendarMonth _buildCalendarMonth(DateTime date) {
    final first = DateTime(date.year, date.month, 1);
    final days = DateTime(date.year, date.month + 1, 0).day;

    final daysInMonth = [
      // leading nulls to align with the first day of the week, Monday
      for (var i = 1; i < first.weekday; i++) null,

      // days of the month
      for (var day = 1; day <= days; day++)
        CalendarDay(
          date: DateTime(date.year, date.month, day),
          isSelected: _isSelected(DateTime(date.year, date.month, day)),
          isToday: DateTime(date.year, date.month, day).isToday,
          isDisabled: _isOutsideBounds(DateTime(date.year, date.month, day)),
        ),
    ];

    return CalendarMonth(date: date, days: daysInMonth);
  }

  bool _isSelected(DateTime date) {
    if (!_isRange || _selectedDates.length < 2) {
      return _selectedDates.contains(date);
    }

    return !date.isBefore(_selectedDates.first) &&
        !date.isAfter(_selectedDates.last);
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  bool _isOutsideBounds(DateTime value) {
    final date = _dateOnly(value);
    return date.isBefore(_dateOnly(_minDate)) ||
        date.isAfter(_dateOnly(_maxDate));
  }

  void _togglePicker() {
    if (component.disable) return;

    if (!_pickDate && !_pickTime) {
      // close any other open calendar
      final other = _openCalendar;
      if (other != null && !identical(other, this) && other.mounted) {
        other._dismissPicker(restoreFocus: false);
      }

      _openCalendar = this;
      _committedDates = [..._selectedDates];
      _committedTime = _selectedTime;
    } else if (_isRange) {
      _dismissPicker();
      return;
    }

    setState(() {
      if (component.type == CalendarType.time) {
        _pickTime = !_pickTime;
        _pickDate = false;
      } else {
        _pickDate = !_pickDate;
        _pickTime = false;
      }
    });
  }

  void _syncDialogAccessibility(bool open) {
    if (_requestedOpen == open) return;
    _requestedOpen = open;

    onComponentRendered(() {
      if (!mounted) return;

      if (open) {
        _activateDialog();
      } else {
        _deactivateDialog(restoreFocus: !_skipFocusRestore);
        _skipFocusRestore = false;
      }
    });
  }

  /// Closes the picker and discards any uncommitted selection.
  void _dismissPicker({bool restoreFocus = true}) {
    if (!_pickDate && !_pickTime) return;

    _skipFocusRestore = !restoreFocus;

    setState(() {
      _selectedDates = [..._committedDates];
      _selectedTime = _committedTime;
      _pickDate = false;
      _pickTime = false;
      _showYear = false;
    });
  }

  /// Keeps the open picker inside the viewport: shifts it horizontally away
  /// from the screen edges, flips it above the trigger when there is more
  /// room there, and caps its height (it scrolls) when neither side fits.
  void _positionModal() {
    final modal = _dialogKey.currentNode;
    final anchor = modal?.parentElement;
    if (modal == null || anchor == null) return;

    final style = modal.style;
    const tokens = Tokens.current;
    final vars = [
      tokens.calendarTop.name,
      tokens.calendarBottom.name,
      tokens.calendarGap.name,
      tokens.calendarShiftX.name,
      tokens.calendarMaxHeight.name,
    ];

    // measure from the default placement
    for (final name in vars) style.removeProperty(name);

    const margin = 8.0;
    const gap = 10.0;

    final viewportWidth =
        (document.documentElement?.clientWidth ?? window.innerWidth).toDouble();
    final viewportHeight = window.innerHeight.toDouble();

    final anchorRect = anchor.getBoundingClientRect();
    final height = modal.getBoundingClientRect().height.toDouble();

    // vertical placement
    final spaceBelow = viewportHeight - anchorRect.bottom - gap - margin;
    final spaceAbove = anchorRect.top - gap - margin;
    final placeAbove = height > spaceBelow && spaceAbove > spaceBelow;

    if (placeAbove) {
      style
        ..setProperty(tokens.calendarTop.name, 'auto')
        ..setProperty(tokens.calendarBottom.name, '100%')
        ..setProperty(tokens.calendarGap.name, '-${gap}px');
    }

    final available = placeAbove ? spaceAbove : spaceBelow;
    if (height > available) {
      final maxHeight = available < 160 ? 160 : available;
      style.setProperty(tokens.calendarMaxHeight.name, '${maxHeight}px');
    }

    // horizontal placement
    final rect = modal.getBoundingClientRect();
    var shift = 0.0;

    if (rect.width > viewportWidth - 2 * margin) {
      shift = margin - rect.left;
    } else if (rect.left < margin) {
      shift = margin - rect.left;
    } else if (rect.right > viewportWidth - margin) {
      shift = viewportWidth - margin - rect.right;
    }

    if (shift != 0) {
      style.setProperty(tokens.calendarShiftX.name, '${shift}px');
    }
  }

  List<HTMLElement> _focusableElements(HTMLElement surface) {
    final nodes = surface.querySelectorAll(
      'button:not([disabled]), input:not([disabled]), '
      '[tabindex]:not([tabindex="-1"])',
    );

    return [
      for (var index = 0; index < nodes.length; index++)
        nodes.item(index) as HTMLElement,
    ];
  }

  void _activateDialog() {
    final surface = _dialogKey.currentNode;
    if (surface == null) return;

    _previousFocus = document.activeElement as HTMLElement?;

    final initialFocus =
        surface.querySelector(
              '.naki-calendar-date[tabindex="0"], button:not([disabled]), '
              'input:not([disabled])',
            )
            as HTMLElement?;

    (initialFocus ?? surface).focus();
    _keyboardSubscription?.cancel();

    NakiOverlayStack.push(this);

    // keep the picker on screen when the viewport changes
    _resizeSubscription?.cancel();
    _resizeSubscription = EventStreamProviders.resizeEvent
        .forTarget(window)
        .listen((_) => _positionModal());

    _keyboardSubscription = EventStreamProviders.keyDownEvent
        .forTarget(document)
        .listen((event) => _handleDialogKeyDown(event, surface));
  }

  void _handleDialogKeyDown(KeyboardEvent event, HTMLElement surface) {
    // a picker inside another overlay only reacts while it is top-most
    if (!NakiOverlayStack.isTop(this)) return;

    if (event.key == 'Escape') {
      event.preventDefault();
      event.stopPropagation();
      _dismissPicker();
      return;
    }

    final target = event.target as HTMLElement?;
    if (target != null && target.classList.contains('naki-calendar-date')) {
      final delta = switch (event.key) {
        'ArrowLeft' => -1,
        'ArrowRight' => 1,
        'ArrowUp' => -7,
        'ArrowDown' => 7,
        _ => 0,
      };

      if (delta != 0) {
        final nodes = surface.querySelectorAll(
          '.naki-calendar-date:not([disabled])',
        );

        final dates = [
          for (var index = 0; index < nodes.length; index++)
            nodes.item(index) as HTMLElement,
        ];

        final current = dates.indexOf(target);

        if (current != -1 && dates.isNotEmpty) {
          event.preventDefault();

          dates[(current + delta).clamp(0, dates.length - 1)].focus();
        }
        return;
      }
    }

    if (event.key != 'Tab') return;

    final focusable = _focusableElements(surface);
    if (focusable.isEmpty) {
      event.preventDefault();
      surface.focus();
      return;
    }

    final active = document.activeElement;

    if (event.shiftKey &&
        (active == focusable.first || !surface.contains(active))) {
      event.preventDefault();
      focusable.last.focus();
    } else if (!event.shiftKey &&
        (active == focusable.last || !surface.contains(active))) {
      event.preventDefault();
      focusable.first.focus();
    }
  }

  void _deactivateDialog({bool restoreFocus = true}) {
    NakiOverlayStack.remove(this);

    if (identical(_openCalendar, this)) _openCalendar = null;

    _resizeSubscription?.cancel();
    _resizeSubscription = null;
    _keyboardSubscription?.cancel();
    _keyboardSubscription = null;

    if (restoreFocus) _previousFocus?.focus();

    _previousFocus = null;
    _requestedOpen = false;
  }

  /// Converts [CalendarType] to [InputType]
  InputType get inputType => switch (component.type) {
    CalendarType.date => InputType.date,
    CalendarType.time => InputType.time,
    CalendarType.range => InputType.date,
    CalendarType.both => InputType.dateTimeLocal,
  };

  /// Current value of the calendar picker
  DateTime? get currentValue {
    if (_selectedDates.isEmpty) return null;
    if (_selectedTime == null) return _selectedDates.first;

    return _selectedDates.first.copyWith(
      hour: _selectedTime!.inHours,
      minute: _selectedTime!.inMinutes % 60,
      second: 0,
    );
  }

  /// String representation of date/time based on picker type
  String _displayedValue(DateTime value) => switch (component.type) {
    CalendarType.date => value.toDdMmmYyyy,
    CalendarType.time => value.toFullTimeAmPm,
    CalendarType.range => value.asRange(_selectedDates.last),
    CalendarType.both => value.toDateAndTimeWithSlashes,
  };

  /// Native HTML value format for the configured calendar type
  String _inputValue(DateTime value) {
    String twoDigits(int part) => part.toString().padLeft(2, '0');

    final date =
        '${value.year.toString().padLeft(4, '0')}-'
        '${twoDigits(value.month)}-${twoDigits(value.day)}';

    final time =
        '${twoDigits(value.hour)}:${twoDigits(value.minute)}:'
        '${twoDigits(value.second)}';

    return switch (component.type) {
      CalendarType.date => date,
      CalendarType.range => date,
      CalendarType.time => time,
      CalendarType.both => '${date}T$time',
    };
  }

  /// Updates displayed value and optionally closes the calendar
  void _updateValue({bool close = false}) {
    if (component.disable || component.readOnly) return;

    final date = currentValue;
    if (date == null) return;

    final inputElem = document.getElementById(_calendarId) as HTMLInputElement?;
    inputElem?.value = _inputValue(date);

    if (close) {
      _committedDates = [..._selectedDates];
      _committedTime = _selectedTime;

      _showError();

      if (_isRange) {
        component.onSelectedRange?.call(_rangeDays);
      } else {
        component.onSelected?.call(date);
      }

      setState(() {
        _updateTriggerText();
        _pickDate = false;
        _pickTime = false;
      });
    }
  }

  /// Shows custom validation message
  void _showError() {
    final rangeValidator = _isRange ? component.rangeValidator : null;
    final baseValidator = !_isRange ? component.validator : null;

    if (kIsWeb &&
        (baseValidator != null ||
            rangeValidator != null ||
            component.required)) {
      final error = component.required && currentValue == null
          ? 'This field is required'
          : rangeValidator?.call(currentValue == null ? null : _rangeDays) ??
                baseValidator?.call(currentValue) ??
                '';

      // show custom validation message if enabled
      if (_shouldValidate) {
        showValidationError(_calendarId, error, isCalendar: true);
      }

      // set browser-default validity
      final inputElem =
          document.querySelector('input[name="${component.id}"]')
              as HTMLInputElement?;
      final rangeInputElem =
          document.querySelector('input[name="${component.id}_end"]')
              as HTMLInputElement?;

      inputElem?.setCustomValidity(error);
      rangeInputElem?.setCustomValidity(error);
    }
  }

  /// Handles invalid event when parent form is submitted
  void _invalid(Event event) {
    if (kIsWeb && _shouldValidate) {
      event.preventDefault();
      _showError();
    }
  }

  /// Toggles between months
  void _toggleMonth([bool next = false]) {
    if (_years.isEmpty) return;

    final currentMonth = _visibleDate.month;
    final currentYear = _visibleDate.year;

    if (next) {
      // Move to next month, respecting max date boundary
      if (currentYear == _maxDate.year && currentMonth == _maxDate.month) {
        return;
      }
      setState(() {
        _visibleDate = DateTime(currentYear, currentMonth + 1);
      });
    } else {
      // Move to previous month, respecting min date boundary
      if (currentYear == _minDate.year && currentMonth == _minDate.month) {
        return;
      }
      setState(() {
        _visibleDate = DateTime(currentYear, currentMonth - 1);
      });
    }
  }

  /// Resets to current month view, based on selected value
  void _jumpToMonth(DateTime date) => setState(() {
    _visibleDate = DateTime(date.year, date.month, 1);
    _showYear = false;
  });

  /// Adds or removes date from the selected dates
  void _updateSelection(DateTime date) {
    if (component.readOnly || component.disable) return;

    final extendsRange =
        _isRangePending && !date.isBefore(_selectedDates.first);

    setState(() {
      _selectedDates = extendsRange ? [_selectedDates.first, date] : [date];
    });
  }

  /// Resets selected dates to initial value
  void _resetSelection() => _selectedDates = _initialDates;

  @override
  void dispose() {
    _deactivateDialog(restoreFocus: false);
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final backgroundColor = component.backgroundColor;
    final decoration = component.decoration;

    final labelText = decoration?.labelText ?? '';
    final placeholderText = decoration?.placeholderText ?? '';
    final helperText = decoration?.helperText ?? '';
    final titleText = decoration?.labelText ?? component.title ?? '';

    final hoverColor = decoration?.hoverBorderColor;
    final focusColor = decoration?.focusBorderColor;

    final errorStyle = decoration?.errorStyle;
    final helperStyle = decoration?.helperStyle;
    final labelStyle = decoration?.labelStyle;

    final allowHover =
        hoverColor != null && !component.disable && !component.readOnly;
    final allowFocus =
        focusColor != null && !component.disable && !component.readOnly;

    final effectiveClasses = joinClasses([?component.classes, 'naki-calendar']);

    final currentMonth = _visibleDate.month;
    final currentYear = _visibleDate.year;

    final showDatePickerOnly = inputType == InputType.date;
    final showBoth = inputType == InputType.dateTimeLocal;
    final pickerOpen = _pickDate || _pickTime;

    final triggerContent = _triggerText != null
        ? _triggerText!
        : placeholderText.isNotEmpty
        ? placeholderText
        : _isRange
        ? 'Select date range'
        : showBoth
        ? 'Select date and time'
        : showDatePickerOnly
        ? 'Select date'
        : 'Select time';

    _syncDialogAccessibility(pickerOpen);

    // re-measure after every render while open
    if (pickerOpen) {
      onComponentRendered(() {
        if (mounted) _positionModal();
      });
    }

    final daysInMonth = _buildCalendarMonth(_visibleDate).days;

    final triggerIcon = showDatePickerOnly || showBoth
        ? LucideIcons.icon_calendar
        : LucideIcons.icon_clock;

    final defaultPickerName = _isRange ? 'date range' : 'date and time';
    final triggerLabel = labelText.isNotEmpty
        ? '${pickerOpen ? 'Close' : 'Open'} $labelText picker'
        : '${pickerOpen ? 'Close' : 'Open'} $defaultPickerName picker';

    final triggerAttributes = {
      'aria-haspopup': 'dialog',
      'aria-expanded': '$pickerOpen',
      'aria-controls': '${_calendarId}_dialog',
      'aria-label': triggerLabel,
    };

    final Component effectiveChild = component.child == null
        ? Button.iconText(
            id: '${_calendarId}_default_trigger',
            classes: 'default_trigger',
            text: triggerContent,
            icon: triggerIcon,
            iconSize: 16,
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            width: component.width,
            height: component.height ?? const Dim.px(48),
            border: decoration?.border,
            padding: decoration?.padding,
            textStyle: decoration?.inputStyle,
            backgroundColor: context.fieldBackgroundColor,
            foregroundColor: context.inputTextColor,
            disabled: component.disable,
            attributes: triggerAttributes,
            onTap: _togglePicker,
          )
        : div(
            attributes: triggerAttributes,
            styles: const Styles(raw: {'cursor': 'pointer'}),
            events: events(onClick: _togglePicker),
            [component.child!],
          );

    return .element(
      key: component.key,
      tag: 'naki-calendar',
      id: '${_calendarId}__calendar',
      classes: 'naki-form-field',
      styles: Styles(
        raw: {
          Tokens.current.errorColor.name: ?errorStyle?.color?.value,
          Tokens.current.fontSizeError.name: ?errorStyle?.fontSize?.cssText,
          Tokens.current.fontSizeHint.name: ?helperStyle?.fontSize?.cssText,
          Tokens.current.mutedColor.name: ?helperStyle?.color?.value,
          Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
          Tokens.current.focusBorderColor.name: ?focusColor?.value,
          Tokens.current.dropdownMenuBgColor.name: ?backgroundColor?.value,
          ...?decoration?.margin?.mProps,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(labelText, fieldId: _calendarId, style: labelStyle),

        // Main
        span(
          classes: effectiveClasses,
          attributes: {'data-type': component.type.name},
          [
            // Input for form validation (hidden)
            input(
              name: component.id,
              type: inputType,
              value: currentValue != null ? _inputValue(currentValue!) : null,
              attributes: {
                'required': ?(component.required ? '' : null),
                'tabindex': '-1',
                'aria-hidden': 'true',
              },
              events: InputEvents(onInvalid: _invalid).toMap,
            ),

            // Range end date for form submission (hidden)
            if (_isRange)
              input(
                name: '${component.id}_end',
                type: inputType,
                value: currentValue != null
                    ? _inputValue(_selectedDates.last)
                    : null,
                attributes: {
                  'tabindex': '-1',
                  'aria-hidden': 'true',
                  'required': ?(component.required ? '' : null),
                },
                events: InputEvents(onInvalid: _invalid).toMap,
              ),

            // Trigger (opens/closes modal)
            .wrapElement(
              classes: 'naki-calendar-trigger',
              attributes: {
                'novalue': ?(currentValue == null ? '' : null),
                'selected': ?(currentValue != null ? '' : null),
                'disabled': ?(component.disable ? '' : null),
                'hvr': ?(allowHover ? '' : null),
                'fcs': ?(allowFocus ? '' : null),
              },
              child: effectiveChild,
            ),

            // Modal
            if (pickerOpen)
              ScrollBarWrapper(
                selector: '#${_calendarId}_dialog',
                configuration: ScrollBarConfiguration(
                  thumbColor: context.primaryColor.withOpacity(0.4),
                  trackColor: Colors.transparent,
                  radius: 4,
                  width: 2,
                ),
                child: span(
                  key: _dialogKey,
                  id: '${_calendarId}_dialog',
                  classes: 'naki-calendar-modal',
                  attributes: {
                    'role': 'dialog',
                    'aria-modal': 'true',
                    'aria-label': labelText.isNotEmpty
                        ? '$labelText picker'
                        : _isRange
                        ? 'Date range picker'
                        : 'Date and time picker',
                    'tabindex': '-1',
                  },
                  [
                    // Date picker
                    if (_pickDate)
                      Column(
                        classes: 'naki-date-picker',
                        spacing: 12,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // title
                          Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: NakiText(
                                  titleText.isNotEmpty
                                      ? titleText
                                      : _isRange
                                      ? 'Select date range'
                                      : 'Select date',
                                  classes: 'naki-calendar-title',
                                  style: const TextStyle(truncate: true),
                                ),
                              ),

                              if (currentValue != null)
                                NakiText(
                                  _displayedValue(currentValue!),
                                  classes: 'naki-calendar-picker-preview',
                                  style: _isRange
                                      ? null
                                      : const TextStyle(fontSize: Dim.px(14)),
                                ),
                            ],
                          ),

                          // header
                          Row(
                            classes: 'naki-calendar-header',
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            spacing: 5,
                            children: [
                              // goto previous month
                              Button.icon(
                                MaterialSymbols.round_chevron_left,
                                semanticLabel: 'Previous month',
                                classes: 'naki-calendar-header-action',
                                disabled:
                                    currentYear == _minDate.year &&
                                    currentMonth == _minDate.month,
                                height: const Dim.px(40),
                                width: const Dim.px(40),
                                backgroundColor: Colors.transparent,
                                foregroundColor: context.textColor,
                                disabledBackgroundColor: Colors.transparent,
                                onTap: () => _toggleMonth(),
                              ),

                              // visible month and year
                              Popover(
                                visible: _showYear,
                                child: Button.iconText(
                                  icon:
                                      MaterialIcons.icon_round_arrow_drop_down,
                                  text: _visibleDate.toMonthYear,
                                  classes: 'naki-calendar-header-title',
                                  height: const Dim.px(40),
                                  iconSize: 28,
                                  foregroundColor: context.placeholderColor,
                                  backgroundColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  attributes: {
                                    'showyear': ?(_showYear ? '' : null),
                                  },
                                  onTap: () =>
                                      setState(() => _showYear = !_showYear),
                                ),
                                content: _showYear
                                    ? _yearMonthPopover()
                                    : const .empty(),
                                onClose: () {
                                  final dropdownMenu =
                                      calendarNode?.querySelector(
                                            'naki-dropdown[open]',
                                          )
                                          as HTMLElement? ??
                                      document.querySelector(
                                            'naki-dropdown[open]',
                                          )
                                          as HTMLElement?;
                                  if (dropdownMenu != null) return;
                                  setState(() => _showYear = false);
                                },
                                position: PopoverPosition.bottom,
                              ),

                              // goto next month
                              Button.icon(
                                MaterialSymbols.round_chevron_right,
                                semanticLabel: 'Next month',
                                classes: 'naki-calendar-header-action',
                                disabled:
                                    currentYear == _maxDate.year &&
                                    currentMonth == _maxDate.month,
                                height: const Dim.px(40),
                                width: const Dim.px(40),
                                backgroundColor: Colors.transparent,
                                foregroundColor: context.textColor,
                                disabledBackgroundColor: Colors.transparent,
                                onTap: () => _toggleMonth(true),
                              ),
                            ],
                          ),

                          // days in the month
                          Table(
                            classes: 'naki-calendar-table',
                            headers: [
                              for (final day in kDays)
                                NakiText(
                                  day,
                                  classes: 'naki-calendar-table-header',
                                  style: TextStyle(
                                    color: context.placeholderColor,
                                  ),
                                ),
                            ],
                            rows: _buildCalendarRows(
                              daysInMonth: daysInMonth,
                              showBoth: showBoth,
                            ),
                          ),

                          // footer buttons
                          Row(
                            classes: 'naki-calendar-footer',
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              showBoth
                                  ? Button.text(
                                      _timePreview(),
                                      classes: 'naki-calendar-action',
                                      foregroundColor: context.textColor,
                                      backgroundColor: Colors.transparent,
                                      border: BorderData(
                                        color: context.primaryColor,
                                        radius: BorderRadiusData.all(
                                          const Dim.px(8),
                                        ),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          _pickTime = true;
                                          _pickDate = false;
                                          if (_selectedDates.isEmpty)
                                            _selectedDates = [_visibleDate];
                                        });
                                      },
                                    )
                                  : Button.text(
                                      'Reset',
                                      classes: 'naki-calendar-action',
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: context.subtitleColor,
                                      onTap: () {
                                        if (component.disable ||
                                            component.readOnly) {
                                          return;
                                        }

                                        _resetSelection();

                                        _visibleDate =
                                            currentValue ?? DateTime.now();

                                        if (currentValue != null && showBoth) {
                                          _selectedTime = Duration(
                                            hours: currentValue!.hour,
                                            minutes: currentValue!.minute,
                                          );
                                        }

                                        setState(() {});
                                        _updateValue();
                                      },
                                    ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // cancel date picker
                                  Button.text(
                                    'Cancel',
                                    classes: 'naki-calendar-action',
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: context.textColor,
                                    onTap: () {
                                      setState(() {
                                        _selectedDates = [..._committedDates];
                                        _selectedTime = _committedTime;
                                        _visibleDate =
                                            currentValue ?? DateTime.now();
                                        _pickDate = false;
                                        _pickTime = false;
                                      });
                                    },
                                  ),

                                  // submit date
                                  Button.text(
                                    'Ok',
                                    classes: 'naki-calendar-action',
                                    disabled:
                                        _selectedDates.isEmpty ||
                                        _isRangePending,
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    foregroundColor: context.primaryColor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onTap: () => _updateValue(close: true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                    // Time picker
                    if (_pickTime)
                      Column(
                        classes: 'naki-time-picker',
                        spacing: 12,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // header
                          Row(
                            classes: 'naki-calendar-header',
                            spacing: 10,
                            children: [
                              Expanded(
                                child: NakiText(
                                  titleText.isNotEmpty
                                      ? titleText
                                      : 'Select time',
                                  classes: 'naki-calendar-title',
                                  style: const TextStyle(truncate: true),
                                ),
                              ),

                              NakiText(
                                _timePreview(),
                                classes: 'naki-calendar-picker-preview',
                                style: const TextStyle(fontSize: Dim.px(14)),
                              ),
                            ],
                          ),

                          // steppers
                          Row(
                            spacing: 6,
                            classes: 'naki-time-picker-steppers',
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTimeStepper(id: _calendarId, hour: true),
                              const NakiText(
                                ':',
                                classes: 'naki-time-separator',
                              ),
                              _buildTimeStepper(id: _calendarId, hour: false),
                            ],
                          ),

                          // footer actions
                          Row(
                            classes: 'naki-calendar-footer',
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // reset to initial time
                              Button.text(
                                'Reset',
                                classes: 'naki-calendar-action',
                                backgroundColor: Colors.transparent,
                                foregroundColor: context.subtitleColor,
                                onTap: () {
                                  if (component.disable || component.readOnly) {
                                    return;
                                  }

                                  final date = currentValue ?? DateTime.now();
                                  _selectedTime = Duration(
                                    hours: date.hour,
                                    minutes: date.minute,
                                  );

                                  setState(() {});
                                  _updateValue();
                                },
                              ),

                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // cancel time picker
                                  Button.text(
                                    'Cancel',
                                    classes: 'naki-calendar-action',
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: context.textColor,
                                    onTap: () {
                                      setState(() {
                                        _selectedTime = _committedTime;
                                        _pickTime = false;
                                        if (showBoth) {
                                          _pickDate = true;
                                        } else {
                                          _selectedDates = [..._committedDates];
                                        }
                                      });
                                    },
                                  ),

                                  // submit time
                                  Button.text(
                                    'Ok',
                                    classes: 'naki-calendar-action',
                                    disabled: _selectedTime == null,
                                    backgroundColor: Colors.transparent,
                                    disabledBackgroundColor: Colors.transparent,
                                    foregroundColor: context.primaryColor,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onTap: () => _updateValue(close: true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
          ],
        ),

        // Helper
        if (helperText.isNotEmpty)
          p(classes: 'naki-helper', styles: Styles(raw: helperStyle?.props), [
            .text(helperText),
          ]),
      ],
    );
  }

  /// 12-hour preview of the selected time, e.g. `1:27 PM`
  String _timePreview() {
    final now = DateTime.now();
    final time =
        _selectedTime ?? Duration(hours: now.hour, minutes: now.minute);

    final hr = time.inHours % 24;
    final mins = (time.inMinutes % 60).toString().padLeft(2, '0');
    final displayHr = hr % 12 == 0 ? 12 : hr % 12;

    return '$displayHr:$mins ${hr < 12 ? 'AM' : 'PM'}';
  }

  /// Accessible label of a date cell, e.g. `Fri June 12, 2026, range start`
  String _dayLabel(CalendarDay day) {
    final label = day.date.toDayMonthYear;
    if (!_isMultiDayRange) return label;

    if (day.date == _selectedDates.first) return '$label, range start';
    if (day.date == _selectedDates.last) return '$label, range end';
    return label;
  }

  List<TableRow> _buildCalendarRows({
    required List<CalendarDay?> daysInMonth,
    bool showBoth = false,
  }) {
    final rows = <TableRow>[];
    final selectableDays = daysInMonth.whereType<CalendarDay>().where(
      (day) => !day.isDisabled,
    );

    final focusDay =
        selectableDays.where((day) => day.isSelected).firstOrNull ??
        selectableDays.where((day) => day.isToday).firstOrNull ??
        selectableDays.firstOrNull;

    final remainder = daysInMonth.length % 7;
    final paddedDays = [
      ...daysInMonth,
      if (remainder > 0) ...List.filled(7 - remainder, null),
    ];

    for (int i = 0; i < paddedDays.length; i += 7) {
      final rowDays = paddedDays.sublist(i, i + 7);
      final cells = rowDays
          .map(
            (day) => day == null
                ? const Component.empty()
                : Button.text(
                    '${day.date.day}',
                    id: '${_calendarId}_day_${day.date.year}_${day.date.month}_${day.date.day}',
                    classes: 'naki-calendar-date',
                    backgroundColor: Colors.transparent,
                    foregroundColor: context.textColor,
                    disabled: day.isDisabled,
                    attributes: {
                      'aria-label': _dayLabel(day),
                      'aria-pressed': '${day.isSelected}',
                      'aria-current': ?(day.isToday ? 'date' : null),
                      'tabindex': identical(day, focusDay) ? '0' : '-1',
                      'data-today': ?(day.isToday ? '' : null),
                      'data-in-range': ?(_isMultiDayRange && day.isSelected
                          ? ''
                          : null),
                      'data-range-start':
                          ?(_isMultiDayRange && day.date == _selectedDates.first
                          ? ''
                          : null),
                      'data-range-end':
                          ?(_isMultiDayRange && day.date == _selectedDates.last
                          ? ''
                          : null),
                    },
                    onTap: () => _updateSelection(day.date),
                  ),
          )
          .toList();

      rows.add(TableRow(children: cells, classes: 'naki-calendar-week'));
    }

    return rows;
  }

  Component _buildTimeStepper({required String id, required bool hour}) {
    final now = DateTime.now();
    final time =
        _selectedTime ?? Duration(hours: now.hour, minutes: now.minute);

    final hrInputElem =
        document.getElementById('naki-stepper-$id-hr') as HTMLInputElement?;
    final minsInputElem =
        document.getElementById('naki-stepper-$id-mins') as HTMLInputElement?;

    int _hr = time.inHours % 24;
    int _mins = time.inMinutes % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    void _updateTime() =>
        setState(() => _selectedTime = Duration(hours: _hr, minutes: _mins));

    void _updateMinsInputValue(int value) =>
        minsInputElem?.value = twoDigits(value);

    void _updateHrInputValue(int value) =>
        hrInputElem?.value = twoDigits(value);

    void _increase() {
      // hour block
      if (hour) {
        _hr = _hr >= 23 ? 0 : _hr + 1;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (_mins >= 59) {
        _mins = 0;
        _hr = (_hr + 1) % 24;
        _updateHrInputValue(_hr);
      } else {
        _mins += 1;
      }

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    void _decrease() {
      // hour block
      if (hour) {
        _hr = _hr <= 0 ? 23 : _hr - 1;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (_mins <= 0) {
        _mins = 59;
        _hr = _hr <= 0 ? 23 : _hr - 1;
        _updateHrInputValue(_hr);
      } else {
        _mins -= 1;
      }

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    void _onInputChange(String value) {
      int? val = int.tryParse(value);
      if (val == null) return;

      // hour block
      if (hour) {
        if (val < 0 || val > 23) val = 0;
        _hr = val;
        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (val < 0) val = 0;
      if (val > 59) {
        val = 0;
        _hr = (_hr + 1) % 24;
        _updateHrInputValue(_hr);
      }

      _mins = val;

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    return Column(
      classes: 'naki-time-stepper',
      mainAxisSize: MainAxisSize.min,
      children: [
        // up button
        Button.icon(
          LucideIcons.icon_chevron_up,
          size: 18,
          semanticLabel: hour ? 'Increase hour' : 'Increase minutes',
          disabled: component.disable || component.readOnly,
          onTap: _increase,
          classes: 'naki-time-stepper-button',
        ),

        // input
        input<num>(
          id: hour ? 'naki-stepper-$id-hr' : 'naki-stepper-$id-mins',
          type: InputType.number,
          disabled: component.disable || component.readOnly,
          attributes: {
            'min': '0',
            'max': hour ? '24' : '60',
            'step': '1',
            'maxlength': '2',
            'aria-label': hour ? 'Hour' : 'Minutes',
          },
          value: twoDigits(hour ? _hr : _mins),
          onInput: (v) => _onInputChange(v.toCleanString),
        ),

        // down button
        Button.icon(
          LucideIcons.icon_chevron_down,
          size: 18,
          semanticLabel: hour ? 'Decrease hour' : 'Decrease minutes',
          disabled: component.disable || component.readOnly,
          onTap: _decrease,
          classes: 'naki-time-stepper-button',
        ),
      ],
    );
  }

  Component _yearMonthPopover() {
    int selectedYear = _visibleDate.year;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isOutsideMonthBounds(int month) {
          return selectedYear == _minDate.year && month < _minDate.month ||
              selectedYear == _maxDate.year && month > _maxDate.month;
        }

        return Column(
          classes: 'naki-calendar-ymp',
          spacing: 15,
          mainAxisSize: MainAxisSize.min,
          children: [
            // years dropdown
            Dropdown<int>(
              id: 'ymp-years',
              classes: 'naki-calendar-ymp__years',
              options: _years
                  .map(
                    (year) => DropdownItem(
                      label: '$year',
                      value: year,
                      selected: year == selectedYear,
                    ),
                  )
                  .toList(),
              onSelected: (item) {
                selectedYear = item.value!;
                _visibleDate = _visibleDate.copyWith(year: selectedYear);
                setState(() {});
              },
              placeholder: 'Year',
              enableSearch: _years.length > 10,
              menuHeight: const Dim.px(200),
              size: const SizeConstraints(
                width: Dim.percent(100),
                height: Dim.px(40),
              ),
            ),

            // months grid
            GridView.count(
              4,
              mainAxisSpacing: const Dim.px(10),
              crossAxisSpacing: const Dim.px(10),
              classes: 'naki-calendar-ymp__months',
              shrinkWrap: true,
              mainAxisExtent: const Dim.px(35),
              children: kMonths.map((month) {
                final visibleMonthIdx = _visibleDate.month - 1;
                final monthIdx = kMonths.indexOf(month);
                final isDisabled = isOutsideMonthBounds(monthIdx + 1);
                final isSelected =
                    month == kMonths[visibleMonthIdx] && !isDisabled;

                return Button.text(
                  month,
                  id: 'ymp_month_$monthIdx',
                  classes: 'naki-calendar-ymp__month',
                  backgroundColor: Colors.transparent,
                  foregroundColor: context.textColor,
                  disabled: isDisabled,
                  border: BorderData(
                    color: context.popoverBorderColor,
                    radius: BorderRadiusData.all(const Dim.px(6)),
                  ),
                  attributes: {
                    'aria-label': '$month $selectedYear',
                    'aria-pressed': '$isSelected',
                  },
                  onTap: () =>
                      _jumpToMonth(DateTime(selectedYear, monthIdx + 1)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
