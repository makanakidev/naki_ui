import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../models/naki.dart' show ScrollBarConfiguration;
import '../theme/tokens.dart';
import '../utilities/constants.dart';
import '../utilities/extensions.dart';

import 'css.dart';

extension StyleRulesExtension on Iterable<StyleRule> {
  /// Converts a list of style rules into raw css.
  String toCss() {
    final imports = StringBuffer();
    final rules = StringBuffer();
    const indent = kDebugMode || kGenerateMode ? '\n' : ' ';

    for (final rule in this) {
      final css = rule.toCss() + indent;

      if (css.trim().startsWith('@import')) {
        imports.write(css);
      } else {
        rules.write(css);
      }
    }

    return (imports.toString() + rules.toString()).trimRight();
  }
}

/// A component utility for rendering a list of [StyleRule] objects
/// into a `<style>` element.
class StyleRules extends StatelessComponent {
  /// The style rules to render.
  final List<StyleRule> rules;

  /// An optional id for the style element.
  final String? id;

  /// Optional attributes to set on the style element.
  final Map<String, String>? attributes;

  /// Creates a new instance of [StyleRules].
  const StyleRules(this.rules, {super.key, this.id, this.attributes});

  @override
  Component build(BuildContext context) {
    return .element(
      tag: 'style',
      id: id,
      attributes: attributes,
      children: [RawText(rules.toCss())],
    );
  }
}

/// Central registry to ensure style rules are registered
/// exactly once per document tree or component type.
final class NakiStyleRegistry {
  final Set<String> _registeredKeys = {};
  final Set<String> _generatedCss = {};

  /// Global static registry used for compile-time `@css` getters.
  static final NakiStyleRegistry global = NakiStyleRegistry();

  /// Static helper for `@css` getters
  static List<StyleRule> once(String key, List<StyleRule> rules) =>
      global.register(key, rules);

  /// Static helper to dedupe rules.
  static List<StyleRule> dedupe(List<StyleRule> rules) => global._dedupe(rules);

  /// Registers [rules] once per [key] within this registry instance.
  List<StyleRule> register(String key, List<StyleRule> rules) {
    if (_registeredKeys.contains(key)) return const [];
    _registeredKeys.add(key);
    return _dedupe(rules);
  }

  /// Deduplicate css rules and return unique rules
  List<StyleRule> _dedupe(List<StyleRule> rules) {
    final uniqueRules = <StyleRule>[];

    for (final rule in rules) {
      final css = rule.toCss();
      if (_generatedCss.contains(css)) continue;
      _generatedCss.add(css);
      uniqueRules.add(rule);
    }

    return uniqueRules;
  }

  /// Clears the registry.
  void clear() {
    _registeredKeys.clear();
    _generatedCss.clear();
  }
}

/// Style rules for Naki components.
///
/// Add desired rules after the build method of a component using
/// `@css` decorator:
/// ```dart
/// // @css
/// static List<StyleRule> get styles => NakiStyleRegistry.once('Switch',
/// [Rules.nakiSwitchRules]);
/// ```
class Rules {
  /// Adjust appbar position if present
  static final _appbarAdjustment = [
    css('.naki-appbar').styles(raw: {'position': 'fixed'}),

    // push scaffold content down if present
    css(
      '.naki-scaffold-body',
    ).styles(raw: {'margin-top': 'var(${Tokens.current.appbarHeight})'}),
  ];

  static const _fastTransition = '150ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';
  static const _mediumTransition = '320ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';
  static const _slowTransition = '500ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';

  /// Build scrollbar styling rules for a selector.
  static List<StyleRule> buildScrollbarRules(
    String selector,
    ScrollBarConfiguration config,
  ) {
    final thumbColor = config.thumbColor;
    final trackColor = config.trackColor;
    final hoverThumbColor = config.hoverColor;
    final width = config.width;
    final height = config.height;
    final radius = config.radius;

    return [
      css(selector, [
        // base
        css('&').styles(
          raw: {
            'scrollbar-width': 'thin',
            'scrollbar-gutter': 'stable',
            'scrollbar-color': '${thumbColor.value} ${trackColor.value}',
          },
        ),

        // webkit scrollbar
        if (width != null || height != null)
          css(
            '&::-webkit-scrollbar',
          ).styles(raw: {'width': ?width?.toPx, 'height': ?height?.toPx}),

        // webkit scrollbar track
        css(
          '&::-webkit-scrollbar-track',
        ).styles(raw: {'background-color': trackColor.value}),

        // webkit scrollbar thumb
        css('&::-webkit-scrollbar-thumb').styles(
          raw: {
            'background-color': thumbColor.value,
            'border-radius': ?radius?.toPx,
            'border': '2px solid ${trackColor.value}',
          },
        ),

        // webkit scrollbar thumb hover state
        if (hoverThumbColor != null)
          css(
            '&::-webkit-scrollbar-thumb:hover',
          ).styles(raw: {'background-color': hoverThumbColor.value}),
      ]),
    ];
  }

  /// Default foundation rules.
  static List<StyleRule> get nakiFoundationRules => [
    css.media(const MediaQuery.raw('(prefers-reduced-motion: reduce)'), [
      css('*, *::before, *::after').styles(
        raw: {
          'scroll-behavior': 'auto !important',
          'animation-duration': '0.01ms !important',
          'animation-iteration-count': '1 !important',
          'transition-duration': '0.01ms !important',
        },
      ),
    ]),

    // theme switching animation
    css(
      'html.switching-theme *, html.switching-theme *::before, '
      'html.switching-theme *::after',
    ).styles(raw: {'transition': 'all $_slowTransition'}),

    css.supports('(view-transition-name: root)', [
      css('html').styles(raw: {'view-transition-name': 'root'}),

      css('::view-transition-old(root), ::view-transition-new(root)').styles(
        raw: {
          'animation-duration': '500ms',
          'animation-timing-function': 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
          'opacity': '1',
        },
      ),
    ]),

    // apply margin and padding on body element
    css('body').styles(raw: {'margin': '0', 'padding': '0'}),

    // apply border-box sizing on all elements
    css('*').styles(raw: {'box-sizing': 'border-box'}),

    // root typography
    css('html, body').styles(
      raw: {
        'background-color':
            'var(${Tokens.current.backgroundColor}, ${Tokens.current.backgroundColor.value})',
        'color':
            'var(${Tokens.current.baseTextColor}, ${Tokens.current.baseTextColor.value})',
        'font-family':
            'var(${Tokens.current.fontFamily}, ${Tokens.current.fontFamily.value})',
        'font-size':
            'var(${Tokens.current.fontSizeMd}, ${Tokens.current.fontSizeMd.value})',
        'scrollbar-width': 'none',
      },
    ),
  ];

