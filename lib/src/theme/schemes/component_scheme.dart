part of '../theme.dart';

/// Represents customizable variables for Naki components.
class ComponentScheme {
  /// Text max lines.
  final int? textMaxLines;

  /// Input height for `TextField`, `Dropdown`, etc.
  final Dim? inputHeight;

  /// Input text color.
  final Color? inputTextColor;

  /// Label color.
  final Color? labelColor;

  /// Input font size.
  final Dim? fontSizeInput;

  /// Input background color.
  final Color? fieldBackgroundColor;

  /// Input hover border color.
  final Color? fieldHoverColor;

  /// Button background color.
  final Color? buttonBackgroundColor;

  /// Button text color.
  final Color? buttonColor;

  /// Button hover background color.
  final Color? buttonHoverBgColor;

  /// Button height.
  final Dim? buttonHeight;

  /// Button width.
  final Dim? buttonWidth;

  /// Dropdown default trigger height.
  final Dim? dropdownHeight;

  /// Dropdown default trigger width.
  final Dim? dropdownWidth;

  /// Dropdown menu height.
  final Dim? dropdownMenuHeight;

  /// Dropdown menu background color.
  final Color? dropdownMenuBackgroundColor;

  /// Dropdown option font size.
  final Dim? dropdownOptionFontSize;

  /// Dropdown option padding.
  final Dim? dropdownOptionPadding;

  /// Spinner size.
  final Dim? spinnerSize;

  /// Spinner border width.
  final Dim? spinnerBorderWidth;

  /// Spinner track color.
  final Color? spinnerTrackColor;

  /// Spinner color.
  final Color? spinnerColor;

  /// Spinner blade color (for iOS spinner style).
  final Color? spinnerBladeColor;

  /// Spinner surface color (for glassmorphism spinner style).
  final Color? spinnerSurfaceColor;

  /// Strength of the light rim on a glass spinner `in percent`.
  final double? spinnerGlassRim;

  /// Slider thumb color.
  final Color? sliderThumbColor;

  /// Slider track color.
  final Color? sliderTrackColor;

  /// Slider thumb size.
  final Dim? sliderThumbSize;

  /// Switch thumb color.
  final Color? switchThumbColor;

  /// Radio button radius.
  final Dim? radioButtonRadius;

  /// Radio button color.
  final Color? radioButtonColor;

  /// Appbar background color.
  final Color? appbarBackgroundColor;

  /// Appbar height.
  final Dim? appbarHeight;

  /// Bottom navbar background color.
  final Color? bottomNavbarBackgroundColor;

  /// Bottom navbar height.
  final Dim? bottomNavbarHeight;

  /// How much of the bottom navbar background color
  /// a frosted glass bar keeps `in percent`.
  final double? bottomNavbarGlassTint;

  /// Strength of the light rim on a frosted glass bar
  /// and its droplet `in percent`.
  final double? bottomNavbarGlassRim;

  /// How strongly the droplet of a frosted glass bar darkens
  /// and tints the content behind it `in percent`.
  final double? bottomNavbarGlassDroplet;

  /// Displacement of a liquid glass bottom navbar `in percent`,
  /// where `0` leaves the bar frosted.
  final double? bottomNavbarGlassRefraction;

  /// How much of its background color a glass card or dialog
  /// keeps `in percent`.
  final double? glassTint;

  /// Strength of the light rim on a glass card or dialog `in percent`.
  final double? glassRim;

  /// Backdrop blur of a glass card or dialog.
  final Dim? glassBlur;

  /// Backdrop blur of a frosted glass bottom navbar,
  /// for example `Dim.px(20)`.
  final Dim? bottomNavbarGlassBlur;

  /// Carousel item extent.
  final Dim? carouselItemExtent;

  /// Carousel gap.
  final Dim? carouselGap;

  /// Table header background color.
  final Color? tableHeaderBackgroundColor;

  /// Table row hover background color.
  final Color? tableRowHoverColor;

  /// Table header border color.
  final Color? tableHeaderBorderColor;

  /// Grid gap.
  final Dim? gridGap;

  /// Snackbar background color.
  final Color? snackbarBackgroundColor;

  /// Snackbar foreground color.
  final Color? snackbarForegroundColor;

