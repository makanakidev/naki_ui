part of 'theme.dart';

/// Theme data for dark mode used in [ThemeConfig].
///
/// Allows customization of colors, typography, spacing, borders, elevation,
/// border radius, shapes, and component-specific token overrides.
class DarkThemeData extends _DarkModeTokens {
  /// Seed for customizing base and semantic color tokens.
  final ColorSeed? colorSeed;

  /// Seed for customizing font family, sizes, and weights.
  final TypographyScheme? typography;

  /// Seed for customizing global padding and margin spacing tokens.
  final SpacingScheme? spacing;

  /// Seed for customizing border width tokens.
  final BorderScheme? borderWidth;

  /// Seed for customizing shadow and elevation color tokens.
  final ElevationScheme? elevation;

  /// Seed for customizing border radius tokens.
  final RadiusScheme? radius;

  /// Seed for customizing component-specific token overrides.
  final ComponentScheme? component;

  /// Custom CSS key-value variables to inject into dark mode styles.
  final Map<String, String>? styles;

  const DarkThemeData({
    this.colorSeed,
    this.typography,
    this.spacing,
    this.borderWidth,
    this.elevation,
    this.radius,
    this.component,
    this.styles,
  }) : super(styles);

  @override
  String get colorScheme => 'dark';

  // ===========================================================================
  // Color Tokens Overrides (String Values)
  // ===========================================================================

  @override
  String get primaryColorValue =>
      colorSeed?.primary?.value ?? super.primaryColorValue;

  @override
  String get secondaryColorValue =>
      colorSeed?.secondary?.value ?? super.secondaryColorValue;

  @override
  String get accentColorValue =>
      colorSeed?.accent?.value ?? super.accentColorValue;

  @override
  String get greenValue => colorSeed?.green?.value ?? super.greenValue;

  @override
  String get yellowValue => colorSeed?.yellow?.value ?? super.yellowValue;

  @override
  String get redValue => colorSeed?.red?.value ?? super.redValue;

  @override
  String get baseTextColorValue =>
      colorSeed?.baseTextColor?.value ?? super.baseTextColorValue;

  @override
  String get placeholderColorValue =>
      colorSeed?.placeholderColor?.value ?? super.placeholderColorValue;

  @override
  String get mutedColorValue =>
      colorSeed?.mutedColor?.value ?? super.mutedColorValue;

  @override
  String get subtitleColorValue =>
      colorSeed?.subtitleColor?.value ?? super.subtitleColorValue;

  @override
  String get selectedItemColorValue =>
      colorSeed?.selectedItemColor?.value ?? super.selectedItemColorValue;

  @override
  String get selectedTextBgColorValue =>
      colorSeed?.selectedTextBackgroundColor?.value ??
      super.selectedTextBgColorValue;

  @override
  String get selectedTextColorValue =>
      colorSeed?.selectedTextColor?.value ?? super.selectedTextColorValue;

  @override
  String get selectedItemBgColorValue =>
      colorSeed?.selectedItemBackgroundColor?.value ??
      super.selectedItemBgColorValue;

  @override
  String get backgroundColorValue =>
      colorSeed?.backgroundColor?.value ?? super.backgroundColorValue;

  @override
  String get borderColorValue =>
      borderWidth?.borderColor?.value ?? super.borderColorValue;

  @override
  String get errorColorValue =>
      colorSeed?.errorColor?.value ?? super.errorColorValue;

  @override
  String get successColorValue =>
      colorSeed?.successColor?.value ?? super.successColorValue;

  @override
  String get warningColorValue =>
      colorSeed?.warningColor?.value ?? super.warningColorValue;

  @override
  String get infoColorValue =>
      colorSeed?.infoColor?.value ?? super.infoColorValue;

  @override
  String get errorWeakColorValue =>
      colorSeed?.errorWeakColor?.value ?? super.errorWeakColorValue;

  @override
  String get successWeakColorValue =>
      colorSeed?.successWeakColor?.value ?? super.successWeakColorValue;

  @override
  String get warningWeakColorValue =>
      colorSeed?.warningWeakColor?.value ?? super.warningWeakColorValue;

  @override
  String get infoWeakColorValue =>
      colorSeed?.infoWeakColor?.value ?? super.infoWeakColorValue;

