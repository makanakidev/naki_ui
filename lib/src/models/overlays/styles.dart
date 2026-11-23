import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for overlay model hosts.
abstract final class OverlayModelStyles {
  @css
  static List<StyleRule> get overlayHost =>
      NakiStyleRegistry.once('OverlayHost', [Rules.nakiContentBoxRules]);
}