  /// Snackbar border radius.
  final Dim? snackbarBorderRadius;

  /// Banner background color.
  final Color? bannerBackgroundColor;

  /// Banner foreground color.
  final Color? bannerForegroundColor;

  /// Banner border radius.
  final Dim? bannerBorderRadius;

  /// Banner border color.
  final Color? bannerBorderColor;

  /// Tooltip background color.
  final Color? tooltipBackgroundColor;

  /// Tooltip text color.
  final Color? tooltipTextColor;

  /// Tooltip border radius.
  final Dim? tooltipBorderRadius;

  /// Tooltip font size.
  final Dim? tooltipFontSize;

  /// Popover background color.
  final Color? popoverBackgroundColor;

  /// Popover text color.
  final Color? popoverTextColor;

  /// Popover border color.
  final Color? popoverBorderColor;

  /// Popover border radius.
  final Dim? popoverBorderRadius;

  /// Dialog background color.
  final Color? dialogBackgroundColor;

  /// Dialog border radius.
  final Dim? dialogBorderRadius;

  /// Dialog barrier backdrop color.
  final Color? dialogBarrierBackgroundColor;

  /// Drawer background color.
  final Color? drawerBackgroundColor;

  /// Drawer width.
  final Dim? drawerWidth;

  /// Drawer barrier backdrop color.
  final Color? drawerBarrierBackgroundColor;

  /// Bottom sheet background color.
  final Color? bottomSheetBackgroundColor;

  /// Bottom sheet max height.
  final Dim? bottomSheetMaxHeight;

  /// Bottom sheet barrier backdrop color.
  final Color? bottomSheetBarrierBackgroundColor;

  /// Calendar picker sizes.
  final CalendarScheme? calendar;

  const ComponentScheme({
    this.textMaxLines,
    this.inputHeight,
    this.inputTextColor,
    this.labelColor,
    this.fontSizeInput,
    this.fieldBackgroundColor,
    this.fieldHoverColor,
    this.buttonBackgroundColor,
    this.buttonColor,
    this.buttonHeight,
    this.buttonWidth,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownMenuHeight,
    this.dropdownMenuBackgroundColor,
    this.dropdownOptionFontSize,
    this.dropdownOptionPadding,
    this.spinnerSize,
    this.spinnerBorderWidth,
    this.spinnerTrackColor,
    this.spinnerColor,
    this.spinnerBladeColor,
    this.spinnerSurfaceColor,
    this.spinnerGlassRim,
    this.sliderThumbColor,
    this.sliderTrackColor,
    this.sliderThumbSize,
    this.switchThumbColor,
    this.radioButtonRadius,
    this.radioButtonColor,
    this.appbarBackgroundColor,
    this.appbarHeight,
    this.bottomNavbarBackgroundColor,
    this.bottomNavbarHeight,
    this.bottomNavbarGlassTint,
    this.bottomNavbarGlassRim,
    this.bottomNavbarGlassDroplet,
    this.bottomNavbarGlassBlur,
    this.bottomNavbarGlassRefraction,
    this.glassTint,
    this.glassRim,
    this.glassBlur,
    this.carouselItemExtent,
    this.carouselGap,
    this.tableHeaderBackgroundColor,
    this.tableHeaderBorderColor,
    this.tableRowHoverColor,
    this.gridGap,
    this.snackbarBackgroundColor,
    this.snackbarForegroundColor,
    this.snackbarBorderRadius,
    this.bannerBackgroundColor,
    this.bannerForegroundColor,
    this.bannerBorderRadius,
    this.bannerBorderColor,
    this.tooltipBackgroundColor,
    this.tooltipTextColor,
    this.tooltipBorderRadius,
    this.tooltipFontSize,
    this.popoverBackgroundColor,
    this.popoverTextColor,
    this.popoverBorderColor,
    this.popoverBorderRadius,
    this.dialogBackgroundColor,
    this.dialogBorderRadius,
    this.dialogBarrierBackgroundColor,
    this.drawerBackgroundColor,
    this.drawerWidth,
    this.drawerBarrierBackgroundColor,
    this.bottomSheetBackgroundColor,
    this.bottomSheetMaxHeight,
    this.bottomSheetBarrierBackgroundColor,
    this.buttonHoverBgColor,
    this.calendar,
  });