  @override
  String get surfaceVariantColorValue =>
      colorSeed?.surfaceVariantColor?.value ?? super.surfaceVariantColorValue;

  @override
  String get surfaceMutedColorValue =>
      colorSeed?.surfaceMutedColor?.value ?? super.surfaceMutedColorValue;

  @override
  String get shadowColorValue =>
      elevation?.shadowColor?.value ?? super.shadowColorValue;

  @override
  String get smallShadowColorValue =>
      elevation?.smallShadowColor?.value ?? super.smallShadowColorValue;

  @override
  String get mediumShadowColorValue =>
      elevation?.mediumShadowColor?.value ?? super.mediumShadowColorValue;

  @override
  String get largeShadowColorValue =>
      elevation?.largeShadowColor?.value ?? super.largeShadowColorValue;

  @override
  String get focusBorderColorValue =>
      colorSeed?.focusBorderColor?.value ?? super.focusBorderColorValue;

  @override
  String get hoverColorValue =>
      colorSeed?.hoverColor?.value ?? super.hoverColorValue;

  @override
  String get disabledBgColorValue =>
      colorSeed?.disabledBackgroundColor?.value ?? super.disabledBgColorValue;

  @override
  String get disabledColorValue =>
      colorSeed?.disabledColor?.value ?? super.disabledColorValue;

  // ===========================================================================
  // Border Tokens Overrides
  // ===========================================================================

  @override
  Token get border => borderWidth?.borderWidth != null
      ? Token(
          value:
              '${borderWidth!.borderWidth!.cssText} solid var($borderColor, ${borderColor.value})',
          name: super.border.name,
        )
      : super.border;

