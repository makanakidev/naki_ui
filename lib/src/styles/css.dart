import 'package:jaspr/dom.dart';
import '../models/styling.dart';
import '../theme/tokens.dart';
import '../utilities/extensions.dart';
import 'text_style.dart';

/// CSS styling utilities and default styles for Naki components.
///
/// Contains default styles for common components
/// (inputs, checkboxes, sliders, etc.) and helper method
/// for color opacity manipulation.
class Css {
  /// Mixes a color with transparent space to apply a custom opacity level.
  ///
  /// [opacity] is a percentage value from 0.0 to 100.0.
  static Color applyOpacity(Color color, double opacity) {
    return Color(
      'color-mix(in srgb, ${color.value} ${opacity.toCleanString}%, transparent)',
    );
  }

  /// Floating Action Button z-index -> `900`.
  static const _fabZindex = '900';

  /// AppBar z-index -> `950`.
  static const _appBarZindex = '950';

  /// Bottom navigation bar z-index -> `950`.
  static const _bottomNavBarZindex = '950';

  /// Popover barrier z-index -> `999`.
  static const _popoverBarrierZindex = '999';

  /// Popover z-index -> `1000`.
  static const _popoverZindex = '1000';

  /// Dropdown z-index -> `1050`.
  static const _dropdownZindex = '1050';

  /// Drawer barrier z-index -> `1099`.
  static const _drawerBarrierZindex = '1099';

  /// Drawer z-index -> `1100`.
  static const _drawerZindex = '1100';

  /// Bottom sheet barrier z-index -> `1199`.
  static const _bottomSheetBarrierZindex = '1199';

  /// Bottom sheet z-index -> `1200`.
  static const _bottomSheetZindex = '1200';

  /// Modal barrier z-index -> `1999`.
  static const _modalBarrierZindex = '1999';

  /// Modal z-index -> `2000`.
  static const _modalZindex = '2000';

  /// Snackbar z-index -> `5000`.
  static const _snackbarZindex = '5000';

  /// Tooltip z-index -> `10000`.
  static const _tooltipZindex = '10000';

  /// Default text truncation CSS styling rule.
  /// Prevents long text from wrapping and clips it with an ellipsis.
  static final nakiTextTruncateStyle = {
    'text-overflow': 'ellipsis',
    'overflow': 'hidden',
    'white-space': 'nowrap',
  };

  /// Background lock CSS styling rule.
  /// Prevents background from scrolling and locks the viewport.
  static final nakiBackgroundLockStyle = {
    'overflow': 'hidden',
    'height': '100dvh',
    'max-height': '100dvh',
    'touch-action': 'none',
  };

  /// Default text max lines CSS styling rule.
  /// Prevents text from wrapping and clips it with an ellipsis
  /// after the defined line count.
  static final nakiTextClampStyle = {
    'display': '-webkit-box',
    '-webkit-box-orient': 'vertical',
    'line-clamp':
        'var(${Tokens.current.textMaxLines}, ${Tokens.current.textMaxLines.value})',
    '-webkit-line-clamp':
        'var(${Tokens.current.textMaxLines}, ${Tokens.current.textMaxLines.value})',
    'overflow': 'hidden',
    'height': 'auto',
    'max-height': 'none',
  };

  /// Default text style for form field labels.
  static final nakiLabelTextStyle = TextStyle(
    fontWeight: .w500,
    fontSize: .variable(
      Tokens.current.fontSizeLabel.name,
      defaultValue: Tokens.current.fontSizeLabel.value,
    ),
    color: .variable(
      '${Tokens.current.labelColor}, ${Tokens.current.labelColor.value}',
    ),
    width: const .fitContent(),
    margin: const EdgeInsets.only(bottom: Dim.px(12)),
  );

  /// Default text style for helper/hint text.
  static final nakiHelperTextStyle = TextStyle(
    fontSize: .variable(
      Tokens.current.fontSizeHint.name,
      defaultValue: Tokens.current.fontSizeHint.value,
    ),
    color: .variable(
      '${Tokens.current.mutedColor}, ${Tokens.current.mutedColor.value}',
    ),
    margin: const EdgeInsets.only(top: Dim.px(5)),
    extra: {'white-space': 'pre-wrap', 'word-break': 'break-word'},
  );

  /// Default styles applied to components in their disabled state.
  static final nakiDisabledStyle = {'opacity': '0.3', 'pointer-events': 'none'};

  /// Default text style for form validation errors.
  static final nakiErrorTextStyle = TextStyle(
    fontSize: .variable(
      Tokens.current.fontSizeError.name,
      defaultValue: Tokens.current.fontSizeError.value,
    ),
    color: .variable(
      '${Tokens.current.errorColor}, ${Tokens.current.errorColor.value}',
    ),
    extra: {'white-space': 'pre-wrap', 'word-break': 'break-word'},
  );

  /// Default border styling rule applied to inputs with validation errors.
  static final nakiErrorBorderStyle = {
    'outline': 'none',
    'border': Tokens.current.errorBorder.value,
  };

  /// Default border styling rule applied to inputs with focus.
  static final nakiFocusBorderStyle = {
    'outline': 'none',
    'border': Tokens.current.focusBorder.value,
  };

  /// Default styling rule applied to input fields on hover.
  static final nakiFieldHoverStyle = {
    'outline': 'none',
    'border': Tokens.current.fieldHoverBorder.value,
  };

  /// Default placeholder text styling rule inside inputs.
  static final nakiPlaceholderStyle = {
    'color':
        'var(${Tokens.current.placeholderColor}, ${Tokens.current.placeholderColor.value})',
    'opacity': '1',
  };

  /// Default inline-block alignment and size styling rule for icons.
  static final nakiIconStyle = {
    'display': 'inline-block',
    'vertical-align': 'middle',
    'box-sizing': 'border-box',
  };

