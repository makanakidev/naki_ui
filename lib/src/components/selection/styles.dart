import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for selection components.
abstract final class SelectionStyles {
  @css
  static List<StyleRule> get radioButton =>
      NakiStyleRegistry.once('RadioButton', [
        Rules.nakiRadioBtnRules,
        Rules.nakiHitboxRules,
      ]);

  @css
  static List<StyleRule> get checkbox => NakiStyleRegistry.once('Checkbox', [
    Rules.nakiCheckboxRules,
    Rules.nakiHitboxRules,
  ]);

  @css
  static List<StyleRule> get dropdown =>
      NakiStyleRegistry.once('Dropdown', [...Rules.nakiDropdownRules]);

  @css
  static List<StyleRule> get slider =>
      NakiStyleRegistry.once('Slider', [Rules.nakiSliderRules]);

  @css
  static List<StyleRule> get nakiSwitch => NakiStyleRegistry.once('Switch', [
    Rules.nakiSwitchRules,
    Rules.nakiHitboxRules,
  ]);
}
