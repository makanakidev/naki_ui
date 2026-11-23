import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for scaffold components.
abstract final class ScaffoldStyles {
  @css
  static List<StyleRule> get scaffold =>
      NakiStyleRegistry.once('Scaffold', [Rules.nakiScaffoldRules]);

  @css
  static List<StyleRule> get appBar =>
      NakiStyleRegistry.once('AppBar', [Rules.nakiAppBarRules]);

  @css
  static List<StyleRule> get bottomNavigationBar => NakiStyleRegistry.once(
    'BottomNavBar',
    [Rules.nakiBottomNavBarRules],
  );
}