  /// Default styling rules for single-line text inputs.
  static final nakiInputStyle = {
    'height':
        'var(${Tokens.current.inputHeight}, ${Tokens.current.inputHeight.value})',
    'color':
        'var(${Tokens.current.inputTextColor}, ${Tokens.current.inputTextColor.value})',
    'font-size':
        'var(${Tokens.current.fontSizeInput}, ${Tokens.current.fontSizeInput.value})',
    'background-color':
        'var(${Tokens.current.fieldBackgroundColor}, ${Tokens.current.fieldBackgroundColor.value})',
    'border-radius': '12px',
    'padding': '0 15px',
    'border': Tokens.current.border.value,
    'margin': '0',
  };

  /// Default styling rules for segmented input fields.
  static final nakiSegmentedInputStyle = {
    'wrapper': {
      'display': 'inline-flex',
      'flex-direction': 'row',
      'align-items': 'center',
      'gap': '10px',
      'width': 'fit-content',
    },

    'segment': {
      'width': '45px',
      'height': '45px',
      'text-align': 'center',
      'font-size':
          'var(${Tokens.current.fontSizeInput}, ${Tokens.current.fontSizeInput.value})',
      'font-weight': '600',
      'color':
          'var(${Tokens.current.inputTextColor}, ${Tokens.current.inputTextColor.value})',
      'background-color':
          'var(${Tokens.current.fieldBackgroundColor}, ${Tokens.current.fieldBackgroundColor.value})',
      'border': Tokens.current.border.value,
      'border-radius': '12px',
      'outline': 'none',
      'transition': 'border-color 0.2s, box-shadow 0.2s, background 0.2s',
      'box-sizing': 'border-box',
      'padding': '0',
      'margin': '0',
    },

    'underline': {
      'border-top': 'none',
      'border-left': 'none',
      'border-right': 'none',
      'border-bottom': Tokens.current.border.value,
      'border-radius': '0',
      'background-color': 'transparent',
    },
  };

  /// Default styling rules for multi-line textareas.
  static final nakiTextareaStyle = {
    'min-height':
        'var(${Tokens.current.inputHeight}, ${Tokens.current.inputHeight.value})',
    'color':
        'var(${Tokens.current.inputTextColor}, ${Tokens.current.inputTextColor.value})',
    'font-size':
        'var(${Tokens.current.fontSizeInput}, ${Tokens.current.fontSizeInput.value})',
    'background-color':
        'var(${Tokens.current.fieldBackgroundColor}, ${Tokens.current.fieldBackgroundColor.value})',
    'display': 'block',
    'max-height': '250px',
    'padding': '10px 15px',
    'line-height': '1.5',
    'border-radius': '12px',
    'width': 'fit-content',
    'margin': '0',
  };

  /// Default CSS styles map for stacked layers.
  static final nakiStackStyle = {
    'position': 'relative',
    'display': 'block',
    'isolation': 'isolate',
  };

  /// Default CSS styles map for styling check boxes
  /// (wrapper, input tick, disabled states).
  static final nakiCheckboxStyle = {
    'wrapper': {
      'display': 'flex',
      'width': 'fit-content',
      'align-items': 'center',
    },

    'input': {
      'border': Tokens.current.border.value,
      'position': 'relative',
      'display': 'inline-block',
      'flex-shrink': '0',
      'cursor': 'pointer',
      'appearance': 'none',
      '-webkit-appearance': 'none',
      'border-radius': '12px',
      'padding': '4px',
      'vertical-align': 'middle',
      'color': 'currentcolor',
      'transition': 'background 0.2s, box-shadow 0.2s',
      'width': '24px',
      'height': '24px',
      'margin': '0',
    },

    'before': {
      'content': '""',
      'display': 'block',
      'width': '100%',
      'height': '100%',
      'rotate': '45deg',
      'background-color': 'currentcolor',
      'opacity': '0%',
      'transition': 'clip-path 0.3s, opacity 0.1s, rotate 0.3s, translate 0.3s',
      'transition-delay': '0.1s',
      'clip-path':
          'polygon(20% 100%, 20% 80%, 50% 80%, 50% 80%, 70% 80%, 70% 100%)',
      'font-size': '15px',
      'line-height': '0.75',
    },

    'checked:before': {
      'clip-path':
          'polygon(20% 100%, 20% 80%, 50% 80%, 50% 0%, 70% 0%, 70% 100%)',
      'opacity': '100%',
    },

    'disabled': nakiDisabledStyle,
  };

  /// Default CSS styles map for styling switches
  /// (track, thumb, checked, and disabled states).
  static final nakiSwitchStyle = {
    'wrapper': {
      'display': 'flex',
      'gap': '15px',
      'width': 'fit-content',
      'align-items': 'center',
    },

    'input': {
      'border': Tokens.current.border.value,
      'position': 'relative',
      'display': 'inline-grid',
      'flex-shrink': '0',
      'cursor': 'pointer',
      'appearance': 'none',
      '-webkit-appearance': 'none',
      'place-content': 'center',
      'vertical-align': 'middle',
      'grid-template-columns': '0fr 1fr 1fr',
      'border-radius': '12px',
      'padding': '5px',
      'transition': 'color 0.3s, grid-template-columns 0.2s',
      'width': '40px',
      'height': '24px',
      'margin': '0',
    },

    'not-checked': {
      'color':
          'var(${Tokens.current.subtitleColor}, ${Tokens.current.subtitleColor.value})',
    },

    'before': {
      'content': '""',
      'position': 'relative',
      'grid-column-start': '2',
      'grid-row-start': '1',
      'aspect-ratio': '1 / 1',
      'height': '100%',
      'border-radius': '12px',
      'background-color': 'currentcolor',
      'translate': '0',
      'transition': 'background 0.1s, translate 0.2s, inset-inline-start 0.2s',
    },

    'checked': {
      'grid-template-columns': '1fr 1fr 0fr',
      'color':
          'var(${Tokens.current.switchThumbColor}, ${Tokens.current.switchThumbColor.value})',
      'background-color': 'color-mix(in srgb, currentcolor 15%, transparent)',
    },

    'disabled': nakiDisabledStyle,

    'disabled:before': {
      'background-color': 'transparent',
      'height': 'auto',
      'border': '1px solid currentcolor',
    },
  };

