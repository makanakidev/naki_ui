import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for basic UI components.
abstract final class BasicsStyles {
  @css
  static List<StyleRule> get text =>
      NakiStyleRegistry.once('Text', [Rules.nakiTextRules]);

  @css
  static List<StyleRule> get button =>
      NakiStyleRegistry.once('Button', [Rules.nakiButtonRules]);

  @css
  static List<StyleRule> get icon => NakiStyleRegistry.once('Icon', [
    Rules.nakiIconRules,
    Rules.nakiHitboxRules,
  ]);

  @css
  static List<StyleRule> get row =>
      NakiStyleRegistry.once('Row', [Rules.nakiRowRules]);

  @css
  static List<StyleRule> get banner =>
      NakiStyleRegistry.once('Banner', [Rules.nakiBannerRules]);

  @css
  static List<StyleRule> get spinner =>
      NakiStyleRegistry.once('Spinner', Rules.nakiSpinnerRules);

  @css
  static List<StyleRule> get column =>
      NakiStyleRegistry.once('Column', [Rules.nakiColumnRules]);
}
