part of 'theme_data.dart';

// /////////////////////////////////////////////////////////////////////////////
// NAKI THEME MODE TOKENS
// /////////////////////////////////////////////////////////////////////////////

/// Default light theme mode tokens extending [Tokens].
class _LightModeTokens extends Tokens {
  /// Creates a [_LightModeTokens] instance.
  const _LightModeTokens([super.customVariables]);

  @override
  String get colorScheme => 'light';
}

/// Dark theme mode tokens extending [Tokens], overriding
/// color-related variables for dark theme.
class _DarkModeTokens extends Tokens {
  /// Creates a [_DarkModeTokens] instance.
  const _DarkModeTokens([super.customVariables]);

  @override
  String get colorScheme => 'dark';

  // Brand Color Overrides

  @override
  String get primaryColorValue => '#3182ce';

  @override
  String get secondaryColorValue => '#64748b';

  @override
  String get accentColorValue => '#059669';

  // Base Color Overrides

  /// Green accent color (dark: `#4ade80`).
  @override
  String get greenValue => '#4ade80';

  /// Yellow accent color (dark: `#fbbf24`).
  @override
  String get yellowValue => '#fbbf24';

  /// Red accent color (dark: `#ff3d00`).
  @override
  String get redValue => '#ff3d00';

  /// Default text placeholder color (dark: `#94a3b8`).
  @override
  String get placeholderColorValue => '#94a3b8';

  /// Muted background/foreground color (dark: `#94a3b8`).
  @override
  String get mutedColorValue => '#94a3b8';

  /// Subtitle or secondary text color (dark: `#94a3b8`).
  @override
  String get subtitleColorValue => '#94a3b8';

  /// Selected item color for dropdowns and list items (dark: `#0f172a`).
  @override
  String get selectedItemColorValue => '#0f172a';

  /// Selected text background color (dark: `#60a5fa`).
  @override
  String get selectedTextBgColorValue => '#60a5fa';

  /// Selected text color (dark: `#0f172a`).
  @override
  String get selectedTextColorValue => '#0f172a';

  /// Selected item background color for dropdowns
  /// and list items (dark: `#60a5fa`).
  @override
  String get selectedItemBgColorValue => '#60a5fa';

  /// Root background color (dark: `#0f172a`).
  @override
  String get backgroundColorValue => '#0f172a';

  /// Default border color (dark: `#64748b`).
  @override
  String get borderColorValue => '#64748b';

  /// Error state color (dark: `#f43f5e`).
  @override
  String get errorColorValue => '#f43f5e';

  /// Success state color (dark: `#4ade80`).
  @override
  String get successColorValue => '#4ade80';

  /// Warning state color (dark: `#fbbf24`).
  @override
  String get warningColorValue => '#fbbf24';

  /// Info state color (dark: `#60a5fa`).
  @override
  String get infoColorValue => '#60a5fa';

  /// Weak background color for error/alert callouts (dark: `#3f1d24`).
  @override
  String get errorWeakColorValue => '#3f1d24';

  /// Weak background color for success callouts (dark: `#132e19`).
  @override
  String get successWeakColorValue => '#132e19';

  /// Weak background color for warning callouts (dark: `#362415`).
  @override
  String get warningWeakColorValue => '#362415';

  /// Weak background color for info callouts (dark: `#162a3d`).
  @override
  String get infoWeakColorValue => '#162a3d';

  /// Secondary surface background color variation (dark: `#334155`).
  @override
  String get surfaceVariantColorValue => '#334155';

  /// Muted background color for container surfaces (dark: `#1e293b`).
  @override
  String get surfaceMutedColorValue => '#1e293b';

  // Shadow Color Overrides

  /// Default shadow color (dark: `rgba(0, 0, 0, 0.4)`).
  @override
  String get shadowColorValue => 'rgba(0, 0, 0, 0.4)';

  /// Small shadow color (dark: `rgba(0, 0, 0, 0.3)`).
  @override
  String get smallShadowColorValue => 'rgba(0, 0, 0, 0.3)';

  /// Medium shadow color (dark: `rgba(0, 0, 0, 0.5)`).
  @override
  String get mediumShadowColorValue => 'rgba(0, 0, 0, 0.5)';

  /// Large shadow color (dark: `rgba(0, 0, 0, 0.6)`).
  @override
  String get largeShadowColorValue => 'rgba(0, 0, 0, 0.6)';

  // State Color Overrides

  /// Hover background color for buttons (dark: `#334155`).
  @override
  String get buttonHoverBgColorValue => '#334155';

  /// Hover color for components (dark: `#334155`).
  @override
  String get hoverColorValue => '#334155';

  /// Border color for focused components (dark: `#60a5fa`).
  @override
  String get focusBorderColorValue => '#60a5fa';

  /// Border color for hovered form fields (dark: `#64748b`).
  @override
  String get fieldHoverColorValue => '#64748b';

  /// Background color for disabled components (dark: `#334155`).
  @override
  String get disabledBgColorValue => '#334155';

  /// Foreground color for disabled components (dark: `#94a3b8`).
  @override
  String get disabledColorValue => '#94a3b8';

  // Component Color Overrides

  /// Background color for dropdown menu (dark: `#1e293b`).
  @override
  String get dropdownMenuBgColorValue => '#1e293b';

  /// Text color inside input fields (dark: `#f8fafc`).
  @override
  String get inputTextColorValue => '#f8fafc';