  /// Default CSS styles map for styling range sliders
  /// (track, thumb, progress, tooltips).
  static final nakiSliderStyle = {
    'wrapper': {
      'display': 'inline-block',
      'position': 'relative',
      'width': 'auto',
    },

    'tooltip': {
      'position': 'absolute',
      'bottom': 'calc(100% + 2px)',
      'left': '-100%',
      'transform': 'translateX(-50%)',
      'background-color':
          'var(${Tokens.current.baseTextColor}, ${Tokens.current.baseTextColor.value})',
      'color':
          'var(${Tokens.current.backgroundColor}, ${Tokens.current.backgroundColor.value})',
      'padding': '7px',
      'pointer-events': 'none',
      'border-radius': '50%',
      'font-size': '12px',
      'line-height': '1',
    },

    'input': {
      'border': 'none',
      'cursor': 'pointer',
      'appearance': 'none',
      '-webkit-appearance': 'none',
      'border-radius': '12px',
      'background-color': 'transparent',
      'vertical-align': 'middle',
      'margin': '0',
      'height':
          'var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value})',
    },

    'webkit-track': {
      'background-color':
          'var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
      'border-radius': '12px',
      'height':
          'calc(var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value}) * 0.5)',
    },

    'webkit-thumb': {
      'position': 'relative',
      'box-sizing': 'border-box',
      'border-radius': '50%',
      'background-color':
          'var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
      'height':
          'var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value})',
      'width':
          'var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value})',
      'border':
          '5px solid var(${Tokens.current.sliderThumbColor}, ${Tokens.current.sliderThumbColor.value})',
      'appearance': 'none',
      '-webkit-appearance': 'none',
      'box-shadow':
          '0 0 0 2px var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
      'bottom': '50%',
    },

    'moz-track': {
      'width': '100%',
      'background-color':
          'var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
      'border-radius': '12px',
      'height':
          'calc(var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value}) * 0.5)',
    },

    'moz-thumb': {
      'position': 'relative',
      'box-sizing': 'border-box',
      'border-radius': '50%',
      'background-color':
          'var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
      'height':
          'var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value})',
      'width':
          'var(${Tokens.current.sliderThumbSize}, ${Tokens.current.sliderThumbSize.value})',
      'border':
          '5px solid var(${Tokens.current.sliderThumbColor}, ${Tokens.current.sliderThumbColor.value})',
      'top': '50%',
      'box-shadow':
          '0 0 0 2px var(${Tokens.current.sliderTrackColor}, ${Tokens.current.sliderTrackColor.value})',
    },

    'disabled': nakiDisabledStyle,
  };

  /// Default CSS styles map for styling AppBars
  /// (header wrapper, title, actions).
  static final nakiAppBarStyle = {
    'wrapper': {
      'display': 'flex',
      'align-items': 'center',
      'position': 'static',
      'flex-shrink': '0',
      'top': '0',
      'left': '0',
      'width': '100%',
      'gap': '12px',
      'justify-content': 'space-between',
      'padding': '0 20px',
      'backdrop-filter': 'blur(12px)',
      'height':
          'var(${Tokens.current.appbarHeight}, '
          '${Tokens.current.appbarHeight.value})',
      'background-color':
          'var(${Tokens.current.appbarBgColor}, '
          '${Tokens.current.appbarBgColor.value})',
      'box-shadow': '0px 2px 4px rgba(0, 0, 0, 0.1)',
    },

    'title': {
      'font-size':
          'var(${Tokens.current.fontSize3xl}, '
          '${Tokens.current.fontSize3xl.value})',
      'font-weight':
          'var(${Tokens.current.fontWeightSemiBold}, '
          '${Tokens.current.fontWeightSemiBold.value})',
      'flex-grow': '1',
      'text-overflow': 'ellipsis',
      'overflow': 'hidden',
      'white-space': 'nowrap',
    },

    'actions': {
      'margin-left': 'auto',
      'display': 'flex',
      'gap': '10px',
      'align-items': 'center',
    },
  };

