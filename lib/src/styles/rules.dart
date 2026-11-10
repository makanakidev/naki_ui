import 'dart:async';

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

/// Central registry to ensure style rules are emitted exactly once per
/// stylesheet.
///
/// Jaspr evaluates every `@css` getter synchronously each time it builds a
/// stylesheet; in the default inline-styles mode that happens on *every*
/// server request. Deduplication is therefore scoped to a single synchronous
/// pass and reset in a microtask, so later requests receive the full set of
/// rules again instead of an empty list.
final class NakiStyleRegistry {
  final Set<String> _registeredKeys = {};
  final Set<String> _generatedCss = {};
  bool _resetScheduled = false;

  /// Cache of rendered css per rule instance (rules are static finals).
  static final Expando<String> _cssCache = Expando('naki-css');

  /// Global static registry used for compile-time `@css` getters.
  static final NakiStyleRegistry global = NakiStyleRegistry();

  /// Static helper for `@css` getters
  static List<StyleRule> once(String key, List<StyleRule> rules) =>
      global.register(key, rules);

  /// Static helper to dedupe rules.
  static List<StyleRule> dedupe(List<StyleRule> rules) => global._dedupe(rules);

  /// Registers [rules] once per [key] within the current stylesheet pass.
  List<StyleRule> register(String key, List<StyleRule> rules) {
    _scheduleReset();
    if (_registeredKeys.contains(key)) return const [];
    _registeredKeys.add(key);
    return _dedupe(rules);
  }

  /// Deduplicate css rules and return unique rules
  List<StyleRule> _dedupe(List<StyleRule> rules) {
    _scheduleReset();
    final uniqueRules = <StyleRule>[];

    for (final rule in rules) {
      final css = _cssCache[rule] ??= rule.toCss();
      if (_generatedCss.contains(css)) continue;
      _generatedCss.add(css);
      uniqueRules.add(rule);
    }

    return uniqueRules;
  }

  /// Resets the registry once the current synchronous pass completes.
  void _scheduleReset() {
    if (_resetScheduled) return;
    _resetScheduled = true;
    scheduleMicrotask(clear);
  }

  /// Clears the registry.
  void clear() {
    _registeredKeys.clear();
    _generatedCss.clear();
    _resetScheduled = false;
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
  /// Styles for the direct children of a container.
  static List<StyleRule> _childRules(
    Map<String, String> raw, [
    String child = '> *',
  ]) => [
    css('& $child').styles(raw: raw),
  ];

  /// Themed calendar size tokens paired with their small-screen cap tokens.
  static final List<(Token, Token)> _writeVariableTokens = [
    (Tokens.current.calendarCellSize, Tokens.current.calendarCompactCellSize),
    (
      Tokens.current.calendarDateFontSize,
      Tokens.current.calendarCompactDateFontSize,
    ),
    (
      Tokens.current.calendarWeekdayFontSize,
      Tokens.current.calendarCompactWeekdayFontSize,
    ),
    (
      Tokens.current.calendarWeekdayGap,
      Tokens.current.calendarCompactWeekdayGap,
    ),
    (
      Tokens.current.calendarTitleFontSize,
      Tokens.current.calendarCompactTitleFontSize,
    ),
    (
      Tokens.current.calendarStepperHeight,
      Tokens.current.calendarCompactStepperHeight,
    ),
    (
      Tokens.current.calendarStepperFontSize,
      Tokens.current.calendarCompactStepperFontSize,
    ),
  ];

  /// Writes a variable token with its default value.
  static String _var(Token token, [String? fallback]) =>
      'var($token, ${fallback ?? token.value})';

  /// A small-screen calendar size: the themed [token] capped at its compact
  /// token (smaller themed values are kept).
  static String _compactCalendarSize(Token token) {
    final (_, compact) = _writeVariableTokens.firstWhere(
      (pair) => pair.$1.name == token.name,
    );
    return 'min(${_var(token)}, ${_var(compact)})';
  }

  /// Small-screen (≤ 420px) rule for [selector] capping each property's
  /// calendar size. Nested next to the base rule so it has the same
  /// specificity and, coming later, wins on small screens.
  static StyleRule _compactCalendarRule(
    String selector,
    Map<String, Token> properties,
  ) => css.media(const MediaQuery.screen(maxWidth: Unit.pixels(420)), [
    css(selector).styles(
      raw: {
        for (final MapEntry(key: property, value: token) in properties.entries)
          property: _compactCalendarSize(token),
      },
    ),
  ]);

  static const _fastTransition = '100ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';
  static const _mediumTransition = '250ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';
  static const _slowTransition = '500ms cubic-bezier(0.25, 0.46, 0.45, 0.94)';

  /// Build scrollbar styling rules for a selector.
  static List<StyleRule> buildScrollbarRules(
    String selector,
    ScrollBarConfiguration config,
  ) {
    final thumbColor = config.thumbColor;
    final trackColor = config.trackColor;
    final hoverThumbColor = config.hoverColor ?? thumbColor;

    final width = config.width;
    final height = config.height;
    final radius = config.radius;

    return [
      css(selector, [
        // base
        css('&').styles(
          raw: {
            'scrollbar-width': 'thin',
            'scrollbar-gutter': 'auto',
            'scrollbar-color': '${thumbColor.value} ${trackColor.value}',
          },
        ),

        // webkit scrollbar
        css(
          '&::-webkit-scrollbar',
        ).styles(raw: {'width': width.toPx, 'height': height.toPx}),

        // webkit scrollbar track
        css(
          '&::-webkit-scrollbar-track',
        ).styles(raw: {'background-color': trackColor.value}),

        // webkit scrollbar thumb
        css('&::-webkit-scrollbar-thumb').styles(
          raw: {
            'background-color': thumbColor.value,
            'border-radius': ?radius?.toPx,
            'border': '1px solid ${trackColor.value}',
          },
        ),

        // webkit scrollbar thumb hover state
        css(
          '&::-webkit-scrollbar-thumb:hover',
        ).styles(raw: {'background-color': hoverThumbColor.value}),
      ]),
    ];
  }

  /// Rules that give up a glass surface's translucency when the user or the
  /// platform asks for it. [style] holds the `glass-solid`,
  /// `glass-high-contrast` and `glass-forced-colors` entries.
  static List<StyleRule> _glassFallbacks(
    Map<String, Map<String, String>> style,
  ) => [
    css.media(const MediaQuery.raw('(prefers-reduced-transparency: reduce)'), [
      css('&').styles(raw: style['glass-solid']),
    ]),

    css.media(const MediaQuery.raw('(prefers-contrast: more)'), [
      css('&').styles(raw: style['glass-high-contrast']),
    ]),

    css.media(const MediaQuery.raw('(forced-colors: active)'), [
      css('&').styles(raw: style['glass-forced-colors']),
    ]),
  ];

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

    // while the theme's color variables fade on <html>, everything else
    // follows them directly; a component's own transition would trail behind
    css(
      'html.switching-theme *, html.switching-theme *::before, '
      'html.switching-theme *::after',
    ).styles(raw: {'transition': 'none !important'}),

    css.supports('(view-transition-name: root)', [
      css('html').styles(raw: {'view-transition-name': 'root'}),

      css(
        '::view-transition-old(root), ::view-transition-new(root)',
      ).styles(
        raw: {
          'animation-duration': '250ms',
          'animation-timing-function': 'cubic-bezier(0.25, 0.46, 0.45, 0.94)',
          'opacity': '1',
        },
      ),
    ]),

    // override default margin and padding on body element
    css('body').styles(raw: {'margin': '0', 'padding': '0'}),

    // ensure section elements are not hidden by the appbar when
    // scrolling to them via anchor links
    css('section').styles(
      raw: {'scroll-margin-top': _var(Tokens.current.appbarHeight)},
    ),

    // override browser's focus outline on buttons, links, and inputs
    css(':is(html) :focus-visible:not([fcs])').styles(raw: {'outline': 'none'}),

    // iOS Safari zooms into inputs below 16px on focus; keep inputs at 16px
    // there instead of disabling pinch-zoom for everyone (WCAG 1.4.4)
    css.supports('(-webkit-touch-callout: none)', [
      css('input, textarea, select').styles(
        raw: {
          'font-size':
              'max(16px, ${_var(Tokens.current.fontSizeInput)}) !important',
        },
      ),
    ]),

    // global element styles
    css('*').styles(
      raw: {
        'scrollbar-width': 'none',
        'box-sizing': 'border-box',
        'font-family': _var(Tokens.current.fontFamily),
        '-webkit-tap-highlight-color': 'transparent',
      },
    ),

    // root typography
    css('html, body').styles(
      raw: {
        'background-color': _var(Tokens.current.backgroundColor),
        'color': _var(Tokens.current.baseTextColor),
        'font-size': _var(Tokens.current.fontSizeMd),
        'touch-action': 'manipulation',
      },
    ),
  ];

