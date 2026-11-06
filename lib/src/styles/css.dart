import 'package:jaspr/dom.dart';
import '../models/styling.dart';
import '../theme/tokens.dart';
import 'text_style.dart';

/// CSS variable holding the selected index of a frosted bottom navigation bar.
const kNavbarIndexVar = '--naki-navbar-index';

/// CSS variable holding the item count of a frosted bottom navigation bar.
const kNavbarCountVar = '--naki-navbar-count';

/// Custom property holding the frosted bottom navbar's refraction filter.
const kNavbarRefractionVar = '--naki-navbar-refraction';

/// Custom property holding the selection droplet's refraction filter.
const kNavbarDropletRefractionVar = '--naki-navbar-droplet-refraction';

/// Custom property holding the color behind a glass card.
const kCardGlassColorVar = '--naki-card-glass-color';

/// Marks a component that handles the Scaffold insets itself.
///
/// A Scaffold body with such a direct child publishes the insets through
/// [kBodyInsetTopVar] and [kBodyInsetBottomVar] instead of padding its content.
const kInsetOwnerClass = 'naki-inset-owner';

/// Marks a scroll view that takes the height of its parent, so a
/// parent Row or Column has to give it one.
const kFillScrollClass = 'naki-fill-scroll';

/// Height of the Scaffold body covered by a fixed app bar.
const kScaffoldInsetTopVar = '--naki-scaffold-inset-top';

/// Top inset a [kInsetOwnerClass] component has to apply.
const kBodyInsetTopVar = '--naki-body-inset-top';

/// Bottom inset a [kInsetOwnerClass] component has to apply.
const kBodyInsetBottomVar = '--naki-body-inset-bottom';

/// CSS styling utilities and default styles for Naki components.
///
/// Contains default styles for common components
/// (inputs, checkboxes, sliders, etc.) and helper method
/// for color opacity manipulation.
class Css {
  /// Writes a variable token with its default value.
  static String _var(Token token, [String? fallback]) =>
      'var($token, ${fallback ?? token.value})';

  /// White at [alpha], scaled by the rim strength in [token].
  static String _glassRim(
    double alpha, [
    Token? token,
  ]) {
    final strength = _var(token ?? Tokens.current.bottomNavbarGlassRim);
    return 'color-mix(in srgb, white calc($strength * $alpha), transparent)';
  }

  /// Lit edge of a glass surface: a hairline, two highlights and a soft glow.
  static String _glassEdge(Token rim, {String glow = '10px'}) =>
      'inset 0 0 0 1px ${_glassRim(0.45, rim)}, '
      'inset 1.5px 1.5px 1px -0.5px ${_glassRim(0.85, rim)}, '
      'inset -1.5px -1.5px 1px -0.5px ${_glassRim(0.6, rim)}, '
      'inset 0 0 $glow 1px ${_glassRim(0.28, rim)}';

  /// The recipe every glass surface shares: [color] mixed down to [tint] over
  /// a blurred backdrop, finished with an edge lit by [rim].
  ///
  /// [refraction] names a custom property that replaces the blur when set.
  static Map<String, String> _glassSurface({
    required String color,
    required String tint,
    required String blur,
    required Token rim,
    String glow = '10px',
    String? shadow,
    String? refraction,
  }) {
    final frost = 'blur($blur)';
    return {
      'background-color': 'color-mix(in srgb, $color $tint, transparent)',
      '-webkit-backdrop-filter': '$frost saturate(140%)',
      'backdrop-filter': refraction == null
          ? '$frost saturate(140%)'
          : 'var($refraction, $frost) saturate(140%)',
      'box-shadow': [?shadow, _glassEdge(rim, glow: glow)].join(', '),
    };
  }

  /// Removes the backdrop effect from a glass surface.
  static const _noGlass = {
    '-webkit-backdrop-filter': 'none',
    'backdrop-filter': 'none',
  };

  /// Opaque glass for `prefers-reduced-transparency`.
  static Map<String, String> _glassSolid(String color) => {
    ..._noGlass,
    'background-color': color,
  };

  /// Opaque glass with a visible edge for `prefers-contrast`.
  static Map<String, String> _glassHighContrast(String color) => {
    ..._glassSolid(color),
    'box-shadow': 'inset 0 0 0 1.5px currentColor',
  };

  /// Outlined glass for `forced-colors`.
  static const _glassForcedColors = {
    ..._noGlass,
    'outline': '1px solid CanvasText',
  };

  /// Space between a glass spinner's disc and its arc.
  static const _spinnerGlassInset = '8px';

  /// Darkens the content behind the selection droplet.
  static String get _dropletDim {
    final strength = _var(Tokens.current.bottomNavbarGlassDroplet);
    return 'brightness(calc(100% - $strength * 0.25))';
  }

  /// Padding of a scroll view: [padding], plus the Scaffold insets when the
  /// view is [vertical], so its content can scroll clear of the bars.
  static Map<String, String> scrollPadding(
    EdgeInsets? padding, {
    required bool vertical,
  }) => {
    ...?padding?.pProps,
    if (vertical) ...{
      'padding-top': _insetPadding(padding?.top, kBodyInsetTopVar),
      'padding-bottom': _insetPadding(padding?.bottom, kBodyInsetBottomVar),
    },
  };