  /// Default CSS styles map for styling bottom navigation bar.
  static final nakiBottomNavBarStyle = {
    'wrapper': {
      'display': 'flex',
      'align-items': 'center',
      'flex-shrink': '0',
      'bottom': '0',
      'left': '0',
      'height':
          'var(${Tokens.current.bottomNavbarHeight}, '
          '${Tokens.current.bottomNavbarHeight.value})',
      'background-color':
          'var(${Tokens.current.bottomNavbarBgColor}, '
          '${Tokens.current.bottomNavbarBgColor.value})',
      'box-shadow': '0px -1px 0px rgba(0, 0, 0, 0.06)',
      'box-sizing': 'border-box',
      'z-index': _bottomNavBarZindex,
    },

    // Navbar types
    'fixed': {'width': '100%', 'border-radius': '0'},

    'floating': {
      'width': 'calc(100% - 32px)',
      'max-width': '600px',
      'border-radius': '12px',
      'box-shadow': '0px 8px 24px rgba(0, 0, 0, 0.12)',
    },

    'frosted-glass': {
      'width': 'calc(100% - 32px)',
      'max-width': '600px',
      'border-radius': '12px',
      'background-color':
          'color-mix(in srgb, var(${Tokens.current.bottomNavbarBgColor}, ${Tokens.current.bottomNavbarBgColor.value}) 75%, transparent)',
      'backdrop-filter': 'blur(20px) saturate(180%)',
      '-webkit-backdrop-filter': 'blur(20px) saturate(180%)',
      'border':
          '1px solid var(${Tokens.current.borderColor}, rgba(255, 255, 255, 0.2))',
      'box-shadow': '0px 8px 24px rgba(0, 0, 0, 0.12)',
    },

    'frosted-glass-tile': {
      'padding': '0 5px',
      'border-radius': '12px',
      'transition':
          'transform 0.15s ease, color 0.15s ease, background 0.2s ease, box-shadow 0.2s ease',
    },

    'frosted-glass-hover-tile': {
      'background-color':
          'color-mix(in srgb, var(${Tokens.current.primaryColor}, ${Tokens.current.primaryColor.value}) 7%, transparent)',
    },

    'frosted-glass-selected-tile': {
      'background-color':
          'color-mix(in srgb, var(${Tokens.current.primaryColor}, ${Tokens.current.primaryColor.value}) 14%, transparent)',
      'height': '90%',
      'padding': '0 22px',
      'box-shadow':
          'inset 0 0 0 1px color-mix(in srgb, var(${Tokens.current.primaryColor}, ${Tokens.current.primaryColor.value}) 18%, transparent)',
    },

    // Landscape layouts
    'spread-layout': {'justify-content': 'space-around'},

    'centered-layout': {'justify-content': 'space-between'},

    'linear-layout': {'justify-content': 'space-around'},

    // Tile
    'tile': {
      'cursor': 'pointer',
      'height': '100%',
      'user-select': 'none',
      'box-sizing': 'border-box',
      'transition': 'transform 0.15s ease, color 0.15s ease',
      'justify-content': 'center',
      'display': 'flex',
      'align-items': 'center',
    },

    'label': {
      'line-height': '1',
      'text-overflow': 'ellipsis',
      'overflow': 'hidden',
      'white-space': 'nowrap',
    },

    'fixed-tile': {
      'flex': '1',
      'min-width': '64px',
      'max-width': '168px',
      'height': '100%',
    },
  };

  /// Default CSS styles map for styling buttons
  /// (paddings, typography, hover/disabled transitions).
  static final nakiButtonStyle = {
    'height':
        'var(${Tokens.current.buttonHeight}, '
        '${Tokens.current.buttonHeight.value})',
    'width':
        'var(${Tokens.current.buttonWidth}, '
        '${Tokens.current.buttonWidth.value})',
    'display': 'flex',
    'box-sizing': 'border-box',
    'padding': '10px',
    'border': 'none',
    'cursor': 'pointer',
    'border-radius': '12px',
    'background-color':
        'var(${Tokens.current.buttonBackgroundColor}, '
        '${Tokens.current.buttonBackgroundColor.value})',
    'justify-content': 'center',
    'align-items': 'center',
    'color':
        'var(${Tokens.current.buttonColor}, '
        '${Tokens.current.buttonColor.value})',
    'text-wrap-mode': 'nowrap',
    'text-align': 'center',
    'line-height': '1',
  };

  /// Default CSS styles map for styling scaffold layout
  /// (wrapper height, main content, floating action button placement).
  static final nakiScaffoldStyle = {
    'wrapper': {
      'display': 'flex',
      'flex-direction': 'column',
      'height': '100dvh',
      'max-height': '100dvh',
      'overflow': 'hidden',
      'position': 'relative',
      'width': '100%',
      'padding-top': 'env(safe-area-inset-top, 0px)',
      'padding-left': 'env(safe-area-inset-left, 0px)',
      'padding-right': 'env(safe-area-inset-right, 0px)',
      'padding-bottom': 'env(safe-area-inset-bottom, 0px)',
    },

    'appbar': {
      'z-index': _appBarZindex,
      'position': 'sticky',
      'top': '0',
      'width': '100%',
      'flex-shrink': '0',
    },

    'layout': {
      'display': 'flex',
      'flex': '1',
      'min-height': '0',
      'width': '100%',
      'overflow': 'hidden',
    },

    'sidebar': {
      'flex-shrink': '1',
      'align-self': 'start',
      'overflow': 'auto',
      'height':
          'calc(100dvh - var(${Tokens.current.appbarHeight}, '
          '${Tokens.current.appbarHeight.value}))',
      'top':
          'var(${Tokens.current.appbarHeight}, '
          '${Tokens.current.appbarHeight.value})',
    },

    'body': {
      'flex': '1',
      'min-width': '0',
      'min-height': '0',
      'height': '100%',
      'overflow': 'hidden',
      'position': 'relative',
    },

    'bottom-navbar': {
      'width': '100%',
      'flex-shrink': '0',
      'position': 'sticky',
      'bottom': '0',
      'z-index': _bottomNavBarZindex,
    },

    'fab': {
      'position': 'fixed',
      'bottom': '24px',
      'right': '24px',
      'z-index': _fabZindex,
    },
  };

  /// Default CSS styles map for styling radio buttons
  /// (wrapper, input, checked, disabled states).
  static final nakiRadioBtnStyle = {
    'wrapper': {
      'display': 'flex',
      'gap': '15px',
      'width': 'fit-content',
      'align-items': 'center',
    },

    'input': {
      'position': 'relative',
      'display': 'inline-block',
      'flex-shrink': '0',
      'cursor': 'pointer',
      'appearance': 'none',
      '-webkit-appearance': 'none',
      'border-radius': '50%',
      'padding': '4px',
      'vertical-align': 'middle',
      'border': '1px solid',
      'border-color': 'color-mix(in srgb, currentcolor 20%, #0000)',
      'width':
          'var(${Tokens.current.radioBtnRadius}, ${Tokens.current.radioBtnRadius.value})',
      'height':
          'var(${Tokens.current.radioBtnRadius}, ${Tokens.current.radioBtnRadius.value})',
      'color':
          'var(${Tokens.current.radioBtnColor}, ${Tokens.current.radioBtnColor.value})',
      'transition': 'border-color 0.2s',
      'margin': '0',
    },

    'before': {
      'content': '""',
      'display': 'block',
      'width': '100%',
      'height': '100%',
      'border-radius': '50%',
      'background-color': 'transparent',
      'transition': 'background 0.2s ease-out',
    },

    'checked': {
      'border-color': 'currentcolor',
      'background-color':
          'var(${Tokens.current.backgroundColor}, ${Tokens.current.backgroundColor.value})',
    },

    'checked:before': {'background-color': 'currentcolor'},

    'disabled': nakiDisabledStyle,
  };

