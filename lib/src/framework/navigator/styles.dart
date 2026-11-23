import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for navigation components.
abstract final class NavigatorStyles {
  @css
  static List<StyleRule> get rules => NakiStyleRegistry.once('Navigator', [
    Rules.nakiHideRules,
  ]);
}