  @override
  Token get fieldHoverBorder => borderWidth?.fieldHoverBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.fieldHoverBorderWidth!.cssText} solid var($fieldHoverColor, ${fieldHoverColor.value})',
          name: super.fieldHoverBorder.name,
        )
      : super.fieldHoverBorder;

  @override
  Token get focusBorder => borderWidth?.focusBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.focusBorderWidth!.cssText} solid var($focusBorderColor, ${focusBorderColor.value})',
          name: super.focusBorder.name,
        )
      : super.focusBorder;

  @override
  Token get errorBorder => borderWidth?.errorBorderWidth != null
      ? Token(
          value:
              '${borderWidth!.errorBorderWidth!.cssText} solid var($errorColor, ${errorColor.value})',
          name: super.errorBorder.name,
        )
      : super.errorBorder;

  // ===========================================================================
  // Typography Tokens Overrides
  // ===========================================================================

  @override
  Token get fontFamily =>
      typography?.fontFamily != null && typography!.fontFamily!.isNotEmpty
      ? Token(
          value: _normaliseFontFamily(typography!.fontFamily!),
          name: super.fontFamily.name,
        )
      : super.fontFamily;

  @override
  Token get fontSizeSm => typography?.fontSizeSm != null
      ? Token(
          value: typography!.fontSizeSm!.cssText,
          name: super.fontSizeSm.name,
        )
      : super.fontSizeSm;

  @override
  Token get fontSizeMd => typography?.fontSizeMd != null
      ? Token(
          value: typography!.fontSizeMd!.cssText,
          name: super.fontSizeMd.name,
        )
      : super.fontSizeMd;

  @override
  Token get fontSizeLg => typography?.fontSizeLg != null
      ? Token(
          value: typography!.fontSizeLg!.cssText,
          name: super.fontSizeLg.name,
        )
      : super.fontSizeLg;

  @override
  Token get fontSizeXl => typography?.fontSizeXl != null
      ? Token(
          value: typography!.fontSizeXl!.cssText,
          name: super.fontSizeXl.name,
        )
      : super.fontSizeXl;

  @override
  Token get fontSize2xl => typography?.fontSize2xl != null
      ? Token(
          value: typography!.fontSize2xl!.cssText,
          name: super.fontSize2xl.name,
        )
      : super.fontSize2xl;

  @override
  Token get fontSize3xl => typography?.fontSize3xl != null
      ? Token(
          value: typography!.fontSize3xl!.cssText,
          name: super.fontSize3xl.name,
        )
      : super.fontSize3xl;

  @override
  Token get fontSize4xl => typography?.fontSize4xl != null
      ? Token(
          value: typography!.fontSize4xl!.cssText,
          name: super.fontSize4xl.name,
        )
      : super.fontSize4xl;

  @override
  Token get fontSize5xl => typography?.fontSize5xl != null
      ? Token(
          value: typography!.fontSize5xl!.cssText,
          name: super.fontSize5xl.name,
        )
      : super.fontSize5xl;

  @override
  Token get fontSizeError => typography?.fontSizeError != null
      ? Token(
          value: typography!.fontSizeError!.cssText,
          name: super.fontSizeError.name,
        )
      : super.fontSizeError;

  @override
  Token get fontSizeHint => typography?.fontSizeHint != null
      ? Token(
          value: typography!.fontSizeHint!.cssText,
          name: super.fontSizeHint.name,
        )
      : super.fontSizeHint;

  @override
  Token get fontSizeLabel => typography?.fontSizeLabel != null
      ? Token(
          value: typography!.fontSizeLabel!.cssText,
          name: super.fontSizeLabel.name,
        )
      : super.fontSizeLabel;

  @override
  Token get fontSizeSectionHeader => typography?.fontSizeSectionHeader != null
      ? Token(
          value: typography!.fontSizeSectionHeader!.cssText,
          name: super.fontSizeSectionHeader.name,
        )
      : super.fontSizeSectionHeader;

  @override
  Token get fontWeightNormal => typography?.fontWeightNormal != null
      ? Token(
          value: typography!.fontWeightNormal.toString(),
          name: super.fontWeightNormal.name,
        )
      : super.fontWeightNormal;

  @override
  Token get fontWeightMedium => typography?.fontWeightMedium != null
      ? Token(
          value: typography!.fontWeightMedium.toString(),
          name: super.fontWeightMedium.name,
        )
      : super.fontWeightMedium;

  @override
  Token get fontWeightSemiBold => typography?.fontWeightSemiBold != null
      ? Token(
          value: typography!.fontWeightSemiBold.toString(),
          name: super.fontWeightSemiBold.name,
        )
      : super.fontWeightSemiBold;

  @override
  Token get fontWeightBold => typography?.fontWeightBold != null
      ? Token(
          value: typography!.fontWeightBold.toString(),
          name: super.fontWeightBold.name,
        )
      : super.fontWeightBold;

  @override
  Token get fontWeightSectionHeader =>
      typography?.fontWeightSectionHeader != null
      ? Token(
          value: typography!.fontWeightSectionHeader.toString(),
          name: super.fontWeightSectionHeader.name,
        )
      : super.fontWeightSectionHeader;

  // ===========================================================================
  // Spacing Tokens Overrides
  // ===========================================================================

  @override
  Token get paddingSm => spacing?.paddingSm != null
      ? Token(value: spacing!.paddingSm!.cssText, name: super.paddingSm.name)
      : super.paddingSm;

  @override
  Token get paddingMd => spacing?.paddingMd != null
      ? Token(value: spacing!.paddingMd!.cssText, name: super.paddingMd.name)
      : super.paddingMd;

  @override
  Token get paddingLg => spacing?.paddingLg != null
      ? Token(value: spacing!.paddingLg!.cssText, name: super.paddingLg.name)
      : super.paddingLg;

  @override
  Token get marginSm => spacing?.marginSm != null
      ? Token(value: spacing!.marginSm!.cssText, name: super.marginSm.name)
      : super.marginSm;

  @override
  Token get marginMd => spacing?.marginMd != null
      ? Token(value: spacing!.marginMd!.cssText, name: super.marginMd.name)
      : super.marginMd;

  @override
  Token get marginLg => spacing?.marginLg != null
      ? Token(value: spacing!.marginLg!.cssText, name: super.marginLg.name)
      : super.marginLg;

  // ===========================================================================
  // Border Radius Tokens Overrides
  // ===========================================================================

  @override
  Token get radiusSm => radius?.radiusSm != null
      ? Token(value: radius!.radiusSm!.cssText, name: super.radiusSm.name)
      : super.radiusSm;

  @override
  Token get radiusMd => radius?.radiusMd != null
      ? Token(value: radius!.radiusMd!.cssText, name: super.radiusMd.name)
      : super.radiusMd;

  @override
  Token get radiusLg => radius?.radiusLg != null
      ? Token(value: radius!.radiusLg!.cssText, name: super.radiusLg.name)
      : super.radiusLg;

  // ===========================================================================
  // Component Tokens Overrides
  // ===========================================================================

  @override
  Token get textMaxLines => component?.textMaxLines != null
      ? Token(
          value: component!.textMaxLines.toString(),
          name: super.textMaxLines.name,
        )
      : super.textMaxLines;

  @override
  Token get inputHeight => component?.inputHeight != null
      ? Token(
          value: component!.inputHeight!.cssText,
          name: super.inputHeight.name,
        )
      : super.inputHeight;

  @override
  String get inputTextColorValue =>
      component?.inputTextColor?.value ?? super.inputTextColorValue;

  @override
  String get labelColorValue =>
      component?.labelColor?.value ?? super.labelColorValue;

  @override
  Token get fontSizeInput => component?.fontSizeInput != null
      ? Token(
          value: component!.fontSizeInput!.cssText,
          name: super.fontSizeInput.name,
        )
      : super.fontSizeInput;

  @override
  String get fieldBackgroundColorValue =>
      component?.fieldBackgroundColor?.value ?? super.fieldBackgroundColorValue;

  @override
  String get fieldHoverColorValue =>
      component?.fieldHoverColor?.value ?? super.fieldHoverColorValue;

  @override
  String get buttonBackgroundColorValue =>
      component?.buttonBackgroundColor?.value ??
      super.buttonBackgroundColorValue;

  @override
  String get buttonForegroundColorValue =>
      component?.buttonColor?.value ?? super.buttonForegroundColorValue;

  @override
  String get buttonHoverBgColorValue =>
      component?.buttonHoverBgColor?.value ?? super.buttonHoverBgColorValue;

  @override
  Token get buttonHeight => component?.buttonHeight != null
      ? Token(
          value: component!.buttonHeight!.cssText,
          name: super.buttonHeight.name,
        )
      : super.buttonHeight;

  @override
  Token get buttonWidth => component?.buttonWidth != null
      ? Token(
          value: component!.buttonWidth!.cssText,
          name: super.buttonWidth.name,
        )
      : super.buttonWidth;

  @override
  Token get dropdownHeight => component?.dropdownHeight != null
      ? Token(
          value: component!.dropdownHeight!.cssText,
          name: super.dropdownHeight.name,
        )
      : super.dropdownHeight;

  @override
  Token get dropdownWidth => component?.dropdownWidth != null
      ? Token(
          value: component!.dropdownWidth!.cssText,
          name: super.dropdownWidth.name,
        )
      : super.dropdownWidth;

  @override
  Token get dropdownMenuHeight => component?.dropdownMenuHeight != null
      ? Token(
          value: component!.dropdownMenuHeight!.cssText,
          name: super.dropdownMenuHeight.name,
        )
      : super.dropdownMenuHeight;

  @override
  String get dropdownMenuBgColorValue =>
      component?.dropdownMenuBackgroundColor?.value ??
      super.dropdownMenuBgColorValue;

  @override
  Token get dropdownOptionFontSize => component?.dropdownOptionFontSize != null
      ? Token(
          value: component!.dropdownOptionFontSize!.cssText,
          name: super.dropdownOptionFontSize.name,
        )
      : super.dropdownOptionFontSize;

  @override
  Token get dropdownOptionPadding => component?.dropdownOptionPadding != null
      ? Token(
          value: component!.dropdownOptionPadding!.cssText,
          name: super.dropdownOptionPadding.name,
        )
      : super.dropdownOptionPadding;

  @override
  Token get spinnerSize => component?.spinnerSize != null
      ? Token(
          value: component!.spinnerSize!.cssText,
          name: super.spinnerSize.name,
        )
      : super.spinnerSize;

  @override
  Token get spinnerBorderWidth => component?.spinnerBorderWidth != null
      ? Token(
          value: component!.spinnerBorderWidth!.cssText,
          name: super.spinnerBorderWidth.name,
        )
      : super.spinnerBorderWidth;

  @override
  String get spinnerTrackColorValue =>
      component?.spinnerTrackColor?.value ?? super.spinnerTrackColorValue;

  @override
  String get spinnerSurfaceColorValue =>
      component?.spinnerSurfaceColor?.value ?? super.spinnerSurfaceColorValue;

  @override
  String get spinnerGlassRimValue =>
      component?.spinnerGlassRim?.toPct ?? super.spinnerGlassRimValue;

  @override
  String get sliderThumbColorValue =>
      component?.sliderThumbColor?.value ?? super.sliderThumbColorValue;

  @override
  String get sliderTrackColorValue =>
      component?.sliderTrackColor?.value ?? super.sliderTrackColorValue;

  @override
  Token get sliderThumbSize => component?.sliderThumbSize != null
      ? Token(
          value: component!.sliderThumbSize!.cssText,
          name: super.sliderThumbSize.name,
        )
      : super.sliderThumbSize;

  @override
  String get switchThumbColorValue =>
      component?.switchThumbColor?.value ?? super.switchThumbColorValue;

  @override
  Token get radioBtnRadius => component?.radioButtonRadius != null
      ? Token(
          value: component!.radioButtonRadius!.cssText,
          name: super.radioBtnRadius.name,
        )
      : super.radioBtnRadius;

  @override
  String get radioBtnColorValue =>
      component?.radioButtonColor?.value ?? super.radioBtnColorValue;

  @override
  String get appbarBgColorValue =>
      component?.appbarBackgroundColor?.value ?? super.appbarBgColorValue;

  @override
  Token get appbarHeight => component?.appbarHeight != null
      ? Token(
          value: component!.appbarHeight!.cssText,
          name: super.appbarHeight.name,
        )
      : super.appbarHeight;

  @override
  String get bottomNavbarBgColorValue =>
      component?.bottomNavbarBackgroundColor?.value ??
      super.bottomNavbarBgColorValue;

  @override
  Token get bottomNavbarHeight => component?.bottomNavbarHeight != null
      ? Token(
          value: component!.bottomNavbarHeight!.cssText,
          name: super.bottomNavbarHeight.name,
        )
      : super.bottomNavbarHeight;

  @override
  String get bottomNavbarGlassTintValue =>
      component?.bottomNavbarGlassTint?.toPct ??
      super.bottomNavbarGlassTintValue;

  @override
  String get bottomNavbarGlassRimValue =>
      component?.bottomNavbarGlassRim?.toPct ?? super.bottomNavbarGlassRimValue;

  @override
  String get bottomNavbarGlassDropletValue =>
      component?.bottomNavbarGlassDroplet?.toPct ??
      super.bottomNavbarGlassDropletValue;

  @override
  Token get bottomNavbarGlassBlur => component?.bottomNavbarGlassBlur != null
      ? Token(
          value: component!.bottomNavbarGlassBlur!.cssText,
          name: super.bottomNavbarGlassBlur.name,
        )
      : super.bottomNavbarGlassBlur;

  @override
  double get bottomNavbarGlassRefractionValue =>
      component?.bottomNavbarGlassRefraction ??
      super.bottomNavbarGlassRefractionValue;

  @override
  String get glassTintValue =>
      component?.glassTint?.toPct ?? super.glassTintValue;

  @override
  String get glassRimValue => component?.glassRim?.toPct ?? super.glassRimValue;

  @override
  Token get glassBlur => component?.glassBlur != null
      ? Token(
          value: component!.glassBlur!.cssText,
          name: super.glassBlur.name,
        )
      : super.glassBlur;

  @override
  Token get carouselItemExtent => component?.carouselItemExtent != null
      ? Token(
          value: component!.carouselItemExtent!.cssText,
          name: super.carouselItemExtent.name,
        )
      : super.carouselItemExtent;

  @override
  Token get carouselGap => component?.carouselGap != null
      ? Token(
          value: component!.carouselGap!.cssText,
          name: super.carouselGap.name,
        )
      : super.carouselGap;

  @override
  String get tableHeaderBgValue =>
      component?.tableHeaderBackgroundColor?.value ?? super.tableHeaderBgValue;

  @override
  String get tableRowHoverBgValue =>
      component?.tableRowHoverColor?.value ?? super.tableRowHoverBgValue;

  @override
  Token get gridGap => component?.gridGap != null
      ? Token(value: component!.gridGap!.cssText, name: super.gridGap.name)
      : super.gridGap;

  @override
  String get snackbarBgColorValue =>
      component?.snackbarBackgroundColor?.value ?? super.snackbarBgColorValue;

  @override
  String get snackbarForegroundColorValue =>
      component?.snackbarForegroundColor?.value ??
      super.snackbarForegroundColorValue;

  @override
  Token get snackbarBorderRadius => component?.snackbarBorderRadius != null
      ? Token(
          value: component!.snackbarBorderRadius!.cssText,
          name: super.snackbarBorderRadius.name,
        )
      : super.snackbarBorderRadius;

  @override
  String get bannerBgColorValue =>
      component?.bannerBackgroundColor?.value ?? super.bannerBgColorValue;

  @override
  String get bannerForegroundColorValue =>
      component?.bannerForegroundColor?.value ??
      super.bannerForegroundColorValue;

  @override
  Token get bannerBorderRadius => component?.bannerBorderRadius != null
      ? Token(
          value: component!.bannerBorderRadius!.cssText,
          name: super.bannerBorderRadius.name,
        )
      : super.bannerBorderRadius;

  @override
  String get bannerBorderColorValue =>
      component?.bannerBorderColor?.value ?? super.bannerBorderColorValue;

  @override
  String get tooltipBgColorValue =>
      component?.tooltipBackgroundColor?.value ?? super.tooltipBgColorValue;

  @override
  String get tooltipTextColorValue =>
      component?.tooltipTextColor?.value ?? super.tooltipTextColorValue;

  @override
  Token get tooltipBorderRadius => component?.tooltipBorderRadius != null
      ? Token(
          value: component!.tooltipBorderRadius!.cssText,
          name: super.tooltipBorderRadius.name,
        )
      : super.tooltipBorderRadius;

  @override
  Token get tooltipFontSize => component?.tooltipFontSize != null
      ? Token(
          value: component!.tooltipFontSize!.cssText,
          name: super.tooltipFontSize.name,
        )
      : super.tooltipFontSize;

  @override
  String get popoverBgColorValue =>
      component?.popoverBackgroundColor?.value ?? super.popoverBgColorValue;

  @override
  String get popoverTextColorValue =>
      component?.popoverTextColor?.value ?? super.popoverTextColorValue;

  @override
  String get popoverBorderColorValue =>
      component?.popoverBorderColor?.value ?? super.popoverBorderColorValue;

  @override
  Token get popoverBorderRadius => component?.popoverBorderRadius != null
      ? Token(
          value: component!.popoverBorderRadius!.cssText,
          name: super.popoverBorderRadius.name,
        )
      : super.popoverBorderRadius;

  @override
  String get dialogBgColorValue =>
      component?.dialogBackgroundColor?.value ?? super.dialogBgColorValue;

  @override
  Token get dialogBorderRadius => component?.dialogBorderRadius != null
      ? Token(
          value: component!.dialogBorderRadius!.cssText,
          name: super.dialogBorderRadius.name,
        )
      : super.dialogBorderRadius;

  @override
  String get dialogBarrierBgValue =>
      component?.dialogBarrierBackgroundColor?.value ??
      super.dialogBarrierBgValue;

  @override
  String get drawerBgColorValue =>
      component?.drawerBackgroundColor?.value ?? super.drawerBgColorValue;

  @override
  Token get drawerWidth => component?.drawerWidth != null
      ? Token(
          value: component!.drawerWidth!.cssText,
          name: super.drawerWidth.name,
        )
      : super.drawerWidth;

  @override
  String get drawerBarrierBgValue =>
      component?.drawerBarrierBackgroundColor?.value ??
      super.drawerBarrierBgValue;

  @override
  String get bottomSheetBgColorValue =>
      component?.bottomSheetBackgroundColor?.value ??
      super.bottomSheetBgColorValue;

  @override
  Token get bottomSheetMaxHeight => component?.bottomSheetMaxHeight != null
      ? Token(
          value: component!.bottomSheetMaxHeight!.cssText,
          name: super.bottomSheetMaxHeight.name,
        )
      : super.bottomSheetMaxHeight;

  @override
  String get bottomSheetBarrierBgValue =>
      component?.bottomSheetBarrierBackgroundColor?.value ??
      super.bottomSheetBarrierBgValue;

  @override
  Token get calendarCellSize => component?.calendar?.cellSize != null
      ? Token(
          value: component!.calendar!.cellSize!.cssText,
          name: super.calendarCellSize.name,
        )
      : super.calendarCellSize;

  @override
  Token get calendarDateFontSize => component?.calendar?.dateFontSize != null
      ? Token(
          value: component!.calendar!.dateFontSize!.cssText,
          name: super.calendarDateFontSize.name,
        )
      : super.calendarDateFontSize;

  @override
  Token get calendarWeekdayFontSize =>
      component?.calendar?.weekdayFontSize != null
      ? Token(
          value: component!.calendar!.weekdayFontSize!.cssText,
          name: super.calendarWeekdayFontSize.name,
        )
      : super.calendarWeekdayFontSize;

  @override
  Token get calendarWeekdayGap => component?.calendar?.weekdayGap != null
      ? Token(
          value: component!.calendar!.weekdayGap!.cssText,
          name: super.calendarWeekdayGap.name,
        )
      : super.calendarWeekdayGap;

  @override
  Token get calendarTitleFontSize => component?.calendar?.titleFontSize != null
      ? Token(
          value: component!.calendar!.titleFontSize!.cssText,
          name: super.calendarTitleFontSize.name,
        )
      : super.calendarTitleFontSize;

  @override
  Token get calendarStepperWidth => component?.calendar?.stepperWidth != null
      ? Token(
          value: component!.calendar!.stepperWidth!.cssText,
          name: super.calendarStepperWidth.name,
        )
      : super.calendarStepperWidth;

  @override
  Token get calendarStepperHeight => component?.calendar?.stepperHeight != null
      ? Token(
          value: component!.calendar!.stepperHeight!.cssText,
          name: super.calendarStepperHeight.name,
        )
      : super.calendarStepperHeight;

  @override
  Token get calendarStepperFontSize =>
      component?.calendar?.stepperFontSize != null
      ? Token(
          value: component!.calendar!.stepperFontSize!.cssText,
          name: super.calendarStepperFontSize.name,
        )
      : super.calendarStepperFontSize;

  @override
  Token get calendarCompactCellSize =>
      component?.calendar?.compactCellSize != null
      ? Token(
          value: component!.calendar!.compactCellSize!.cssText,
          name: super.calendarCompactCellSize.name,
        )
      : super.calendarCompactCellSize;

  @override
  Token get calendarCompactDateFontSize =>
      component?.calendar?.compactDateFontSize != null
      ? Token(
          value: component!.calendar!.compactDateFontSize!.cssText,
          name: super.calendarCompactDateFontSize.name,
        )
      : super.calendarCompactDateFontSize;

  @override
  Token get calendarCompactWeekdayFontSize =>
      component?.calendar?.compactWeekdayFontSize != null
      ? Token(
          value: component!.calendar!.compactWeekdayFontSize!.cssText,
          name: super.calendarCompactWeekdayFontSize.name,
        )
      : super.calendarCompactWeekdayFontSize;

  @override
  Token get calendarCompactWeekdayGap =>
      component?.calendar?.compactWeekdayGap != null
      ? Token(
          value: component!.calendar!.compactWeekdayGap!.cssText,
          name: super.calendarCompactWeekdayGap.name,
        )
      : super.calendarCompactWeekdayGap;

  @override
  Token get calendarCompactTitleFontSize =>
      component?.calendar?.compactTitleFontSize != null
      ? Token(
          value: component!.calendar!.compactTitleFontSize!.cssText,
          name: super.calendarCompactTitleFontSize.name,
        )
      : super.calendarCompactTitleFontSize;

  @override
  Token get calendarCompactStepperHeight =>
      component?.calendar?.compactStepperHeight != null
      ? Token(
          value: component!.calendar!.compactStepperHeight!.cssText,
          name: super.calendarCompactStepperHeight.name,
        )
      : super.calendarCompactStepperHeight;

  @override
  Token get calendarCompactStepperFontSize =>
      component?.calendar?.compactStepperFontSize != null
      ? Token(
          value: component!.calendar!.compactStepperFontSize!.cssText,
          name: super.calendarCompactStepperFontSize.name,
        )
      : super.calendarCompactStepperFontSize;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DarkThemeData &&
        other.colorSeed == colorSeed &&
        other.typography == typography &&
        other.spacing == spacing &&
        other.borderWidth == borderWidth &&
        other.elevation == elevation &&
        other.radius == radius &&
        other.component == component &&
        other.styles == styles;
  }

  @override
  int get hashCode => Object.hashAll([
    colorSeed,
    typography,
    spacing,
    borderWidth,
    elevation,
    radius,
    component,
    styles,
  ]);
}