  /// Default CSS style maps for styling dropdown
  /// (wrapper, host, label, options, item, selected item).
  static final nakiDropdownStyle = {
    'wrapper': {
      'position': 'relative',
      'width':
          'var(${Tokens.current.dropdownWidth}, ${Tokens.current.dropdownWidth.value})',
    },

    'trigger': {
      'display': 'inline-flex',
      'justify-content': 'space-between',
      'align-items': 'center',
      'box-sizing': 'border-box',
      'cursor': 'pointer',
      'color':
          'var(${Tokens.current.inputTextColor}, ${Tokens.current.inputTextColor.value})',
      'font-size':
          'var(${Tokens.current.fontSizeInput}, ${Tokens.current.fontSizeInput.value})',
      'background-color':
          'var(${Tokens.current.fieldBackgroundColor}, ${Tokens.current.fieldBackgroundColor.value})',
      'border-radius': '12px',
      'border': Tokens.current.border.value,
      'padding': '0 15px',
      'width': '100%',
      'height':
          'var(${Tokens.current.dropdownHeight}, ${Tokens.current.dropdownHeight.value})',
      'text-overflow': 'ellipsis',
      'overflow': 'hidden',
      'white-space': 'nowrap',
    },

    'option': {
      'display': 'block',
      'scroll-snap-align': 'center',
      'padding':
          'var(${Tokens.current.dropdownOptionPadding}, ${Tokens.current.dropdownOptionPadding.value})',
      'cursor': 'pointer',
      'font-size':
          'var(${Tokens.current.dropdownOptionFontSize}, ${Tokens.current.dropdownOptionFontSize.value})',
    },

    'option:selected': {
      'color':
          'var(${Tokens.current.selectedItemColor}, ${Tokens.current.selectedItemColor.value})',
      'background-color':
          'var(${Tokens.current.selectedItemBgColor}, ${Tokens.current.selectedItemBgColor.value})',
    },

    'placeholder.option': {
      'color':
          'var(${Tokens.current.placeholderColor}, ${Tokens.current.placeholderColor.value})',
      'pointer-events': 'none',
    },

    'section.option': {
      'font-weight':
          'var(${Tokens.current.fontWeightSectionHeader}, ${Tokens.current.fontWeightSectionHeader.value})',
      'font-size':
          'var(${Tokens.current.fontSizeSectionHeader}, ${Tokens.current.fontSizeSectionHeader.value})',
      'pointer-events': 'none',
    },

    'inner:after': {
      // arrow down (dropdown closed)
      'content': '""',
      'position': 'relative',
      'width': '8px',
      'height': '8px',
      'border-top': '2px solid currentcolor',
      'border-right': '2px solid currentcolor',
      'rotate': '134deg',
      'margin-bottom': '5px',
      'border-radius': '2px',
    },

    'inner.is-open:after': {
      // arrow up (dropdown open)
      'rotate': '315deg',
      'margin-top': '10px',
    },

    'options-wrapper': {
      'visibility': 'hidden',
      'opacity': '0',
      'overflow': 'hidden',
      'pointer-events': 'none',
      'top': 'calc(100% + 3px)',
      'left': '0',
      'z-index': _dropdownZindex,
      'width': '100%',
      'height': '0',
      'display': 'flex',
      'flex-direction': 'column',
      'position': 'absolute',
      'transform-origin': 'top left',
      'transition':
          'transform 0.2s ease, opacity 0.2s ease, visibility 0.2s ease, height 0.2s ease',
    },

    'open:options-wrapper': {
      'visibility': 'visible',
      'opacity': '1',
      'pointer-events': 'auto',
      'height': 'fit-content',
      'overscroll-behavior': 'none',
      'background-color':
          'var(${Tokens.current.dropdownMenuBgColor}, ${Tokens.current.dropdownMenuBgColor.value})',
      'border': Tokens.current.border.value,
      'border-radius': '12px',
      'max-height':
          'var(${Tokens.current.dropdownMenuHeight}, ${Tokens.current.dropdownMenuHeight.value})',
    },

    'upward:options-wrapper': {
      'top': 'auto',
      'bottom': 'calc(100% + 3px)',
      'transform-origin': 'bottom left',
    },

    'search-box': {
      'position': 'sticky',
      'top': '-1px',
      'z-index': '15',
      'background-color':
          'var(${Tokens.current.dropdownMenuBgColor}, ${Tokens.current.dropdownMenuBgColor.value})',
    },

    'no-search-result': {
      'padding': '20px',
      'font-size': '13px',
      'text-align': 'center',
      'color':
          'var(${Tokens.current.placeholderColor}, ${Tokens.current.placeholderColor.value})',
      'user-select': 'none',
      'margin': '0 auto',
    },
  };

