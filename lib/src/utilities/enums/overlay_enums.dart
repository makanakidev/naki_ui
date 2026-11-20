part of 'index.dart';

/// Severity / intent type for `Banner` component.
enum BannerType {
  /// Informational alert (blue tint).
  info,

  /// Success alert (green tint).
  success,

  /// Warning alert (yellow / amber tint).
  warning,

  /// Error / danger alert (red tint).
  error,

  /// Neutral alert (grey tint).
  neutral,
}

/// Screen positioning for `Snackbar` component.
enum SnackbarPosition {
  /// Top center of the screen.
  top('sb-top'),

  /// Bottom center of the screen.
  bottom('sb-bottom'),

  /// Top left of the screen.
  topLeft('sb-top-left'),

  /// Top right of the screen.
  topRight('sb-top-right'),

  /// Bottom left of the screen.
  bottomLeft('sb-bottom-left'),

  /// Bottom right of the screen.
  bottomRight('sb-bottom-right')
  ;

  /// The standard CSS class name representing the snackbar position.
  final String className;
  const SnackbarPosition(this.className);
}

/// Slide direction / anchor for `Drawer` component.
enum DrawerPosition {
  /// Drawer slides from the left edge.
  left,

  /// Drawer slides from the right edge.
  right,
}

/// Placement position for `Tooltip` relative to its target.
enum TooltipPosition {
  /// Tooltip appears above the target component.
  top,

  /// Tooltip appears below the target component.
  bottom,

  /// Tooltip appears to the left of
  /// the target component.
  left,

  /// Tooltip appears to the right of
  /// the target component.
  right,
}

/// Placement position for `Popover` relative to its target.
enum PopoverPosition {
  /// Popover appears above the target component.
  top,

  /// Popover appears below the target component.
  bottom,

  /// Popover appears to the left of the target component.
  left,

  /// Popover appears to the right of the target component.
  right,

  /// Popover appears above and to the left of the target component.
  topLeft,

  /// Popover appears above and to the right of the target component.
  topRight,

  /// Popover appears below and to the left of the target component.
  bottomLeft,

  /// Popover appears below and to the right of the target component.
  bottomRight
  ;

  /// The CSS value representing the popover position.
  String get value => switch (this) {
    PopoverPosition.top => 'top',
    PopoverPosition.bottom => 'bottom',
    PopoverPosition.left => 'left',
    PopoverPosition.right => 'right',
    PopoverPosition.topLeft => 'top-left',
    PopoverPosition.topRight => 'top-right',
    PopoverPosition.bottomLeft => 'bottom-left',
    PopoverPosition.bottomRight => 'bottom-right',
  };
}

/// Positioning / alignment option for `Dialog` component.
enum DialogPosition {
  /// Aligns dialog at the center of the screen (default).
  center,

  /// Aligns dialog near the top of the screen.
  top,

  /// Aligns dialog near the bottom of the screen.
  bottom,
}