  /// Adds the inset in [variable] to a padding [value].
  static String _insetPadding(Dim? value, String variable) =>
      'calc(${value?.cssText ?? '0px'} + var($variable, 0px))';

  /// Bottom inset of the Scaffold body.
  static String get _scaffoldInsetBottom =>
      _var(Tokens.current.bottomNavbarInset);

  /// Top inset of the Scaffold body.
  static const _scaffoldInsetTop = 'var($kScaffoldInsetTopVar, 0px)';

  /// Stops descendants from applying insets that are already handled.
  static const nakiInsetConsumedStyle = {
    kBodyInsetTopVar: '0px',
    kBodyInsetBottomVar: '0px',
  };

  /// Mixes a color with transparent space to apply a custom opacity level.
  ///
  /// [opacity] is a value from 0.0 to 1.0.
  static Color applyOpacity(Token token, double opacity) {
    opacity = opacity > 1 ? opacity / 100 : opacity;
    return Color(_var(token)).withOpacity(opacity);
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
    'width': '100%',
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
    '-webkit-line-clamp': _var(Tokens.current.textMaxLines),
    'line-clamp': _var(Tokens.current.textMaxLines),
    'overflow': 'hidden',
    'height': 'auto',
    'max-height': 'none',
  };

  /// Default text style for form field labels.
  static final nakiLabelStyle = TextStyle(
    fontWeight: .w500,
    fontSize: Dim(null, unit: _var(Tokens.current.fontSizeLabel)),
    color: Color(_var(Tokens.current.labelColor)),
    lineHeight: Dim.normal,
    width: Dim.fitContent,
    margin: const EdgeInsets.only(bottom: Dim.px(12)),
  );

  /// Default text style for helper/hint text.
  static final nakiHelperTextStyle = TextStyle(
    fontSize: Dim(null, unit: _var(Tokens.current.fontSizeHint)),
    color: Color(_var(Tokens.current.mutedColor)),
    lineHeight: Dim.normal,
    padding: const EdgeInsets.only(top: Dim.px(5)),
    margin: EdgeInsets.zero,
    extra: {'white-space': 'pre-wrap', 'word-break': 'break-word'},
  );

  /// Default styles applied to components in their disabled state.
  static final nakiDisabledStyle = {'opacity': '0.3', 'pointer-events': 'none'};

  /// Default text style for form validation errors.
  static final nakiErrorTextStyle = TextStyle(
    fontSize: Dim(null, unit: _var(Tokens.current.fontSizeError)),
    lineHeight: Dim.normal,
    color: Color(_var(Tokens.current.errorColor)),
    extra: {'white-space': 'pre-wrap', 'word-break': 'break-word'},
  );

  /// Default border styling rule applied to inputs with validation errors.
  static final nakiErrorBorderStyle = {
    'outline': 'none',
    'border': '${Tokens.current.errorBorder.value} !important',
  };

  /// Default border styling rule applied to inputs with focus.
  static final nakiFocusBorderStyle = {
    'outline': 'none',
    'border': '${Tokens.current.focusBorder.value} !important',
  };

  /// Default styling rule applied to input fields on hover.
  static final nakiFieldHoverStyle = {
    'border': '${Tokens.current.fieldHoverBorder.value} !important',
  };

  /// Default placeholder text styling rule inside inputs.
  static final nakiPlaceholderStyle = {
    'color': _var(Tokens.current.placeholderColor),
    'opacity': '0.6',
    'z-index': '0',
    'position': 'absolute',
  };

  /// Default inline-block alignment and size styling rule for icons.
  static final nakiIconStyle = {
    'display': 'inline-block',
    'vertical-align': 'middle',
    'box-sizing': 'border-box',
  };

  /// Default styling rules for single-line text inputs.
  static final nakiInputStyle = {
    'icon-wrapper': {
      'height': _var(Tokens.current.inputHeight),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'border-radius': '12px',
      'border': Tokens.current.border.value,
      'overflow': 'clip',
    },

    'input': {
      'padding': '0 15px',
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'color': _var(Tokens.current.inputTextColor),
      'font-size': _var(Tokens.current.fontSizeInput),
      'margin': '0',
      'border-radius': '12px',
      'width': 'auto',
      'line-height': 'normal',
      'height': _var(Tokens.current.inputHeight),
      'border': Tokens.current.border.value,
      'overflow': 'clip',
    },
  };