  /// Form field label color (dark: `#94a3b8`).
  @override
  String get labelColorValue => '#94a3b8';

  /// Base text color (dark: `#f8fafc`).
  @override
  String get baseTextColorValue => '#f8fafc';

  /// Button background color (dark: `white`).
  @override
  String get buttonBackgroundColorValue => 'white';

  /// Button foreground color (dark: `black`).
  @override
  String get buttonForegroundColorValue => 'black';

  /// Form field background color (dark: `#1e293b`).
  @override
  String get fieldBackgroundColorValue => '#1e293b';

  // Selection Component Overrides

  /// Slider thumb color (dark: `primary color`).
  @override
  String get sliderThumbColorValue => primaryColorValue;

  /// Slider track color (dark: `secondary color`).
  @override
  String get sliderTrackColorValue => secondaryColorValue;

  /// Switch thumb color (dark: `primary color`).
  @override
  String get switchThumbColorValue => primaryColorValue;

  /// Radio button color (dark: `primary color`).
  @override
  String get radioBtnColorValue => primaryColorValue;

  /// Appbar background color (dark: `#1e293b`).
  @override
  String get appbarBgColorValue => '#1e293b';

  /// Bottom navbar background color (dark: `#1e293b`).
  @override
  String get bottomNavbarBgColorValue => '#1e293b';

  /// Frosted glass bottom navbar tint (dark: `30%`).
  @override
  String get bottomNavbarGlassTintValue => '30%';

  /// Frosted glass bottom navbar rim strength (dark: `40%`).
  @override
  String get bottomNavbarGlassRimValue => '40%';

  /// Frosted glass bottom navbar droplet backplate (dark: `50%`).
  @override
  String get bottomNavbarGlassDropletValue => '50%';

  // Scrolling Component Overrides

  /// Table header background color (dark: `transparent`).
  @override
  String get tableHeaderBgValue => 'transparent';

  /// Table row hover background color (dark: `transparent`).
  @override
  String get tableRowHoverBgValue => 'transparent';

  /// Table header border color (dark: `"#64748b"`).
  @override
  String get tableHeaderBorderColorValue => '#64748b';

  // Spinner Component Overrides

  /// Spinner track color (dark: `rgba(255, 255, 255, 0.15)`).
  @override
  String get spinnerTrackColorValue => 'rgba(255, 255, 255, 0.15)';

  /// Spinner glass surface color (dark: `#1e293b`).
  @override
  String get spinnerSurfaceColorValue => '#1e293b';

  /// Card and dialog glass tint (dark: `30%`).
  @override
  String get glassTintValue => '30%';

  /// Card and dialog glass rim strength (dark: `40%`).
  @override
  String get glassRimValue => '40%';

  /// Spinner glass rim strength (dark: `40%`).
  @override
  String get spinnerGlassRimValue => '40%';

  // Overlay Component Overrides

  /// Snackbar background color (dark: `#1e293b`).
  @override
  String get snackbarBgColorValue => '#1e293b';

  /// Snackbar foreground color (dark: `#f8fafc`).
  @override
  String get snackbarForegroundColorValue => '#f8fafc';

  /// Banner background color (dark: `#1e293b`).
  @override
  String get bannerBgColorValue => '#1e293b';

  /// Banner foreground color (dark: `#f8fafc`).
  @override
  String get bannerForegroundColorValue => '#f8fafc';

  /// Banner border color (dark: `#64748b`).
  @override
  String get bannerBorderColorValue => '#64748b';

  /// Tooltip background color (dark: `#334155`).
  @override
  String get tooltipBgColorValue => '#334155';

  /// Tooltip text color (dark: `#f8fafc`).
  @override
  String get tooltipTextColorValue => '#f8fafc';

  /// Popover background color (dark: `#1e293b`).
  @override
  String get popoverBgColorValue => '#1e293b';

  /// Popover text color (dark: `#f8fafc`).
  @override
  String get popoverTextColorValue => '#f8fafc';

  /// Popover border color (dark: `#334155`).
  @override
  String get popoverBorderColorValue => '#334155';

  /// Popover box shadow
  /// (dark: `0 10px 15px -3px rgba(0, 0, 0, 0.4),
  /// 0 4px 6px -4px rgba(0, 0, 0, 0.4)`).
  @override
  String get popoverShadowValue =>
      '0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -4px rgba(0, 0, 0, 0.4)';

  /// Dialog background color (dark: `#1e293b`).
  @override
  String get dialogBgColorValue => '#1e293b';

  /// Dialog barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get dialogBarrierBgValue => 'rgba(0, 0, 0, 0.7)';

  /// Drawer background color (dark: `#1e293b`).
  @override
  String get drawerBgColorValue => '#1e293b';

  /// Drawer barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get drawerBarrierBgValue => 'rgba(0, 0, 0, 0.7)';

  /// BottomSheet background color (dark: `#1e293b`).
  @override
  String get bottomSheetBgColorValue => '#1e293b';

  /// BottomSheet barrier backdrop color (dark: `rgba(0, 0, 0, 0.7)`).
  @override
  String get bottomSheetBarrierBgValue => 'rgba(0, 0, 0, 0.7)';

  /// BottomSheet drag handle color (dark: `rgba(148, 163, 184, 0.4)`).
  @override
  String get bottomSheetHandleColorValue => 'rgba(148, 163, 184, 0.4)';
}