  /// Breakpoint rules
  static final nakiBreakpointRules = [
    // Hide all by default
    css(
      '.br-xs, .br-sm, .br-md, .br-lg, .br-xl',
    ).styles(raw: {'display': 'none'}),

    // xs: <= 480px
    css.media(
      const MediaQuery.screen(maxWidth: Unit.pixels(kBreakpointXSmall)),
      [
        css('.br-xs').styles(raw: {'display': 'contents'}),
      ],
    ),

    // sm: 480px - 576px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointXSmall + 0.02),
        maxWidth: Unit.pixels(kBreakpointSmall),
      ),
      [
        css('.br-sm').styles(raw: {'display': 'contents'}),
      ],
    ),

    // md: 576px - 768px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointSmall + 0.02),
        maxWidth: Unit.pixels(kBreakpointMedium),
      ),
      [
        css('.br-md').styles(raw: {'display': 'contents'}),
      ],
    ),

    // lg: 768px - 1024px
    css.media(
      const MediaQuery.screen(
        minWidth: Unit.pixels(kBreakpointMedium + 0.02),
        maxWidth: Unit.pixels(kBreakpointLarge),
      ),
      [
        css('.br-lg').styles(raw: {'display': 'contents'}),
      ],
    ),

    // xl: 1024px and above
    css.media(
      const MediaQuery.screen(minWidth: Unit.pixels(kBreakpointLarge + 0.02)),
      [
        css('.br-xl').styles(raw: {'display': 'contents'}),
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
    css(
      '&[fcs]:is(:focus, :focus-visible), &[data-focused]',
    ).styles(raw: Css.nakiFocusBorderStyle),

    // placeholder
    css('&::-webkit-input-placeholder').styles(raw: Css.nakiPlaceholderStyle),

    // hide stepper if input type is number or tel
    css(
      '&::-webkit-inner-spin-button',
    ).styles(raw: {'margin': '0', 'appearance': 'none'}),

    // disabled state
    css('&:disabled').styles(raw: {'cursor': 'not-allowed'}),

    // leading / trailing icon
    css(
      '.naki-icon',
    ).styles(raw: {'height': _var(Tokens.current.inputHeight)}),

    // input
    css('input, input.naki-input').styles(raw: Css.nakiInputStyle['input']),

    // hide stepper if input type is number or tel
    css(
      'input::-webkit-inner-spin-button, input::-webkit-outer-spin-button',
    ).styles(raw: {'margin': '0', 'appearance': 'none'}),

    // placeholder
    css(
      'input::-webkit-input-placeholder',
    ).styles(raw: Css.nakiPlaceholderStyle),

    // hover state
    css('input[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css(
      'input[fcs]:is(:focus, :focus-visible)',
    ).styles(raw: Css.nakiFocusBorderStyle),

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
    css(
      '&[fcs]:is(:focus, :focus-visible), &[data-focused]',
    ).styles(raw: Css.nakiFocusBorderStyle),

    // placeholder
    css('&::-webkit-input-placeholder').styles(raw: Css.nakiPlaceholderStyle),

    // disabled state
    css('&:disabled').styles(raw: {'cursor': 'not-allowed'}),

    // leading / trailing icon
    css('.naki-icon').styles(
      raw: {'height': _var(Tokens.current.inputHeight)},
    ),

    // textarea
    css(
      'textarea, textarea.naki-textarea',
    ).styles(raw: Css.nakiTextareaStyle['input']),

    // placeholder
    css(
      'textarea::-webkit-input-placeholder',
    ).styles(raw: Css.nakiPlaceholderStyle),

    // hover state
    css('textarea[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

    // focus state
    css(
      'textarea[fcs]:is(:focus, :focus-visible)',
    ).styles(raw: Css.nakiFocusBorderStyle),

    // disabled state
    css('textarea:disabled').styles(raw: {'cursor': 'not-allowed'}),
  ]);

  /// Form field rules
  static final nakiFormFieldRules =
      css(
        '.naki-form-field',
      ).styles(
        raw: {
          'display': 'flex',
          'flex-direction': 'column',
          'scroll-margin-top': '75px',
        },
      );

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
          raw: {'color': _var(Tokens.current.placeholderColor)},
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

        // header area
        css(
          '.naki-calendar-header',
        ).styles(raw: Css.nakiCalendarStyle['header']),

        // header title
        css('.naki-calendar-title').styles(
          raw: {
            'font-size': '14px',
            'font-weight': '600',
            'letter-spacing': '0.04em',
            'text-transform': 'capitalize',
            'color': _var(Tokens.current.mutedColor),
          },
        ),

        // preview
        css('.naki-calendar-picker-preview').styles(
          raw: {
            'font-size': '12px',
            'font-weight': '500',
            'font-variant-numeric': 'tabular-nums',
            'color': _var(Tokens.current.primaryColor),
          },
        ),

        // footer area
        css('.naki-calendar-footer').styles(
          raw: {
            'padding': '8px 0',
            'position': 'sticky',
            'bottom': '-1px',
            'background-color': _var(Tokens.current.dropdownMenuBgColor),
            'border-top':
                '1px solid color-mix(in srgb, '
                '${_var(Tokens.current.borderColor)} 25%, transparent)',
          },
        ),

        // action buttons
        css('.naki-calendar-action').styles(
          raw: {
            'font-weight': '500',
            'font-size': '14px',
            'border-radius': '24px',
            'padding': '8px 12px',
            'height': 'auto',
            'white-space': 'nowrap',
          },
        ),

        // date picker
        css('.naki-date-picker', [
          css('&').styles(
            raw: {
              'width': '100%',
              'padding': '6px 4px 0',
            },
          ),

          // header button
          css(
            '.naki-calendar-header-action',
          ).styles(raw: {'border-radius': '999px', 'padding': '0'}),

          // header title
          css('.naki-calendar-header-title', [
            css('&').styles(
              raw: {
                'font-size': _var(Tokens.current.calendarTitleFontSize),
                'font-weight': '500',
                'cursor': 'pointer',
                '-webkit-user-select': 'none',
                'user-select': 'none',
                'padding': '0',
                'transition': 'transform 300ms cubic-bezier(0.2, 0.8, 0.2, 1)',
                'color': _var(Tokens.current.inputTextColor),
              },
            ),

            _compactCalendarRule('&', {
              'font-size': Tokens.current.calendarTitleFontSize,
            }),

            // rotate chevron icon
            css(
              '&[showyear] .naki-icon',
            ).styles(raw: {'transform': 'rotate(180deg)'}),
          ]),

          // year-month popover
          css('.naki-calendar-ymp', [
            // years dropdown
            css(
              '.naki-calendar-ymp__years .naki-dropdown-menu.upward',
            ).styles(raw: Css.nakiCalendarStyle['years-menu']),

            // months grid item
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
              css(
                '&[aria-pressed="true"]',
              ).styles(raw: Css.nakiCalendarStyle['selected']),
            ]),
          ]),

          // calendar table
          css('.naki-calendar-table', [
            // table header cells
            css('th').styles(
              raw: {
                'padding': 'min(0.5dvw, 4px)',
                'text-align': 'center',
                'font-weight': '400',
                'font-size': _var(Tokens.current.calendarWeekdayFontSize),
                'border':
                    '${_var(Tokens.current.calendarWeekdayGap)} '
                    'solid transparent',
                'background-color': 'transparent',
              },
            ),

            _compactCalendarRule('th', {
              'font-size': Tokens.current.calendarWeekdayFontSize,
              'border-width': Tokens.current.calendarWeekdayGap,
            }),

            // table body cells
            css('td').styles(
              raw: {'padding': 'min(0.5dvw, 4px) 0px', 'text-align': 'center'},
            ),

            // date cells
            css('.naki-calendar-date', [
              css('&').styles(
                raw: {
                  'font-size': _var(Tokens.current.calendarDateFontSize),
                  'text-align': 'center',
                  'width': _var(Tokens.current.calendarCellSize),
                  'height': _var(Tokens.current.calendarCellSize),
                  'border-radius': '999px',
                  'padding': '0',
                  'margin': '0 auto',
                  'border': 'none',
                },
              ),

              // fill the column so a range has no gaps between dates
              css('&[data-in-range]').styles(
                raw: {
                  'width': '100%',
                  'min-width': _var(Tokens.current.calendarCellSize),
                  'border-radius': '0',
                },
              ),

              // range start
              css(
                '&[data-range-start]',
              ).styles(raw: {'border-radius': '999px 0 0 999px'}),

              // range end
              css(
                '&[data-range-end]',
              ).styles(raw: {'border-radius': '0 999px 999px 0'}),

              // today
              css('&[data-today]').styles(
                raw: {
                  'border': '1px solid ${_var(Tokens.current.primaryColor)}',
                },
              ),

              // selected state
              css(
                '&[aria-pressed="true"]',
              ).styles(raw: Css.nakiCalendarStyle['selected']),

              // disabled state
              css('&[disabled]').styles(raw: Css.nakiCalendarStyle['disabled']),

              _compactCalendarRule('&', {
                'font-size': Tokens.current.calendarDateFontSize,
                'width': Tokens.current.calendarCellSize,
                'height': Tokens.current.calendarCellSize,
              }),

              _compactCalendarRule('&[data-in-range]', {
                'min-width': Tokens.current.calendarCellSize,
              }),
            ]),
          ]),
        ]),

        // time picker
        css('.naki-time-picker', [
          css('&').styles(
            raw: {
              'width': '100%',
              'padding': '10px 12px 0',
            },
          ),

          // steppers separator
          css('.naki-time-separator').styles(
            raw: {
              'font-size': _var(Tokens.current.calendarStepperFontSize),
              'font-weight': '600',
              'padding-bottom': '2px',
              'color': _var(Tokens.current.mutedColor),
            },
          ),

          css('.naki-time-picker-steppers').styles(raw: {'padding': '10px 0'}),

          // time stepper
          css('.naki-time-stepper', [
            css('&').styles(
              raw: {
                'width': _var(Tokens.current.calendarStepperWidth),
                'padding': '4px',
                'gap': '2px',
                'border-radius': '14px',
                'border': '2px solid transparent',
                'background-color':
                    'color-mix(in srgb, ${_var(Tokens.current.borderColor)} 10%, transparent)',
                'transition':
                    'border-color $_fastTransition, '
                    'box-shadow $_fastTransition',
              },
            ),

            // focus ring around the whole stepper
            css('&:focus-within').styles(
              raw: {
                'border-color': _var(Tokens.current.primaryColor),
                'box-shadow':
                    '0 0 4px 2px color-mix(in srgb, '
                    '${_var(Tokens.current.primaryColor)} 20%, transparent)',
              },
            ),

            // input
            css('& > input').styles(
              raw: {
                'width': '100%',
                'height': _var(Tokens.current.calendarStepperHeight),
                'font-weight': '600',
                'font-size': _var(Tokens.current.calendarStepperFontSize),
                'font-variant-numeric': 'tabular-nums',
                'text-align': 'center',
                'padding': '0',
                'margin': '0',
                'border': 'none',
                'border-radius': '10px',
                'color': _var(Tokens.current.inputTextColor),
                'background-color': _var(Tokens.current.dropdownMenuBgColor),
                'box-shadow': '0 1px 2px rgb(0 0 0 / 0.06)',
                '-moz-appearance': 'textfield',
              },
            ),

            _compactCalendarRule('& > input', {
              'height': Tokens.current.calendarStepperHeight,
              'font-size': Tokens.current.calendarStepperFontSize,
            }),

            // stepper button
            css('.naki-time-stepper-button', [
              css('&').styles(
                raw: {
                  'height': '28px',
                  'width': '100%',
                  'border': 'none',
                  'border-radius': '8px',
                  'padding': '0',
                  'background-color': 'transparent',
                  'cursor': 'pointer',
                  'color': _var(Tokens.current.mutedColor),
                  'transition':
                      'background-color $_fastTransition, '
                      'color $_fastTransition',
                },
              ),

              css('&:hover').styles(
                raw: {
                  'color': _var(Tokens.current.primaryColor),
                  'background-color':
                      'color-mix(in srgb, '
                      '${_var(Tokens.current.primaryColor)} 10%, transparent)',
                },
              ),
            ]),
          ]),
        ]),
      ]),

      // small screens: cap the themed sizes so 7 columns always fit
      // (smaller values from the theme are kept)
      css.media(const MediaQuery.screen(maxWidth: Unit.pixels(420)), [
        css('.naki-calendar-modal').styles(raw: {'padding': '6px 3px 0'}),
      ]),
    ]),
  ];

  /// Label rules
  static final nakiLabelRules = css(
    '.naki-label',
  ).styles(raw: Css.nakiLabelStyle.props);

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
        css('&.shape-circle').styles(raw: {'border-radius': '999px'}),

        // hover state
        css('&[hvr]:hover').styles(raw: Css.nakiFieldHoverStyle),

        // focus state
        css(
          '&[fcs]:is(:focus, :focus-visible)',
        ).styles(raw: Css.nakiFocusBorderStyle),

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

  /// Error text rules
  static final nakiErrorRules = css(
    'naki-error',
  ).styles(raw: Css.nakiErrorTextStyle.props);

  /// Checkbox rules
  static final nakiCheckboxRules = css('naki-checkbox', [
    // wrapper
    css('&').styles(raw: Css.nakiCheckboxStyle['wrapper']),

    // input element
    css('.naki-checkbox', [
      css('&').styles(raw: Css.nakiCheckboxStyle['input']),

      // round shape
      css('&[shape="round"]').styles(raw: {'border-radius': '999px'}),

      css(
        '&[fcs]:is(:focus)',
      ).styles(raw: Css.nakiFocusBorderStyle),

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

      css(
        '&[fcs]:is(:focus)',
      ).styles(raw: Css.nakiFocusBorderStyle),

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

    // active track
    css(
      '.naki-slider-active-track',
    ).styles(raw: Css.nakiSliderStyle['active-track']),

    // input element
    css('.naki-slider', [
      css('&').styles(raw: Css.nakiSliderStyle['input']),

      // tooltip visibility
      css(
        '&:is(:hover, :focus-visible, :active) ~ .slider-tooltip',
      ).styles(raw: {'opacity': '1'}),

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
    css('&', [
      css('&').styles(raw: Css.nakiAppBarStyle['wrapper']),

      // backdrop filter for frosted glass effect
      css('&[blur="true"]').styles(
        raw: {
          '-webkit-backdrop-filter': 'blur(10px)',
          'backdrop-filter': 'blur(10px)',
          'background-color': Css.applyOpacity(
            Tokens.current.appbarBgColor,
            65,
          ).value,
        },
      ),
    ]),

    // text title
    css('.naki-appbar-title').styles(raw: Css.nakiAppBarStyle['title']),

    // actions
    css('.naki-appbar-actions').styles(raw: Css.nakiAppBarStyle['actions']),
  ]);

  /// BottomNavBar rules
  static final nakiBottomNavBarRules = css('.naki-bottombar', [
    // wrapper
    css('&').styles(raw: Css.nakiBottomNavBarStyle['wrapper']),

    css(
      '& .naki-gesture-detector',
    ).styles(raw: Css.nakiBottomNavBarStyle['tile-action']),

    css(
      '& > .naki-navbar-tile:active',
    ).styles(raw: Css.nakiBottomNavBarStyle['pressed-tile']),

    // fixed navbar type
    css('&.navbar__fixed', [
      css('&').styles(raw: Css.nakiBottomNavBarStyle['fixed']),

      css('&::after').styles(raw: Css.nakiBottomNavBarStyle['fixed-safe-area']),

      css('& > .naki-navbar-tile', [
        css('&').styles(raw: {'width': '100%'}),

        css(
          '&:is(:focus-within)',
        ).styles(
          raw: {
            'border-radius': '10px',
            'height': 'calc(100% - 12px)',
            'transition': 'height $_fastTransition',
            'background-color':
                'color-mix(in srgb, '
                '${_var(Tokens.current.primaryColor)} 7%, transparent)',
          },
        ),
      ]),
    ]),

    // floating navbar type
    css('&.navbar__floating', [
      css('&').styles(raw: Css.nakiBottomNavBarStyle['floating']),

      css('& > .naki-navbar-tile', [
        css('&').styles(raw: Css.nakiBottomNavBarStyle['fixed-tile']),

        css(
          '&:is(:focus-within)',
        ).styles(
          raw: {
            'border-radius': 'inherit',
            'transition': 'height $_fastTransition',
            'background-color':
                'color-mix(in srgb, '
                '${_var(Tokens.current.primaryColor)} 7%, transparent)',
          },
        ),
      ]),
    ]),

    // frosted glass navbar type
    css('&.navbar__frosted-glass', [
      css('&').styles(raw: Css.nakiBottomNavBarStyle['frosted-glass']),

      css(
        '&::before',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-rim']),

      css(
        '& > .naki-navbar-tile',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-tile']),

      css(
        '& > .naki-navbar-tile .naki-gesture-detector::after',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-tile-target']),

      css(
        '& > .naki-navbar-tile .naki-gesture-detector:focus-visible',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-tile-focus']),

      css(
        '& > .naki-navbar-indicator',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-indicator']),

      css(
        '& > .naki-navbar-refraction',
      ).styles(raw: Css.nakiBottomNavBarStyle['frosted-glass-refraction']),

      css.media(
        const MediaQuery.raw('(prefers-reduced-transparency: reduce)'),
        [
          css('&').styles(
            raw:
                Css.nakiBottomNavBarStyle['frosted-glass-reduced-transparency'],
          ),
          css('&::before').styles(raw: {'display': 'none'}),
          css('& > .naki-navbar-indicator').styles(
            raw: Css.nakiBottomNavBarStyle['frosted-glass-solid-indicator'],
          ),
        ],
      ),

      // browsers without SVG backdrop filters, such as WebKit on iOS
      css('&.navbar__liquid-glass:not([data-refracted])', [
        css(
          '&::before',
        ).styles(raw: Css.nakiBottomNavBarStyle['liquid-glass-lens']),

        css(
          '& > .naki-navbar-indicator',
        ).styles(raw: Css.nakiBottomNavBarStyle['liquid-glass-lens-indicator']),
      ]),

      css.media(const MediaQuery.raw('(hover: hover)'), [
        css(
          '& > .naki-navbar-tile:hover:not(:has([aria-current]))',
        ).styles(raw: Css.nakiBottomNavBarStyle['hover-tile']),
      ]),

      css.media(const MediaQuery.raw('(prefers-contrast: more)'), [
        css('&').styles(
          raw: Css.nakiBottomNavBarStyle['frosted-glass-high-contrast'],
        ),
        css('&::before').styles(raw: {'display': 'none'}),
        css('& > .naki-navbar-indicator').styles(
          raw: Css
              .nakiBottomNavBarStyle['frosted-glass-high-contrast-indicator'],
        ),
      ]),

      css.media(const MediaQuery.raw('(forced-colors: active)'), [
        css('&').styles(
          raw: Css.nakiBottomNavBarStyle['frosted-glass-forced-colors'],
        ),
        css('&::before').styles(raw: {'display': 'none'}),
        css('& > .naki-navbar-indicator').styles(
          raw: Css
              .nakiBottomNavBarStyle['frosted-glass-forced-colors-indicator'],
        ),
      ]),
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

    // keyboard focus ring
    css(
      '.naki-navbar-tile .naki-gesture-detector:focus-visible',
    ).styles(raw: Css.nakiBottomNavBarStyle['tile-focus']),

    // tile label
    css('.naki-navbar-label').styles(raw: Css.nakiBottomNavBarStyle['label']),
  ]);

  /// Button rules
  static final nakiButtonRules = css('.naki-button', [
    // button
    css('&').styles(
      raw: Css.nakiButtonStyle.combine({
        'transition': 'background-color $_fastTransition',
      }),
    ),

    // disabled state
    css('&:disabled').styles(
      raw: Css.nakiDisabledStyle.combine({
        'background-color': _var(Tokens.current.disabledBgColor),
      }),
    ),

    // hover state
    css('&[hvr]:hover').styles(
      raw: {
        'background-color': _var(Tokens.current.buttonHoverBgColor),
      },
    ),

    // scale down when tapped
    css('&[scl]:active').styles(raw: {'transform': 'scale(0.97)'}),
  ]);

  /// Icon rules
  static final nakiIconRules = css('.naki-icon').styles(raw: Css.nakiIconStyle);

  /// Fragment rules
  static final nakiFragmentRules = css(
    'naki-fragment, naki-overlay-host',
  ).styles(raw: {'display': 'contents'});

  /// Scaffold rules
  static final nakiScaffoldRules = css('.naki-scaffold', [
    // wrapper
    css('&').styles(raw: Css.nakiScaffoldStyle['wrapper']),

    // app bar when fixed
    css(
      '.naki-appbar-wrapper .naki-appbar[fixed="true"]',
    ).styles(raw: Css.nakiScaffoldStyle['appbar']),

    // the app bar paints behind the status bar, so it owns the top inset
    css(
      '&:has(> .naki-appbar-wrapper)',
    ).styles(raw: {'padding-top': '0'}),

    css(
      '& > .naki-appbar-wrapper .naki-appbar',
    ).styles(raw: Css.nakiScaffoldStyle['appbar-inset']),

    // an app bar in the flow still paints out to the screen edges
    css('& > .naki-appbar-wrapper .naki-appbar:not([fixed="true"])').styles(
      raw: {
        'margin-left': 'calc(-1 * ${Css.safeAreaLeft})',
        'margin-right': 'calc(-1 * ${Css.safeAreaRight})',
        'width': 'calc(100% + ${Css.safeAreaLeft} + ${Css.safeAreaRight})',
      },
    ),

    // layout
    css('.naki-scaffold-layout').styles(raw: Css.nakiScaffoldStyle['layout']),

    // sidebar
    css('.naki-scaffold-sidebar').styles(raw: Css.nakiScaffoldStyle['sidebar']),

    // a fixed app bar overlays the body
    css('&:has(.naki-appbar-wrapper .naki-appbar[fixed="true"])').styles(
      raw: {
        kScaffoldInsetTopVar: _var(
          Tokens.current.appbarOffset,
          Css.nakiScaffoldStyle['appbar-inset']!['height'],
        ),
      },
    ),

    css('.naki-scaffold-body', [
      css('&').styles(raw: Css.nakiScaffoldStyle['body']),

      css('&:has(> .$kInsetOwnerClass)').styles(
        raw: Css.nakiScaffoldStyle['inset-owner-body'],
      ),
    ]),

    // extendBody: fixed navbar overlays the body as well
    css('.extended-body ~ .naki-navbar-wrapper').styles(
      raw: {
        'position': 'absolute',
        'left': Css.safeAreaLeft,
        'right': Css.safeAreaRight,
        'bottom': Css.safeAreaBottom,
        'width': 'auto',
      },
    ),

    // bottom navbar
    css('.naki-navbar-wrapper', [
      css('&').styles(raw: Css.nakiScaffoldStyle['bottom-navbar']),

      ..._childRules({'position': 'static'}, '.navbar__fixed'),

      ..._childRules({
        'position': 'fixed',
        'bottom': 'calc(20px + ${Css.safeAreaBottom})',
        'left': '50%',
        'transform': 'translateX(-50%)',
      }, ':is(.navbar__floating, .navbar__frosted-glass)'),
    ]),

    // floating action button
    css('.naki-scaffold-fab').styles(raw: Css.nakiScaffoldStyle['fab']),
  ]);

  /// Stack rules
  static final nakiStackRules = css('.naki-stack', [
    css('&').styles(raw: Css.nakiStackStyle),
    ..._childRules({'grid-area': 'stack'}),
  ]);

  /// Align rules
  static final nakiAlignRules = css('.naki-align').styles(
    raw: {
      'width': '100%',
      'height': 'auto',
      'min-height': '100%',
      'display': 'flex',
      'box-sizing': 'border-box',
      'flex-shrink': '0',
    },
  );

  /// Cliprect rules
  static final nakiClipRectRules = css(
    '.naki-cliprect',
  ).styles(raw: {'display': 'inline-block', 'overflow': 'hidden'});

  /// SizedBox rules
  static final nakiSizedBoxRules = css(
    '.naki-sizedbox',
  ).styles(raw: Css.nakiSizedBoxStyle);

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

    // glass card
    css('&.naki-card--glass', [
      css('&').styles(raw: Css.nakiCardStyle['glass']),

      css('&.naki-card--interactive[hvr]:hover').styles(
        raw: Css.nakiCardStyle['glass-hover'],
      ),

      ..._glassFallbacks(Css.nakiCardStyle),
    ]),

    // interactive card
    css('&.naki-card--interactive', [
      css('&').styles(
        raw: {
          'cursor': 'pointer',
          '-webkit-user-select': 'none',
          'user-select': 'none',
        },
      ),

      // hover state
      css('&[hvr]:hover').styles(
        raw: {
          'box-shadow':
              '0 4px 6px -1px ${_var(Tokens.current.mediumShadowColor)}, '
              '0 2px 4px -2px ${_var(Tokens.current.mediumShadowColor)}',
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
  ).styles(raw: {'display': 'inline-block', 'position': 'absolute'});

  /// Wrap rules
  static final nakiWrapRules = css(
    '.naki-wrap',
  ).styles(raw: {'display': 'flex', 'flex-wrap': 'wrap'});

  /// ClipOval rules
  static final nakiClipOvalRules =
      css(
        '.naki-clip-oval',
      ).styles(
        raw: {'display': 'block', 'border-radius': '999px', 'overflow': 'clip'},
      );

  /// Radio button rules
  static final nakiRadioBtnRules = css('naki-radiobtn', [
    // wrapper
    css('&').styles(raw: Css.nakiRadioBtnStyle['wrapper']),

    // input element
    css('.naki-radio-btn', [
      css('&').styles(raw: Css.nakiRadioBtnStyle['input']),

      // when focused
      css(
        '&[fcs]:is(:focus)',
      ).styles(raw: Css.nakiFocusBorderStyle),

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
        css(
          '&[fcs]:is(:focus, :focus-visible)',
        ).styles(raw: Css.nakiFocusBorderStyle),
      ]),

      // wrapped trigger
      css('.naki-dropdown-trigger', [
        // color when no selection is made
        css('&:not([data-selected])').styles(
          raw: {
            'color': _var(Tokens.current.placeholderColor),
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

        // keyboard-active / hovered state
        css(
          '&:is([data-active], :hover):not([aria-selected="true"])',
        ).styles(
          raw: {
            'background-color': Css.applyOpacity(
              Tokens.current.hoverColor,
              12,
            ).value,
          },
        ),

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

    // replaces rotation when the user prefers reduced motion
    css.keyframes('nakiSpinnerPulse', {
      'from': const Styles(opacity: 1),
      'to': const Styles(opacity: 0.4),
    }),

    css('.naki-spinner', [
      // default spinner
      css('&').styles(raw: Css.nakiSpinnerStyle['default']),

      // ios-style spinner
      css('&[data-type="ios"]').styles(raw: Css.nakiSpinnerStyle['ios']),

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
      css('&[data-type="glass"]', [
        css('&').styles(raw: Css.nakiSpinnerStyle['glass']),

        // the arc spins on its own so the glass stays still
        css('&::after').styles(raw: Css.nakiSpinnerStyle['glass-arc']),

        ..._glassFallbacks(Css.nakiSpinnerStyle),
      ]),

      // the foundation rule stops every animation after one frame, which would
      // freeze a loader, so these outrank it with a gentle pulse
      css.media(const MediaQuery.raw('(prefers-reduced-motion: reduce)'), [
        css(
          '&:not([data-type="glass"]), &[data-type="glass"]::after',
        ).styles(raw: Css.nakiSpinnerStyle['reduced-motion']),

        css('.spinner-blade').styles(raw: {'animation': 'none !important'}),
      ]),
    ]),
  ];

  /// AutoCompleteField rules
  static final nakiAutoCompleteFieldRules = [
    css('naki-autocomplete', [
      // wrapper
      css('&').styles(raw: {'position': 'relative'}),

      // options menu
      css('.naki-autocomplete-menu').styles(
        raw: {
          ...?Css.nakiDropdownStyle['options-wrapper'],
          ...?Css.nakiDropdownStyle['open:options-wrapper'],
        },
      ),

      // option
      css('.naki-autocomplete-option', [
        // default state
        css('&').styles(raw: Css.nakiDropdownStyle['option']),

        // keyboard-active / hovered state
        css(
          '&:is([aria-selected="true"], :hover)',
        ).styles(
          raw: {
            'background-color': Css.applyOpacity(
              Tokens.current.hoverColor,
              12,
            ).value,
          },
        ),
      ]),
    ]),
  ];

  /// Form rules
  static final nakiFormRules = css('.naki-form').styles(raw: Css.nakiFormStyle);

  /// Text rules
  static final nakiTextRules = css('.naki-text', [
    css('&').styles(raw: {'display': 'block', 'box-sizing': 'border-box'}),

    // selection (standard)
    css('&::selection').styles(
      raw: {
        'background-color': _var(Tokens.current.selectedTextBgColor),
        'color': _var(Tokens.current.selectedTextColor),
      },
    ),

    // selection (firefox)
    css('&::-moz-selection').styles(
      raw: {
        'background-color': _var(Tokens.current.selectedTextBgColor),
        'color': _var(Tokens.current.selectedTextColor),
      },
    ),
  ]);

  /// A scroll view applies the Scaffold insets, so anything nested in it
  /// starts clear of the bars.
  static StyleRule get _insetConsumedRule =>
      css('&.$kInsetOwnerClass > *').styles(raw: Css.nakiInsetConsumedStyle);

  /// Row rules
  static final nakiRowRules = css('.naki-row', [
    // a vertical scroll view needs a height to scroll within, like a Flutter
    // Row inheriting its parent's constraints
    css(
      '&:has(> .$kFillScrollClass, '
      '> :is(.naki-expanded, .naki-flexible) > .$kFillScrollClass)',
    ).styles(raw: {'height': '100%', 'min-height': '0'}),

    css(
      '& > :is(.naki-expanded, .naki-flexible):has(> .$kFillScrollClass)',
    ).styles(raw: {'align-self': 'stretch'}),
  ]);

  /// Column rules
  static final nakiColumnRules = css('.naki-column', [_insetConsumedRule]);

  /// SingleChildScrollView rules
  static final nakiSingleChildScrollViewRules = css(
    '.naki-singlechild-scrollview',
    [
      css('&').styles(raw: Css.nakiSingleChildScrollViewStyle),
      _insetConsumedRule,
      ..._childRules({'flex-shrink': '0'}),
    ],
  );

  /// ListView rules
  static final nakiListViewRules = css('.naki-listview', [
    css('&').styles(raw: Css.nakiListViewStyle),
    _insetConsumedRule,

    ..._childRules({
      'height': _var(Tokens.current.listViewItemExtentHeight),
      'width': _var(Tokens.current.listViewItemExtentWidth),
      'flex-shrink': '0',
    }),
  ]);

  /// GridView rules
  static final nakiGridViewRules = css('.naki-gridview', [
    css('&').styles(raw: Css.nakiGridViewStyle),
    _insetConsumedRule,
    ..._childRules({'height': '100%', 'width': '100%'}),
  ]);

  /// PageView rules
  static final nakiPageViewRules = css('.naki-pageview', [
    // container scroll snap configuration
    css('&').styles(raw: Css.nakiPageViewStyle),

    // pages receive the Scaffold insets, those that scroll apply them themselves
    css('& > :not(.$kInsetOwnerClass)', [
      css('&').styles(raw: Css.nakiPageViewStaticPageStyle),
      css('& > *').styles(raw: Css.nakiInsetConsumedStyle),
    ]),

    // PageController.animateToPage drives the scroll position itself
    css('&[data-animating]').styles(
      raw: {'scroll-snap-type': 'none !important'},
    ),

    //
    css('&[snap] > *').styles(raw: {'scroll-snap-stop': 'always'}),

    // page item snap alignment and extent, specific enough to beat a scroll
    // view's own `flex` when one is used as a page
    css('&.naki-pageview > *').styles(
      raw: {
        'scroll-snap-align': 'start',
        'flex': '0 0 100%',
        'width': '100%',
        'height': '100%',
      },
    ),
  ]);

  /// CarouselView rules
  static final nakiCarouselRules = css('.naki-carouselview', [
    // carousel container flex scroll layout
    css('&').styles(raw: Css.nakiCarouselStyle),

    css('&[snap] > *').styles(raw: {'scroll-snap-stop': 'always'}),

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
        'background-color': _var(Tokens.current.tableHeaderBg),
        'padding': '12px 16px',
        'font-weight': '600',
        'border': 'none',
      },
    ),

    // row cell
    css('td').styles(raw: {'padding': '12px 16px'}),

    // row hover state
    css('tbody tr[hvr]:hover').styles(
      raw: {'background-color': _var(Tokens.current.tableRowHoverBg)},
    ),
  ]);

  /// Aspect ratio rules
  static final nakiAspectRatioRules = css(
    '.naki-aspectratio',
  ).styles(raw: {'display': 'block', 'overflow': 'hidden'});

  /// Flexible rules
  static final nakiFlexibleRules = [
    css('.naki-flexible, .naki-expanded').styles(
      raw: {
        'min-height': '0',
        'min-width': '0',
        'display': 'flex',
        'flex-direction': 'column',
      },
    ),

    css('.naki-flexible', _childRules({'flex-shrink': '1'})),

    css('.naki-expanded', _childRules({'width': '100%'})),
  ];

  /// Hide rules
  static final nakiHide = css(
    '.naki-hide',
  ).styles(raw: {'display': 'none !important'});

  /// StaggeredView rules
  static final nakiStaggeredRules = css('.naki-staggeredview', [
    // wrapper
    css('&').styles(raw: Css.nakiStaggeredStyle),
    _insetConsumedRule,

    // item
    css('.naki-staggered-item').styles(
      raw: {
        'display': 'block',
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

    // exit
    css(
      '&[data-exiting=true]',
    ).styles(
      raw: {
        'animation':
            'nakiDialogFadeOut 0.2s cubic-bezier(0.4, 0, 0.2, 1) forwards',
      },
    ),

    // top position
    css('&.sb-top').styles(
      raw: {
        'top':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaTop}))',
        'left': '50%',
        'transform': 'translateX(-50%)',
      },
    ),

    // bottom position
    css('&.sb-bottom').styles(
      raw: {
        'bottom':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaBottom}))',
        'left': '50%',
        'transform': 'translateX(-50%)',
      },
    ),

    // top-left position
    css(
      '&.sb-top-left',
    ).styles(
      raw: {
        'top':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaTop}))',
        'left': 'calc(20px + ${Css.safeAreaLeft})',
      },
    ),

    // top-right position
    css(
      '&.sb-top-right',
    ).styles(
      raw: {
        'top':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaTop}))',
        'right': 'calc(20px + ${Css.safeAreaRight})',
      },
    ),

    // bottom-left position
    css(
      '&.sb-bottom-left',
    ).styles(
      raw: {
        'bottom':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaBottom}))',
        'left': 'calc(20px + ${Css.safeAreaLeft})',
      },
    ),

    // bottom-right position
    css(
      '&.sb-bottom-right',
    ).styles(
      raw: {
        'bottom':
            'max(${_var(Tokens.current.snackbarOffset)}, calc(10px + ${Css.safeAreaBottom}))',
        'right': 'calc(20px + ${Css.safeAreaRight})',
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
        'text-wrap': 'wrap',
      },
    ),

    // actions area
    css('.banner-actions').styles(raw: {'margin-top': '10px', 'gap': '10px'}),

    // info banner
    css('&.banner-info').styles(
      raw: {
        'background-color': _var(Tokens.current.infoWeakColor),
        'border-color': _var(Tokens.current.infoColor),
      },
    ),

    // success banner
    css('&.banner-success').styles(
      raw: {
        'background-color': _var(Tokens.current.successWeakColor),
        'border-color': _var(Tokens.current.successColor),
      },
    ),

    // warning banner
    css('&.banner-warning').styles(
      raw: {
        'background-color': _var(Tokens.current.warningWeakColor),
        'border-color': _var(Tokens.current.warningColor),
      },
    ),

    // error banner
    css('&.banner-error').styles(
      raw: {
        'background-color': _var(Tokens.current.errorWeakColor),
        'border-color': _var(Tokens.current.errorColor),
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
      raw: {
        'content': '""',
        'position': 'absolute',
        'border-style': 'solid',
        'translate':
            'var($kTooltipArrowXVar, 0px) var($kTooltipArrowYVar, 0px)',
        'rotate': 'var($kTooltipArrowRotateVar, 0deg)',
      },
    ),

    // show tooltip on target hover or focus
    css(
      '.naki-tooltip-target:is(:hover, :has(:focus-visible)) ~ .naki-tooltip-content',
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
        'left': 'calc(50% - 6px)',
        'border-width': '6px 6px 0 6px',
        'border-color':
            '${_var(Tokens.current.tooltipBgColor)} '
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
        'left': 'calc(50% - 6px)',
        'border-width': '0 6px 6px 6px',
        'border-color':
            'transparent transparent '
            '${_var(Tokens.current.tooltipBgColor)} transparent',
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
        'top': 'calc(50% - 6px)',
        'border-width': '6px 0 6px 6px',
        'border-color':
            'transparent transparent transparent '
            '${_var(Tokens.current.tooltipBgColor)}',
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
        'top': 'calc(50% - 6px)',
        'border-width': '6px 6px 6px 0',
        'border-color':
            'transparent ${_var(Tokens.current.tooltipBgColor)} '
            'transparent transparent',
      },
    ),
  ]);

  /// Popover rules
  static final nakiPopoverRules = [
    css('.naki-popover', [
      // wrapper
      css('&').styles(raw: Css.nakiPopoverStyle['wrapper']),

      // popover content
      css('.naki-popover-content').styles(raw: Css.nakiPopoverStyle['popup']),

      // show popover content when trigger can be focused or hovered
      css(
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
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
        '&[aria-expanded="true"] .popover-top, '
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-top, .popover-top:hover, '
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
        '&[aria-expanded="true"] .popover-bottom, '
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-bottom, .popover-bottom:hover, '
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
        '&[aria-expanded="true"] .popover-left, '
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-left, .popover-left:hover, '
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
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-right, '
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
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-top-left, '
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
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-top-right, '
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
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-bottom-left, '
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
        '.naki-popover-trigger[canfocus]:is(:hover, :has(:focus-visible)) ~ '
        '.popover-bottom-right, '
        '.popover-bottom-right:hover, '
        '.popover-bottom-right:focus-within',
      ).styles(raw: {'transform': 'translateY(8px) scale(1)'}),
    ]),
  ];

  /// A modal scrim fades its own color and blur, as Material 3's scrim is a
  /// layer of its own. Fading the barrier's opacity would also fade the
  /// dialog, sheet or drawer inside it.
  static final _scrimKeyframes = [
    css.keyframes('nakiScrimIn', {
      'from': const Styles(
        raw: {
          'background-color': 'transparent',
          '-webkit-backdrop-filter': 'blur(0)',
          'backdrop-filter': 'blur(0)',
        },
      ),
    }),
    css.keyframes('nakiScrimOut', {
      'to': const Styles(
        raw: {
          'background-color': 'transparent',
          '-webkit-backdrop-filter': 'blur(0)',
          'backdrop-filter': 'blur(0)',
        },
      ),
    }),
  ];

  /// Dialog rules
  static final nakiDialogRules = [
    ..._scrimKeyframes,

    css.keyframes('nakiDialogGrow', {
      'from': Styles(
        raw: {
          'clip-path':
              'inset(0 0 65% 0 round ${_var(Tokens.current.dialogBorderRadius)})',
        },
      ),
      'to': Styles(
        raw: {
          'clip-path':
              'inset(0 round ${_var(Tokens.current.dialogBorderRadius)})',
        },
      ),
    }),

    css.keyframes('nakiDialogShrink', {
      'from': Styles(
        raw: {
          'clip-path':
              'inset(0 round ${_var(Tokens.current.dialogBorderRadius)})',
        },
      ),
      'to': Styles(
        raw: {
          'clip-path':
              'inset(0 0 65% 0 round ${_var(Tokens.current.dialogBorderRadius)})',
        },
      ),
    }),

    // fade in animation for backdrop
    css.keyframes('nakiDialogFadeIn', {
      'from': const Styles(raw: {'opacity': '0'}),
      'to': const Styles(raw: {'opacity': '1'}),
    }),

    // fade out animation for backdrop
    css.keyframes('nakiDialogFadeOut', {
      'from': const Styles(raw: {'opacity': '1'}),
      'to': const Styles(raw: {'opacity': '0'}),
    }),

    // a barrier below full opacity is a backdrop root, so a glass dialog's
    // barrier fades its color instead
    css.keyframes('nakiDialogBarrierIn', {
      'from': const Styles(raw: {'background-color': 'transparent'}),
      'to': Styles(
        raw: {'background-color': _var(Tokens.current.dialogBarrierBg)},
      ),
    }),

    css.keyframes('nakiDialogBarrierOut', {
      'from': Styles(
        raw: {'background-color': _var(Tokens.current.dialogBarrierBg)},
      ),
      'to': const Styles(raw: {'background-color': 'transparent'}),
    }),

    // main
    css('.naki-dialog', [
      // backdrop
      css('&').styles(raw: Css.nakiDialogStyle['backdrop']),

      // exit backdrop
      css(
        '&[data-exiting="true"]',
      ).styles(
        raw: {'animation': 'nakiScrimOut 150ms linear both'},
      ),

      // content container
      css('.naki-dialog-content').styles(raw: Css.nakiDialogStyle['container']),

      // content and actions fade in after the container starts growing
      css('.naki-dialog-content > *').styles(
        raw: {'animation': 'nakiDialogFadeIn 200ms linear 50ms backwards'},
      ),
      css('.naki-dialog-content > .naki-dialog-actions').styles(
        raw: {'animation': 'nakiDialogFadeIn 150ms linear 150ms backwards'},
      ),

      // exit content
      css('.naki-dialog-content[data-exiting="true"]', [
        css('&').styles(
          raw: {
            'animation':
                'nakiDialogShrink 150ms cubic-bezier(0.3, 0, 0.8, 0.15) forwards, '
                'nakiDialogFadeOut 50ms linear 100ms forwards',
          },
        ),
        css('& > *').styles(
          raw: {'animation': 'nakiDialogFadeOut 100ms linear forwards'},
        ),
      ]),

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

      // glass dialog
      css('&.dialog-glass', [
        css('&').styles(raw: Css.nakiDialogStyle['glass-backdrop']),

        css('&[data-exiting="true"]').styles(
          raw: Css.nakiDialogStyle['glass-backdrop-exit'],
        ),

        css('.naki-dialog-content', [
          css('&').styles(raw: Css.nakiDialogStyle['glass']),
          ..._glassFallbacks(Css.nakiDialogStyle),
        ]),
      ]),
    ]),

    // prevent background body scrolling when dialog is open
    css(':root:has(.naki-dialog)', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
    ]),
  ];

  /// Drawer rules
  static final nakiDrawerRules = [
    ..._scrimKeyframes,

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

    // slide out left animation
    css.keyframes('nakiDrawerSlideOutLeft', {
      'from': const Styles(raw: {'transform': 'translateX(0)'}),
      'to': const Styles(raw: {'transform': 'translateX(-100%)'}),
    }),

    // slide out right animation
    css.keyframes('nakiDrawerSlideOutRight', {
      'from': const Styles(raw: {'transform': 'translateX(0)'}),
      'to': const Styles(raw: {'transform': 'translateX(100%)'}),
    }),

    // main
    css('.naki-drawer', [
      // barrier
      css('&').styles(raw: Css.nakiDrawerStyle['wrapper']),

      // exit animation
      css(
        '&[data-exiting="true"]',
      ).styles(
        raw: {
          'animation':
              'nakiScrimOut 120ms cubic-bezier(0.25, 0.3, 0.15, 1) both',
        },
      ),

      // content
      css('.naki-drawer-content').styles(raw: Css.nakiDrawerStyle['content']),

      // left drawer
      css('.drawer-left').styles(
        raw: {
          'left': '0',
          'padding-left': Css.safeAreaLeft,
          'width':
              'calc(${_var(Tokens.current.drawerWidth)} + '
              '${Css.safeAreaLeft})',
          'animation':
              'nakiDrawerSlideInLeft 210ms cubic-bezier(0.2, 0.05, 0.25, 1) both',
        },
      ),

      // left drawer exit
      css('.drawer-left[data-exiting="true"]').styles(
        raw: {
          'animation':
              'nakiDrawerSlideOutLeft 120ms cubic-bezier(0.25, 0.3, 0.15, 1) both',
        },
      ),

      // right drawer
      css('.drawer-right').styles(
        raw: {
          'right': '0',
          'padding-right': Css.safeAreaRight,
          'width':
              'calc(${_var(Tokens.current.drawerWidth)} + '
              '${Css.safeAreaRight})',
          'animation':
              'nakiDrawerSlideInRight 210ms cubic-bezier(0.2, 0.05, 0.25, 1) both',
        },
      ),

      // right drawer exit
      css('.drawer-right[data-exiting="true"]').styles(
        raw: {
          'animation':
              'nakiDrawerSlideOutRight 120ms cubic-bezier(0.25, 0.3, 0.15, 1) both',
        },
      ),
    ]),

    // prevent background body scrolling when drawer is open
    css(':root:has(.naki-drawer)', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
    ]),
  ];

  /// Sidebar rules
  static final nakiSidebarRules = [
    css('.naki-sidebar', [
      css('.naki-sidebar-content').styles(raw: Css.nakiSidebarStyle['content']),
    ]),
  ];

  /// BottomSheet rules
  ///
  /// Material 3 motion, from Compose's ModalBottomSheet: the sheet shows on the
  /// DefaultSpatial spring (210ms cubic-bezier(0.2, 0.05, 0.25, 1)) and hides
  /// on the FastEffects spring (120ms cubic-bezier(0.25, 0.3, 0.15, 1)), while
  /// the scrim fades on its own on the DefaultEffects spring
  /// (190ms cubic-bezier(0.25, 0.3, 0.15, 1)).
  static final nakiBottomSheetRules = [
    ..._scrimKeyframes,

    // slide up animation
    css.keyframes('nakiBottomSheetSlideUp', {
      'from': const Styles(raw: {'transform': 'translateY(100%)'}),
      'to': const Styles(raw: {'transform': 'translateY(0)'}),
    }),

    // slide down animation
    css.keyframes('nakiBottomSheetSlideDown', {
      'from': const Styles(raw: {'transform': 'translateY(0)'}),
      'to': const Styles(raw: {'transform': 'translateY(100%)'}),
    }),

    // main
    css('.naki-bottomsheet', [
      // backdrop
      css('&').styles(raw: Css.nakiBottomSheetStyle['backdrop']),

      // backdrop exit
      css(
        '&[data-exiting="true"]',
      ).styles(
        raw: {
          'animation':
              'nakiScrimOut 190ms cubic-bezier(0.25, 0.3, 0.15, 1) both',
        },
      ),

      // content
      css(
        '.naki-bottomsheet-content',
      ).styles(raw: Css.nakiBottomSheetStyle['container']),

      // content exit
      css('.naki-bottomsheet-content[data-exiting="true"]').styles(
        raw: {
          'animation':
              'nakiBottomSheetSlideDown 120ms cubic-bezier(0.25, 0.3, 0.15, 1) both',
        },
      ),

      // handle
      css(
        '.naki-bottomsheet-handle',
      ).styles(raw: Css.nakiBottomSheetStyle['handle']),
    ]),

    // prevent background body scrolling when bottom sheet is open
    css(':root:has(.naki-bottomsheet)', [
      css('&').styles(raw: Css.nakiBackgroundLockStyle),
    ]),
  ];
}