  /// Default styling rules for multi-line textareas.
  static final nakiTextareaStyle = {
    'icon-wrapper': {
      'min-height': _var(Tokens.current.inputHeight),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'border-radius': '12px',
      'border': Tokens.current.border.value,
      'overflow': 'clip',
    },

    'input': {
      'min-height': _var(Tokens.current.inputHeight),
      'color': _var(Tokens.current.inputTextColor),
      'font-size': _var(Tokens.current.fontSizeInput),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'border': Tokens.current.border.value,
      'max-height': '250px',
      'padding': '10px 15px',
      'line-height': '1.5',
      'border-radius': '12px',
      'width': 'auto',
      'margin': '0',
      'overflow': 'clip',
    },
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
      'font-size': _var(Tokens.current.fontSizeInput),
      'font-weight': '600',
      'color': _var(Tokens.current.inputTextColor),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
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

  /// Default CSS styles map for stacked layers.
  static final nakiStackStyle = {
    'position': 'relative',
    'display': 'grid',
    'grid-template-areas': '"stack"',
    'place-items': 'start start',
    'isolation': 'isolate',
    'height': 'fit-content',
    'width': 'fit-content',
  };

  /// Default CSS styles map for safe area.
  static final nakiSafeAreaStyles = {
    'padding-top': 'env(safe-area-inset-top, 0px)',
    'padding-left': 'env(safe-area-inset-left, 0px)',
    'padding-right': 'env(safe-area-inset-right, 0px)',
    'padding-bottom': 'env(safe-area-inset-bottom, 0px)',
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
      '-webkit-appearance': 'none',
      'appearance': 'none',
      'border-radius': '4px',
      'padding': '4px',
      'vertical-align': 'middle',
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
      'line-height': 'normal',
    },

    'input': {
      'border': Tokens.current.border.value,
      'position': 'relative',
      'display': 'inline-grid',
      'flex-shrink': '0',
      'cursor': 'pointer',
      '-webkit-appearance': 'none',
      'appearance': 'none',
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
      'color': _var(Tokens.current.subtitleColor),
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
      'color': _var(Tokens.current.switchThumbColor),
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
      'display': 'flex',
      'position': 'relative',
    },

    'tooltip': {
      'position': 'absolute',
      'bottom': 'calc(100% + 5px)',
      'opacity': '0',
      'transform': 'translateX(-50%)',
      'background-color': _var(Tokens.current.baseTextColor),
      'color': _var(Tokens.current.backgroundColor),
      'padding': '7px',
      'pointer-events': 'none',
      'border-radius': '999px',
      'font-size': '12px',
      'min-width': '29px',
      'min-height': '29px',
      'text-align': 'center',
      'line-height': 'normal',
    },

    'input': {
      'border': 'none',
      'cursor': 'pointer',
      '-webkit-appearance': 'none',
      'appearance': 'none',
      'border-radius': '12px',
      'background-color': 'transparent',
      'vertical-align': 'middle',
      'margin': '0',
      'width': '100%',
      'height': _var(Tokens.current.sliderThumbSize),
    },

    'webkit-track': {
      'background-color': _var(Tokens.current.sliderTrackColor),
      'border-radius': '12px',
      'height': 'calc(${_var(Tokens.current.sliderThumbSize)} * 0.5)',
    },

    'webkit-thumb': {
      'position': 'relative',
      'box-sizing': 'border-box',
      'border-radius': '999px',
      'background-color': _var(Tokens.current.sliderTrackColor),
      'height': _var(Tokens.current.sliderThumbSize),
      'width': _var(Tokens.current.sliderThumbSize),
      'border': '5px solid ${_var(Tokens.current.sliderThumbColor)}',
      '-webkit-appearance': 'none',
      'appearance': 'none',
      'box-shadow': '0 0 0 2px ${_var(Tokens.current.sliderTrackColor)}',
      'bottom': '50%',
    },

    'moz-track': {
      'width': '100%',
      'background-color': _var(Tokens.current.sliderTrackColor),
      'border-radius': '12px',
      'height': 'calc(${_var(Tokens.current.sliderThumbSize)} * 0.5)',
    },

    'moz-thumb': {
      'position': 'relative',
      'box-sizing': 'border-box',
      'border-radius': '999px',
      'background-color': _var(Tokens.current.sliderTrackColor),
      'height': _var(Tokens.current.sliderThumbSize),
      'width': _var(Tokens.current.sliderThumbSize),
      'border': '5px solid ${_var(Tokens.current.sliderThumbColor)}',
      'top': '50%',
      'box-shadow': '0 0 0 2px ${_var(Tokens.current.sliderTrackColor)}',
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
      'height': _var(Tokens.current.appbarHeight),
      'background-color': _var(Tokens.current.appbarBgColor),
      'box-shadow': '0px 1px 2px rgba(0, 0, 0, 0.1)',
      'line-height': 'normal',
    },

    'title': {
      'font-size': _var(Tokens.current.fontSize3xl),
      'font-weight': _var(Tokens.current.fontWeightSemiBold),
      'flex-grow': '1',
      ...nakiTextTruncateStyle,
    },

    'actions': {
      'margin-left': 'auto',
      'display': 'flex',
      'gap': '20px',
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
      'height': _var(Tokens.current.bottomNavbarHeight),
      'background-color': _var(Tokens.current.bottomNavbarBgColor),
      'box-shadow': '0px -1px 0px rgba(0, 0, 0, 0.06)',
      'box-sizing': 'border-box',
      'z-index': _bottomNavBarZindex,
    },

    // Navbar types
    'fixed': {'width': '100%', 'border-radius': '0', 'padding': '0 3px'},

    'floating': {
      'width': 'calc(100% - 32px)',
      'max-width': '600px',
      'border-radius': '25px',
      'box-shadow':
          '0px 8px 24px rgba(0, 0, 0, 0.12), 0 1px 3px rgba(0, 0, 0, 0.08)',
    },

    'frosted-glass': {
      'width': 'calc(100% - 32px)',
      'max-width': '600px',
      'border-radius': '999px',
      'background-color': 'transparent',
      'box-shadow':
          '0 8px 28px rgba(0, 0, 0, 0.14), 0 1px 3px rgba(0, 0, 0, 0.08)',
    },

    'frosted-glass-rim': {
      'content': '""',
      'position': 'absolute',
      'inset': '0',
      'border-radius': 'inherit',
      'pointer-events': 'none',
      ..._glassSurface(
        color: _var(Tokens.current.bottomNavbarBgColor),
        tint: _var(Tokens.current.bottomNavbarGlassTint),
        blur: _var(Tokens.current.bottomNavbarGlassBlur),
        rim: Tokens.current.bottomNavbarGlassRim,
        refraction: kNavbarRefractionVar,
      ),
    },

    'frosted-glass-tile': {
      'position': 'relative',
      'flex': '1 1 0',
      'min-width': '0',
      'padding': '0 5px',
      'border-radius': '999px',
      'line-height': 'normal',
      'transition':
          'scale 0.45s cubic-bezier(0.2, 1.6, 0.35, 1), color 0.15s ease, '
          'background 0.2s ease',
    },

    'frosted-glass-tile-target': {
      'content': '""',
      'position': 'absolute',
      'inset': '0',
    },

    'frosted-glass-indicator': {
      'position': 'absolute',
      'top': '3px',
      'bottom': '3px',
      'inset-inline-start':
          'calc(100% * var($kNavbarIndexVar, 0) / var($kNavbarCountVar, 1) '
          '+ 3px)',
      'width': 'calc(100% / var($kNavbarCountVar, 1) - 6px)',
      'border-radius': '999px',
      'pointer-events': 'none',
      'background-color':
          'color-mix(in srgb, ${_var(Tokens.current.bottomNavbarBgColor)} '
          '${_var(Tokens.current.bottomNavbarGlassDroplet)}, '
          'transparent)',
      '-webkit-backdrop-filter': _dropletDim,
      'backdrop-filter': 'var($kNavbarDropletRefractionVar,) $_dropletDim',
      'box-shadow':
          '0 2px 10px rgba(0, 0, 0, 0.14), '
          'inset 0 0 0 1px ${_glassRim(0.55)}, '
          'inset 1.5px 1.5px 1px -0.5px ${_glassRim(0.9)}, '
          'inset -1.5px -1.5px 1px -0.5px ${_glassRim(0.65)}, '
          'inset 0 0 8px 1px ${_glassRim(0.35)}',
      'transition': 'inset-inline-start 0.3s cubic-bezier(0.2, 0.9, 0.3, 1)',
    },

    'frosted-glass-refraction': {
      'position': 'absolute',
      'width': '0',
      'height': '0',
    },

    'frosted-glass-reduced-transparency': {
      'background-color': _var(Tokens.current.bottomNavbarBgColor),
      ..._noGlass,
    },

    'frosted-glass-solid-indicator': {
      ..._noGlass,
      'background-color':
          'color-mix(in srgb, '
          '${_var(Tokens.current.primaryColor)} 14%, transparent)',
      'box-shadow': 'none',
    },

    'frosted-glass-high-contrast': {
      'background-color':
          'color-mix(in srgb, '
          '${_var(Tokens.current.bottomNavbarBgColor)} 92%, transparent)',
      'box-shadow': 'inset 0 0 0 1.5px currentColor',
    },

    'frosted-glass-high-contrast-indicator': {
      ..._noGlass,
      'background-color':
          'color-mix(in srgb, '
          '${_var(Tokens.current.primaryColor)} 24%, transparent)',
      'box-shadow': 'inset 0 0 0 2px ${_var(Tokens.current.primaryColor)}',
    },

    'frosted-glass-forced-colors': _glassForcedColors,

    'frosted-glass-forced-colors-indicator': {
      ..._noGlass,
      'outline': '2px solid Highlight',
      'outline-offset': '-2px',
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
      'line-height': 'normal',
    },

    'label': {
      'text-overflow': 'ellipsis',
      'overflow': 'hidden',
      'white-space': 'nowrap',
    },

    'frosted-glass-tile-focus': {'border-radius': '999px'},

    'tile-focus': {
      'outline': '2px solid ${_var(Tokens.current.primaryColor)}',
      'outline-offset': '-2px',
      'border-radius': '8px',
    },

    'tile-action': {'width': '100%'},

    'pressed-tile': {'scale': '0.96'},

    'hover-tile': {
      'border-radius': 'inherit',
      'background-color':
          'color-mix(in srgb, '
          '${_var(Tokens.current.primaryColor)} 7%, transparent)',
    },

    'fixed-tile': {
      'flex': '1',
      'max-width': '168px',
    },
  };

