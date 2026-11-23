import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for overlay components.
abstract final class OverlaysStyles {
  @css
  static List<StyleRule> get dialog =>
      NakiStyleRegistry.once('Dialog', Rules.nakiDialogRules);

  @css
  static List<StyleRule> get calendarModal => NakiStyleRegistry.once(
    'CalendarModal',
    [...Rules.nakiDialogRules, ...Rules.nakiCalendarRules],
  );

  @css
  static List<StyleRule> get popover =>
      NakiStyleRegistry.once('Popover', Rules.nakiPopoverRules);

  @css
  static List<StyleRule> get tooltip =>
      NakiStyleRegistry.once('Tooltip', [Rules.nakiTooltipRules]);

  @css
  static List<StyleRule> get bottomSheet =>
      NakiStyleRegistry.once('BottomSheet', Rules.nakiBottomSheetRules);

  @css
  static List<StyleRule> get drawer =>
      NakiStyleRegistry.once('Drawer', Rules.nakiDrawerRules);

  @css
  static List<StyleRule> get snackbar =>
      NakiStyleRegistry.once('Snackbar', [Rules.nakiSnackbarRules]);

  @css
  static List<StyleRule> get sidebar =>
      NakiStyleRegistry.once('Sidebar', Rules.nakiSidebarRules);
}
