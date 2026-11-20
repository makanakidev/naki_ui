part of 'index.dart';

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