  /// Default CSS styles map for styling buttons
  /// (paddings, typography, hover/disabled transitions).
  static final nakiButtonStyle = {
    'height': _var(Tokens.current.buttonHeight),
    'width': _var(Tokens.current.buttonWidth),
    'display': 'flex',
    'box-sizing': 'border-box',
    'padding': '8px',
    'border': 'none',
    'cursor': 'pointer',
    'border-radius': '12px',
    'background-color': _var(Tokens.current.buttonBackgroundColor),
    'justify-content': 'center',
    'align-items': 'center',
    'color': _var(Tokens.current.buttonForegroundColor),
    'text-wrap-mode': 'nowrap',
    'text-align': 'center',
    'line-height': 'normal',
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
      'position': 'absolute',
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
      'align-self': 'stretch',
      'overflow': 'auto',
      'height': '100%',
      'min-height': '0',
    },

    'body': {
      ...nakiInsetConsumedStyle,
      'flex': '1',
      'min-width': '0',
      'min-height': '0',
      'height': '100%',
      'overflow': 'hidden',
      'position': 'relative',
      'box-sizing': 'border-box',
      'padding-top': _scaffoldInsetTop,
      'padding-bottom': _scaffoldInsetBottom,
    },

    // the owner takes over, so its content can pass behind the bars
    'inset-owner-body': {
      kBodyInsetTopVar: _scaffoldInsetTop,
      kBodyInsetBottomVar: _scaffoldInsetBottom,
      'padding-top': '0',
      'padding-bottom': '0',
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
      'bottom':
          'calc(20px + ${_var(Tokens.current.bottomNavbarOffset, '0px')} '
          '+ env(safe-area-inset-bottom, 0px))',
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
      '-webkit-appearance': 'none',
      'appearance': 'none',
      'border-radius': '999px',
      'padding': '4px',
      'vertical-align': 'middle',
      'border': '1px solid color-mix(in srgb, currentcolor 20%, #0000)',
      'width': _var(Tokens.current.radioBtnRadius),
      'height': _var(Tokens.current.radioBtnRadius),
      'color': _var(Tokens.current.radioBtnColor),
      'transition': 'border-color 0.2s',
      'margin': '0',
    },

