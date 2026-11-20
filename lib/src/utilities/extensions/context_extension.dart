part of 'index.dart';

/// Extension on [BuildContext] for accessing Naki
/// theme state and properties.
extension ContextExtension on BuildContext {
  /// Toggles between dark, light and system theme modes.
  ///
  /// The component where this method is used must be a descendant of
  /// [NakiThemeProvider], otherwise this operation will silently fail.
  void toggleTheme() => NakiThemeProvider.toggleMode(this);

  /// Sets the global theme to the provided [mode].
  ///
  /// The component where this method is used must be a descendant of
  /// [NakiThemeProvider], otherwise this operation will silently fail.
  void setTheme(ThemeMode mode) => NakiThemeProvider.setMode(this, mode);

  /// Returns the active theme mode for this context.
  ///
  /// Defaults to [ThemeMode.system] if no [NakiThemeProvider] ancestor is found.
  ThemeMode get themeMode => NakiThemeProvider.modeOf(this);

  /// Returns the design tokens for the active theme in this context.
  ///
  /// Defaults to global tokens if no [NakiThemeProvider] ancestor is found.
  Tokens get themeTokens => NakiThemeProvider.tokensOf(this);

  // /////////////////////
  // ACCESS COLOR TOKEN VALUES
  // /////////////////////

  // Brand Colors

  /// Primary color.
  Color get primaryColor => themeTokens.primaryColor.color!;

  /// Secondary color.
  Color get secondaryColor => themeTokens.secondaryColor.color!;

  /// Accent color.
  Color get accentColor => themeTokens.accentColor.color!;

  // Base Accent Colors

  /// Green accent color.
  Color get green => themeTokens.green.color!;

  /// Yellow accent color.
  Color get yellow => themeTokens.yellow.color!;

  /// Red accent/danger color.
  Color get red => themeTokens.red.color!;

  // Text & Background Colors

  /// Default text color.
  Color get textColor => themeTokens.baseTextColor.color!;

  /// Default text placeholder color.
  Color get placeholderColor => themeTokens.placeholderColor.color!;

  /// Muted background/foreground color.
  Color get mutedColor => themeTokens.mutedColor.color!;

  /// Subtitle or secondary text color.
  Color get subtitleColor => themeTokens.subtitleColor.color!;

  // Selection Colors

  /// Selected item color.
  Color get selectedItemColor => themeTokens.selectedItemColor.color!;

  /// Selected text background color.
  Color get selectedTextBgColor => themeTokens.selectedTextBgColor.color!;

  /// Selected text color.
  Color get selectedTextColor => themeTokens.selectedTextColor.color!;

  /// Selected item background color.
  Color get selectedItemBgColor => themeTokens.selectedItemBgColor.color!;

  // Surface & Background Colors

  /// Root background color.
  Color get backgroundColor => themeTokens.backgroundColor.color!;

  /// Alias for surface variant color.
  Color get surfaceColor => themeTokens.surfaceVariantColor.color!;

  /// Secondary surface background color variation.
  Color get surfaceVariantColor => themeTokens.surfaceVariantColor.color!;

  /// Muted background color for container surfaces.
  Color get surfaceMutedColor => themeTokens.surfaceMutedColor.color!;

  // Border & Status Colors

  /// Default border color.
  Color get borderColor => themeTokens.borderColor.color!;

  /// Error state color.
  Color get errorColor => themeTokens.errorColor.color!;

  /// Success state color.
  Color get successColor => themeTokens.successColor.color!;

  /// Warning state color.
  Color get warningColor => themeTokens.warningColor.color!;

  /// Info state color.
  Color get infoColor => themeTokens.infoColor.color!;

  // Weak Callout Colors

  /// Weak background color for error callouts.
  Color get errorWeakColor => themeTokens.errorWeakColor.color!;

  /// Weak background color for success callouts.
  Color get successWeakColor => themeTokens.successWeakColor.color!;

  /// Weak background color for warning callouts.
  Color get warningWeakColor => themeTokens.warningWeakColor.color!;

  /// Weak background color for info callouts.
  Color get infoWeakColor => themeTokens.infoWeakColor.color!;

  // Shadow Colors

  /// Shadow overlay color.
  Color get shadowColor => themeTokens.shadowColor.color!;

  /// Small shadow overlay color.
  Color get smallShadowColor => themeTokens.smallShadowColor.color!;

  /// Medium shadow overlay color.
  Color get mediumShadowColor => themeTokens.mediumShadowColor.color!;

  /// Large shadow overlay color.
  Color get largeShadowColor => themeTokens.largeShadowColor.color!;

