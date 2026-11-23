import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for form and input components.
abstract final class InputsStyles {
  @css
  static List<StyleRule> get segmentedInput =>
      NakiStyleRegistry.once('SegmentedInput', [
        ...Rules.nakiSegmentedInputRules,
        Rules.nakiFormFieldRules,
        Rules.nakiHelperRules,
        Rules.nakiErrorRules,
      ]);

  @css
  static List<StyleRule> get label =>
      NakiStyleRegistry.once('Label', [Rules.nakiLabelRules]);

  @css
  static List<StyleRule> get textField => NakiStyleRegistry.once('TextField', [
    Rules.nakiInputRules,
    Rules.nakiFormFieldRules,
    Rules.nakiTextareaRules,
    Rules.nakiHelperRules,
    Rules.nakiErrorRules,
  ]);

  @css
  static List<StyleRule> get calendar => NakiStyleRegistry.once('Calendar', [
    ...Rules.nakiCalendarRules,
    Rules.nakiFormFieldRules,
    Rules.nakiHelperRules,
    Rules.nakiErrorRules,
  ]);

  @css
  static List<StyleRule> get formBuilder =>
      NakiStyleRegistry.once('FormBuilder', [Rules.nakiFormRules]);

  @css
  static List<StyleRule> get autoCompleteField => NakiStyleRegistry.once(
    'AutoCompleteField',
    Rules.nakiAutoCompleteFieldRules,
  );
}