  ComponentScheme copyWith({
    int? textMaxLines,
    Dim? inputHeight,
    Color? inputTextColor,
    Color? labelColor,
    Dim? fontSizeInput,
    Color? fieldBackgroundColor,
    Color? fieldHoverColor,
    Color? buttonBackgroundColor,
    Color? buttonColor,
    Color? buttonHoverBgColor,
    Dim? buttonHeight,
    Dim? buttonWidth,
    Dim? dropdownHeight,
    Dim? dropdownWidth,
    Dim? dropdownMenuHeight,
    Color? dropdownMenuBackgroundColor,
    Dim? dropdownOptionFontSize,
    Dim? dropdownOptionPadding,
    Dim? spinnerSize,
    Dim? spinnerBorderWidth,
    Color? spinnerTrackColor,
    Color? spinnerColor,
    Color? spinnerBladeColor,
    Color? spinnerSurfaceColor,
    double? spinnerGlassRim,
    Color? sliderThumbColor,
    Color? sliderTrackColor,
    Dim? sliderThumbSize,
    Color? switchThumbColor,
    Dim? radioButtonRadius,
    Color? radioButtonColor,
    Color? appbarBackgroundColor,
    Dim? appbarHeight,
    Color? bottomNavbarBackgroundColor,
    Dim? bottomNavbarHeight,
    double? bottomNavbarGlassTint,
    double? bottomNavbarGlassRim,
    double? bottomNavbarGlassDroplet,
    Dim? bottomNavbarGlassBlur,
    double? bottomNavbarGlassRefraction,
    double? glassTint,
    double? glassRim,
    Dim? glassBlur,
    Dim? carouselItemExtent,
    Dim? carouselGap,
    Color? tableHeaderBackgroundColor,
    Color? tableHeaderBorderColor,
    Color? tableRowHoverColor,
    Dim? gridGap,
    Color? snackbarBackgroundColor,
    Color? snackbarForegroundColor,
    Dim? snackbarBorderRadius,
    Color? bannerBackgroundColor,
    Color? bannerForegroundColor,
    Dim? bannerBorderRadius,
    Color? bannerBorderColor,
    Color? tooltipBackgroundColor,
    Color? tooltipTextColor,
    Dim? tooltipBorderRadius,
    Dim? tooltipFontSize,
    Color? popoverBackgroundColor,
    Color? popoverTextColor,
    Color? popoverBorderColor,
    Dim? popoverBorderRadius,
    Color? dialogBackgroundColor,
    Dim? dialogBorderRadius,
    Color? dialogBarrierBackgroundColor,
    Color? drawerBackgroundColor,
    Dim? drawerWidth,
    Color? drawerBarrierBackgroundColor,
    Color? bottomSheetBackgroundColor,
    Dim? bottomSheetMaxHeight,
    Color? bottomSheetBarrierBackgroundColor,
    CalendarScheme? calendar,
  }) => ComponentScheme(
    textMaxLines: textMaxLines ?? this.textMaxLines,
    inputHeight: inputHeight ?? this.inputHeight,
    inputTextColor: inputTextColor ?? this.inputTextColor,
    labelColor: labelColor ?? this.labelColor,
    fontSizeInput: fontSizeInput ?? this.fontSizeInput,
    fieldBackgroundColor: fieldBackgroundColor ?? this.fieldBackgroundColor,
    fieldHoverColor: fieldHoverColor ?? this.fieldHoverColor,
    buttonBackgroundColor: buttonBackgroundColor ?? this.buttonBackgroundColor,
    buttonColor: buttonColor ?? this.buttonColor,
    buttonHoverBgColor: buttonHoverBgColor ?? this.buttonHoverBgColor,
    buttonHeight: buttonHeight ?? this.buttonHeight,
    buttonWidth: buttonWidth ?? this.buttonWidth,
    dropdownHeight: dropdownHeight ?? this.dropdownHeight,
    dropdownWidth: dropdownWidth ?? this.dropdownWidth,
    dropdownMenuHeight: dropdownMenuHeight ?? this.dropdownMenuHeight,
    dropdownMenuBackgroundColor:
        dropdownMenuBackgroundColor ?? this.dropdownMenuBackgroundColor,
    dropdownOptionFontSize:
        dropdownOptionFontSize ?? this.dropdownOptionFontSize,
    dropdownOptionPadding: dropdownOptionPadding ?? this.dropdownOptionPadding,
    spinnerSize: spinnerSize ?? this.spinnerSize,
    spinnerBorderWidth: spinnerBorderWidth ?? this.spinnerBorderWidth,
    spinnerTrackColor: spinnerTrackColor ?? this.spinnerTrackColor,
    spinnerColor: spinnerColor ?? this.spinnerColor,
    spinnerBladeColor: spinnerBladeColor ?? this.spinnerBladeColor,
    spinnerSurfaceColor: spinnerSurfaceColor ?? this.spinnerSurfaceColor,
    spinnerGlassRim: spinnerGlassRim ?? this.spinnerGlassRim,
    sliderThumbColor: sliderThumbColor ?? this.sliderThumbColor,
    sliderTrackColor: sliderTrackColor ?? this.sliderTrackColor,
    sliderThumbSize: sliderThumbSize ?? this.sliderThumbSize,
    switchThumbColor: switchThumbColor ?? this.switchThumbColor,
    radioButtonRadius: radioButtonRadius ?? this.radioButtonRadius,
    radioButtonColor: radioButtonColor ?? this.radioButtonColor,
    appbarBackgroundColor: appbarBackgroundColor ?? this.appbarBackgroundColor,
    appbarHeight: appbarHeight ?? this.appbarHeight,
    bottomNavbarBackgroundColor:
        bottomNavbarBackgroundColor ?? this.bottomNavbarBackgroundColor,
    bottomNavbarHeight: bottomNavbarHeight ?? this.bottomNavbarHeight,
    bottomNavbarGlassTint: bottomNavbarGlassTint ?? this.bottomNavbarGlassTint,
    bottomNavbarGlassRim: bottomNavbarGlassRim ?? this.bottomNavbarGlassRim,
    bottomNavbarGlassDroplet:
        bottomNavbarGlassDroplet ?? this.bottomNavbarGlassDroplet,
    bottomNavbarGlassBlur: bottomNavbarGlassBlur ?? this.bottomNavbarGlassBlur,
    bottomNavbarGlassRefraction:
        bottomNavbarGlassRefraction ?? this.bottomNavbarGlassRefraction,
    glassTint: glassTint ?? this.glassTint,
    glassRim: glassRim ?? this.glassRim,
    glassBlur: glassBlur ?? this.glassBlur,
    carouselItemExtent: carouselItemExtent ?? this.carouselItemExtent,
    carouselGap: carouselGap ?? this.carouselGap,
    tableHeaderBackgroundColor:
        tableHeaderBackgroundColor ?? this.tableHeaderBackgroundColor,
    tableHeaderBorderColor:
        tableHeaderBorderColor ?? this.tableHeaderBorderColor,
    tableRowHoverColor: tableRowHoverColor ?? this.tableRowHoverColor,
    gridGap: gridGap ?? this.gridGap,
    snackbarBackgroundColor:
        snackbarBackgroundColor ?? this.snackbarBackgroundColor,
    snackbarForegroundColor:
        snackbarForegroundColor ?? this.snackbarForegroundColor,
    snackbarBorderRadius: snackbarBorderRadius ?? this.snackbarBorderRadius,
    bannerBackgroundColor: bannerBackgroundColor ?? this.bannerBackgroundColor,
    bannerForegroundColor: bannerForegroundColor ?? this.bannerForegroundColor,
    bannerBorderRadius: bannerBorderRadius ?? this.bannerBorderRadius,
    bannerBorderColor: bannerBorderColor ?? this.bannerBorderColor,
    tooltipBackgroundColor:
        tooltipBackgroundColor ?? this.tooltipBackgroundColor,
    tooltipTextColor: tooltipTextColor ?? this.tooltipTextColor,
    tooltipBorderRadius: tooltipBorderRadius ?? this.tooltipBorderRadius,
    tooltipFontSize: tooltipFontSize ?? this.tooltipFontSize,
    popoverBackgroundColor:
        popoverBackgroundColor ?? this.popoverBackgroundColor,
    popoverTextColor: popoverTextColor ?? this.popoverTextColor,
    popoverBorderColor: popoverBorderColor ?? this.popoverBorderColor,
    popoverBorderRadius: popoverBorderRadius ?? this.popoverBorderRadius,
    dialogBackgroundColor: dialogBackgroundColor ?? this.dialogBackgroundColor,
    dialogBorderRadius: dialogBorderRadius ?? this.dialogBorderRadius,
    dialogBarrierBackgroundColor:
        dialogBarrierBackgroundColor ?? this.dialogBarrierBackgroundColor,
    drawerBackgroundColor: drawerBackgroundColor ?? this.drawerBackgroundColor,
    drawerWidth: drawerWidth ?? this.drawerWidth,
    drawerBarrierBackgroundColor:
        drawerBarrierBackgroundColor ?? this.drawerBarrierBackgroundColor,
    bottomSheetBackgroundColor:
        bottomSheetBackgroundColor ?? this.bottomSheetBackgroundColor,
    bottomSheetMaxHeight: bottomSheetMaxHeight ?? this.bottomSheetMaxHeight,
    bottomSheetBarrierBackgroundColor:
        bottomSheetBarrierBackgroundColor ??
        this.bottomSheetBarrierBackgroundColor,
    calendar: calendar ?? this.calendar,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComponentScheme &&
        other.textMaxLines == textMaxLines &&
        other.inputHeight == inputHeight &&
        other.inputTextColor == inputTextColor &&
        other.labelColor == labelColor &&
        other.fontSizeInput == fontSizeInput &&
        other.fieldBackgroundColor == fieldBackgroundColor &&
        other.fieldHoverColor == fieldHoverColor &&
        other.buttonBackgroundColor == buttonBackgroundColor &&
        other.buttonColor == buttonColor &&
        other.buttonHoverBgColor == buttonHoverBgColor &&
        other.buttonHeight == buttonHeight &&
        other.buttonWidth == buttonWidth &&
        other.dropdownHeight == dropdownHeight &&
        other.dropdownWidth == dropdownWidth &&
        other.dropdownMenuHeight == dropdownMenuHeight &&
        other.dropdownMenuBackgroundColor == dropdownMenuBackgroundColor &&
        other.dropdownOptionFontSize == dropdownOptionFontSize &&
        other.dropdownOptionPadding == dropdownOptionPadding &&
        other.spinnerSize == spinnerSize &&
        other.spinnerBorderWidth == spinnerBorderWidth &&
        other.spinnerTrackColor == spinnerTrackColor &&
        other.spinnerColor == spinnerColor &&
        other.spinnerBladeColor == spinnerBladeColor &&
        other.spinnerSurfaceColor == spinnerSurfaceColor &&
        other.spinnerGlassRim == spinnerGlassRim &&
        other.sliderThumbColor == sliderThumbColor &&
        other.sliderTrackColor == sliderTrackColor &&
        other.sliderThumbSize == sliderThumbSize &&
        other.switchThumbColor == switchThumbColor &&
        other.radioButtonRadius == radioButtonRadius &&
        other.radioButtonColor == radioButtonColor &&
        other.appbarBackgroundColor == appbarBackgroundColor &&
        other.appbarHeight == appbarHeight &&
        other.bottomNavbarBackgroundColor == bottomNavbarBackgroundColor &&
        other.bottomNavbarHeight == bottomNavbarHeight &&
        other.bottomNavbarGlassTint == bottomNavbarGlassTint &&
        other.bottomNavbarGlassRim == bottomNavbarGlassRim &&
        other.bottomNavbarGlassDroplet == bottomNavbarGlassDroplet &&
        other.bottomNavbarGlassBlur == bottomNavbarGlassBlur &&
        other.bottomNavbarGlassRefraction == bottomNavbarGlassRefraction &&
        other.glassTint == glassTint &&
        other.glassRim == glassRim &&
        other.glassBlur == glassBlur &&
        other.carouselItemExtent == carouselItemExtent &&
        other.carouselGap == carouselGap &&
        other.tableHeaderBackgroundColor == tableHeaderBackgroundColor &&
        other.tableHeaderBorderColor == tableHeaderBorderColor &&
        other.tableRowHoverColor == tableRowHoverColor &&
        other.gridGap == gridGap &&
        other.snackbarBackgroundColor == snackbarBackgroundColor &&
        other.snackbarForegroundColor == snackbarForegroundColor &&
        other.snackbarBorderRadius == snackbarBorderRadius &&
        other.bannerBackgroundColor == bannerBackgroundColor &&
        other.bannerForegroundColor == bannerForegroundColor &&
        other.bannerBorderRadius == bannerBorderRadius &&
        other.bannerBorderColor == bannerBorderColor &&
        other.tooltipBackgroundColor == tooltipBackgroundColor &&
        other.tooltipTextColor == tooltipTextColor &&
        other.tooltipBorderRadius == tooltipBorderRadius &&
        other.tooltipFontSize == tooltipFontSize &&
        other.popoverBackgroundColor == popoverBackgroundColor &&
        other.popoverTextColor == popoverTextColor &&
        other.popoverBorderColor == popoverBorderColor &&
        other.popoverBorderRadius == popoverBorderRadius &&
        other.dialogBackgroundColor == dialogBackgroundColor &&
        other.dialogBorderRadius == dialogBorderRadius &&
        other.dialogBarrierBackgroundColor == dialogBarrierBackgroundColor &&
        other.drawerBackgroundColor == drawerBackgroundColor &&
        other.drawerWidth == drawerWidth &&
        other.drawerBarrierBackgroundColor == drawerBarrierBackgroundColor &&
        other.bottomSheetBackgroundColor == bottomSheetBackgroundColor &&
        other.bottomSheetMaxHeight == bottomSheetMaxHeight &&
        other.bottomSheetBarrierBackgroundColor ==
            bottomSheetBarrierBackgroundColor &&
        other.calendar == calendar;
  }