  // Interactive & State Component Colors

  /// Hover background color for buttons.
  Color get buttonHoverColor => themeTokens.buttonHoverBgColor.color!;

  /// Hover color for components.
  Color get hoverColor => themeTokens.hoverColor.color!;

  /// Border color for focused components.
  Color get focusBorderColor => themeTokens.focusBorderColor.color!;

  /// Border color for hovered inputs.
  Color get fieldHoverColor => themeTokens.fieldHoverColor.color!;

  /// Background color for disabled components.
  Color get disabledBgColor => themeTokens.disabledBgColor.color!;

  /// Color for disabled components.
  Color get disabledColor => themeTokens.disabledColor.color!;

  /// Spinner track color.
  Color get spinnerTrackColor => themeTokens.spinnerTrackColor.color!;

  /// Spinner surface color.
  Color get spinnerSurfaceColor => themeTokens.spinnerSurfaceColor.color!;

  /// Background color for dropdown menu.
  Color get dropdownMenuBgColor => themeTokens.dropdownMenuBgColor.color!;

  /// Text color inside input fields.
  Color get inputTextColor => themeTokens.inputTextColor.color!;

  /// Form field label color.
  Color get labelColor => themeTokens.labelColor.color!;

  /// Button background color.
  Color get buttonBackgroundColor => themeTokens.buttonBackgroundColor.color!;

  /// Button foreground color.
  Color get buttonForegroundColor => themeTokens.buttonForegroundColor.color!;

  /// Form field background color.
  Color get fieldBackgroundColor => themeTokens.fieldBackgroundColor.color!;

  /// Slider thumb color.
  Color get sliderThumbColor => themeTokens.sliderThumbColor.color!;

  /// Slider track color.
  Color get sliderTrackColor => themeTokens.sliderTrackColor.color!;

  /// Switch thumb color.
  Color get switchThumbColor => themeTokens.switchThumbColor.color!;

  /// Radio button color.
  Color get radioBtnColor => themeTokens.radioBtnColor.color!;

  /// Appbar background color.
  Color get appbarBgColor => themeTokens.appbarBgColor.color!;

  /// Bottom navigation bar background color.
  Color get bottomNavbarBgColor => themeTokens.bottomNavbarBgColor.color!;

  // Table & Overlay Colors

  /// Table header background color.
  Color get tableHeaderBg => themeTokens.tableHeaderBg.color!;

  /// Table row hover background color.
  Color get tableRowHoverBg => themeTokens.tableRowHoverBg.color!;

  /// Table header border color.
  Color get tableHeaderBorderColor => themeTokens.tableHeaderBorderColor.color!;

  /// Snackbar background color.
  Color get snackbarBgColor => themeTokens.snackbarBgColor.color!;

  /// Snackbar foreground color.
  Color get snackbarForegroundColor =>
      themeTokens.snackbarForegroundColor.color!;

  /// Banner background color.
  Color get bannerBgColor => themeTokens.bannerBgColor.color!;

  /// Banner foreground color.
  Color get bannerForegroundColor => themeTokens.bannerForegroundColor.color!;

  /// Banner border color.
  Color get bannerBorderColor => themeTokens.bannerBorderColor.color!;

  /// Tooltip background color.
  Color get tooltipBgColor => themeTokens.tooltipBgColor.color!;

  /// Tooltip text color.
  Color get tooltipTextColor => themeTokens.tooltipTextColor.color!;

  /// Popover background color.
  Color get popoverBgColor => themeTokens.popoverBgColor.color!;

  /// Popover text color.
  Color get popoverTextColor => themeTokens.popoverTextColor.color!;

  /// Popover border color.
  Color get popoverBorderColor => themeTokens.popoverBorderColor.color!;

  /// Dialog background color.
  Color get dialogBgColor => themeTokens.dialogBgColor.color!;

  /// Dialog barrier backdrop color.
  Color get dialogBarrierBg => themeTokens.dialogBarrierBg.color!;

  /// Drawer background color.
  Color get drawerBgColor => themeTokens.drawerBgColor.color!;

  /// Drawer barrier backdrop color.
  Color get drawerBarrierBg => themeTokens.drawerBarrierBg.color!;

  /// BottomSheet background color.
  Color get bottomSheetBgColor => themeTokens.bottomSheetBgColor.color!;

  /// BottomSheet barrier backdrop color.
  Color get bottomSheetBarrierBg => themeTokens.bottomSheetBarrierBg.color!;
}

final _timeAgoNotifiers = <String, ValueNotifier<String>>{};