  /// Default CSS styles map for styling spinner.
  static final nakiSpinnerStyle = {
    'default': {
      'width':
          'var(${Tokens.current.spinnerSize}, ${Tokens.current.spinnerSize.value})',
      'height':
          'var(${Tokens.current.spinnerSize}, ${Tokens.current.spinnerSize.value})',
      'border-radius': '50%',
      'border': Tokens.current.spinnerBorder.value,
      'border-top-color':
          'var(${Tokens.current.spinnerColor}, ${Tokens.current.spinnerColor.value})',
      'animation': 'nakiSpin 0.8s linear infinite',
      'user-select': 'none',
      'pointer-events': 'none',
    },

    'glass': {
      'background-color':
          'color-mix(in srgb, var(${Tokens.current.spinnerSurfaceColor}, ${Tokens.current.spinnerSurfaceColor.value}) 85%, grey)',
      'backdrop-filter': 'blur(6px)',
      'padding': '6px',
    },

    'ios': {
      'position': 'relative',
      'display': 'inline-block',
      'border': 'none',
      'animation': 'none',
      'border-radius': 'unset',
    },

    'blade': {
      'position': 'absolute',
      'top': '0',
      'height': '25%',
      'background-color':
          'var(${Tokens.current.spinnerBladeColor}, ${Tokens.current.spinnerBladeColor.value})',
      'border-radius': '2px',
      'left':
          'calc(50% - (min(var(${Tokens.current.spinnerBorderWidth}, ${Tokens.current.spinnerBorderWidth.value}), 4px) / 2))',
      'width':
          'min(var(${Tokens.current.spinnerBorderWidth}, ${Tokens.current.spinnerBorderWidth.value}), 4px)',
      'transform-origin':
          '50% calc(var(${Tokens.current.spinnerSize}, ${Tokens.current.spinnerSize.value}) / 2)',
    },
  };

  /// Default CSS styles map for a form.
  static final nakiFormStyle = {
    'display': 'flex',
    'justify-content': 'flex-start',
    'flex-direction': 'column',
    'overflow': 'auto',
  };

  /// Default CSS styles map for SingleChildScrollView.
  static final nakiSingleChildScrollViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for ListView.
  static final nakiListViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for GridView.
  static final nakiGridViewStyle = {
    'display': 'grid',
    'box-sizing': 'border-box',
    'grid-template-columns': 'repeat(auto-fill, minmax(150px, 1fr))',
    'gap': 'var(${Tokens.current.gridGap})',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for PageView.
  static final nakiPageViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'overflow-x': 'auto',
    'overflow-y': 'auto',
    'scrollbar-width': 'none',
    '-ms-overflow-style': 'none',
  };

  /// Default CSS styles map for CarouselView.
  static final nakiCarouselStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'overflow-x': 'auto',
    'overflow-y': 'hidden',
    'gap': 'var(${Tokens.current.carouselGap})',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for TableView / Table.
  static final nakiTableStyle = {
    'wrapper': {
      'display': 'block',
      'overflow-x': 'auto',
      'width': '100%',
      'scrollbar-width': 'none',
    },

    'main': {
      'width': '100%',
      'border-collapse': 'collapse',
      'box-sizing': 'border-box',
      'text-align': 'left',
    },

    'empty': {
      'max-width': '300px',
      'text-align': 'center',
      'margin': '0 auto',
      'padding': '60px, 0',
      'text-wrap': 'balance',
    },
  };

  /// Default CSS styles map for StaggeredView.
  static final nakiStaggeredStyle = {
    'display': 'block',
    'width': '100%',
    'box-sizing': 'border-box',
    'overflow-y': 'auto',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for Snackbar.
  static final nakiSnackbarStyle = {
    'position': 'fixed',
    'z-index': _snackbarZindex,
    'display': 'flex',
    'align-items': 'center',
    'justify-content': 'space-between',
    'max-width': '600px',
    'width': 'max-content',
    'gap': '10px',
    'background-color':
        'var(${Tokens.current.snackbarBgColor}, ${Tokens.current.snackbarBgColor.value})',
    'color':
        'var(${Tokens.current.snackbarForegroundColor}, ${Tokens.current.snackbarForegroundColor.value})',
    'border-radius':
        'var(${Tokens.current.snackbarBorderRadius}, ${Tokens.current.snackbarBorderRadius.value})',
    'padding':
        'var(${Tokens.current.snackbarPadding}, ${Tokens.current.snackbarPadding.value})',
    'box-shadow':
        'var(${Tokens.current.largeShadow}, ${Tokens.current.largeShadow.value})',
    'box-sizing': 'border-box',
    'line-height': '1',
    'transition': 'transform 0.2s cubic-bezier(0.4, 0, 0.2, 1)',
  };

  /// Default CSS styles map for Banner.
  static final nakiBannerStyle = {
    'display': 'flex',
    'align-items': 'center',
    'gap': '10px',
    'background-color':
        'var(${Tokens.current.bannerBgColor}, ${Tokens.current.bannerBgColor.value})',
    'color':
        'var(${Tokens.current.bannerForegroundColor}, ${Tokens.current.bannerForegroundColor.value})',
    'border-radius':
        'var(${Tokens.current.bannerBorderRadius}, ${Tokens.current.bannerBorderRadius.value})',
    'padding':
        'var(${Tokens.current.bannerPadding}, ${Tokens.current.bannerPadding.value})',
    'border':
        '1px solid var(${Tokens.current.bannerBorderColor}, ${Tokens.current.bannerBorderColor.value})',
    'box-sizing': 'border-box',
    'width': '100%',
    'line-height': '1',
  };

  /// Default CSS styles map for Tooltip.
  static final nakiTooltipStyle = {
    'wrapper': {
      'position': 'relative',
      'display': 'inline-block',
    },

    'content': {
      'position': 'absolute',
      'z-index': _tooltipZindex,
      'background-color':
          'var(${Tokens.current.tooltipBgColor}, ${Tokens.current.tooltipBgColor.value})',
      'color':
          'var(${Tokens.current.tooltipTextColor}, ${Tokens.current.tooltipTextColor.value})',
      'border-radius':
          'var(${Tokens.current.tooltipBorderRadius}, ${Tokens.current.tooltipBorderRadius.value})',
      'padding':
          'var(${Tokens.current.tooltipPadding}, ${Tokens.current.tooltipPadding.value})',
      'font-size':
          'var(${Tokens.current.tooltipFontSize}, ${Tokens.current.tooltipFontSize.value})',
      'pointer-events': 'none',
      'opacity': '0',
      'visibility': 'hidden',
      'transition': 'opacity 0.15s ease, visibility 0.15s ease',
      'width': 'max-content',
      'max-width': '200px',
      'line-height': '16px',
      'height': 'fit-content',
      'overflow': 'visible',
      'text-wrap': 'balance',
      'box-shadow': Tokens.current.smallShadow.value,
    },
  };

  /// Default CSS styles map for Popover.
  static final nakiPopoverStyle = {
    'wrapper': {
      'position': 'relative',
      'display': 'inline-block',
    },

    'barrier': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _popoverBarrierZindex,
      'background-color': 'transparent',
      'cursor': 'default',
    },

    'show': {
      'opacity': '1',
      'visibility': 'visible',
      'pointer-events': 'auto',
      'height': 'fit-content',
      'background-color':
          'var(${Tokens.current.popoverBgColor}, ${Tokens.current.popoverBgColor.value})',
      'color':
          'var(${Tokens.current.popoverTextColor}, ${Tokens.current.popoverTextColor.value})',
      'border-radius':
          'var(${Tokens.current.popoverBorderRadius}, ${Tokens.current.popoverBorderRadius.value})',
      'border':
          '1px solid var(${Tokens.current.popoverBorderColor}, ${Tokens.current.popoverBorderColor.value})',
      'box-shadow':
          'var(${Tokens.current.popoverShadow}, ${Tokens.current.popoverShadow.value})',
      'padding':
          'var(${Tokens.current.popoverPadding}, ${Tokens.current.popoverPadding.value})',
    },

    'popup': {
      'position': 'absolute',
      'z-index': _popoverZindex,
      'opacity': '0',
      'visibility': 'hidden',
      'pointer-events': 'none',
      'height': '0',
      'width': 'fit-content',
      'box-sizing': 'border-box',
    },
  };

