import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for painting components.
abstract final class PaintingStyles {
  @css
  static List<StyleRule> get clipOval =>
      NakiStyleRegistry.once('ClipOval', [Rules.nakiClipOvalRules]);

  @css
  static List<StyleRule> get visibility =>
      NakiStyleRegistry.once('Visibility', [Rules.nakiHideRules]);

  @css
  static List<StyleRule> get clipRect =>
      NakiStyleRegistry.once('ClipRect', [Rules.nakiClipRectRules]);
}