    'before': {
      'content': '""',
      'display': 'block',
      'width': '100%',
      'height': '100%',
      'border-radius': '999px',
      'background-color': 'transparent',
      'transition': 'background 0.2s ease-out',
    },

    'checked': {
      'border-color': 'currentcolor',
      'background-color': _var(Tokens.current.backgroundColor),
    },

    'checked:before': {'background-color': 'currentcolor'},

    'disabled': nakiDisabledStyle,
  };

  /// Default CSS style maps for styling dropdown
  /// (wrapper, host, label, options, item, selected item).
  static final nakiDropdownStyle = {
    'wrapper': {
      'position': 'relative',
      'width': _var(Tokens.current.dropdownWidth),
    },

    'trigger': {
      'display': 'inline-flex',
      'justify-content': 'space-between',
      'align-items': 'center',
      'box-sizing': 'border-box',
      'cursor': 'pointer',
      'color': _var(Tokens.current.inputTextColor),
      'font-size': _var(Tokens.current.fontSizeInput),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'border-radius': '12px',
      'border': Tokens.current.border.value,
      'padding': '0 15px',
      'width': '100%',
      'height': _var(Tokens.current.dropdownHeight),
      'text-overflow': 'ellipsis',
      'overflow': 'hidden',
      'white-space': 'nowrap',
    },

    'option': {
      'display': 'block',
      'scroll-snap-align': 'center',
      'scroll-margin-top': '40px',
      'padding': _var(Tokens.current.dropdownOptionPadding),
      'cursor': 'pointer',
      'font-size': _var(Tokens.current.dropdownOptionFontSize),
    },

    'option:selected': {
      'color': _var(Tokens.current.selectedItemColor),
      'background-color': _var(Tokens.current.selectedItemBgColor),
    },

    'placeholder.option': {
      'color': _var(Tokens.current.placeholderColor),
      'pointer-events': 'none',
    },

    'section.option': {
      'font-weight': _var(Tokens.current.fontWeightSectionHeader),
      'font-size': _var(Tokens.current.fontSizeSectionHeader),
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
      'background-color': _var(Tokens.current.dropdownMenuBgColor),
      'border': Tokens.current.border.value,
      'border-radius': '12px',
      'line-height': 'normal',
      'max-height': _var(Tokens.current.dropdownMenuHeight),
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
      'background-color': _var(Tokens.current.dropdownMenuBgColor),
    },

    'no-search-result': {
      'padding': '20px',
      'font-size': '13px',
      'text-align': 'center',
      'color': _var(Tokens.current.placeholderColor),
      'user-select': 'none',
      'margin': '0 auto',
    },
  };

  /// Default CSS styles map for styling spinner.
  static final nakiSpinnerStyle = {
    'default': {
      'width': _var(Tokens.current.spinnerSize),
      'height': _var(Tokens.current.spinnerSize),
      'border-radius': '999px',
      'border': Tokens.current.spinnerBorder.value,
      'border-top-color': _var(Tokens.current.spinnerColor),
      'animation': 'nakiSpin 0.8s linear infinite',
      'user-select': 'none',
      'pointer-events': 'none',
    },

    'glass': {
      'position': 'relative',
      'display': 'inline-block',
      'box-sizing': 'content-box',
      'padding': _spinnerGlassInset,
      'border': 'none',
      'animation': 'none',
      ..._glassSurface(
        color: _var(Tokens.current.spinnerSurfaceColor),
        tint: '20%',
        blur: '8px',
        rim: Tokens.current.spinnerGlassRim,
        glow: '8px',
        shadow: '0 6px 18px rgba(0, 0, 0, 0.14), 0 1px 3px rgba(0, 0, 0, 0.08)',
      ),
    },

    'glass-arc': {
      'content': '""',
      'position': 'absolute',
      'inset': _spinnerGlassInset,
      'box-sizing': 'border-box',
      'border-radius': '999px',
      'border': Tokens.current.spinnerBorder.value,
      'border-top-color': _var(Tokens.current.spinnerColor),
      'animation': 'nakiSpin 0.8s linear infinite',
    },

    'reduced-motion': {
      'animation-name': 'nakiSpinnerPulse !important',
      'animation-duration': '0.8s !important',
      'animation-timing-function': 'ease-in-out !important',
      'animation-iteration-count': 'infinite !important',
      'animation-direction': 'alternate !important',
    },

    'glass-solid': _glassSolid(_var(Tokens.current.spinnerSurfaceColor)),

    'glass-high-contrast': _glassHighContrast(
      _var(Tokens.current.spinnerSurfaceColor),
    ),

    'glass-forced-colors': _glassForcedColors,

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
      'background-color': _var(Tokens.current.spinnerBladeColor),
      'border-radius': '2px',
      'left':
          'calc(50% - (min(${_var(Tokens.current.spinnerBorderWidth)}, 4px) / 2))',
      'width': 'min(${_var(Tokens.current.spinnerBorderWidth)}, 4px)',
      'transform-origin': '50% calc(${_var(Tokens.current.spinnerSize)} / 2)',
    },
  };

  /// Default CSS styles map for a form.
  static final nakiFormStyle = {
    'display': 'flex',
    'justify-content': 'flex-start',
    'flex-direction': 'column',
    'min-height': '0',
    'min-width': '0',
    'overflow': 'auto',
  };

  /// Default CSS styles map for SingleChildScrollView.
  static final nakiSingleChildScrollViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'flex': '1',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for ListView.
  static final nakiListViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'flex': '1',
    'min-height': '0',
    'min-width': '0',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for GridView.
  static final nakiGridViewStyle = {
    'display': 'grid',
    'box-sizing': 'border-box',
    'grid-template-columns': 'repeat(auto-fill, minmax(150px, 1fr))',
    'gap': _var(Tokens.current.gridGap),
    'justify-items': 'start',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for PageView.
  static final nakiPageViewStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'overflow-x': 'auto',
    'overflow-y': 'auto',
    'flex': '1',
    'width': '100%',
    'height': '100%',
    'min-height': '0',
    'min-width': '0',
    'scrollbar-width': 'none',
  };

  /// Default CSS styles map for a PageView page that does not scroll, which
  /// has nothing to pass behind the Scaffold's bars.
  static final nakiPageViewStaticPageStyle = {
    'box-sizing': 'border-box',
    'padding-top': _insetPadding(null, kBodyInsetTopVar),
    'padding-bottom': _insetPadding(null, kBodyInsetBottomVar),
  };

  /// Default CSS styles map for CarouselView.
  static final nakiCarouselStyle = {
    'display': 'flex',
    'box-sizing': 'border-box',
    'overflow-x': 'auto',
    'overflow-y': 'hidden',
    'gap': _var(Tokens.current.carouselGap),
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
      'padding': '60px 0',
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
    'justify-content': 'space-between',
    'max-width': '600px',
    'width': 'max-content',
    'gap': '10px',
    'background-color': _var(Tokens.current.snackbarBgColor),
    'color': _var(Tokens.current.snackbarForegroundColor),
    'border-radius': _var(Tokens.current.snackbarBorderRadius),
    'padding': _var(Tokens.current.snackbarPadding),
    'box-shadow': _var(Tokens.current.largeShadow),
    'box-sizing': 'border-box',
    'line-height': 'normal',
    'animation': 'nakiDialogFadeIn 0.2s cubic-bezier(0.4, 0, 0.2, 1) forwards',
  };

  /// Default CSS styles map for Banner.
  static final nakiBannerStyle = {
    'display': 'flex',
    'gap': '10px',
    'background-color': _var(Tokens.current.bannerBgColor),
    'color': _var(Tokens.current.bannerForegroundColor),
    'border-radius': _var(Tokens.current.bannerBorderRadius),
    'padding': _var(Tokens.current.bannerPadding),
    'border': '1px solid ${_var(Tokens.current.bannerBorderColor)}',
    'box-sizing': 'border-box',
    'width': '100%',
    'line-height': 'normal',
    'overflow': 'clip',
  };

  /// Default CSS styles map for Tooltip.
  static final nakiTooltipStyle = {
    'wrapper': {'position': 'relative', 'display': 'inline-block'},

    'content': {
      'position': 'absolute',
      'z-index': _tooltipZindex,
      'background-color': _var(Tokens.current.tooltipBgColor),
      'color': _var(Tokens.current.tooltipTextColor),
      'border-radius': _var(Tokens.current.tooltipBorderRadius),
      'padding': _var(Tokens.current.tooltipPadding),
      'font-size': _var(Tokens.current.tooltipFontSize),
      'pointer-events': 'none',
      'opacity': '0',
      'visibility': 'hidden',
      'transition': 'opacity 0.15s ease, visibility 0.15s ease',
      'width': 'max-content',
      'max-width': '200px',
      'line-height': 'normal',
      'height': 'fit-content',
      'overflow': 'visible',
      'text-wrap': 'balance',
      'box-shadow': Tokens.current.smallShadow.value,
    },
  };

  /// Default CSS styles map for Popover.
  static final nakiPopoverStyle = {
    'wrapper': {'position': 'relative', 'display': 'block'},

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
      'line-height': 'normal',
      'background-color': _var(Tokens.current.popoverBgColor),
      'color': _var(Tokens.current.popoverTextColor),
      'border-radius': _var(Tokens.current.popoverBorderRadius),
      'border': '1px solid ${_var(Tokens.current.popoverBorderColor)}',
      'box-shadow': _var(Tokens.current.popoverShadow),
      'padding': _var(Tokens.current.popoverPadding),
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
      'transition': 'opacity 0.15s ease-in-out, visibility 0.15s ease-in-out',
    },
  };

  /// Default CSS styles map for Dialog.
  static final nakiDialogStyle = {
    'backdrop': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _modalBarrierZindex,
      'background-color': _var(Tokens.current.dialogBarrierBg),
      'display': 'flex',
      'align-items': 'center',
      'justify-content': 'center',
      'box-sizing': 'border-box',
      'width': '100dvw',
      'height': '100dvh',
      '-webkit-backdrop-filter': 'blur(5px)',
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
      'background-color': _var(Tokens.current.dialogBgColor),
      'border-radius': _var(Tokens.current.dialogBorderRadius),
      'padding': _var(Tokens.current.dialogPadding),
      'width': 'fit-content',
      'height': 'fit-content',
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'line-height': 'normal',
      'animation':
          'nakiDialogPopIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards',
    },

    // a blurred barrier is a backdrop root, which would hide the page from the
    // glass above it
    'glass-backdrop': _noGlass,

    'glass': _glassSurface(
      color: _var(Tokens.current.dialogBgColor),
      tint: _var(Tokens.current.glassTint),
      blur: _var(Tokens.current.glassBlur),
      rim: Tokens.current.glassRim,
      shadow: Tokens.current.largeShadow.value,
    ),

    'glass-solid': _glassSolid(_var(Tokens.current.dialogBgColor)),

    'glass-high-contrast': _glassHighContrast(
      _var(Tokens.current.dialogBgColor),
    ),

    'glass-forced-colors': _glassForcedColors,
  };

  /// Default CSS styles map for Sidebar.
  static final nakiSidebarStyle = {
    'content': {
      'height': '100%',
      'width': _var(Tokens.current.drawerWidth),
      'background-color': _var(Tokens.current.drawerBgColor),
      'box-sizing': 'border-box',
      'overflow': 'auto',
      'line-height': 'normal',
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
      'background-color': _var(Tokens.current.drawerBarrierBg),
      'box-sizing': 'border-box',
      '-webkit-backdrop-filter': 'blur(5px)',
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
      'width': _var(Tokens.current.drawerWidth),
      'background-color': _var(Tokens.current.drawerBgColor),
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'transition': 'transform 0.25s cubic-bezier(0.4, 0, 0.2, 1)',
      'line-height': 'normal',
    },
  };

  /// Default CSS styles map for BottomSheet.
  static final nakiBottomSheetStyle = {
    'backdrop': {
      'position': 'fixed',
      'inset': '0',
      'z-index': _bottomSheetBarrierZindex,
      'background-color': _var(Tokens.current.bottomSheetBarrierBg),
      'display': 'flex',
      'align-items': 'flex-end',
      'justify-content': 'center',
      'width': '100dvw',
      'height': '100dvh',
      'box-sizing': 'border-box',
      '-webkit-backdrop-filter': 'blur(5px)',
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
      'max-height': _var(Tokens.current.bottomSheetMaxHeight),
      'background-color': _var(Tokens.current.bottomSheetBgColor),
      'border-radius': _var(Tokens.current.bottomSheetBorderRadius),
      'box-shadow': Tokens.current.largeShadow.value,
      'box-sizing': 'border-box',
      'overflow-y': 'hidden',
      'display': 'flex',
      'flex-direction': 'column',
      'line-height': 'normal',
      'animation':
          'nakiBottomSheetSlideUp 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards',
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
    'wrapper': {'position': 'relative', 'display': 'block'},

    'default-trigger': {
      'height': _var(Tokens.current.buttonHeight),
      'color': _var(Tokens.current.inputTextColor),
      'font-size': _var(Tokens.current.fontSizeInput),
      'background-color': _var(Tokens.current.fieldBackgroundColor),
      'border-radius': '12px',
      'padding': '0 15px',
      'border': Tokens.current.border.value,
      'user-select': 'none',
      'text-align': 'left',
      'justify-content': 'left',
      ...nakiTextTruncateStyle,
    },

    'modal': {
      'top': _var(Tokens.current.calendarTop),
      'bottom': _var(Tokens.current.calendarBottom),
      'left': '50%',
      'transform':
          'translateX(calc(-50% + ${_var(Tokens.current.calendarShiftX)})) '
          'translateY(${_var(Tokens.current.calendarGap)})',
      'z-index': '10',
      'overflow': 'auto',
      'box-sizing': 'border-box',
      'max-width': 'min(380px, calc(100dvw - 16px))',
      'max-height': _var(Tokens.current.calendarMaxHeight),
      'overscroll-behavior': 'none',
      'position': 'absolute',
      'background-color': _var(Tokens.current.dropdownMenuBgColor),
      'border': Tokens.current.border.value,
      'border-radius': '12px',
      'padding': '8px 5px 0',
      'box-shadow': _var(Tokens.current.popoverShadow),
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
      Tokens.current.baseTextColor.name: 'white',
      'border-color': 'transparent',
      'background-color': _var(Tokens.current.primaryColor),
    },

    'disabled': {
      'opacity': '0.3',
      'pointer-events': 'none',
      'background-color': 'transparent',
    },
  };

  /// Default CSS styles map for SizedBox.
  static final nakiSizedBoxStyle = {
    'display': 'block',
    'box-sizing': 'border-box',
    'flex-shrink': '0',
  };

  /// Default CSS styles map for Container.
  static final nakiContainerStyle = {
    'display': 'block',
    'height': 'auto',
    'width': 'auto',
    'box-sizing': 'border-box',
  };

  /// Color behind a glass card.
  static String get _cardGlassColor =>
      'var($kCardGlassColorVar, ${_var(Tokens.current.backgroundColor)})';

  /// Default CSS styles map for Card component.
  static final nakiCardStyle = {
    'root': {
      'display': 'block',
      'box-sizing': 'border-box',
      'background-color': _var(Tokens.current.backgroundColor),
      'color': _var(Tokens.current.baseTextColor),
      'border-radius': _var(Tokens.current.radiusMd),
      'transition':
          'box-shadow 200ms ease, transform 200ms ease, border-color 200ms ease',
    },

    'elevated': {
      'box-shadow':
          '0 1px 3px 0 ${_var(Tokens.current.shadowColor)}, 0 1px 2px -1px ${_var(Tokens.current.shadowColor)}',
    },

    'outlined': {
      'border': '1px solid ${_var(Tokens.current.borderColor)}',
      'box-shadow': 'none',
    },

    'filled': {
      'background-color': _var(Tokens.current.surfaceVariantColor),
      'box-shadow': 'none',
    },

    'glass': _glassSurface(
      color: _cardGlassColor,
      tint: _var(Tokens.current.glassTint),
      blur: _var(Tokens.current.glassBlur),
      rim: Tokens.current.glassRim,
      shadow: '0 8px 28px rgba(0, 0, 0, 0.14), 0 1px 3px rgba(0, 0, 0, 0.08)',
    ),

    'glass-hover': {
      'box-shadow':
          '0 12px 36px rgba(0, 0, 0, 0.18), 0 2px 6px rgba(0, 0, 0, 0.1), '
          '${_glassEdge(Tokens.current.glassRim)}',
    },

    'glass-solid': _glassSolid(_cardGlassColor),

    'glass-high-contrast': _glassHighContrast(_cardGlassColor),

    'glass-forced-colors': _glassForcedColors,
  };

  /// Default CSS styles map for ExpansionPanelList and ExpansionTile components.
  static final nakiExpansionPanelStyle = {
    'list': {
      'display': 'flex',
      'flex-direction': 'column',
      'width': '100%',
      'background-color': _var(Tokens.current.backgroundColor),
      'overflow': 'hidden',
    },

    'panel': {
      'display': 'block',
      'position': 'relative',
      'transition': 'background-color 200ms ease',
    },

    'header': {
      'display': 'flex',
      'align-items': 'center',
      'justify-content': 'space-between',
      'width': '100%',
      'padding': '8px 12px',
      'cursor': 'pointer',
      'user-select': 'none',
      'background-color': 'transparent',
      'border': 'none',
      'text-align': 'left',
      'text-wrap-mode': 'wrap',
      'font-family': 'inherit',
      'font-size': 'inherit',
      'color': 'inherit',
      'transition': 'background-color 200ms ease',
      'line-height': 'normal',
    },

    'chevron': {
      'display': 'inline-flex',
      'align-items': 'center',
      'justify-content': 'center',
      'transition': 'transform 250ms cubic-bezier(0.2, 0.8, 0.2, 1)',
      'color': _var(Tokens.current.mutedColor),
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
      'line-height': 'normal',
    },

    'body-inner': {'padding': '5px 16px 16px 16px', 'box-sizing': 'border-box'},
  };
}
