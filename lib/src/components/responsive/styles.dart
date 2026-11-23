import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for responsive layout components.
abstract final class ResponsiveStyles {
  @css
  static List<StyleRule> get responsiveLayout =>
      NakiStyleRegistry.once('ResponsiveLayout', Rules.nakiBreakpointRules);
}