  /// Default CSS styles map for Dialog.
  static final nakiDialogStyle = {
    'backdrop': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _modalBarrierZindex,
      'background-color':
          'var(${Tokens.current.dialogBarrierBg}, ${Tokens.current.dialogBarrierBg.value})',
      'display': 'flex',
      'align-items': 'center',
      'justify-content': 'center',
      'box-sizing': 'border-box',
      'width': '100dvw',
      'height': '100dvh',
      'backdrop-filter': 'blur(5px)',
      'overscroll-behavior': 'none',
      'touch-action': 'none',
      'animation':
          'nakiDialogFadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },

    'container': {
      'position': 'relative',
      'z-index': _modalZindex,
      'display': 'flex',
      'flex-direction': 'column',
      'margin': '20px',
      'background-color':
          'var(${Tokens.current.dialogBgColor}, ${Tokens.current.dialogBgColor.value})',
      'border-radius':
          'var(${Tokens.current.dialogBorderRadius}, ${Tokens.current.dialogBorderRadius.value})',
      'padding':
          'var(${Tokens.current.dialogPadding}, ${Tokens.current.dialogPadding.value})',
      'width': 'fit-content',
      'height': 'fit-content',
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'animation':
          'nakiDialogPopIn 0.22s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },
  };

  /// Default CSS styles map for Drawer.
  static final nakiDrawerStyle = {
    'wrapper': {
      'position': 'relative',
      'overflow': 'auto',
      'overscroll-behavior': 'none',
      'z-index': _drawerZindex,
      'display': 'inline-flex',
      'animation':
          'nakiDrawerFadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },

    'barrier': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _drawerBarrierZindex,
      'width': '100dvw',
      'height': '100dvh',
      'background-color':
          'var(${Tokens.current.drawerBarrierBg}, ${Tokens.current.drawerBarrierBg.value})',
      'box-sizing': 'border-box',
      'backdrop-filter': 'blur(5px)',
      'touch-action': 'none',
      'display': 'block',
    },

    'content': {
      'position': 'fixed',
      'top': '0',
      'bottom': '0',
      'overflow': 'auto',
      'z-index': _drawerZindex,
      'width':
          'var(${Tokens.current.drawerWidth}, ${Tokens.current.drawerWidth.value})',
      'background-color':
          'var(${Tokens.current.drawerBgColor}, ${Tokens.current.drawerBgColor.value})',
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'transition': 'transform 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
    },
  };

  /// Default CSS styles map for BottomSheet.
  static final nakiBottomSheetStyle = {
    'backdrop': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _bottomSheetBarrierZindex,
      'background-color':
          'var(${Tokens.current.bottomSheetBarrierBg}, ${Tokens.current.bottomSheetBarrierBg.value})',
      'display': 'flex',
      'align-items': 'flex-end',
      'justify-content': 'center',
      'width': '100dvw',
      'height': '100dvh',
      'box-sizing': 'border-box',
      'backdrop-filter': 'blur(5px)',
      'overscroll-behavior': 'none',
      'touch-action': 'none',
      'animation':
          'nakiDrawerFadeIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },

    'container': {
      'position': 'relative',
      'z-index': _bottomSheetZindex,
      'width': '100%',
      'max-width': '600px',
      'max-height':
          'var(${Tokens.current.bottomSheetMaxHeight}, ${Tokens.current.bottomSheetMaxHeight.value})',
      'background-color':
          'var(${Tokens.current.bottomSheetBgColor}, ${Tokens.current.bottomSheetBgColor.value})',
      'border-radius':
          'var(${Tokens.current.bottomSheetBorderRadius}, ${Tokens.current.bottomSheetBorderRadius.value})',
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'overflow-y': 'auto',
      'animation':
          'nakiBottomSheetSlideUp 0.28s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },

    'handle': {
      'display': 'block',
      'position': 'sticky',
      'top': '0',
      'z-index': _bottomSheetZindex,
      'width': '70px',
      'height': '5px',
      'border-radius': '12px',
      'background-color': 'rgba(150, 150, 150, 0.4)',
      'margin': '10px auto',
    },
  };

  /// Default calendar style
  static final nakiCalendarStyle = {
    'wrapper': {'position': 'relative'},

    'default-trigger': {
      'height':
          'var(${Tokens.current.buttonHeight}, ${Tokens.current.buttonHeight.value})',
      'color':
          'var(${Tokens.current.inputTextColor}, ${Tokens.current.inputTextColor.value})',
      'font-size':
          'var(${Tokens.current.fontSizeInput}, ${Tokens.current.fontSizeInput.value})',
      'background-color':
          'var(${Tokens.current.fieldBackgroundColor}, ${Tokens.current.fieldBackgroundColor.value})',
      'border-radius': '12px',
      'padding': '0 15px',
      'border': Tokens.current.border.value,
      'user-select': 'none',
      'line-height': 'normal',
      'text-align': 'left',
      'justify-content': 'left',
      ...nakiTextTruncateStyle,
    },

    'modal': {
      'top': 'calc(100% + 3px)',
      'left': '0',
      'z-index': '10',
      'max-width': 'min(320px, 100vw)',
      'height': 'fit-content',
      'position': 'absolute',
      'background-color':
          'var(${Tokens.current.dropdownMenuBgColor}, ${Tokens.current.dropdownMenuBgColor.value})',
      'border': Tokens.current.border.value,
      'border-radius': '12px',
      'transform-origin': 'top left',
      'padding': '8px 5px',
      'transition': 'transform 0.2s ease',
    },

    'input': {
      'position': 'absolute',
      'top': '0',
      'left': '0',
      'visibility': 'hidden',
      'pointer-events': 'none',
      '-webkit-appearance': 'none',
      'appearance': 'none',
      'margin': '0',
      'height': '0',
      'width': '0',
    },

    'years-dropdown': {'z-index': '12'},

    'selected': {
      'color': 'white',
      'background-color':
          'var(${Tokens.current.primaryColor}, '
          '${Tokens.current.primaryColor.value})',
    },

    'disabled': {
      'opacity': '0.6',
      'pointer-events': 'none',
      'background-color': 'none',
    },
  };

  /// Default CSS styles map for Container.
  static final nakiContainerStyle = {
    'height': 'auto',
    'width': 'auto',
    'box-sizing': 'border-box',
  };

  /// Default CSS styles map for Card component.
  static final nakiCardStyle = {
    'root': {
      'display': 'block',
      'position': 'relative',
      'box-sizing': 'border-box',
      'background-color':
          'var(${Tokens.current.backgroundColor}, ${Tokens.current.backgroundColor.value})',
      'color':
          'var(${Tokens.current.baseTextColor}, ${Tokens.current.baseTextColor.value})',
      'border-radius':
          'var(${Tokens.current.radiusMd}, ${Tokens.current.radiusMd.value})',
      'transition':
          'box-shadow 200ms ease, transform 200ms ease, border-color 200ms ease',
    },

    'elevated': {
      'box-shadow':
          '0 1px 3px 0 var(${Tokens.current.shadowColor}, ${Tokens.current.shadowColor.value}), 0 1px 2px -1px var(${Tokens.current.shadowColor}, ${Tokens.current.shadowColor.value})',
    },

    'outlined': {
      'border':
          '1px solid var(${Tokens.current.borderColor}, ${Tokens.current.borderColor.value})',
      'box-shadow': 'none',
    },

    'filled': {
      'background-color':
          'var(${Tokens.current.surfaceVariantColor}, ${Tokens.current.surfaceVariantColor.value})',
      'box-shadow': 'none',
    },
  };

  /// Default CSS styles map for ExpansionPanelList and ExpansionTile components.
  static final nakiExpansionPanelStyle = {
    'list': {
      'display': 'flex',
      'flex-direction': 'column',
      'width': '100%',
      'box-sizing': 'border-box',
      'background-color':
          'var(${Tokens.current.backgroundColor}, ${Tokens.current.backgroundColor.value})',
      'overflow': 'hidden',
    },

    'panel': {
      'display': 'block',
      'position': 'relative',
      'box-sizing': 'border-box',
      'transition': 'background 200ms ease',
    },

    'header': {
      'display': 'flex',
      'align-items': 'center',
      'justify-content': 'space-between',
      'width': '100%',
      'padding': '14px 16px',
      'box-sizing': 'border-box',
      'cursor': 'pointer',
      'user-select': 'none',
      'background-color': 'transparent',
      'border': 'none',
      'text-align': 'left',
      'text-wrap-mode': 'wrap',
      'font-family': 'inherit',
      'font-size': 'inherit',
      'color': 'inherit',
      'transition': 'background 200ms ease',
    },

    'chevron': {
      'display': 'inline-flex',
      'align-items': 'center',
      'justify-content': 'center',
      'transition': 'transform 250ms cubic-bezier(0.2, 0.8, 0.2, 1)',
      'color':
          'var(${Tokens.current.mutedColor}, ${Tokens.current.mutedColor.value})',
    },

    'body-wrapper': {
      'display': 'grid',
      'grid-template-rows': '0fr',
      'transition': 'grid-template-rows 250ms cubic-bezier(0.2, 0.8, 0.2, 1)',
    },

    'body-content': {
      'overflow': 'hidden',
      'box-sizing': 'border-box',
      'text-wrap-mode': 'wrap',
    },

    'body-inner': {
      'padding': '5px 16px 16px 16px',
      'box-sizing': 'border-box',
    },
  };
}
