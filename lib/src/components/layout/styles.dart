import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for layout components.
abstract final class LayoutStyles {
  @css
  static List<StyleRule> get expansionPanelList => NakiStyleRegistry.once(
    'ExpansionPanelList',
    Rules.nakiExpansionPanelRules,
  );

  @css
  static List<StyleRule> get wrap =>
      NakiStyleRegistry.once('Wrap', [Rules.nakiWrapRules]);

  @css
  static List<StyleRule> get card =>
      NakiStyleRegistry.once('Card', [Rules.nakiCardRules]);

  @css
  static List<StyleRule> get container =>
      NakiStyleRegistry.once('Container', [Rules.nakiContainerRules]);

  @css
  static List<StyleRule> get positioned =>
      NakiStyleRegistry.once('Positioned', [Rules.nakiPositionedRules]);

  @css
  static List<StyleRule> get expansionTile =>
      NakiStyleRegistry.once('ExpansionTile', Rules.nakiExpansionPanelRules);

  @css
  static List<StyleRule> get align =>
      NakiStyleRegistry.once('Align', [Rules.nakiAlignRules]);

  @css
  static List<StyleRule> get flexible =>
      NakiStyleRegistry.once('Flexible', Rules.nakiFlexibleRules);

  @css
  static List<StyleRule> get sizedBox =>
      NakiStyleRegistry.once('SizedBox', [Rules.nakiSizedBoxRules]);

  @css
  static List<StyleRule> get aspectRatio =>
      NakiStyleRegistry.once('AspectRatio', [Rules.nakiAspectRatioRules]);

  @css
  static List<StyleRule> get stack =>
      NakiStyleRegistry.once('Stack', [Rules.nakiStackRules]);
}