  @override
  int get hashCode => Object.hashAll([
    textMaxLines,
    inputHeight,
    inputTextColor,
    labelColor,
    fontSizeInput,
    fieldBackgroundColor,
    fieldHoverColor,
    buttonBackgroundColor,
    buttonColor,
    buttonHoverBgColor,
    buttonHeight,
    buttonWidth,
    dropdownHeight,
    dropdownWidth,
    dropdownMenuHeight,
    dropdownMenuBackgroundColor,
    dropdownOptionFontSize,
    dropdownOptionPadding,
    spinnerSize,
    spinnerBorderWidth,
    spinnerTrackColor,
    spinnerColor,
    spinnerBladeColor,
    spinnerSurfaceColor,
    spinnerGlassRim,
    sliderThumbColor,
    sliderTrackColor,
    sliderThumbSize,
    switchThumbColor,
    radioButtonRadius,
    radioButtonColor,
    appbarBackgroundColor,
    appbarHeight,
    bottomNavbarBackgroundColor,
    bottomNavbarHeight,
    bottomNavbarGlassTint,
    bottomNavbarGlassRim,
    bottomNavbarGlassDroplet,
    bottomNavbarGlassBlur,
    bottomNavbarGlassRefraction,
    glassTint,
    glassRim,
    glassBlur,
    carouselItemExtent,
    carouselGap,
    tableHeaderBackgroundColor,
    tableRowHoverColor,
    tableHeaderBorderColor,
    gridGap,
    snackbarBackgroundColor,
    snackbarForegroundColor,
    snackbarBorderRadius,
    bannerBackgroundColor,
    bannerForegroundColor,
    bannerBorderRadius,
    bannerBorderColor,
    tooltipBackgroundColor,
    tooltipTextColor,
    tooltipBorderRadius,
    tooltipFontSize,
    popoverBackgroundColor,
    popoverTextColor,
    popoverBorderColor,
    popoverBorderRadius,
    dialogBackgroundColor,
    dialogBorderRadius,
    dialogBarrierBackgroundColor,
    drawerBackgroundColor,
    drawerWidth,
    drawerBarrierBackgroundColor,
    bottomSheetBackgroundColor,
    bottomSheetMaxHeight,
    bottomSheetBarrierBackgroundColor,
    calendar,
  ]);
}
