import 'dart:async';

import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart' hide Table;

import '../framework/framework.dart';
import '../framework/inherited.dart';
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
import '../utilities/helpers.dart' show nakiDomId, onComponentRendered, showValidationError;

import 'basics.dart';
import 'layout.dart';
import 'overlays.dart';
import 'scrolling.dart';
import 'selection.dart';
import 'styling.dart' show Bold;

// event handlers argument types based on InputType:
//  - `bool` for checkbox and radio
//  - `double` for number and range
//  - `List<File>` for file
//  - `Color` for color
//  - `String` for others

/// Signature for callbacks that validate form field.
typedef FieldValidator<T> = String? Function(T value);

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
  const Label(
    this.text, {
    super.key,
    this.fieldId,
    this.style,
  });

  @override
  Component build(BuildContext context) {
    return label(
      key: key,
      classes: 'naki-label',
      styles: Styles(raw: style?.props),
      htmlFor: fieldId,
      [.text(text)],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Label', [
    Rules.nakiLabelRules,
  ]);
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

  /// Text field width.
  final Dim? width;

  /// Text field height.
  final Dim? height;

  /// Function called when the user is typing into the field.
  final ValueChanged<String>? onTyping;

  /// Function called when the user submits the field
  /// (e.g., by pressing `Enter` key).
  final ValueChanged<String>? onSubmit;

  /// Function that returns an error message if the text field value is
  /// invalid, or `null` otherwise.
  ///
  /// This function is only called when [autoValidate] is `true`.
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
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (autoFocus && inputNode != null) {
      if (isMultiline) {
        (inputNode as HTMLTextAreaElement).focus();
      } else {
        (inputNode as HTMLInputElement).focus();
      }
    }

    return null;
  }

  /// Whether to validate the input (when autoValidate or required is true)
  bool get _shouldValidate => autoValidate || required;

  /// Current value of the text field
  String? get currentValue {
    if (kIsServer || inputNode == null) return null;

    return isMultiline
        ? (inputNode as HTMLTextAreaElement).value.trim()
        : (inputNode as HTMLInputElement).value.trim();
  }

  /// Shows custom validation message
  void _showError() {
    if (kIsWeb && (validator != null || required)) {
      final value = currentValue ?? '';
      final error = required && value.isEmpty ? 'required' : validator?.call(value) ?? '';

      // show custom validation message if enabled
      if (_shouldValidate) showValidationError(id, error);

      // set native validity
      _setValidity(error);
    }
  }

  /// Sets validation constraint for native validity
  /// (signalling an error if [error] is not empty)
  void _setValidity(String error) {
    if (inputNode != null) {
      if (isMultiline) {
        (inputNode as HTMLTextAreaElement).setCustomValidity(error);
      } else {
        (inputNode as HTMLInputElement).setCustomValidity(
          error,
        );
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
    NakiDebounce.run(
      'validate_$id',
      const Duration(milliseconds: 500),
      _showError,
    );
  }

  /// Handles input changes
  void _handleInput(dynamic value) {
    _validate();

    final inputValue = value.toString().trim();
    if (inputValue.isNotEmpty) onTyping?.call(inputValue);
  }

  /// Handles submit action on enter key press
  void _handleSubmit(KeyboardEvent event) {
    if (event.key == 'Enter' && !isMultiline) {
      event.preventDefault();
      _validate();

      final inputValue = currentValue ?? '';
      if (inputValue.isNotEmpty) onSubmit?.call(inputValue);
    }
  }

  @override
  Component build(BuildContext context) {
    final baseClass = 'naki-${isMultiline ? 'textarea' : 'input'}';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveWidth = expand ? '100%' : width?.cssText;
    final effectiveHeight = height?.cssText;

    final labelText = decoration?.labelText ?? '';
    final placeholderText = decoration?.placeholderText;
    final helperText = decoration?.helperText ?? '';

    final border = decoration?.border?.props;
    final margin = decoration?.margin?.mProps;
    final padding = decoration?.padding?.pProps;

    final hoverColor = decoration?.hoverBorderColor;
    final focusColor = decoration?.focusBorderColor;
    final placeholderColor = decoration?.placeholderColor;

    final inputTextStyle = decoration?.inputStyle;
    final errorStyle = decoration?.errorStyle;
    final helperStyle = decoration?.helperStyle;
    final labelStyle = decoration?.labelStyle;

    final disableHoverStyle = decoration?.disableHoverStyle ?? false;
    final disableFocusStyle = decoration?.disableFocusStyle ?? false;

    final effectiveStyles = {
      'width': ?effectiveWidth,
      ...?border,
      ...?padding,
      'outline': ?(disableFocusStyle || disableHoverStyle ? 'none !important' : null),
    };

    final defaultEvents = InputEvents(
      onFocusOut: (_) => _validate(),
      onInvalid: _invalid,
      onKeyDown: _handleSubmit,
    );

    final effectiveEvents = events?.merge(defaultEvents) ?? defaultEvents;

    return .element(
      tag: 'naki-textfield',
      id: '${id}__textfield',
      classes: 'naki-form-field',
      styles: Styles(
        raw: {
          Tokens.current.inputHeight.name: ?effectiveHeight,
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
          ...?margin,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty) Label(labelText, fieldId: id, style: labelStyle),

        // Field
        isMultiline
            ? textarea(
                key: key,
                id: id,
                name: id,
                classes: effectiveClasses,
                styles: Styles(raw: effectiveStyles),
                disabled: disable,
                required: required,
                placeholder: placeholderText,
                readonly: readOnly,
                wrap: .soft,
                rows: visibleLines,
                spellCheck: enableSpellCheck ? SpellCheck.isTrue : SpellCheck.isFalse,
                attributes: {
                  ...?attributes,
                  'pattern': ?pattern?.value,
                  'autocomplete': ?autofill?.value,
                  'maxlength': ?maxLength?.toString(),
                  'minlength': ?minLength?.toString(),
                  'autofocus': ?(autoFocus ? '' : null),
                },
                onInput: _handleInput,
                events: effectiveEvents.toMap,
                [
                  if (initialValue.isNotNullAndEmpty) .text(initialValue!),
                ],
              )
            : input(
                key: key,
                id: id,
                name: id,
                classes: effectiveClasses,
                styles: Styles(raw: effectiveStyles),
                type: type,
                disabled: disable,
                attributes: {
                  ...?attributes,
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
                  'autofocus': ?(autoFocus ? '' : null),
                  'inputmode': ?(type == InputType.number || type == InputType.tel
                      ? 'numeric'
                      : null),
                },
                value: initialValue,
                onInput: _handleInput,
                events: effectiveEvents.toMap,
              ),

        // Helper text
        if (helperText.isNotEmpty)
          p(
            classes: 'naki-helper',
            styles: Styles(raw: helperStyle?.props),
            [
              .text(helperText),
            ],
          ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('TextField', [
    Rules.nakiInputRules,
    Rules.nakiFormFieldRules,
    Rules.nakiTextareaRules,
    Rules.nakiHelperRules,
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

  /// Set this to `true` if you want the form to automatically validate
  /// when a [Button] in [children] is clicked.
  final bool autoValidate;

  /// {@macro FormBuilder}
  FormBuilder({
    required GlobalNodeKey<HTMLFormElement> super.key,
    required this.children,
    this.direction = Direction.vertical,
    this.autoValidate = false,
    this.spacing,
    this.classes,
    this.name,
    this.attributes,
  }) : assert(
         children.isNotEmpty,
         'FormBuilder must have at least one child',
       );

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-form';
    final effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final effectiveSyles = {
      'flex-direction': ?(direction == Direction.horizontal ? 'row' : null),
      'gap': ?spacing?.toPx,
    };

    return FormScope(
      allowValidation: autoValidate,
      child: form(
        key: key as GlobalNodeKey<HTMLFormElement>,
        name: name,
        classes: effectiveClasses,
        // when autoValidate is true, the native browser form validation is
        // disabled and Button is responsible for the validation
        noValidate: autoValidate,
        attributes: attributes,
        styles: Styles(raw: effectiveSyles),
        children,
      ),
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('FormBuilder', [
    Rules.nakiFormRules,
  ]);
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
  }) : assert(
         options.isNotEmpty,
         'options must have at least 1 option',
       ),
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

class _AutoCompleteFieldState extends State<AutoCompleteField> with NakiStatefulMixin {
  late String _id;

  final _filteredOptions = ValueNotifier<List<String>>([]);
  int? _activeOptionIndex;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'nac', id: component.id);
  }

  @override
  void dispose() {
    _filteredOptions.dispose();
    super.dispose();
  }

  /// Returns the input element node
  HTMLInputElement? get inputNode => component.key is GlobalNodeKey<HTMLInputElement>
      ? (component.key as GlobalNodeKey<HTMLInputElement>).currentNode
      : document.getElementById(_id) as HTMLInputElement?;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (component.autoFocus) inputNode?.focus();
    return null;
  }

  /// Handles typing
  void _onTyping(String value) {
    // clear the filtered options when input is empty
    if (value.isEmpty) {
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
            .where(
              (o) => o.toLowerCase().contains(
                value.toLowerCase(),
              ),
            )
            .toList();

        setState(() {
          _activeOptionIndex = filtered.isEmpty ? null : 0;
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

    // update text field value
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

      _activeOptionIndex = (current + delta) % options.length;

      setState(() {});
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
                    attributes: {
                      'role': 'option',
                      'aria-selected': (_activeOptionIndex == entry.$1).toString(),
                    },
                    events: Events(
                      onClick: (_) => _onSelect(entry.$2),
                    ).toMap,
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
  static List<StyleRule> get styles => NakiStyleRegistry.once('SegmentedInput', [
    ...Rules.nakiSegmentedInputRules,
    Rules.nakiFormFieldRules,
    Rules.nakiHelperRules,
  ]);
}

class _SegmentedInputState extends State<SegmentedInput> with NakiStatefulMixin {
  late String _fieldId;

  List<String> _segmentValues = [];
  List<GlobalNodeKey<HTMLInputElement>> _segmentKeys = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _fieldId = nakiDomId(context, 'nsi', id: component.id);
    _initValues();
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (component.autoFocus) _focusSegment(0);
    return null;
  }

  @override
  void didUpdateComponent(SegmentedInput oldcomponent) {
    super.didUpdateComponent(oldcomponent);

    if (component.length != oldcomponent.length) {
      _initValues();
    } else if (component.value != oldcomponent.value && component.value != null) {
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
      (index) =>
          index < previousKeys.length ? previousKeys[index] : GlobalNodeKey<HTMLInputElement>(),
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
      _segmentValues.every((val) => val.isNotEmpty) && _segmentValues.length == component.length;

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
          ? 'required'
          : component.validator?.call(_fullValue) ?? '';

      // show validation message when autoValidate enabled
      if (shouldValidate) {
        showValidationError(
          _fieldId,
          error,
          isSegmentedInput: true,
        );
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
        for (int i = 0; i < cleanChars.length && (index + i) < component.length; i++) {
          setState(
            () => _segmentValues[index + i] = cleanChars[i],
          );
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

    for (int i = 0; i < cleanChars.length && (startIndex + i) < component.length; i++) {
      setState(
        () => _segmentValues[startIndex + i] = cleanChars[i],
      );
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
        style?.textStyle?.fontSize?.cssText ?? decoration?.inputStyle?.fontSize?.cssText;

    final hoverColor = style?.hoverBorderColor ?? decoration?.hoverBorderColor;
    final focusColor = style?.focusBorderColor ?? decoration?.focusBorderColor;
    final errorColor = style?.errorBorderColor ?? decoration?.errorStyle?.color;
    final inputColor = style?.textStyle?.color?.value ?? decoration?.inputStyle?.color?.value;

    final borderProps = component.style?.border?.props;
    final radiusProps = component.style?.borderRadius?.props;
    final paddingProps = component.style?.padding?.pProps;
    final marginProps = component.style?.margin?.mProps ?? component.decoration?.margin?.mProps;

    final disableHoverStyle = component.decoration?.disableHoverStyle ?? false;
    final disableFocusStyle = component.decoration?.disableFocusStyle ?? false;

    const baseClass = 'naki-segmented-input';
    final effectiveSegmentClasses = 'input-segment shape-${shape.name}';
    final effectiveContainerClasses = component.classes.isNotNullAndEmpty
        ? '$baseClass ${component.classes}'
        : baseClass;

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
      'outline': ?(disableFocusStyle || disableHoverStyle ? 'none !important' : null),
      ...?borderProps,
      ...?radiusProps,
      ...?paddingProps,
    };

    final effectiveType =
        ((component.obscureText || component.type == SegmentedInputType.password) &&
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
          Label(
            labelText,
            fieldId: '${_fieldId}_0',
            style: labelStyle,
          ),

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
              classes: '$effectiveSegmentClasses${isFilled ? ' is-filled' : ''}',
              styles: Styles(
                raw: {
                  ...effectiveInputStyles,
                  'background-color': ?bgColor,
                },
              ),
              type: effectiveType,
              disabled: component.disable,
              value: displayedValue,
              attributes: {
                'maxlength': '1',
                'autocomplete': i == 0 ? Autofill.oneTimeCode.value : Autofill.off.value,
                'inputmode': component.type == SegmentedInputType.number ? 'numeric' : 'text',
                'pattern': ?(component.type == SegmentedInputType.number
                    ? ValidationPattern.digitsOnly.value
                    : null),
                'aria-label': 'Segment ${i + 1} of ${component.length}',
                'readonly': ?(component.readOnly ? '' : null),
                'required': ?(component.required && i == 0 ? '' : null),
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
          p(
            classes: 'naki-helper',
            styles: Styles(raw: helperStyle?.props),
            [
              .text(helperText),
            ],
          ),
      ],
    );
  }
}

/// {@template Calendar}
/// A component that enables selection of date, time, or both
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

  /// Minimum allowed date or time values for the calendar.
  final DateTime? minimum;

  /// The maximum allowed date or time values for the calendar.
  final DateTime? maximum;

  /// Callback invoked when a date or time is selected.
  final ValueChanged<DateTime> onSelected;

  /// Callback that returns an error message if the selected
  /// date or time is invalid, or `null` otherwise.
  final FieldValidator<DateTime?>? validator;

  /// Whether the calendar component is read-only (default: `false`).
  ///
  /// When `true`, the calendar date or time pickers will be displayed
  /// and not interactive.
  final bool readOnly;

  /// Custom component such as text or icon, which opens and closes
  /// the calendar modal.
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
  /// Note: [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// Calendar background color.
  final Color? backgroundColor;

  /// Width of the calendar [child].
  /// This will be ignored when [child] is provided.
  final Dim? width;

  /// Height of the calendar [child].
  /// This will be ignored when [child] is provided.
  final Dim? height;

  /// Decoration configuration for placeholder, label, helper text,
  /// error text, and the default calendar [child].
  final InputDecoration? decoration;

  /// Additional CSS classes applied to the calendar component.
  final String? classes;

  /// {@macro Calendar}
  Calendar({
    super.key,
    required this.id,
    required this.type,
    required this.onSelected,
    this.readOnly = false,
    this.disable = false,
    this.autoFocus = false,
    this.required = false,
    this.autoValidate = false,
    this.child,
    this.initialValue,
    this.validator,
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
         initialValue == null || minimum == null || !initialValue.isBefore(minimum),
         'initialValue must not be before minimum',
       ),
       assert(
         initialValue == null || maximum == null || !initialValue.isAfter(maximum),
         'initialValue must not be after maximum',
       ),
       assert(
         !autoValidate || validator != null,
         'validator is required when autoValidate is true',
       );

  @override
  State<Calendar> createState() => _CalendarState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Calendar', [
    ...Rules.nakiCalendarRules,
    Rules.nakiFormFieldRules,
    Rules.nakiHelperRules,
  ]);
}

class _CalendarState extends State<Calendar> with NakiStatefulMixin {
  late DateTime _visibleMonth;
  late final String _calendarId = nakiDomId(
    context,
    'ncp',
    id: component.id,
  );

  final _dialogKey = GlobalNodeKey<HTMLElement>();

  bool _pickTime = false;
  bool _pickDate = false;
  bool _showYear = false;
  bool _requestedOpen = false;

  DateTime? _selectedDate;
  Duration? _selectedTime;

  List<int> _years = [];

  HTMLElement? _previousFocus;
  StreamSubscription<KeyboardEvent>? _keyboardSubscription;

  @override
  void initState() {
    super.initState();
    _initCalendar();
  }

  @override
  void didUpdateComponent(Calendar oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.initialValue != component.initialValue) {
      _initCalendar();
    }

    if (oldComponent.minimum != component.minimum || oldComponent.maximum != component.maximum) {
      _initCalendar();
    }
  }

  /// Returns the calendar element node
  HTMLElement? get calendarNode => component.key is GlobalNodeKey<HTMLElement>
      ? (component.key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById('${_calendarId}__calendar') as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (component.autoFocus && component.child == null) {
      final triggerId = '${_calendarId}_default_trigger';
      (document.getElementById(triggerId) as HTMLButtonElement?)?.focus();
    }

    // listener that checks if an outside click occurred
    final clickSubscription = EventStreamProviders.clickEvent.forTarget(window).listen((event) {
      if (!_pickTime && !_pickDate) return;

      final target = event.target as Node?;
      if (target == null) return;

      // ignore targets that were unmounted during click handling
      if (!target.isConnected) return;

      // ignore clicks inside the calendar
      if (calendarNode != null && calendarNode!.contains(target)) return;

      // if dropdown menu is open, let dropdown handle closing
      final dropdownMenu =
          calendarNode?.querySelector(
                'naki-dropdown[open]',
              )
              as HTMLElement? ??
          document.querySelector('naki-dropdown[open]') as HTMLElement?;

      if (dropdownMenu != null) return;

      if (_showYear) {
        setState(() => _showYear = false);
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

    _pickTime = false;
    _pickDate = false;
    _showYear = false;

    _selectedDate = component.initialValue;
    _visibleMonth = _selectedDate ?? now;

    if (type != CalendarType.date) {
      _selectedTime = Duration(
        hours: _selectedDate?.hour ?? now.hour,
        minutes: _selectedDate?.minute ?? now.minute,
      );

      if (type == CalendarType.time) _selectedDate ??= now;
    }

    final minYear = component.minimum?.year ?? _visibleMonth.year - 100;
    final maxYear = (component.maximum ?? now.copyWith(year: now.year + 10)).year;

    final count = maxYear >= minYear ? (maxYear - minYear + 1) : 0;
    _years = List.generate(count, (i) => minYear + i);
  }

  /// Whether to validate the input (when autoValidate or required is true)
  bool get _shouldValidate => component.autoValidate || component.required;

  /// Builds the calendar month component
  CalendarMonth _buildCalendarMonth(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final days = DateTime(
      month.year,
      month.month + 1,
      0,
    ).day;

    final daysInMonth = [
      // leading nulls to align with first day of week
      // Monday being the 1st day
      for (var i = 1; i < first.weekday; i++) null,

      // days of month
      for (var day = 1; day <= days; day++)
        CalendarDay(
          date: DateTime(month.year, month.month, day),
          isSelected:
              _selectedDate?.year == month.year &&
              _selectedDate?.month == month.month &&
              _selectedDate?.day == day,
          isToday: DateTime(
            month.year,
            month.month,
            day,
          ).isToday,
          isDisabled: _isOutsideBounds(
            DateTime(month.year, month.month, day),
          ),
        ),
    ];

    return CalendarMonth(date: month, days: daysInMonth);
  }

  DateTime _dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  bool _isOutsideBounds(DateTime value) {
    final date = _dateOnly(value);
    final minimum = component.minimum;
    final maximum = component.maximum;

    return (minimum != null && date.isBefore(_dateOnly(minimum))) ||
        (maximum != null && date.isAfter(_dateOnly(maximum)));
  }

  void _togglePicker() {
    if (component.disable) return;

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
        _deactivateDialog();
      }
    });
  }

  List<HTMLElement> _focusableElements(
    HTMLElement surface,
  ) {
    final nodes = surface.querySelectorAll(
      'button:not([disabled]), input:not([disabled]), '
      '[tabindex]:not([tabindex="-1"])',
    );

    return [
      for (var index = 0; index < nodes.length; index++) nodes.item(index) as HTMLElement,
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

    _keyboardSubscription = EventStreamProviders.keyDownEvent
        .forTarget(document)
        .listen(
          (event) => _handleDialogKeyDown(event, surface),
        );
  }

  void _handleDialogKeyDown(
    KeyboardEvent event,
    HTMLElement surface,
  ) {
    if (event.key == 'Escape') {
      event.preventDefault();

      setState(() {
        _pickDate = false;
        _pickTime = false;
        _showYear = false;
      });

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
          for (var index = 0; index < nodes.length; index++) nodes.item(index) as HTMLElement,
        ];

        final current = dates.indexOf(target);

        if (current != -1 && dates.isNotEmpty) {
          event.preventDefault();

          dates[(current + delta).clamp(
                0,
                dates.length - 1,
              )]
              .focus();
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

    if (event.shiftKey && (active == focusable.first || !surface.contains(active))) {
      event.preventDefault();
      focusable.last.focus();
    } else if (!event.shiftKey && (active == focusable.last || !surface.contains(active))) {
      event.preventDefault();
      focusable.first.focus();
    }
  }

  void _deactivateDialog({bool restoreFocus = true}) {
    _keyboardSubscription?.cancel();
    _keyboardSubscription = null;

    if (restoreFocus) _previousFocus?.focus();

    _previousFocus = null;
    _requestedOpen = false;
  }

  @override
  void dispose() {
    _deactivateDialog(restoreFocus: false);
    super.dispose();
  }

  /// Converts [CalendarType] to [InputType]
  InputType get inputType => switch (component.type) {
    CalendarType.date => InputType.date,
    CalendarType.time => InputType.time,
    CalendarType.both => InputType.dateTimeLocal,
  };

  /// Current value of the calendar picker
  DateTime? get currentValue {
    if (_selectedDate == null) return null;
    if (_selectedTime == null) return _selectedDate;

    return _selectedDate!.copyWith(
      hour: _selectedTime!.inHours,
      minute: _selectedTime!.inMinutes % 60,
      second: 0,
    );
  }

  /// String representation of date/time based on picker type
  String _displayedValue(DateTime value) => switch (component.type) {
    CalendarType.date => value.toDdMmmYyyy,
    CalendarType.time => value.toFullTimeAmPm,
    CalendarType.both => value.toDateTimeLong,
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

    if (close) _submitAndClose(date);
  }

  /// Performs validation and invokes onSelected callback
  void _submitAndClose(DateTime date) {
    _showError(date);
    component.onSelected.call(date);
    _pickDate = false;
    _pickTime = false;
    setState(() {});
  }

  /// Shows custom validation message
  void _showError([DateTime? date]) {
    if (kIsWeb && (component.validator != null || component.required)) {
      final value = date ?? currentValue;
      final error = component.required && value == null
          ? 'required'
          : component.validator?.call(value) ?? '';

      // show custom validation message if enabled
      if (_shouldValidate) {
        showValidationError(
          _calendarId,
          error,
          isCalendar: true,
        );
      }

      // set browser-default validity
      final inputElem = document.getElementById(_calendarId) as HTMLInputElement?;
      inputElem?.setCustomValidity(error);
    }
  }

  /// Handles invalid event when parent form is submitted
  void _invalid(Event event) {
    if (kIsWeb && _shouldValidate) {
      event.preventDefault();

      final inputElem = event.currentTarget as HTMLInputElement?;
      final value = inputElem == null ? null : DateTime.tryParse(inputElem.value);

      _showError(value);
    }
  }

  /// Toggles between months
  void _toggleMonth([bool next = false]) {
    if (_years.isEmpty) return;

    final currentMonth = _visibleMonth.month;
    final currentYear = _visibleMonth.year;

    if (next) {
      // Move to next month, respecting max year boundary
      if (currentYear == _years.last && currentMonth == 12) return;
      setState(() {
        _visibleMonth = DateTime(
          currentYear,
          currentMonth + 1,
          1,
        );
      });
    } else {
      // Move to previous month, respecting min year boundary
      if (currentYear == _years.first && currentMonth == 1) return;
      setState(() {
        _visibleMonth = DateTime(
          currentYear,
          currentMonth - 1,
          1,
        );
      });
    }
  }

  /// Resets to current month view, based on selected value
  void _jumpToMonth(DateTime date) => setState(() {
    _visibleMonth = date.copyWith(day: 1);
    _showYear = false;
  });

  @override
  Component build(BuildContext context) {
    final backgroundColor = component.backgroundColor;
    final decoration = component.decoration;

    final labelText = decoration?.labelText ?? '';
    final placeholderText = decoration?.placeholderText ?? '';
    final helperText = decoration?.helperText ?? '';

    final hoverColor = decoration?.hoverBorderColor;
    final focusColor = decoration?.focusBorderColor;
    final placeholderColor = decoration?.placeholderColor;

    final errorStyle = decoration?.errorStyle;
    final helperStyle = decoration?.helperStyle;
    final labelStyle = decoration?.labelStyle;

    final disableHoverStyle = decoration?.disableHoverStyle ?? false;
    final disableFocusStyle = decoration?.disableFocusStyle ?? false;

    final effectiveClasses = component.classes.isNotNullAndEmpty
        ? 'naki-calendar ${component.classes}'
        : 'naki-calendar';

    final content = currentValue != null
        ? _displayedValue(currentValue!)
        : placeholderText.isNotNullAndEmpty
        ? placeholderText
        : 'Select date or time';

    final currentMonth = _visibleMonth.month;
    final currentYear = _visibleMonth.year;

    final showDatePickerOnly = component.type == CalendarType.date;
    final showBoth = component.type == CalendarType.both;
    final pickerOpen = _pickDate || _pickTime;

    _syncDialogAccessibility(pickerOpen);

    final daysInMonth = _buildCalendarMonth(
      _visibleMonth,
    ).days;
    final triggerIcon = showDatePickerOnly || showBoth
        ? LucideIcons.icon_calendar
        : LucideIcons.icon_clock;

    final triggerLabel = labelText.isNotEmpty
        ? '${pickerOpen ? 'Close' : 'Open'} $labelText picker'
        : '${pickerOpen ? 'Close' : 'Open'} date and time picker';

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
            text: content,
            icon: triggerIcon,
            iconSize: 16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            width: component.width,
            height: component.height ?? const Dim.px(48),
            border: decoration?.border,
            padding: decoration?.padding,
            textStyle: decoration?.inputStyle,
            backgroundColor: context.fieldBackgroundColor,
            hoverColor: context.fieldBackgroundColor,
            disabled: component.disable,
            attributes: triggerAttributes,
            onTap: _togglePicker,
          )
        : GestureDetector(
            semanticLabel: triggerLabel,
            attributes: triggerAttributes,
            gestures: Gestures(
              onClick: (_) => _togglePicker(),
            ),
            child: component.child!,
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
          Tokens.current.placeholderColor.name: ?placeholderColor?.value,
          Tokens.current.fieldHoverColor.name: ?hoverColor?.value,
          Tokens.current.focusBorderColor.name: ?focusColor?.value,
          Tokens.current.dropdownMenuBgColor.name: ?backgroundColor?.value,
          ...?decoration?.margin?.mProps,
        },
      ),
      children: [
        // Label
        if (labelText.isNotEmpty)
          Label(
            labelText,
            fieldId: _calendarId,
            style: labelStyle,
          ),

        // Wrapper
        div(classes: effectiveClasses, [
          // Input for form validation (hidden)
          input(
            id: _calendarId,
            name: component.id,
            type: inputType,
            value: currentValue != null ? _inputValue(currentValue!) : null,
            attributes: {
              'required': ?(component.required ? '' : null),
              'readonly': '',
            },
            events: InputEvents(
              onInvalid: (event) => _invalid(event),
            ).toMap,
          ),

          // Trigger (opens/closes modal)
          .wrapElement(
            child: effectiveChild,
            classes: 'naki-calendar-trigger',
            styles: Styles(
              raw: {
                'outline': ?(disableFocusStyle || disableHoverStyle ? 'none !important' : null),
              },
            ),
            attributes: {
              'novalue': ?(currentValue == null ? '' : null),
              'selected': ?(currentValue != null ? '' : null),
              'disabled': ?(component.disable ? '' : null),
            },
          ),

          // Modal
          if (pickerOpen)
            div(
              key: _dialogKey,
              id: '${_calendarId}_dialog',
              classes: 'naki-calendar-modal',
              attributes: {
                'role': 'dialog',
                'aria-modal': 'true',
                'aria-label': labelText.isNotEmpty ? '$labelText picker' : 'Date and time picker',
                'tabindex': '-1',
              },
              [
                // Date picker
                if (_pickDate)
                  Column(
                    classes: 'naki-date-picker',
                    spacing: 5,
                    children: [
                      // header
                      Row(
                        classes: 'naki-calendar-header',
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        spacing: 5,
                        children: [
                          // goto previous month
                          Button.icon(
                            MaterialSymbols.round_chevron_left,
                            classes: 'naki-calendar-header__button',
                            disabled: currentYear == _years.first && currentMonth == 1,
                            height: const Dim.px(48),
                            width: const Dim.px(48),
                            backgroundColor: Colors.transparent,
                            onTap: () => _toggleMonth(),
                          ),

                          // visible month and year
                          Popover(
                            visible: _showYear,
                            child: Button.iconText(
                              icon: MaterialIcons.icon_round_arrow_drop_down,
                              text: _visibleMonth.toMonthYear,
                              classes: 'naki-calendar-header__title',
                              height: const Dim.px(48),
                              iconSize: 28,
                              foregroundColor: context.placeholderColor,
                              backgroundColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              attributes: {
                                'showyear': ?(_showYear ? '' : null),
                              },
                              onTap: () => setState(
                                () => _showYear = !_showYear,
                              ),
                            ),
                            content: _showYear ? _yearMonthPopover() : const .empty(),
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
                              setState(
                                () => _showYear = false,
                              );
                            },
                            position: PopoverPosition.bottom,
                          ),

                          // goto next month
                          Button.icon(
                            MaterialSymbols.round_chevron_right,
                            classes: 'naki-calendar-header__button',
                            disabled: currentYear == _years.last && currentMonth == 12,
                            height: const Dim.px(48),
                            width: const Dim.px(48),
                            backgroundColor: Colors.transparent,
                            onTap: () => _toggleMonth(true),
                          ),
                        ],
                      ),

                      // days
                      Table(
                        classes: 'naki-calendar-body',
                        headers: [
                          for (final day in kDays)
                            NakiText(
                              day,
                              classes: 'naki-calendar-body__header',
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

                      // time picker shortcut
                      if (showBoth)
                        SizedBox(
                          width: const Dim.percent(100),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              Dim.px(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              spacing: 10,
                              children: [
                                const Bold('Time'),

                                Button.text(
                                  () {
                                    final now = DateTime.now();
                                    final time = _selectedTime ??= Duration(
                                      hours: _selectedDate?.hour ?? now.hour,
                                      minutes: _selectedDate?.minute ?? now.minute,
                                    );
                                    final _hr = time.inHours % 24;
                                    final _mins = time.inMinutes % 60;

                                    String twoDigits(
                                      int value,
                                    ) => value.toString().padLeft(2, '0');

                                    return '${twoDigits(_hr)}:${twoDigits(_mins)}';
                                  }(),
                                  classes: 'naki-calendar-action__button',
                                  onTap: () {
                                    setState(() {
                                      _pickTime = true;
                                      _pickDate = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                      // actions
                      Row(
                        classes: 'naki-calendar-actions',
                        spacing: 10,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // cancel date picker
                          Button.text(
                            'Cancel',
                            classes: 'naki-calendar-action__button',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                            backgroundColor: Colors.transparent,
                            onTap: () {
                              _selectedDate ??= component.initialValue;
                              _visibleMonth = _selectedDate ?? DateTime.now();

                              _selectedTime ??= null;
                              _pickDate = false;
                              _pickTime = false;

                              setState(() {});
                              _updateValue();
                            },
                          ),

                          // reset to initial date
                          Button.text(
                            'Reset',
                            classes: 'naki-calendar-action__button',
                            backgroundColor: Colors.transparent,
                            onTap: () {
                              if (component.disable || component.readOnly) return;

                              _selectedDate = component.initialValue;
                              _visibleMonth = _selectedDate ?? DateTime.now();

                              if (_selectedDate != null && showBoth) {
                                _selectedTime = Duration(
                                  hours: _selectedDate!.hour,
                                  minutes: _selectedDate!.minute,
                                );
                              }

                              setState(() {});
                              _updateValue();
                            },
                          ),

                          // submit date
                          Button.text(
                            'Submit',
                            classes: 'naki-calendar-action__button',
                            disabled: _selectedDate == null,
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                            backgroundColor: Colors.transparent,
                            onTap: () => _updateValue(close: true),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Time picker
                if (_pickTime)
                  Column(
                    classes: 'naki-time-picker',
                    children: [
                      const SizedBox.height(Dim.px(10)),

                      // steppers
                      Row(
                        spacing: 5,
                        classes: 'naki-time-picker-steppers',
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimeStepper(
                            id: _calendarId,
                            hour: true,
                          ),
                          const NakiText(
                            ':',
                            classes: 'naki-time-separator',
                          ),
                          _buildTimeStepper(
                            id: _calendarId,
                            hour: false,
                          ),
                        ],
                      ),

                      const SizedBox.height(Dim.px(10)),

                      // actions
                      Row(
                        classes: 'naki-calendar-actions',
                        spacing: 20,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // cancel time picker
                          Button.text(
                            'Cancel',
                            classes: 'naki-calendar-action__button',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                            backgroundColor: Colors.transparent,
                            onTap: () {
                              if (showBoth) {
                                _pickDate = true;
                              } else {
                                _selectedDate ??= component.initialValue ?? DateTime.now();
                              }

                              _selectedTime ??= null;
                              _pickTime = false;

                              setState(() {});
                              _updateValue();
                            },
                          ),

                          // reset to initial time
                          Button.text(
                            'Reset',
                            classes: 'naki-calendar-action__button',
                            backgroundColor: Colors.transparent,
                            onTap: () {
                              if (component.disable || component.readOnly) return;

                              final now = DateTime.now();
                              _selectedTime = Duration(
                                hours: _selectedDate?.hour ?? now.hour,
                                minutes: _selectedDate?.minute ?? now.minute,
                              );

                              setState(() {});
                              _updateValue();
                            },
                          ),

                          // submit time
                          Button.text(
                            'Submit',
                            classes: 'naki-calendar-action__button',
                            disabled: _selectedTime == null,
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                            backgroundColor: Colors.transparent,
                            onTap: () => _updateValue(close: true),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
        ]),

        // Helper
        if (helperText.isNotEmpty)
          p(
            classes: 'naki-helper',
            styles: Styles(raw: helperStyle?.props),
            [
              .text(helperText),
            ],
          ),
      ],
    );
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
                    disabled: day.isDisabled,
                    attributes: {
                      'aria-label': '$day',
                      'aria-selected': '${day.isSelected}',
                      'aria-current': ?(day.isToday ? 'date' : null),
                      'tabindex': identical(day, focusDay) ? '0' : '-1',
                      'selected': ?(day.isSelected ? '' : null),
                      'today': ?(day.isToday ? '' : null),
                    },
                    onTap: component.readOnly || day.isDisabled
                        ? null
                        : () => setState(() {
                            _selectedDate = day.date;
                          }),
                  ),
          )
          .toList();

      rows.add(
        TableRow(
          children: cells,
          classes: 'naki-calendar-week',
        ),
      );
    }

    return rows;
  }

  Component _buildTimeStepper({
    required String id,
    required bool hour,
  }) {
    final now = DateTime.now();
    final time = _selectedTime ?? Duration(hours: now.hour, minutes: now.minute);

    final hrInputElem = document.getElementById('naki-stepper-$id-hr') as HTMLInputElement?;
    final minsInputElem = document.getElementById('naki-stepper-$id-mins') as HTMLInputElement?;

    int _hr = time.inHours % 24;
    int _mins = time.inMinutes % 60;

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    void _updateTime() => setState(
      () => _selectedTime = Duration(
        hours: _hr,
        minutes: _mins,
      ),
    );

    void _updateMinsInputValue(int value) => minsInputElem?.value = twoDigits(value);

    void _updateHrInputValue(int value) => hrInputElem?.value = twoDigits(value);

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
        if (val > 23) val = 23;
        if (val < 0) val = 0;
        _hr = val;

        _updateHrInputValue(_hr);
        _updateTime();
        return;
      }

      // minutes block
      if (val > 59) val = 59;
      if (val < 0) val = 0;
      _mins = val;

      _updateMinsInputValue(_mins);
      _updateTime();
    }

    return Column(
      classes: 'naki-time-stepper',
      children: [
        // up button
        Button.icon(
          MaterialIcons.icon_round_arrow_drop_up,
          size: 28,
          onTap: () => _increase(),
          classes: 'naki-time-stepper__button',
        ),

        // input
        input<num>(
          id: hour ? 'naki-stepper-$id-hr' : 'naki-stepper-$id-mins',
          type: InputType.number,
          attributes: {
            'min': '0',
            'max': hour ? '23' : '59',
            'step': '1',
            'maxlength': '2',
          },
          value: hour ? '$_hr' : '$_mins',
          onInput: (v) => _onInputChange(v.toCleanString),
        ),

        // down button
        Button.icon(
          MaterialIcons.icon_round_arrow_drop_down,
          size: 28,
          onTap: () => _decrease(),
          classes: 'naki-time-stepper__button',
        ),
      ],
    );
  }

  Component _yearMonthPopover() {
    final selectedMonthIndex = _visibleMonth.month - 1;
    int selectedYear = _visibleMonth.year;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          classes: 'naki-calendar-ymp',
          spacing: 15,
          children: [
            // years dropdown
            Dropdown<String>(
              id: 'ymp-years',
              classes: 'naki-calendar-ymp__years',
              options: _years
                  .map(
                    (year) => DropdownItem(
                      label: '$year',
                      value: '$year',
                      selected: year == selectedYear,
                    ),
                  )
                  .toList(),
              onSelected: (item) {
                setState(
                  () => selectedYear = int.parse(item.value!),
                );
                _visibleMonth = _visibleMonth.copyWith(
                  year: selectedYear,
                  month: 1,
                );
              },
              placeholder: 'Select year',
              enableSearch: _years.length > 10,
              menuHeight: const Dim.px(150),
              size: const SizeConstraints(
                width: Dim.percent(100),
                height: Dim.px(35),
              ),
            ),

            // months grid
            GridView.count(
              4,
              mainAxisSpacing: const Dim.px(8),
              crossAxisSpacing: const Dim.px(8),
              classes: 'naki-calendar-ymp__months',
              shrinkWrap: true,
              mainAxisExtent: const Dim.px(40),
              children: kMonths
                  .map(
                    (month) => Button.text(
                      month,
                      id: 'ymp_month_${kMonths.indexOf(month)}',
                      classes: 'naki-calendar-ymp__month',
                      backgroundColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      attributes: {
                        'aria-label': '$month $selectedYear',
                        'selected': ?(month == kMonths[selectedMonthIndex] ? '' : null),
                      },
                      onTap: () => _jumpToMonth(
                        DateTime(
                          selectedYear,
                          kMonths.indexOf(month) + 1,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
