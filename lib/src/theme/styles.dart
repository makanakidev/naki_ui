import 'package:jaspr/dom.dart';

import '../styles/rules.dart';

/// Pure CSS rules for theme foundation.
abstract final class ThemeStyles {
  @css
  static List<StyleRule> get foundation => NakiStyleRegistry.once(
    'Foundation',
    Rules.nakiFoundationRules,
  );
}