  /// Breakpoint rules
  static final nakiBreakpointRules = [
    // Hide all by default
    css(
      '.br-xs, .br-sm, .br-md, .br-lg, .br-xl',
    ).styles(raw: {'display': 'none !important'}),

    // xs: <= 480px
    css.media(
      const MediaQuery.screen(maxWidth: Unit.pixels(kBreakpointXSmall)),
      [
        css('.br-xs').styles(raw: {'display': 'inherit !important'}),
      ],
    ),

    // sm: 480px - 576px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointXSmall + 0.02),
        maxWidth: Unit.pixels(kBreakpointSmall),
      ),
      [
        css('.br-sm').styles(raw: {'display': 'inherit !important'}),
      ],
    ),

    // md: 576px - 768px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointSmall + 0.02),
        maxWidth: Unit.pixels(kBreakpointMedium),
      ),
      [
        css('.br-md').styles(raw: {'display': 'inherit !important'}),
      ],
    ),

    // lg: 768px - 1024px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointMedium + 0.02),
        maxWidth: Unit.pixels(kBreakpointLarge),
      ),
      [
        css('.br-lg').styles(raw: {'display': 'inherit !important'}),
      ],
    ),

    // xl: 1024px and above
    css.media(
      const MediaQuery.screen(minWidth: Unit.pixels(kBreakpointLarge + 0.02)),
      [
        css('.br-xl').styles(raw: {'display': 'inherit !important'}),
      ],
    ),
  ];

  /// Input field rules
  static final nakiInputRules = css('.naki-input', [
    // wrapper with icon
    css('&[has-icon]').styles(raw: Css.nakiInputStyle['icon-wrapper']),

    // hover state
    css('&[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css('&[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),

    // disabled state
    css('&:disabled').styles(raw: {'cursor': 'not-allowed'}),

    // leading / trailing icon
    css('.naki-icon').styles(
      raw: {
        'height':
            'var(${Tokens.current.inputHeight}, ${Tokens.current.inputHeight.value})',
      },
    ),

    // input
    css('input, input.naki-input').styles(raw: Css.nakiInputStyle['input']),

    // hide stepper if input type is number or tel
    css(
      'input::-webkit-inner-spin-button, input::-webkit-outer-spin-button',
    ).styles(raw: {'margin': '0', 'appearance': 'none'}),

    // placeholder
    css('input::placeholder').styles(raw: Css.nakiPlaceholderStyle),

    // hover state
    css('input[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css('input[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),

    // focus visible
    css('input:focus-visible').styles(raw: {'outline': 'none'}),

    // disabled state
    css('input:disabled').styles(raw: {'cursor': 'not-allowed'}),
  ]);

  /// Textarea field rules
  static final nakiTextareaRules = css('.naki-textarea', [
    // wrapper with icon
    css('&[has-icon]').styles(raw: Css.nakiTextareaStyle['icon-wrapper']),

    // hover state
    css('&[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css('&[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),

    // disabled state
    css('&:disabled').styles(raw: {'cursor': 'not-allowed'}),

    // leading / trailing icon
    css('.naki-icon').styles(
      raw: {
        'height':
            'var(${Tokens.current.inputHeight}, ${Tokens.current.inputHeight.value})',
      },
    ),

    // textarea
    css(
      'textarea, textarea.naki-textarea',
    ).styles(raw: Css.nakiTextareaStyle['input']),

    // placeholder
    css('textarea::placeholder').styles(raw: Css.nakiPlaceholderStyle),

    // hover state
    css('textarea[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css('textarea[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),

    // focus visible
    css('textarea:focus-visible').styles(raw: {'outline': 'none'}),

    // disabled state
    css('textarea:disabled').styles(raw: {'cursor': 'not-allowed'}),
  ]);

  /// Form field rules
  static final nakiFormFieldRules = css(
    '.naki-form-field',
  ).styles(raw: {'display': 'flex', 'flex-direction': 'column'});

  /// Hitbox rules
  static final nakiHitboxRules = css('.naki-control-hitbox').styles(
    raw: {
      'display': 'inline-flex',
      'align-items': 'center',
      'justify-content': 'center',
      'min-width': '42px',
      'min-height': '42px',
      'cursor': 'pointer',
    },
  );

  /// Calendar rules
  static final nakiCalendarRules = [
    css('.naki-calendar', [
      // wrapper
      css('&').styles(raw: Css.nakiCalendarStyle['wrapper']),

      // default trigger
      css(
        '& > .default_trigger',
      ).styles(raw: Css.nakiCalendarStyle['default-trigger']),

      // wrapped trigger
      css('.naki-calendar-trigger', [
        // no-value state
        css('&[novalue]').styles(
          raw: {
            'color':
                'var(${Tokens.current.placeholderColor}, '
                '${Tokens.current.placeholderColor.value})',
          },
        ),

        // disabled state
        css('&[disabled]').styles(raw: Css.nakiDisabledStyle),
      ]),

      // input (hidden)
      css('& > input').styles(raw: Css.nakiCalendarStyle['input']),

      // numeric input stepper
      css('input', [
        css(
          '&::-webkit-inner-spin-button',
        ).styles(raw: {'margin': '0', 'appearance': 'none'}),

        css(
          '&::-webkit-outer-spin-button',
        ).styles(raw: {'margin': '0', 'appearance': 'none'}),

        // hover state
        css('&:hover').styles(raw: {'outline': 'none'}),

        // focus state
        css('&:focus').styles(raw: {'outline': 'none'}),
      ]),

      // modal
      css('.naki-calendar-modal', [
        css('&').styles(raw: Css.nakiCalendarStyle['modal']),

        // action btn
        css('.naki-calendar-action__button').styles(
          raw: {
            'font-weight': '500',
            'font-size': '14px',
            'border-radius': '24px',
            'padding': '8px 12px',
            'height': 'auto',
          },
        ),

        // date picker
        css('.naki-date-picker', [
          css('&').styles(raw: {'width': '100%'}),

          // header button
          css(
            '.naki-calendar-header__button',
          ).styles(raw: {'border-radius': '50%', 'padding': '0'}),

          // header title
          css('.naki-calendar-header__title', [
            css('&').styles(
              raw: {
                'font-size': '16px',
                'font-weight': '500',
                'cursor': 'pointer',
                'user-select': 'none',
                'padding': '0',
                'transition': 'transform 300ms cubic-bezier(0.2, 0.8, 0.2, 1)',
                'color':
                    'var(${Tokens.current.inputTextColor}, '
                    '${Tokens.current.inputTextColor.value})',
              },
            ),

            // place header above year-month popover barrier when open
            css(
              '&[showyear]',
            ).styles(raw: {'position': 'relative', 'z-index': '50'}),

            // rotate chevron icon
            css(
              '&[showyear] .naki-icon',
            ).styles(raw: {'transform': 'rotate(180deg)'}),
          ]),

          // year-month popover
          css('.naki-calendar-ymp', [
            // years dropdown
            css(
              '.naki-calendar-ymp__years',
            ).styles(raw: Css.nakiCalendarStyle['years-dropdown']),

            // months grid
            css('.naki-calendar-ymp__month', [
              css(
                '&',
              ).styles(
                raw: {
                  'margin': '0',
                  'padding': '0',
                  'height': '100%',
                  'width': '50px',
                },
              ),

              // selected state
              css('&[selected]').styles(raw: Css.nakiCalendarStyle['selected']),
            ]),
          ]),

          // calendar body
          css('.naki-calendar-body', [
            // table head
            css('th').styles(
              raw: {
                'padding': 'min(0.3vw, 4px)',
                'text-align': 'center',
                'font-weight': '400',
                'font-size': '13px',
                'border': '5px solid transparent',
              },
            ),

            // table cells
            css('td').styles(
              raw: {'padding': 'min(0.3vw, 4px)', 'text-align': 'center'},
            ),

            // date cell
            css('.naki-calendar-date', [
              css('&').styles(
                raw: {
                  'font-size': '14px',
                  'text-align': 'center',
                  'width': '42px',
                  'height': '42px',
                  'border-radius': '50%',
                  'padding': '0',
                  'margin': '0 auto',
                  'border': '1px solid transparent',
                },
              ),

              // today
              css('&[today]').styles(
                raw: {
                  'border-color':
                      'var(${Tokens.current.secondaryColor}, '
                      '${Tokens.current.secondaryColor.value})',
                },
              ),

              // selected state
              css('&[selected]').styles(raw: Css.nakiCalendarStyle['selected']),

              // disabled state
              css('&[disabled]').styles(raw: Css.nakiCalendarStyle['disabled']),
            ]),
          ]),
        ]),

        // time picker
        css('.naki-time-picker', [
          css('&').styles(raw: {'width': '100%'}),

          // steppers separator
          css('.naki-time-separator', [
            css('&').styles(raw: {'font-size': '16px', 'font-weight': '600'}),
          ]),

          // time stepper
          css('.naki-time-stepper', [
            css('&').styles(
              raw: {
                'width': '65px',
                'border':
                    '1px solid var(${Tokens.current.borderColor}, '
                    '${Tokens.current.borderColor.value})',
                'border-radius': '4px',
              },
            ),

            // input
            css('& > input').styles(
              raw: {
                'width': '100%',
                'height': '50px',
                'font-weight': '600',
                'font-size': '18px',
                'text-align': 'center',
                'padding': '0',
                'margin': '0',
                'background-color': 'transparent',
                'border-left': 'unset',
                'border-right': 'unset',
                'border-top':
                    '1px solid var(${Tokens.current.borderColor}, '
                    '${Tokens.current.borderColor.value})',
                'border-bottom':
                    '1px solid var(${Tokens.current.borderColor}, '
                    '${Tokens.current.borderColor.value})',
              },
            ),

            // button
            css('.naki-time-stepper__button').styles(
              raw: {
                'height': '30px',
                'width': '100%',
                'border': 'none',
                'padding': '0',
                'background-color': 'transparent',
                'cursor': 'pointer',
                'color':
                    'var(${Tokens.current.borderColor}, '
                    '${Tokens.current.borderColor.value})',
              },
            ),
          ]),
        ]),
      ]),
    ]),

    // prevent background body scrolling when calendar is open
    // css(':root:has(.naki-calendar-modal)', [
    //   css('&').styles(raw: Css.nakiBackgroundLockStyle),
    //   //..._appbarAdjustment,
    // ]),
  ];

  /// Label rules
  static final nakiLabelRules = css(
    '.naki-label',
  ).styles(raw: Css.nakiLabelTextStyle.props);

  /// Segmented input field rules
  static final nakiSegmentedInputRules = [
    css('naki-segmentedfield').styles(raw: {'display': 'contents'}),

    css('.naki-segmented-input', [
      // wrapper
      css('&').styles(raw: Css.nakiSegmentedInputStyle['wrapper']),

      // segment box
      css('.input-segment', [
        // input fields
        css('&').styles(raw: Css.nakiSegmentedInputStyle['segment']),

        // hide stepper
        css(
          '&::-webkit-inner-spin-button',
        ).styles(raw: {'margin': '0', 'appearance': 'none'}),

        css(
          '&::-webkit-outer-spin-button',
        ).styles(raw: {'margin': '0', 'appearance': 'none'}),

        // placeholder
        css('&::placeholder').styles(raw: Css.nakiPlaceholderStyle),

        // underline shape
        css(
          '&.shape-underline',
        ).styles(raw: Css.nakiSegmentedInputStyle['underline']),

        // circle shape
        css('&.shape-circle').styles(raw: {'border-radius': '50%'}),

        // hover state
        css('&[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

        // focus state
        css('&[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),
        css('&:focus-visible').styles(raw: {'outline': 'none'}),

        // disabled state
        css(
          '&:disabled',
        ).styles(raw: {'opacity': '30%', 'cursor': 'not-allowed'}),
      ]),
    ]),
  ];

  /// Helper text rules
  static final nakiHelperRules = css(
    '.naki-helper',
  ).styles(raw: Css.nakiHelperTextStyle.props);

  /// Checkbox rules
  static final nakiCheckboxRules = css('naki-checkbox', [
    // wrapper
    css('&').styles(raw: Css.nakiCheckboxStyle['wrapper']),

    // input element
    css('.naki-checkbox', [
      css('&').styles(raw: Css.nakiCheckboxStyle['input']),

      css('&[fcs]:focus-visible').styles(raw: Css.nakiFocusBorderStyle),

      // tick (default)
      css('&::before').styles(raw: Css.nakiCheckboxStyle['before']),

      // tick (when checked)
      css(
        '&:checked::before',
      ).styles(raw: Css.nakiCheckboxStyle['checked:before']),

      // disabled
      css('&:disabled').styles(raw: Css.nakiCheckboxStyle['disabled']),
    ]),
  ]);

  /// Switch rules
  static final nakiSwitchRules = css('naki-switch', [
    // wrapper
    css('&').styles(raw: Css.nakiSwitchStyle['wrapper']),

    // input element
    css('.naki-switch', [
      css('&').styles(raw: Css.nakiSwitchStyle['input']),

      css('&[fcs]:focus-visible').styles(raw: Css.nakiFocusBorderStyle),

      // track (default)
      css('&:not(:checked)').styles(raw: Css.nakiSwitchStyle['not-checked']),

      // thumb (default)
      css('&::before').styles(raw: Css.nakiSwitchStyle['before']),

      // track (when checked)
      css('&:checked').styles(raw: Css.nakiSwitchStyle['checked']),

      // track (when disabled)
      css('&:disabled').styles(raw: Css.nakiSwitchStyle['disabled']),

      // thumb (when disabled)
      css(
        '&:disabled::before',
      ).styles(raw: Css.nakiSwitchStyle['disabled:before']),
    ]),
  ]);

  /// Slider rules
  static final nakiSliderRules = css('naki-slider', [
    // wrapper
    css('&').styles(raw: Css.nakiSliderStyle['wrapper']),

    // tooltip
    css('.slider-tooltip').styles(raw: Css.nakiSliderStyle['tooltip']),

    // input element
    css('.naki-slider', [
      css('&').styles(raw: Css.nakiSliderStyle['input']),

      // track (webkit)
      css(
        '&::-webkit-slider-runnable-track',
      ).styles(raw: Css.nakiSliderStyle['webkit-track']),

      // thumb (webkit)
      css(
        '&::-webkit-slider-thumb',
      ).styles(raw: Css.nakiSliderStyle['webkit-thumb']),

      // track (firefox)
      css('&::-moz-range-track').styles(raw: Css.nakiSliderStyle['moz-track']),

      // thumb (firefox)
      css('&::-moz-range-thumb').styles(raw: Css.nakiSliderStyle['moz-thumb']),

      // disabled
      css('&:disabled').styles(raw: Css.nakiSliderStyle['disabled']),
    ]),
  ]);

  /// AppBar rules
  static final nakiAppBarRules = css('.naki-appbar', [
    // wrapper
    css('&').styles(raw: Css.nakiAppBarStyle['wrapper']),

    // text title
    css('.naki-appbar-title').styles(raw: Css.nakiAppBarStyle['title']),

    // actions
    css('.naki-appbar-actions').styles(raw: Css.nakiAppBarStyle['actions']),
  ]);

  /// BottomNavBar rules
  static final nakiBottomNavBarRules = css('.naki-bottom-navbar', [
    // wrapper
    css('&').styles(raw: Css.nakiBottomNavBarStyle['wrapper']),

    // fixed navbar type
    css('&.navbar__fixed', [
      css('&').styles(raw: Css.nakiBottomNavBarStyle['fixed']),

      css(
        '& > .naki-navbar-tile',
      ).styles(raw: Css.nakiBottomNavBarStyle['fixed-tile']),
    ]),

    // floating navbar type
    css(
      '&.navbar__floating',
    ).styles(raw: Css.nakiBottomNavBarStyle['floating']),

    // frosted glass navbar type
    css('&.navbar__frosted-glass', [
      css('&').styles(raw: Css.nakiBottomNavBarStyle['frosted-glass']),

      css(
        '& > .naki-navbar-tile',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-tile']),

      // css(
      //   '& > .naki-navbar-tile:not([aria-current="page"]):hover',
      // ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-hover-tile']),
      css(
        '& > .naki-navbar-tile[aria-current="page"]',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-selected-tile']),
    ]),

    // spread landscape layout
    css(
      '&.navbar__spread-layout',
    ).styles(raw: Css.nakiBottomNavBarStyle['spread-layout']),

    // centered landscape layout
    css(
      '&.navbar__centered-layout',
    ).styles(raw: Css.nakiBottomNavBarStyle['centered-layout']),

    // linear landscape layout
    css(
      '&.navbar__linear-layout',
    ).styles(raw: Css.nakiBottomNavBarStyle['linear-layout']),

    // tile
    css('.naki-navbar-tile').styles(raw: Css.nakiBottomNavBarStyle['tile']),

    // tile label
    css('.naki-navbar-label').styles(raw: Css.nakiBottomNavBarStyle['label']),
  ]);

  /// Button rules
  static final nakiButtonRules = css('.naki-button', [
    // button
    css('&').styles(
      raw: Css.nakiButtonStyle.combine({'transition': 'all $_fastTransition'}),
    ),

    // disabled state
    css('&:disabled').styles(
      raw: Css.nakiDisabledStyle.combine({
        'background-color': 'var(${Tokens.current.disabledBgColor})',
      }),
    ),

    // hover state
    css(
      '&[hvr]:hover',
    ).styles(
      raw: {'background-color': 'var(${Tokens.current.buttonHoverBgColor})'},
    ),

    // tap / pressed state
    css('&:not(:disabled):active').styles(raw: {'transform': 'scale(0.97)'}),
  ]);

  /// Icon rules
  static final nakiIconRules = css('.naki-icon').styles(raw: Css.nakiIconStyle);

  /// Fragment rules
  static final nakiFragmentRules = css(
    '.naki-fragment',
  ).styles(raw: {'display': 'contents'});

  /// Scaffold rules
  static final nakiScaffoldRules = css('.naki-scaffold', [
    // wrapper
    css('&').styles(raw: Css.nakiScaffoldStyle['wrapper']),

    // app bar
    css('.naki-scaffold-appbar').styles(raw: Css.nakiScaffoldStyle['appbar']),

    // layout
    css('.naki-scaffold-layout').styles(raw: Css.nakiScaffoldStyle['layout']),

    // sidebar
    css('.naki-scaffold-sidebar').styles(raw: Css.nakiScaffoldStyle['sidebar']),

    // body
    css('.naki-scaffold-body').styles(raw: Css.nakiScaffoldStyle['body']),

    // bottom navbar
    css('.naki-scaffold-bottom-navbar', [
      css('&').styles(raw: Css.nakiScaffoldStyle['bottom-navbar']),

      // types
      css(
        '&:is(.navbar__fixed, .navbar__floating, .navbar__frosted-glass)',
      ).styles(raw: {'position': 'fixed'}),

      // fixed type
      css('.navbar__fixed').styles(raw: {'bottom': '0', 'left': '0'}),

      // floating type
      css(
        '.navbar__floating',
      ).styles(
        raw: {'bottom': '16px', 'left': '50%', 'transform': 'translateX(-50%)'},
      ),

      // frosted glass type
      css(
        '.navbar__frosted-glass',
      ).styles(
        raw: {'bottom': '16px', 'left': '50%', 'transform': 'translateX(-50%)'},
      ),
    ]),

    // floating action button
    css('.naki-scaffold-fab').styles(raw: Css.nakiScaffoldStyle['fab']),
  ]);

  /// Stack rules
  static final nakiStackRules = css(
    '.naki-stack',
  ).styles(raw: Css.nakiStackStyle);

  /// Align rules
  static final nakiAlignRules = css(
    '.naki-align',
  ).styles(raw: {'width': '100%', 'height': '100%'});

  /// Cliprect rules
  static final nakiClipRectRules = css(
    '.naki-cliprect',
  ).styles(raw: {'display': 'block', 'overflow': 'hidden'});

  /// Container rules
  static final nakiContainerRules = css(
    '.naki-container',
  ).styles(raw: Css.nakiContainerStyle);

  /// Footer rules
  static final nakiFooterRules = css('.naki-footer').styles(
    raw: {
      'width': '100%',
      'flex-shrink': '0',
      'height': 'auto',
      'min-height': 'auto',
      'margin-top': 'auto',
    },
  );

  /// Card rules
  static final nakiCardRules = css('.naki-card', [
    css('&').styles(raw: Css.nakiCardStyle['root']),

    // elevated card
    css('&.naki-card--elevated').styles(raw: Css.nakiCardStyle['elevated']),

    // outlined card
    css('&.naki-card--outlined').styles(raw: Css.nakiCardStyle['outlined']),

    // filled card
    css('&.naki-card--filled').styles(raw: Css.nakiCardStyle['filled']),

    // interactive card
    css('&.naki-card--interactive', [
      css('&').styles(raw: {'cursor': 'pointer', 'user-select': 'none'}),

      // hover state
      css('&[hvr]:hover').styles(
        raw: {
          'box-shadow':
              '0 4px 6px -1px var(${Tokens.current.mediumShadowColor}, '
              '${Tokens.current.mediumShadowColor.value}), 0 2px 4px -2px '
              'var(${Tokens.current.mediumShadowColor}, '
              '${Tokens.current.mediumShadowColor.value})',
        },
      ),
    ]),
  ]);

  /// ExpansionPanelList and ExpansionTile rules
  static final nakiExpansionPanelRules = [
    css(
      '.naki-expansion-panel-list, .naki-expansion-tile',
    ).styles(raw: Css.nakiExpansionPanelStyle['list']),

    css('.naki-expansion-panel', [
      css('&').styles(raw: Css.nakiExpansionPanelStyle['panel']),

      css('&:last-child').styles(raw: {'border-bottom': 'none'}),
    ]),

    css('.naki-expansion-panel__header', [
      css('&').styles(raw: Css.nakiExpansionPanelStyle['header']),

      css(
        '&:not(:disabled):hover',
      ).styles(raw: {'color': 'var(${Tokens.current.hoverColor})'}),

      css('&:disabled').styles(raw: {'background-color': 'transparent'}),
    ]),

    css('.naki-expansion-panel__chevron', [
      css('&').styles(raw: Css.nakiExpansionPanelStyle['chevron']),

      css('&.is-expanded').styles(raw: {'transform': 'rotate(180deg)'}),
    ]),

    css('.naki-expansion-panel__body-wrapper', [
      css('&').styles(raw: Css.nakiExpansionPanelStyle['body-wrapper']),

      css('&[aria-expanded="true"]').styles(raw: {'grid-template-rows': '1fr'}),
    ]),

    css(
      '.naki-expansion-panel__body-content',
    ).styles(raw: Css.nakiExpansionPanelStyle['body-content']),

    css(
      '.naki-expansion-panel__body-inner',
    ).styles(raw: Css.nakiExpansionPanelStyle['body-inner']),
  ];

  /// Positioned rules
  static final nakiPositionedRules = css(
    '.naki-positioned',
  ).styles(raw: {'display': 'inline-flex', 'position': 'absolute'});

  /// Wrap rules
  static final nakiWrapRules = css(
    '.naki-wrap',
  ).styles(raw: {'display': 'flex', 'flex-wrap': 'wrap'});

  /// ClipOval rules
  static final nakiClipOvalRules =
      css(
        '.naki-clip-oval',
      ).styles(
        raw: {'display': 'block', 'border-radius': '50%', 'overflow': 'clip'},
      );

  /// Safearea rules
  static final nakiSafeareRules = css('naki-safearea').styles(
    raw: {
      'box-sizing': 'border-box',
      'display': 'block',
      'margin': '0 !important',
      'padding-top': 'env(safe-area-inset-top, 0px)',
      'padding-left': 'env(safe-area-inset-left, 0px)',
      'padding-right': 'env(safe-area-inset-right, 0px)',
      'padding-bottom': 'env(safe-area-inset-bottom, 0px)',
    },
  );

  /// Radio button rules
  static final nakiRadioBtnRules = css('naki-radiobtn', [
    // wrapper
    css('&').styles(raw: Css.nakiRadioBtnStyle['wrapper']),

    // input element
    css('.naki-radio-btn', [
      css('&').styles(raw: Css.nakiRadioBtnStyle['input']),

      // dot indicator (default)
      css('&::before').styles(raw: Css.nakiRadioBtnStyle['before']),

      // radio (when checked)
      css('&:checked').styles(raw: Css.nakiRadioBtnStyle['checked']),

      // dot indicator (when checked)
      css(
        '&:checked::before',
      ).styles(raw: Css.nakiRadioBtnStyle['checked:before']),

      // radio (when disabled)
      css('&:disabled').styles(raw: Css.nakiRadioBtnStyle['disabled']),
    ]),
  ]);

  /// Dropdown rules
  static final nakiDropdownRules = [
    css('naki-dropdown', [
      // wrapper
      css('&').styles(raw: Css.nakiDropdownStyle['wrapper']),

      // no search result
      css(
        '.naki-dropdown-no-result',
      ).styles(raw: Css.nakiDropdownStyle['no-search-result']),

      // search box
      css('naki-textfield').styles(raw: Css.nakiDropdownStyle['search-box']),

      // default trigger
      css('.default_trigger', [
        css('&').styles(raw: Css.nakiDropdownStyle['trigger']),

        // arrow down (dropdown closed)
        css('&::after').styles(raw: Css.nakiDropdownStyle['inner:after']),

        // arrow up (dropdown open)
        css(
          '&[aria-expanded="true"]::after',
        ).styles(raw: Css.nakiDropdownStyle['inner.is-open:after']),

        // hover state
        css('&[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

        // focus state
        css('&[fcs]:focus').styles(raw: Css.nakiFocusBorderStyle),
      ]),

      // wrapped trigger
      css('.naki-dropdown-trigger', [
        // color when no selection is made
        css('&:not([data-selected])').styles(
          raw: {
            'color':
                'var(${Tokens.current.placeholderColor}, '
                '${Tokens.current.placeholderColor.value})',
          },
        ),

        // disabled state
        css('&[aria-disabled="true"]').styles(raw: Css.nakiDisabledStyle),
      ]),

      // options menu (dropdown is closed)
      css(
        '.naki-dropdown-menu',
      ).styles(raw: Css.nakiDropdownStyle['options-wrapper']),

      // options menu (dropdown is open)
      css(
        '&[open] .naki-dropdown-menu',
      ).styles(raw: Css.nakiDropdownStyle['open:options-wrapper']),

      // upward: options menu (positioned above the trigger)
      css(
        '&[open] .naki-dropdown-menu.upward',
      ).styles(raw: Css.nakiDropdownStyle['upward:options-wrapper']),

      // dropdown menu without search field
      css(
        '.naki-dropdown-menu:not([data-searchable])',
      ).styles(raw: {'overscroll-behavior': 'none', 'overflow-y': 'auto'}),

      // dropdown menu with search field
      css('.naki-dropdown-menu[data-searchable]').styles(
        raw: {
          'overscroll-behavior': 'none',
          'display': 'flex',
          'flex-direction': 'column',
          'overflow-y': 'auto',
        },
      ),

      // option
      css('.naki-dropdown-option', [
        // default state
        css('&').styles(raw: Css.nakiDropdownStyle['option']),

        // selected state
        css(
          '&[aria-selected="true"]',
        ).styles(raw: Css.nakiDropdownStyle['option:selected']),

        // placeholder label in options
        css(
          '&.options-placeholder',
        ).styles(raw: Css.nakiDropdownStyle['placeholder.option']),

        // section label in options
        css(
          '&.options-section',
        ).styles(raw: Css.nakiDropdownStyle['section.option']),
      ]),
    ]),

    // prevent background body scrolling when dropdown is open
    // css(':root:has(naki-dropdown[open])', [
    //   css('&').styles(raw: Css.nakiBackgroundLockStyle),
    //   //..._appbarAdjustment,
    // ]),
  ];

  /// Spinner rules
  static final nakiSpinnerRules = [
    // spin animation
    css.keyframes('nakiSpin', {
      'to': const Styles(transform: Transform.rotate(.deg(360))),
    }),

    // blade fade animation
    css.keyframes('nakiBladeFade', {
      'from': const Styles(opacity: 1),
      'to': const Styles(opacity: 0.15),
    }),

    css('.naki-spinner', [
      // default spinner
      css('&').styles(raw: Css.nakiSpinnerStyle['default']),

      // ios-style spinner
      css('&.ios').styles(raw: Css.nakiSpinnerStyle['ios']),

      // ios-style spinner blades
      for (int i = 1; i <= 12; i++)
        css('.spinner-blade:nth-child($i)').styles(
          raw: {
            ...Css.nakiSpinnerStyle['blade']!,
            'transform': 'rotate(calc(($i - 1) * 30deg))',
            'animation': 'nakiBladeFade 1.2s linear infinite',
            'animation-delay': 'calc((($i - 1) * 0.1s) - 1.2s)',
          },
        ),

      // glassmorphism style
      css('&.morphism').styles(raw: Css.nakiSpinnerStyle['glass']),
    ]),
  ];

  /// AutoCompleteField rules
  static final nakiAutoCompleteFieldRules = [
    css('naki-autocomplete', [
      // wrapper
      css('&').styles(raw: {'position': 'relative'}),

      // options menu
      css('.naki-autocomplete-menu', [
        css('&').styles(
          raw: {
            ...?Css.nakiDropdownStyle['options-wrapper'],
            ...?Css.nakiDropdownStyle['open:options-wrapper'],
          },
        ),

        // options
        css('& > *').styles(raw: Css.nakiDropdownStyle['option']),
      ]),
    ]),

    // prevent background body scrolling when menu is open
    // css(':root:has(.naki-autocomplete-menu)', [
    //   css('&').styles(raw: Css.nakiBackgroundLockStyle),
    //   // ..._appbarAdjustment,
    // ]),
  ];

  /// Form rules
  static final nakiFormRules = css('.naki-form').styles(raw: Css.nakiFormStyle);

  /// Text rules
  static final nakiTextRules = css('.naki-text', [
    css('&').styles(raw: {'display': 'block', 'box-sizing': 'border-box'}),

    // selection (standard)
    css('&::selection').styles(
      raw: {
        'background-color': 'var(${Tokens.current.selectedTextBgColor})',
        'color': 'var(${Tokens.current.selectedTextColor})',
      },
    ),

    // selection (firefox)
    css('&::-moz-selection').styles(
      raw: {
        'background-color': 'var(${Tokens.current.selectedTextBgColor})',
        'color': 'var(${Tokens.current.selectedTextColor})',
      },
    ),
  ]);

  /// SingleChildScrollView rules
  static final nakiSingleChildScrollViewRules = css(
    '.naki-singlechild-scrollview',
  ).styles(raw: Css.nakiSingleChildScrollViewStyle);

  /// ListView rules
  static final nakiListViewRules = css('.naki-listview', [
    css('&').styles(raw: Css.nakiListViewStyle),

    css('& > *').styles(
      raw: {
        'height': 'var(--naki-listview-item-extent-h, auto)',
        'width': 'var(--naki-listview-item-extent-w, auto)',
        'flex-shrink': '0',
      },
    ),
  ]);

  /// GridView rules
  static final nakiGridViewRules = css('.naki-gridview', [
    css('&').styles(raw: Css.nakiGridViewStyle),

    css('& > *').styles(raw: {'height': '100%', 'width': '100%'}),
  ]);

  /// PageView rules
  static final nakiPageViewRules = css('.naki-pageview', [
    // container scroll snap configuration
    css('&').styles(raw: Css.nakiPageViewStyle),

    // page item snap alignment and extent
    css('& > *').styles(
      raw: {
        'scroll-snap-align': 'start',
        'flex-shrink': '0',
        'width': '100%',
        'height': '100%',
      },
    ),
  ]);

  /// CarouselView rules
  static final nakiCarouselRules = css('.naki-carouselview', [
    // carousel container flex scroll layout
    css('&').styles(raw: Css.nakiCarouselStyle),

    // carousel item scroll snapping and rounded card borders
    css(
      '.naki-carousel-item',
    ).styles(
      raw: {
        'scroll-snap-align': 'start',
        'flex-shrink': '0',
        'overflow': 'hidden',
      },
    ),
  ]);

  /// Table rules
  static final nakiTableRules = css('naki-table', [
    // wrapper
    css('&').styles(raw: Css.nakiTableStyle['wrapper']),

    // table base structure
    css('table').styles(raw: Css.nakiTableStyle['main']),

    // empty state content
    css('.naki-table__empty').styles(raw: Css.nakiTableStyle['empty']),

    css(
      'td#no-data',
    ).styles(
      raw: {
        'width': '100%',
        'text-align': 'center',
        'vertical-align': 'middle',
      },
    ),

    // header
    css('th').styles(
      raw: {
        'background-color': 'var(${Tokens.current.tableHeaderBg})',
        'padding': '12px 16px',
        'font-weight': '600',
        'border-bottom':
            '1px solid var(${Tokens.current.tableHeaderBorderColor})',
      },
    ),

    // row cell
    css('td').styles(raw: {'padding': '12px 16px'}),

    // row hover state
    css(
      'tbody tr:hover',
    ).styles(
      raw: {'background-color': 'var(${Tokens.current.tableRowHoverBg})'},
    ),
  ]);

  /// Aspect ratio rules
  static final nakiAspectRatioRules = css(
    '.naki-aspectratio',
  ).styles(raw: {'display': 'block', 'overflow': 'hidden'});

  /// Flexible rules
  static final nakiFlexibleRules = [
    css(
      '.naki-flexible, .naki-expanded',
    ).styles(raw: {'min-height': '0', 'min-width': '0', 'display': 'block'}),

    css('.naki-expanded > *').styles(raw: {'width': '100%', 'height': '100%'}),
  ];

  /// Hide rules
  static final nakiHide = css('.naki-hide').styles(raw: {'display': 'none'});

  /// StaggeredView rules
  static final nakiStaggeredRules = css('.naki-staggeredview', [
    // wrapper
    css('&').styles(raw: Css.nakiStaggeredStyle),

    // item
    css('.naki-staggered-item').styles(
      raw: {
        'break-inside': 'avoid',
        'page-break-inside': 'avoid',
        '-webkit-column-break-inside': 'avoid',
      },
    ),
  ]);

  /// Snackbar rules
  static final nakiSnackbarRules = css('.naki-snackbar', [
    // wrapper
    css('&').styles(raw: Css.nakiSnackbarStyle),

    // top position
    css('&.sb-top').styles(
      raw: {
        'top': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'left': '50%',
        'transform': 'translateX(-50%)',
      },
    ),

    // bottom position
    css('&.sb-bottom').styles(
      raw: {
        'bottom': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'left': '50%',
        'transform': 'translateX(-50%)',
      },
    ),

    // top-left position
    css(
      '&.sb-top-left',
    ).styles(
      raw: {
        'top': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'left': '20px',
      },
    ),

    // top-right position
    css(
      '&.sb-top-right',
    ).styles(
      raw: {
        'top': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'right': '20px',
      },
    ),

    // bottom-left position
    css(
      '&.sb-bottom-left',
    ).styles(
      raw: {
        'bottom': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'left': '20px',
      },
    ),

    // bottom-right position
    css(
      '&.sb-bottom-right',
    ).styles(
      raw: {
        'bottom': 'var(${Tokens.current.snackbarOffset}, 10px)',
        'right': '20px',
      },
    ),
  ]);

  /// Banner rules
  static final nakiBannerRules = css('.naki-banner', [
    // wrapper
    css('&').styles(raw: Css.nakiBannerStyle),

    // content area
    css('.banner-content').styles(
      raw: {
        'flex': '1',
        'display': 'flex',
        'flex-direction': 'column',
        'height': 'auto',
        'gap': '4px',
        'text-wrap': 'balance',
      },
    ),

    // actions area
    css('.banner-actions').styles(raw: {'margin-top': '10px', 'gap': '10px'}),

    // info banner
    css('&.banner-info').styles(
      raw: {
        'background-color':
            'var(${Tokens.current.infoWeakColor}, '
            '${Tokens.current.infoWeakColor.value})',
        'border-color':
            'var(${Tokens.current.infoColor}, '
            '${Tokens.current.infoColor.value})',
      },
    ),

    // success banner
    css('&.banner-success').styles(
      raw: {
        'background-color':
            'var(${Tokens.current.successWeakColor}, '
            '${Tokens.current.successWeakColor.value})',
        'border-color':
            'var(${Tokens.current.successColor}, '
            '${Tokens.current.successColor.value})',
      },
    ),

    // warning banner
    css('&.banner-warning').styles(
      raw: {
        'background-color':
            'var(${Tokens.current.warningWeakColor}, '
            '${Tokens.current.warningWeakColor.value})',
        'border-color':
            'var(${Tokens.current.warningColor}, '
            '${Tokens.current.warningColor.value})',
      },
    ),

    // error banner
    css('&.banner-error').styles(
      raw: {
        'background-color':
            'var(${Tokens.current.errorWeakColor}, '
            '${Tokens.current.errorWeakColor.value})',
        'border-color':
            'var(${Tokens.current.errorColor}, '
            '${Tokens.current.errorColor.value})',
      },
    ),
  ]);

  /// Tooltip rules
  static final nakiTooltipRules = css('.naki-tooltip', [
    // wrapper
    css('&').styles(raw: Css.nakiTooltipStyle['wrapper']),

    // tooltip content
    css('.naki-tooltip-content').styles(raw: Css.nakiTooltipStyle['content']),

    // arrow spike base style
    css(
      '.naki-tooltip-content::after',
    ).styles(
      raw: {'content': '""', 'position': 'absolute', 'border-style': 'solid'},
    ),

    // show tooltip on target hover or focus
    css(
      '.naki-tooltip-target:is(:hover, :focus-within) ~ .naki-tooltip-content',
    ).styles(raw: {'opacity': '1', 'visibility': 'visible'}),

    // Escape-dismissed tooltips remain hidden until pointer leave or refocus.
    css(
      '&[dismissed] .naki-tooltip-content',
    ).styles(
      raw: {'opacity': '0 !important', 'visibility': 'hidden !important'},
    ),

    // top positioned tooltip
    css('.tooltip-top').styles(
      raw: {
        'bottom': '100%',
        'left': '50%',
        'transform': 'translateX(-50%) translateY(-8px)',
      },
    ),

    // top tooltip arrow
    css('.tooltip-top::after').styles(
      raw: {
        'top': '100%',
        'left': '50%',
        'transform': 'translateX(-50%)',
        'border-width': '6px 6px 0 6px',
        'border-color':
            'var(${Tokens.current.tooltipBgColor}, '
            '${Tokens.current.tooltipBgColor.value})'
            'transparent transparent transparent',
      },
    ),

    // bottom positioned tooltip
    css(
      '.tooltip-bottom',
    ).styles(
      raw: {
        'top': '100%',
        'left': '50%',
        'transform': 'translateX(-50%) translateY(8px)',
      },
    ),

    // bottom tooltip arrow
    css('.tooltip-bottom::after').styles(
      raw: {
        'bottom': '100%',
        'left': '50%',
        'transform': 'translateX(-50%)',
        'border-width': '0 6px 6px 6px',
        'border-color':
            'transparent transparent var(${Tokens.current.tooltipBgColor}, '
            '${Tokens.current.tooltipBgColor.value}) transparent',
      },
    ),

    // left positioned tooltip
    css('.tooltip-left').styles(
      raw: {
        'right': '100%',
        'top': '50%',
        'transform': 'translateY(-50%) translateX(-8px)',
      },
    ),

    // left tooltip arrow
    css('.tooltip-left::after').styles(
      raw: {
        'left': '100%',
        'top': '50%',
        'transform': 'translateY(-50%)',
        'border-width': '6px 0 6px 6px',
        'border-color':
            'transparent transparent transparent '
            'var(${Tokens.current.tooltipBgColor}, '
            '${Tokens.current.tooltipBgColor.value})',
      },
    ),

    // right positioned tooltip
    css(
      '.tooltip-right',
    ).styles(
      raw: {
        'left': '100%',
        'top': '50%',
        'transform': 'translateY(-50%) translateX(8px)',
      },
    ),

    // right tooltip arrow
    css('.tooltip-right::after').styles(
      raw: {
        'right': '100%',
        'top': '50%',
        'transform': 'translateY(-50%)',
        'border-width': '6px 6px 6px 0',
        'border-color':
            'transparent var(${Tokens.current.tooltipBgColor}, '
            '${Tokens.current.tooltipBgColor.value}) '
            'transparent transparent',
      },
    ),
  ]);

  /// Popover rules
  static final nakiPopoverRules = [
    css('.naki-popover', [
      // wrapper
      css('&').styles(raw: Css.nakiPopoverStyle['wrapper']),

      // barrier (closes popover when tapped)
      css('.naki-popover-barrier').styles(raw: Css.nakiPopoverStyle['barrier']),

      // popover content
      css('.naki-popover-content').styles(raw: Css.nakiPopoverStyle['popup']),

      // show popover content when trigger can be focused or hovered
      css(
        '.naki-popover-trigger[canfocus]:is(:focus-within, :hover) ~ '
        '.naki-popover-content',
      ).styles(raw: Css.nakiPopoverStyle['show']),

      // show popover content when opened by an action
      css(
        '&[aria-expanded="true"] .naki-popover-content',
      ).styles(raw: Css.nakiPopoverStyle['show']),

      // top positioned popover (default state)
      css('.popover-top').styles(
        raw: {
          'bottom': '100%',
          'left': '50%',
          'transform': 'translateX(-50%) translateY(-8px) scale(0.95)',
          'transform-origin': 'bottom center',
        },
      ),

      // scale top popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-top, .popover-top:hover, '
        '.popover-top:focus-within',
      ).styles(
        raw: {'transform': 'translateX(-50%) translateY(-8px) scale(1)'},
      ),

      // bottom positioned popover (default state)
      css('.popover-bottom', [
        css('&').styles(
          raw: {
            'top': '100%',
            'left': '50%',
            'transform': 'translateX(-50%) translateY(8px) scale(0.95)',
            'transform-origin': 'top center',
          },
        ),
      ]),

      // scale bottom popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-bottom, .popover-bottom:hover, '
        '.popover-bottom:focus-within',
      ).styles(raw: {'transform': 'translateX(-50%) translateY(8px) scale(1)'}),

      // left positioned popover (default state)
      css('.popover-left', [
        css('&').styles(
          raw: {
            'right': '100%',
            'top': '50%',
            'transform': 'translateY(-50%) translateX(-8px) scale(0.95)',
            'transform-origin': 'right center',
          },
        ),
      ]),

      // scale left popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-left, .popover-left:hover, '
        '.popover-left:focus-within',
      ).styles(
        raw: {'transform': 'translateY(-50%) translateX(-8px) scale(1)'},
      ),

      // right positioned popover
      css('.popover-right', [
        css('&').styles(
          raw: {
            'left': '100%',
            'top': '50%',
            'transform': 'translateY(-50%) translateX(8px) scale(0.95)',
            'transform-origin': 'left center',
          },
        ),
      ]),

      // scale right popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-right, '
        '.popover-right:hover, '
        '.popover-right:focus-within',
      ).styles(raw: {'transform': 'translateY(-50%) translateX(8px) scale(1)'}),

      // top-left positioned popover (default state)
      css('.popover-top-left', [
        css('&').styles(
          raw: {
            'bottom': '100%',
            'left': '0',
            'transform': 'translateY(-8px) scale(0.95)',
            'transform-origin': 'bottom left',
          },
        ),
      ]),

      // scale top-left popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-top-left, '
        '.popover-top-left:hover, '
        '.popover-top-left:focus-within',
      ).styles(raw: {'transform': 'translateY(-8px) scale(1)'}),

      // top-right positioned popover (default state)
      css('.popover-top-right', [
        css('&').styles(
          raw: {
            'bottom': '100%',
            'right': '0',
            'transform': 'translateY(-8px) scale(0.95)',
            'transform-origin': 'bottom right',
          },
        ),
      ]),

      // scale top-right popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-top-right, '
        '.popover-top-right:hover, '
        '.popover-top-right:focus-within',
      ).styles(raw: {'transform': 'translateY(-8px) scale(1)'}),

      // bottom-left positioned popover (default state)
      css('.popover-bottom-left', [
        css('&').styles(
          raw: {
            'top': '100%',
            'left': '0',
            'transform': 'translateY(8px) scale(0.95)',
            'transform-origin': 'top left',
          },
        ),
      ]),

      // scale bottom-left popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-bottom-left, '
        '.popover-bottom-left:hover, '
        '.popover-bottom-left:focus-within',
      ).styles(raw: {'transform': 'translateY(8px) scale(1)'}),

      // bottom-right positioned popover (default state)
      css('.popover-bottom-right', [
        css('&').styles(
          raw: {
            'top': '100%',
            'right': '0',
            'transform': 'translateY(8px) scale(0.95)',
            'transform-origin': 'top right',
          },
        ),
      ]),

      // scale bottom-right popover when visible and hovered or focused
      css(
        '&[aria-expanded="true"] .popover-bottom-right, '
        '.popover-bottom-right:hover, '
        '.popover-bottom-right:focus-within',
      ).styles(raw: {'transform': 'translateY(8px) scale(1)'}),
    ]),

    // prevent background body scrolling when popover is open
    // css(
    //   ':is(:root:has(.naki-popover[aria-expanded="true"]), '
    //   ':root:has(.naki-popover > '
    //   '.naki-popover-trigger[canfocus]:focus-within))',
    //   [
    //     // ._appbarAdjustment
    //     css('&').styles(raw: Css.nakiBackgroundLockStyle),
    //   ],
    // ),
  ];

  /// Dialog rules
  static final nakiDialogRules = [
    // fade in animation for backdrop
    css.keyframes('nakiDialogFadeIn', {
      'from': const Styles(raw: {'opacity': '0'}),
      'to': const Styles(raw: {'opacity': '1'}),
    }),

    // pop in ease-in animation for dialog card
    css.keyframes('nakiDialogPopIn', {
      'from': const Styles(
        raw: {'opacity': '0', 'transform': 'scale(0.94) translateY(6px)'},
      ),
      'to': const Styles(
        raw: {'opacity': '1', 'transform': 'scale(1) translateY(0)'},
      ),
    }),

    // main
    css('.naki-dialog', [
      // backdrop
      css('&').styles(raw: Css.nakiDialogStyle['backdrop']),

      // content container
      css('.naki-dialog-content').styles(raw: Css.nakiDialogStyle['container']),

      // center position (default)
      css('&.dialog-center').styles(raw: {'align-items': 'center'}),

      // top position
      css(
        '&.dialog-top',
      ).styles(raw: {'align-items': 'flex-start', 'padding-top': '40px'}),

      // bottom position
      css(
        '&.dialog-bottom',
      ).styles(raw: {'align-items': 'flex-end', 'padding-bottom': '40px'}),

      // dialog actions list
      css('.naki-dialog-actions').styles(raw: {'margin-top': '30px'}),
    ]),

    // prevent background body scrolling when dialog is open
    css(':root:has(.naki-dialog)', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
      //..._appbarAdjustment,
    ]),
  ];

  /// Drawer rules
  static final nakiDrawerRules = [
    // fade in animation for backdrop
    css.keyframes('nakiDrawerFadeIn', {
      'from': const Styles(raw: {'opacity': '0'}),
      'to': const Styles(raw: {'opacity': '1'}),
    }),

    // slide in left animation
    css.keyframes('nakiDrawerSlideInLeft', {
      'from': const Styles(raw: {'transform': 'translateX(-100%)'}),
      'to': const Styles(raw: {'transform': 'translateX(0)'}),
    }),

    // slide in right animation
    css.keyframes('nakiDrawerSlideInRight', {
      'from': const Styles(raw: {'transform': 'translateX(100%)'}),
      'to': const Styles(raw: {'transform': 'translateX(0)'}),
    }),

    // main
    css('.naki-drawer', [
      // wrapper
      css('&').styles(raw: Css.nakiDrawerStyle['wrapper']),

      // barrier
      css('.naki-drawer-barrier').styles(raw: Css.nakiDrawerStyle['barrier']),

      // content
      css('.naki-drawer-content').styles(raw: Css.nakiDrawerStyle['content']),

      // persistent navigation variant (no barrier or viewport lock)
      css('&.persistent').styles(
        raw: {
          'position': 'sticky',
          'backdrop-filter': 'none',
          'touch-action': 'auto',
          'animation': 'none',
        },
      ),

      // persistent drawer content styles
      css(
        '&.persistent .naki-drawer-content',
      ).styles(
        raw: {
          'position': 'relative',
          'box-shadow': 'none',
          'animation': 'none',
        },
      ),

      // left drawer
      css('.drawer-left').styles(
        raw: {
          'left': '0',
          'animation':
              'nakiDrawerSlideInLeft 0.25s '
              'cubic-bezier(0.16, 1, 0.3, 1) forwards',
        },
      ),

      // right drawer
      css('.drawer-right').styles(
        raw: {
          'right': '0',
          'animation':
              'nakiDrawerSlideInRight 0.25s '
              'cubic-bezier(0.16, 1, 0.3, 1) forwards',
        },
      ),
    ]),

    // prevent background body scrolling when drawer is open
    css(':root:has(.naki-drawer:not(.persistent))', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
      //..._appbarAdjustment,
    ]),
  ];

  /// BottomSheet rules
  static final nakiBottomSheetRules = [
    // slide up animation for bottom sheet
    css.keyframes('nakiBottomSheetSlideUp', {
      'from': const Styles(raw: {'transform': 'translateY(100%)'}),
      'to': const Styles(raw: {'transform': 'translateY(0)'}),
    }),

    // main
    css('.naki-bottom-sheet', [
      // backdrop
      css('&').styles(raw: Css.nakiBottomSheetStyle['backdrop']),

      // container
      css(
        '.naki-bottom-sheet-content',
      ).styles(raw: Css.nakiBottomSheetStyle['container']),

      // handle
      css(
        '.naki-bottom-sheet-handle',
      ).styles(raw: Css.nakiBottomSheetStyle['handle']),
    ]),

    // prevent background body scrolling when bottom sheet is open
    css(':root:has(.naki-bottom-sheet)', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
      // ..._appbarAdjustment,
    ]),
  ];
}
