import 'package:jaspr/dom.dart';

import '../../theme.dart' show LightThemeData, NakiThemeProvider;
import '../styles/css.dart';

/// Represents an individual design token consisting of a fallback CSS value
/// and its corresponding CSS variable name (e.g. `--naki-green`).
class Token {
  /// The default fallback value of this token (e.g. `#15803d` or `12px`).
  final String value;

  /// The CSS variable name (e.g. `--naki-green`).
  final String name;

  /// The typed [Color] representation of this token if it represents
  /// a color variable, or `null` for non-color design tokens.
  final Color? color;

  /// Creates a constant [Token] definition.
  const Token({
    required this.value,
    required this.name,
    this.color,
  });

  /// Returns the CSS variable name, allowing the token to
  /// be interpolated directly.
  ///
  /// Example:
  /// ```dart
  /// final color = 'var(${Tokens.current.green})'; // var(--naki-green)
  /// ```
  @override
  String toString() => name;
}

/// Abstract base class for Naki Design System tokens and
/// theme mode token collections.
///
/// Subclasses (e.g. `LightModeTokens`, `DarkModeTokens`) can
/// extend [Tokens] and override color-related token variables to
/// customize themes.
abstract class Tokens {
  /// Default tokens used for CSS variable names and fallback values.
  ///
  /// Active theme values are request-local and available from
  /// [NakiThemeProvider.tokensOf] or `context.themeTokens`.
  static const Tokens current = LightThemeData();

  /// User-defined style properties applied on top of [current] theme
  /// tokens when [variables] is called.
  ///
  /// Set by [NakiThemeProvider] when `additionalStyles` is provided.
  /// Entries override matching token variables. Set to `null`
  /// to clear custom styles.
  final Map<String, String>? customVariables;

  /// Base const constructor for token collections.
  const Tokens([this.customVariables]);

  /// The color scheme of the current theme mode.
  String get colorScheme;

  // ===========================================================================
  // Base Color Tokens
  // ===========================================================================

  /// Default value for [green].
  String get greenValue => '#15803d';

  /// Green accent color (default: `#15803d`, CSS variable: `--naki-green`).
  Token get green => Token(
    value: greenValue,
    name: '--naki-green',
    color: const Color('var(--naki-green)'),
  );

  /// Default value for [yellow].
  String get yellowValue => '#a16207';

  /// Yellow accent color (default: `#a16207`, CSS variable: `--naki-yellow`).
  Token get yellow => Token(
    value: yellowValue,
    name: '--naki-yellow',
    color: const Color('var(--naki-yellow)'),
  );

  /// Default value for [red].
  String get redValue => '#F44336';

  /// Red accent/danger color (default: `#F44336`, CSS variable: `--naki-red`).
  Token get red => Token(
    value: redValue,
    name: '--naki-red',
    color: const Color('var(--naki-red)'),
  );

  /// Default value for [primaryColor].
  String get primaryColorValue => '#3182ce';

  /// Primary color
  /// (default: `#3182ce`, CSS variable: `--naki-primary-color`).
  Token get primaryColor => Token(
    value: primaryColorValue,
    name: '--naki-primary-color',
    color: const Color('var(--naki-primary-color)'),
  );

  /// Default value for [secondaryColor]
  String get secondaryColorValue => '#64748b';

  /// Secondary color
  /// (default: `#64748b`, CSS variable: `--naki-secondary-color`).
  Token get secondaryColor => Token(
    value: secondaryColorValue,
    name: '--naki-secondary-color',
    color: const Color('var(--naki-secondary-color)'),
  );

  /// Default value for [accentColor]
  String get accentColorValue => '#059669';

  /// Accent color
  /// (default: `#059669`, CSS variable: `--naki-accent-color`).
  Token get accentColor => Token(
    value: accentColorValue,
    name: '--naki-accent-color',
    color: const Color('var(--naki-accent-color)'),
  );

  /// Default value for [placeholderColor].
  String get placeholderColorValue => '#64748b';

  /// Default text placeholder color
  /// (default: `#64748b`, CSS variable: `--naki-placeholder-color`).
  Token get placeholderColor => Token(
    value: placeholderColorValue,
    name: '--naki-placeholder-color',
    color: const Color('var(--naki-placeholder-color)'),
  );

  /// Default value for [mutedColor].
  String get mutedColorValue => '#3d4044';

  /// Muted background/foreground color
  /// (default: `#3d4044`, CSS variable: `--naki-muted-color`).
  Token get mutedColor => Token(
    value: mutedColorValue,
    name: '--naki-muted-color',
    color: const Color('var(--naki-muted-color)'),
  );

  /// Default value for [subtitleColor].
  String get subtitleColorValue => '#64748b';

  /// Subtitle or secondary text color
  /// (default: `#64748b`, CSS variable: `--naki-subtitle-color`).
  Token get subtitleColor => Token(
    value: subtitleColorValue,
    name: '--naki-subtitle-color',
    color: const Color('var(--naki-subtitle-color)'),
  );

  /// Default value for [selectedItemColor].
  String get selectedItemColorValue => '#ffffff';

  /// Selected item color for dropdowns and list items
  /// (default: `#ffffff`, CSS variable: `--naki-selected-item-color`).
  Token get selectedItemColor => Token(
    value: selectedItemColorValue,
    name: '--naki-selected-item-color',
    color: const Color('var(--naki-selected-item-color)'),
  );

  /// Default value for [selectedTextBgColor].
  String get selectedTextBgColorValue => '#2563eb';

  /// Selected text background color
  /// (default: `#2563eb`,
  /// CSS variable: `--naki-selected-text-background-color`).
  Token get selectedTextBgColor => Token(
    value: selectedTextBgColorValue,
    name: '--naki-selected-text-background-color',
    color: const Color(
      'var(--naki-selected-text-background-color)',
    ),
  );

  /// Default value for [selectedTextColor].
  String get selectedTextColorValue => '#ffffff';

  /// Selected text color
  /// (default: `#ffffff`, CSS variable: `--naki-selected-text-color`).
  Token get selectedTextColor => Token(
    value: selectedTextColorValue,
    name: '--naki-selected-text-color',
    color: const Color('var(--naki-selected-text-color)'),
  );

  /// Default value for [selectedItemBgColor].
  String get selectedItemBgColorValue => '#2563eb';

  /// Selected item background color for dropdowns and list items
  /// (default: `#2563eb`, CSS variable: `--naki-selected-item-bg-color`).
  Token get selectedItemBgColor => Token(
    value: selectedItemBgColorValue,
    name: '--naki-selected-item-bg-color',
    color: const Color('var(--naki-selected-item-bg-color)'),
  );

  /// Default value for [backgroundColor].
  String get backgroundColorValue => '#ffffff';

  /// Root background color (default: `#ffffff`,
  /// CSS variable: `--naki-bg-color`).
  Token get backgroundColor => Token(
    value: backgroundColorValue,
    name: '--naki-bg-color',
    color: const Color('var(--naki-bg-color)'),
  );

  /// Default value for [borderColor].
  String get borderColorValue => '#64748b';

  /// Default border color (default: `#64748b`,
  /// CSS variable: `--naki-border-color`).
  Token get borderColor => Token(
    value: borderColorValue,
    name: '--naki-border-color',
    color: const Color('var(--naki-border-color)'),
  );

  /// Default value for [errorColor].
  String get errorColorValue => '#e11d48';

  /// Error state color (default: `#e11d48`,
  /// CSS variable: `--naki-error-color`).
  Token get errorColor => Token(
    value: errorColorValue,
    name: '--naki-error-color',
    color: const Color('var(--naki-error-color)'),
  );

  /// Default value for [successColor].
  String get successColorValue => '#15803d';

  /// Success state color (default: `#15803d`,
  /// CSS variable: `--naki-success-color`).
  Token get successColor => Token(
    value: successColorValue,
    name: '--naki-success-color',
    color: const Color('var(--naki-success-color)'),
  );

  /// Default value for [warningColor].
  String get warningColorValue => '#b45309';

  /// Warning state color (default: `#b45309`,
  /// CSS variable: `--naki-warning-color`).
  Token get warningColor => Token(
    value: warningColorValue,
    name: '--naki-warning-color',
    color: const Color('var(--naki-warning-color)'),
  );

  /// Default value for [infoColor].
  String get infoColorValue => '#1976d2';

  /// Info state color (default: `#1976d2`, CSS variable: `--naki-info-color`).
  Token get infoColor => Token(
    value: infoColorValue,
    name: '--naki-info-color',
    color: const Color('var(--naki-info-color)'),
  );

  /// Default value for [errorWeakColor].
  String get errorWeakColorValue => '#ffe8ee';

  /// Weak background color for error/alert callouts (default: `#ffe8ee`,
  /// CSS variable: `--naki-error-weak-color`).
  Token get errorWeakColor => Token(
    value: errorWeakColorValue,
    name: '--naki-error-weak-color',
    color: const Color('var(--naki-error-weak-color)'),
  );

  /// Default value for [successWeakColor].
  String get successWeakColorValue => '#e8f5e9';

  /// Weak background color for success callouts (default: `#e8f5e9`,
  /// CSS variable: `--naki-success-weak-color`).
  Token get successWeakColor => Token(
    value: successWeakColorValue,
    name: '--naki-success-weak-color',
    color: const Color('var(--naki-success-weak-color)'),
  );

  /// Default value for [warningWeakColor].
  String get warningWeakColorValue => '#fff4e5';

  /// Weak background color for warning callouts (default: `#fff4e5`,
  /// CSS variable: `--naki-warning-weak-color`).
  Token get warningWeakColor => Token(
    value: warningWeakColorValue,
    name: '--naki-warning-weak-color',
    color: const Color('var(--naki-warning-weak-color)'),
  );

  /// Default value for [infoWeakColor].
  String get infoWeakColorValue => '#e7f4ff';

  /// Weak background color for info callouts (default: `#e7f4ff`,
  /// CSS variable: `--naki-info-weak-color`).
  Token get infoWeakColor => Token(
    value: infoWeakColorValue,
    name: '--naki-info-weak-color',
    color: const Color('var(--naki-info-weak-color)'),
  );

  /// Default value for [surfaceVariantColor].
  String get surfaceVariantColorValue => '#e2e8f0';

  /// Secondary surface background color variation (default: `#e2e8f0`,
  /// CSS variable: `--naki-surface-variant-color`).
  Token get surfaceVariantColor => Token(
    value: surfaceVariantColorValue,
    name: '--naki-surface-variant-color',
    color: const Color('var(--naki-surface-variant-color)'),
  );

  /// Default value for [surfaceMutedColor].
  String get surfaceMutedColorValue => '#eaeaea';

  /// Muted background color for container surfaces (default: `#f8fafc`,
  /// CSS variable: `--naki-surface-muted-color`).
  Token get surfaceMutedColor => Token(
    value: surfaceMutedColorValue,
    name: '--naki-surface-muted-color',
    color: const Color('var(--naki-surface-muted-color)'),
  );

  // ===========================================================================
  // Shadow Color Tokens
  // ===========================================================================

  /// Default value for [shadowColor].
  String get shadowColorValue => 'rgba(0, 0, 0, 0.1)';

  /// Default shadow color overlay (default: `rgba(0, 0, 0, 0.1)`,
  /// CSS variable: `--naki-shadow-color`).
  Token get shadowColor => Token(
    value: shadowColorValue,
    name: '--naki-shadow-color',
    color: const Color('var(--naki-shadow-color)'),
  );

  /// Default value for [smallShadowColor].
  String get smallShadowColorValue => 'rgba(15, 23, 42, 0.02)';

  /// Small shadow color overlay (default: `rgba(15, 23, 42, 0.02)`,
  /// CSS variable: `--naki-small-shadow-color`).
  Token get smallShadowColor => Token(
    value: smallShadowColorValue,
    name: '--naki-small-shadow-color',
    color: const Color('var(--naki-small-shadow-color)'),
  );

  /// Default value for [mediumShadowColor].
  String get mediumShadowColorValue => 'rgba(15, 23, 42, 0.08)';

  /// Medium shadow color overlay (default: `rgba(15, 23, 42, 0.08)`,
  /// CSS variable: `--naki-medium-shadow-color`).
  Token get mediumShadowColor => Token(
    value: mediumShadowColorValue,
    name: '--naki-medium-shadow-color',
    color: const Color('var(--naki-medium-shadow-color)'),
  );

  /// Default value for [largeShadowColor].
  String get largeShadowColorValue => 'rgba(15, 23, 42, 0.12)';

  /// Large shadow color overlay (default: `rgba(15, 23, 42, 0.12)`,
  /// CSS variable: `--naki-large-shadow-color`).
  Token get largeShadowColor => Token(
    value: largeShadowColorValue,
    name: '--naki-large-shadow-color',
    color: const Color('var(--naki-large-shadow-color)'),
  );

  // ===========================================================================
  // State Color Tokens
  // ===========================================================================

  /// Default value for [buttonHoverBgColor].
  String get buttonHoverBgColorValue => '#e2e8f0';

  /// Hover background color for buttons (default: `#e2e8f0`,
  /// CSS variable: `--naki-button-hover-bg-color`).
  Token get buttonHoverBgColor => Token(
    value: buttonHoverBgColorValue,
    name: '--naki-button-hover-bg-color',
    color: const Color('var(--naki-button-hover-bg-color)'),
  );

  /// Default value for [hoverColor]
  String get hoverColorValue => '#64748b';

  /// Color for hovered components (default: `#64748b`,
  /// CSS variable: `--naki-hover-color`).
  Token get hoverColor => Token(
    value: hoverColorValue,
    name: '--naki-hover-color',
    color: const Color('var(--naki-hover-color)'),
  );

  /// Default value for [focusBorderColor].
  String get focusBorderColorValue => '#2563eb';

  /// Border color for focused components (default: `#2563eb`,
  /// CSS variable: `--naki-focus-border-color`).
  Token get focusBorderColor => Token(
    value: focusBorderColorValue,
    name: '--naki-focus-border-color',
    color: const Color('var(--naki-focus-border-color)'),
  );

  /// Default value for [fieldHoverColor].
  String get fieldHoverColorValue => '#64748b';

  /// Color for hovered form fields (default: `#64748b`,
  /// CSS variable: `--naki-field-hover-color`).
  Token get fieldHoverColor => Token(
    value: fieldHoverColorValue,
    name: '--naki-field-hover-color',
    color: const Color('var(--naki-field-hover-color)'),
  );

  /// Default value for [disabledBgColor].
  String get disabledBgColorValue => '#e2e8f0';

  /// Background color for disabled components (default: `#e2e8f0`,
  /// CSS variable: `--naki-disabled-bg-color`).
  Token get disabledBgColor => Token(
    value: disabledBgColorValue,
    name: '--naki-disabled-bg-color',
    color: const Color('var(--naki-disabled-bg-color)'),
  );

  /// Default value for [disabledColor].
  String get disabledColorValue => '#64748b';

  /// Color for disabled components (default: `#64748b`,
  /// CSS variable: `--naki-disabled-color`).
  Token get disabledColor => Token(
    value: disabledColorValue,
    name: '--naki-disabled-color',
    color: const Color('var(--naki-disabled-color)'),
  );

  // ===========================================================================
  // Border Tokens
  // ===========================================================================

  /// Default border styling (default: `1px solid var(--naki-border-color)`,
  /// CSS variable: `--naki-border`).
  Token get border => Token(
    value: '1px solid var(${borderColor.name}, ${borderColor.value})',
    name: '--naki-border',
  );

  /// Input hover border styling
  /// (default: `1px solid var(--naki-field-hover-color)`,
  /// CSS variable: `--naki-field-hover-border`).
  Token get fieldHoverBorder => Token(
    value: '1px solid var(${fieldHoverColor.name}, ${fieldHoverColor.value})',
    name: '--naki-field-hover-border',
  );

  /// Input focus border styling
  /// (default: `1px solid var(--naki-focus-border-color)`,
  /// CSS variable: `--naki-focus-border`).
  Token get focusBorder => Token(
    value: '1px solid var(${focusBorderColor.name}, ${focusBorderColor.value})',
    name: '--naki-focus-border',
  );

  /// Input error border styling
  /// (default: `1px solid var(--naki-error-color)`,
  /// CSS variable: `--naki-error-border`).
  Token get errorBorder => Token(
    value: '1px solid var(${errorColor.name}, ${errorColor.value})',
    name: '--naki-error-border',
  );

  // ===========================================================================
  // Typography Tokens
  // ===========================================================================

  /// Default font family family stack
  /// (default: `helvetica`, CSS variable: `--naki-font-family`).
  Token get fontFamily => const Token(
    value: 'helvetica',
    name: '--naki-font-family',
  );

  /// Small font size (default: `12px`, CSS variable: `--naki-font-size-sm`).
  Token get fontSizeSm => const Token(
    value: '12px',
    name: '--naki-font-size-sm',
  );

  /// Medium font size (default: `14px`, CSS variable: `--naki-font-size-md`).
  Token get fontSizeMd => const Token(
    value: '14px',
    name: '--naki-font-size-md',
  );

  /// Large font size (default: `16px`, CSS variable: `--naki-font-size-lg`).
  Token get fontSizeLg => const Token(
    value: '16px',
    name: '--naki-font-size-lg',
  );

  /// Extra large font size (default: `18px`,
  /// CSS variable: `--naki-font-size-xl`).
  Token get fontSizeXl => const Token(
    value: '18px',
    name: '--naki-font-size-xl',
  );

  /// 2X large title font size (default: `20px`,
  /// CSS variable: `--naki-font-size-2xl`).
  Token get fontSize2xl => const Token(
    value: '20px',
    name: '--naki-font-size-2xl',
  );

  /// 3X large title font size (default: `24px`,
  /// CSS variable: `--naki-font-size-3xl`).
  Token get fontSize3xl => const Token(
    value: '24px',
    name: '--naki-font-size-3xl',
  );

  /// 4X large title font size (default: `28px`,
  /// CSS variable: `--naki-font-size-4xl`).
  Token get fontSize4xl => const Token(
    value: '28px',
    name: '--naki-font-size-4xl',
  );

  /// 5X large title font size (default: `32px`,
  /// CSS variable: `--naki-font-size-5xl`).
  Token get fontSize5xl => const Token(
    value: '32px',
    name: '--naki-font-size-5xl',
  );

  /// Section header font size (default: `15px`,
  /// CSS variable: `--naki-font-size-section-header`).
  Token get fontSizeSectionHeader => const Token(
    value: '15px',
    name: '--naki-font-size-section-header',
  );

  /// Default input text font size
  /// (default: `14px`, CSS variable: `--naki-font-size-input`).
  Token get fontSizeInput => const Token(
    value: '14px',
    name: '--naki-font-size-input',
  );

  /// Default validation error text font size
  /// (default: `12px`, CSS variable: `--naki-font-size-error`).
  Token get fontSizeError => const Token(
    value: '12px',
    name: '--naki-font-size-error',
  );

  /// Default helper/hint text font size
  /// (default: `12px`, CSS variable: `--naki-font-size-hint`).
  Token get fontSizeHint => const Token(
    value: '12px',
    name: '--naki-font-size-hint',
  );

  /// Default label text font size
  /// (default: `15px`, CSS variable: `--naki-font-size-label`).
  Token get fontSizeLabel => const Token(
    value: '15px',
    name: '--naki-font-size-label',
  );

  /// Font size for dropdown option label
  /// (default: `14px`, CSS variable: `--naki-font-size-dropdown-option`).
  Token get fontSizeDropdownOption => const Token(
    value: '14px',
    name: '--naki-font-size-dropdown-option',
  );

  // ===========================================================================
  // Font Weight Tokens
  // ===========================================================================

  /// Normal font weight (default: `400`,
  /// CSS variable: `--naki-font-weight-normal`).
  Token get fontWeightNormal => const Token(
    value: '400',
    name: '--naki-font-weight-normal',
  );

  /// Medium font weight (default: `500`,
  /// CSS variable: `--naki-font-weight-medium`).
  Token get fontWeightMedium => const Token(
    value: '500',
    name: '--naki-font-weight-medium',
  );

  /// Semi-bold font weight (default: `600`,
  /// CSS variable: `--naki-font-weight-semibold`).
  Token get fontWeightSemiBold => const Token(
    value: '600',
    name: '--naki-font-weight-semibold',
  );

  /// Bold font weight
  /// (default: `700`, CSS variable: `--naki-font-weight-bold`).
  Token get fontWeightBold => const Token(
    value: '700',
    name: '--naki-font-weight-bold',
  );

  /// Font weight for section headers (default: `600`,
  /// CSS variable: `--naki-font-weight-section-header`).
  Token get fontWeightSectionHeader => const Token(
    value: '600',
    name: '--naki-font-weight-section-header',
  );

  // ===========================================================================
  // Spinner Tokens
  // ===========================================================================

  /// Default spinner size (default: `24px`,
  /// CSS variable: `--naki-spinner-size`).
  Token get spinnerSize => const Token(
    value: '24px',
    name: '--naki-spinner-size',
  );

  /// Default spinner border width (default: `2px`,
  /// CSS variable: `--naki-spinner-border-width`).
  Token get spinnerBorderWidth => const Token(
    value: '2px',
    name: '--naki-spinner-border-width',
  );

  /// Default value for [spinnerTrackColor].
  String get spinnerTrackColorValue => 'rgba(0, 0, 0, 0.15)';

  /// Default spinner track color
  /// (default: `rgba(0, 0, 0, 0.15)`,
  /// CSS variable: `--naki-spinner-track-color`).
  Token get spinnerTrackColor => Token(
    value: spinnerTrackColorValue,
    name: '--naki-spinner-track-color',
    color: const Color('var(--naki-spinner-track-color)'),
  );

  /// Default spinner color (default: `currentcolor`,
  /// CSS variable: `--naki-spinner-color`).
  Token get spinnerColor => const Token(
    value: 'currentcolor',
    name: '--naki-spinner-color',
    color: Color('var(--naki-spinner-color)'),
  );

  /// Default ios spinner blade color
  /// (default: `#8e8e93`,
  /// CSS variable: `--naki-spinner-blade-color`).
  Token get spinnerBladeColor => const Token(
    value: '#8e8e93',
    name: '--naki-spinner-blade-color',
    color: Color('var(--naki-spinner-blade-color)'),
  );

  /// Default spinner border
  /// (default: `var(--naki-spinner-border-width)
  /// solid var(--naki-spinner-track-color)`,
  /// CSS variable: `--naki-spinner-border`).
  Token get spinnerBorder => Token(
    value:
        'var(${spinnerBorderWidth.name}, ${spinnerBorderWidth.value}) solid var(${spinnerTrackColor.name}, ${spinnerTrackColor.value})',
    name: '--naki-spinner-border',
  );

  /// Default value for [spinnerSurfaceColor].
  String get spinnerSurfaceColorValue => surfaceVariantColorValue;

  /// Default spinner surface color
  /// (default: `var(--naki-surface-variant-color)`,
  /// CSS variable: `--naki-spinner-surface-color`).
  Token get spinnerSurfaceColor => Token(
    value: spinnerSurfaceColorValue,
    name: '--naki-spinner-surface-color',
    color: const Color('var(--naki-spinner-surface-color)'),
  );

  // ===========================================================================
  // Spacing Tokens
  // ===========================================================================

  /// Small padding/margin spacer (default: `12px`,
  /// CSS variable: `--naki-padding-sm`).
  Token get paddingSm => const Token(value: '12px', name: '--naki-padding-sm');

  /// Medium padding/margin spacer (default: `20px`,
  /// CSS variable: `--naki-padding-md`).
  Token get paddingMd => const Token(value: '20px', name: '--naki-padding-md');

  /// Large padding/margin spacer (default: `40px`,
  /// CSS variable: `--naki-padding-lg`).
  Token get paddingLg => const Token(value: '40px', name: '--naki-padding-lg');

  /// Small margin spacer (default: `12px`,
  /// CSS variable: `--naki-margin-sm`).
  Token get marginSm => const Token(value: '12px', name: '--naki-margin-sm');

  /// Medium margin spacer (default: `20px`,
  /// CSS variable: `--naki-margin-md`).
  Token get marginMd => const Token(value: '20px', name: '--naki-margin-md');

  /// Large margin spacer (default: `40px`,
  /// CSS variable: `--naki-margin-lg`).
  Token get marginLg => const Token(value: '40px', name: '--naki-margin-lg');

  // ===========================================================================
  // Shadow Tokens
  // ===========================================================================

  /// Default elevation box shadow rule
  /// (default: `0px 0px 3px 0px var(--naki-shadow-color)`,
  /// CSS variable: `--naki-box-shadow`).
  Token get boxShadow => Token(
    value: '0px 0px 3px 0px var(${shadowColor.name}, ${shadowColor.value})',
    name: '--naki-box-shadow',
  );

  /// Small elevation shadow rule
  /// (default: `0 0 5px var(--naki-small-shadow-color)`,
  /// CSS variable: `--naki-small-shadow`).
  Token get smallShadow => Token(
    value: '0 0 5px var(${smallShadowColor.name}, ${smallShadowColor.value})',
    name: '--naki-small-shadow',
  );

  /// Medium elevation shadow rule
  /// (default: `0 10px 24px var(--naki-medium-shadow-color)`,
  /// CSS variable: `--naki-medium-shadow`).
  Token get mediumShadow => Token(
    value: '0 10px 24px var(${mediumShadowColor.name}, ${mediumShadowColor.value})',
    name: '--naki-medium-shadow',
  );

  /// Large elevation shadow rule
  /// (default: `0 16px 36px var(--naki-large-shadow-color)`,
  /// CSS variable: `--naki-large-shadow`).
  Token get largeShadow => Token(
    value: '0 16px 36px var(${largeShadowColor.name}, ${largeShadowColor.value})',
    name: '--naki-large-shadow',
  );

  // ===========================================================================
  // Border Radius Tokens
  // ===========================================================================

  /// Small border radius (default: `6px`, CSS variable: `--naki-radius-sm`).
  Token get radiusSm => const Token(value: '6px', name: '--naki-radius-sm');

  /// Medium border radius (default: `12px`, CSS variable: `--naki-radius-md`).
  Token get radiusMd => const Token(value: '12px', name: '--naki-radius-md');

  /// Large border radius (default: `24px`, CSS variable: `--naki-radius-lg`).
  Token get radiusLg => const Token(value: '24px', name: '--naki-radius-lg');

  // ===========================================================================
  // Component Tokens
  // ===========================================================================

  /// Text maximum lines (default: `1`,
  /// CSS variable: `--naki-text-max-lines`).
  Token get textMaxLines => const Token(
    value: '1',
    name: '--naki-text-max-lines',
  );

  /// Default form field / input element height
  /// (default: `45px`, CSS variable: `--naki-input-height`).
  Token get inputHeight => const Token(
    value: '45px',
    name: '--naki-input-height',
  );

  /// Default dropdown trigger container height
  /// (default: `45px`, CSS variable: `--naki-dropdown-height`).
  Token get dropdownHeight => const Token(
    value: '45px',
    name: '--naki-dropdown-height',
  );

  /// Default dropdown trigger container width
  /// (default: `100%`, CSS variable: `--naki-dropdown-width`).
  Token get dropdownWidth => const Token(
    value: '100%',
    name: '--naki-dropdown-width',
  );

  /// Default height for dropdown menu
  /// (default: `200px`, CSS variable: `--naki-dropdown-menu-height`).
  Token get dropdownMenuHeight => const Token(
    value: '200px',
    name: '--naki-dropdown-menu-height',
  );

  /// Default value for [dropdownMenuBgColor].
  String get dropdownMenuBgColorValue => '#ffffff';

  /// Background color for dropdown menu
  /// (default: `#ffffff`, CSS variable: `--naki-dropdown-menu-bg-color`).
  Token get dropdownMenuBgColor => Token(
    value: dropdownMenuBgColorValue,
    name: '--naki-dropdown-menu-bg-color',
    color: const Color('var(--naki-dropdown-menu-bg-color)'),
  );

  /// Font size of dropdown menu options
  /// (default: `14px`, CSS variable: `--naki-dropdown-option-font-size`).
  Token get dropdownOptionFontSize => const Token(
    value: '14px',
    name: '--naki-dropdown-option-font-size',
  );

  /// Padding for dropdown options
  /// (default: `10px`, CSS variable: `--naki-dropdown-option-padding`).
  Token get dropdownOptionPadding => const Token(
    value: '10px',
    name: '--naki-dropdown-option-padding',
  );

  /// Default value for [inputTextColor].
  String get inputTextColorValue => '#000000';

  /// Text color inside input fields
  /// (default: `#000000`, CSS variable: `--naki-input-text-color`).
  Token get inputTextColor => Token(
    value: inputTextColorValue,
    name: '--naki-input-text-color',
    color: const Color('var(--naki-input-text-color)'),
  );

  /// Default value for [labelColor].
  String get labelColorValue => '#666666';

  /// Form field label color
  /// (default: `#666666`, CSS variable: `--naki-label-color`).
  Token get labelColor => Token(
    value: labelColorValue,
    name: '--naki-label-color',
    color: const Color('var(--naki-label-color)'),
  );

  /// Default value for [baseTextColor].
  String get baseTextColorValue => '#0f172a';

  /// Base text color
  /// (default: `#0f172a`, CSS variable: `--naki-base-text-color`).
  Token get baseTextColor => Token(
    value: baseTextColorValue,
    name: '--naki-base-text-color',
    color: const Color('var(--naki-base-text-color)'),
  );

  /// Default value for [buttonBackgroundColor].
  String get buttonBackgroundColorValue => '#e5e7f0';

  /// Button background color
  /// (default: `#e5e7f0`, CSS variable: `--naki-button-bg-color`).
  Token get buttonBackgroundColor => Token(
    value: buttonBackgroundColorValue,
    name: '--naki-button-bg-color',
    color: const Color('var(--naki-button-bg-color)'),
  );

  /// Default value for [buttonColor].
  String get buttonColorValue => '#000000';

  /// Button foreground color
  /// (default: `#000000`, CSS variable: `--naki-button-color`).
  Token get buttonColor => Token(
    value: buttonColorValue,
    name: '--naki-button-color',
    color: const Color('var(--naki-button-color)'),
  );

  // ///////////////////////////////////////////////////////////////////////////
  // BUTTON TOKENS
  // ///////////////////////////////////////////////////////////////////////////

  /// Button height
  /// (default: `auto`, CSS variable: `--naki-button-height`).
  Token get buttonHeight => const Token(
    value: 'auto',
    name: '--naki-button-height',
  );

  /// Button width
  /// (default: `auto`, CSS variable: `--naki-button-width`).
  Token get buttonWidth => const Token(
    value: 'auto',
    name: '--naki-button-width',
  );

  /// Default value for [fieldBackgroundColor].
  String get fieldBackgroundColorValue => '#ffffff';

  /// Form field background color
  /// (default: `#ffffff`, CSS variable: `--naki-field-bg-color`).
  Token get fieldBackgroundColor => Token(
    value: fieldBackgroundColorValue,
    name: '--naki-field-bg-color',
    color: const Color('var(--naki-field-bg-color)'),
  );

  /// Default value for [sliderThumbColor].
  String get sliderThumbColorValue => 'currentcolor';

  /// Slider thumb color
  /// (default: `currentcolor`,
  /// CSS variable: `--naki-slider-thumb-color`).
  Token get sliderThumbColor => Token(
    value: sliderThumbColorValue,
    name: '--naki-slider-thumb-color',
    color: const Color('var(--naki-slider-thumb-color)'),
  );

  /// Default value for [sliderTrackColor].
  String get sliderTrackColorValue => Css.applyOpacity(const Color('currentcolor'), 70).value;

  /// Slider track color
  /// (default: `70% of current color`,
  /// CSS variable: `--naki-slider-track-color`).
  Token get sliderTrackColor => Token(
    value: sliderTrackColorValue,
    name: '--naki-slider-track-color',
    color: const Color('var(--naki-slider-track-color)'),
  );

  /// Slider thumb size
  /// (default: `24px`, CSS variable: `--naki-slider-thumb-size`).
  Token get sliderThumbSize => const Token(
    value: '24px',
    name: '--naki-slider-thumb-size',
  );

  /// Default value for [switchThumbColor].
  String get switchThumbColorValue => 'currentcolor';

  /// Switch thumb color
  /// (default: `currentcolor`, CSS variable: `--naki-switch-thumb-color`).
  Token get switchThumbColor => Token(
    value: switchThumbColorValue,
    name: '--naki-switch-thumb-color',
    color: const Color('var(--naki-switch-thumb-color)'),
  );

  /// Radio button radius
  /// (default: `24px`, CSS variable: `--naki-radio-btn-radius`).
  Token get radioBtnRadius => const Token(
    value: '24px',
    name: '--naki-radio-btn-radius',
  );

  /// Default value for [radioBtnColor].
  String get radioBtnColorValue => 'currentcolor';

  /// Radio button color
  /// (default: `currentcolor`, CSS variable: `--naki-radio-btn-color`).
  Token get radioBtnColor => Token(
    value: radioBtnColorValue,
    name: '--naki-radio-btn-color',
    color: const Color('var(--naki-radio-btn-color)'),
  );

  /// Default value for [appbarBgColor].
  String get appbarBgColorValue => '#f5f5f5';

  /// Appbar background color (default: `#f5f5f5`,
  /// CSS variable: `--naki-appbar-bg-color`).
  Token get appbarBgColor => Token(
    value: appbarBgColorValue,
    name: '--naki-appbar-bg-color',
    color: const Color('var(--naki-appbar-bg-color)'),
  );

  /// Default appbar height
  /// (default: `56px`, CSS variable: `--naki-appbar-height`).
  Token get appbarHeight => const Token(
    value: '56px',
    name: '--naki-appbar-height',
  );

  /// Default value for [bottomNavbarBgColor]
  String get bottomNavbarBgColorValue => '#f5f5f5';

  /// Bottom navbar background color (default: `#f5f5f5`,
  /// CSS variable: `--naki-bottom-navbar-bg-color`).
  Token get bottomNavbarBgColor => Token(
    value: bottomNavbarBgColorValue,
    name: '--naki-bottom-navbar-bg-color',
    color: const Color('var(--naki-bottom-navbar-bg-color)'),
  );

  /// Default bottom navbar height
  /// (default: `64px`, CSS variable: `--naki-bottom-navbar-height`).
  Token get bottomNavbarHeight => const Token(
    value: '64px',
    name: '--naki-bottom-navbar-height',
  );

  // ===========================================================================
  // Scrolling Component Tokens
  // ===========================================================================

  /// Carousel item extent (default: `280px`,
  /// CSS variable: `--naki-carousel-item-extent`).
  Token get carouselItemExtent => const Token(
    value: '280px',
    name: '--naki-carousel-item-extent',
  );

  /// Carousel gap (default: `0px`, CSS variable: `--naki-carousel-gap`).
  Token get carouselGap => const Token(
    value: '0px',
    name: '--naki-carousel-gap',
  );

  /// Default value for [tableHeaderBg].
  String get tableHeaderBgValue => 'transparent';

  /// Table header background color (default: `transparent`,
  /// CSS variable: `--naki-table-header-bg`).
  Token get tableHeaderBg => Token(
    value: tableHeaderBgValue,
    name: '--naki-table-header-bg',
    color: const Color('var(--naki-table-header-bg)'),
  );

  /// Default value for [tableHeaderBorderColor]
  String get tableHeaderBorderColorValue => '#64748b';

  /// Table header border color (default: `"#64748b"`,
  /// CSS variable: `--naki-table-header-border-color`).
  Token get tableHeaderBorderColor => Token(
    value: tableHeaderBorderColorValue,
    name: '--naki-table-header-border-color',
    color: const Color('var(--naki-table-header-border-color)'),
  );

  /// Default value for [tableRowHoverBg].
  String get tableRowHoverBgValue => 'transparent';

  /// Table row hover background color (default: `transparent`,
  /// CSS variable: `--naki-table-row-hover-bg`).
  Token get tableRowHoverBg => Token(
    value: tableRowHoverBgValue,
    name: '--naki-table-row-hover-bg',
    color: const Color('var(--naki-table-row-hover-bg)'),
  );

  /// Grid gap (default: `16px`, CSS variable: `--naki-grid-gap`).
  Token get gridGap => const Token(value: '16px', name: '--naki-grid-gap');

  // ===========================================================================
  // Overlay Component Tokens
  // ===========================================================================

  /// Default value for [snackbarBgColor].
  String get snackbarBgColorValue => '#323232';

  /// Snackbar background color
  /// (default: `#323232`, CSS variable: `--naki-snackbar-bg`).
  Token get snackbarBgColor => Token(
    value: snackbarBgColorValue,
    name: '--naki-snackbar-bg',
    color: const Color('var(--naki-snackbar-bg)'),
  );

  /// Default value for [snackbarForegroundColor].
  String get snackbarForegroundColorValue => '#ffffff';

  /// Snackbar foreground color
  /// (default: `#ffffff`, CSS variable: `--naki-snackbar-foreground-color`).
  Token get snackbarForegroundColor => Token(
    value: snackbarForegroundColorValue,
    name: '--naki-snackbar-foreground-color',
    color: const Color('var(--naki-snackbar-foreground-color)'),
  );

  /// Snackbar border radius
  /// (default: `12px`, CSS variable: `--naki-snackbar-border-radius`).
  Token get snackbarBorderRadius => const Token(
    value: '12px',
    name: '--naki-snackbar-border-radius',
  );

  /// Snackbar padding
  /// (default: `10px`, CSS variable: `--naki-snackbar-padding`).
  Token get snackbarPadding => const Token(
    value: '10px',
    name: '--naki-snackbar-padding',
  );

  /// Snackbar vertical offset
  /// (default: `10px`, CSS variable: `--naki-snackbar-offset-y`).
  Token get snackbarOffset => const Token(
    value: '10px',
    name: '--naki-snackbar-offset-y',
  );

  /// Default value for [bannerBgColor].
  String get bannerBgColorValue => '#f8fafc';

  /// Banner background color
  /// (default: `#f8fafc`, CSS variable: `--naki-banner-bg`).
  Token get bannerBgColor => Token(
    value: bannerBgColorValue,
    name: '--naki-banner-bg',
    color: const Color('var(--naki-banner-bg)'),
  );

  /// Default value for [bannerForegroundColor].
  String get bannerForegroundColorValue => '#0f172a';

  /// Banner foreground color
  /// (default: `#0f172a`, CSS variable: `--naki-banner-foreground-color`).
  Token get bannerForegroundColor => Token(
    value: bannerForegroundColorValue,
    name: '--naki-banner-foreground-color',
    color: const Color('var(--naki-banner-foreground-color)'),
  );

  /// Banner border radius
  /// (default: `12px`, CSS variable: `--naki-banner-border-radius`).
  Token get bannerBorderRadius => const Token(
    value: '12px',
    name: '--naki-banner-border-radius',
  );

  /// Banner padding
  /// (default: `10px`, CSS variable: `--naki-banner-padding`).
  Token get bannerPadding => const Token(
    value: '10px',
    name: '--naki-banner-padding',
  );

  /// Default value for [bannerBorderColor].
  String get bannerBorderColorValue => '#e2e8f0';

  /// Banner border color
  /// (default: `#e2e8f0`, CSS variable: `--naki-banner-border-color`).
  Token get bannerBorderColor => Token(
    value: bannerBorderColorValue,
    name: '--naki-banner-border-color',
    color: const Color('var(--naki-banner-border-color)'),
  );

  /// Default value for [tooltipBgColor].
  String get tooltipBgColorValue => '#0f172a';

  /// Tooltip background color
  /// (default: `#0f172a`, CSS variable: `--naki-tooltip-bg`).
  Token get tooltipBgColor => Token(
    value: tooltipBgColorValue,
    name: '--naki-tooltip-bg',
    color: const Color('var(--naki-tooltip-bg)'),
  );

  /// Default value for [tooltipTextColor].
  String get tooltipTextColorValue => '#ffffff';

  /// Tooltip text color
  /// (default: `#ffffff`, CSS variable: `--naki-tooltip-color`).
  Token get tooltipTextColor => Token(
    value: tooltipTextColorValue,
    name: '--naki-tooltip-color',
    color: const Color('var(--naki-tooltip-color)'),
  );

  /// Tooltip border radius
  /// (default: `12px`, CSS variable: `--naki-tooltip-border-radius`).
  Token get tooltipBorderRadius => const Token(
    value: '12px',
    name: '--naki-tooltip-border-radius',
  );

  /// Tooltip padding
  /// (default: `6px`, CSS variable: `--naki-tooltip-padding`).
  Token get tooltipPadding => const Token(
    value: '6px',
    name: '--naki-tooltip-padding',
  );

  /// Tooltip font size
  /// (default: `12px`, CSS variable: `--naki-tooltip-font-size`).
  Token get tooltipFontSize => const Token(
    value: '12px',
    name: '--naki-tooltip-font-size',
  );

  /// Default value for [popoverBgColor].
  String get popoverBgColorValue => '#ffffff';

  /// Popover background color
  /// (default: `#ffffff`, CSS variable: `--naki-popover-bg`).
  Token get popoverBgColor => Token(
    value: popoverBgColorValue,
    name: '--naki-popover-bg',
    color: const Color('var(--naki-popover-bg)'),
  );

  /// Default value for [popoverTextColor].
  String get popoverTextColorValue => '#0f172a';

  /// Popover text color
  /// (default: `#0f172a`, CSS variable: `--naki-popover-color`).
  Token get popoverTextColor => Token(
    value: popoverTextColorValue,
    name: '--naki-popover-color',
    color: const Color('var(--naki-popover-color)'),
  );

  /// Default value for [popoverBorderColor].
  String get popoverBorderColorValue => '#e2e8f0';

  /// Popover border color
  /// (default: `#e2e8f0`, CSS variable: `--naki-popover-border-color`).
  Token get popoverBorderColor => Token(
    value: popoverBorderColorValue,
    name: '--naki-popover-border-color',
    color: const Color('var(--naki-popover-border-color)'),
  );

  /// Popover border radius
  /// (default: `12px`, CSS variable: `--naki-popover-border-radius`).
  Token get popoverBorderRadius => const Token(
    value: '12px',
    name: '--naki-popover-border-radius',
  );

  /// Popover padding
  /// (default: `10px`, CSS variable: `--naki-popover-padding`).
  Token get popoverPadding => const Token(
    value: '10px',
    name: '--naki-popover-padding',
  );

  /// Default value for [popoverShadow].
  String get popoverShadowValue =>
      '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1)';

  /// Popover box shadow
  /// (default: `0 10px 15px -3px rgba(0, 0, 0, 0.1),
  /// 0 4px 6px -4px rgba(0, 0, 0, 0.1)`,
  /// CSS variable: `--naki-popover-shadow`).
  Token get popoverShadow => Token(
    value: popoverShadowValue,
    name: '--naki-popover-shadow',
  );

  /// Default value for [dialogBgColor].
  String get dialogBgColorValue => '#ffffff';

  /// Dialog background color
  /// (default: `#ffffff`, CSS variable: `--naki-dialog-bg`).
  Token get dialogBgColor => Token(
    value: dialogBgColorValue,
    name: '--naki-dialog-bg',
    color: const Color('var(--naki-dialog-bg)'),
  );

  /// Dialog border radius
  /// (default: `12px`, CSS variable: `--naki-dialog-border-radius`).
  Token get dialogBorderRadius => const Token(
    value: '12px',
    name: '--naki-dialog-border-radius',
  );

  /// Dialog padding (default: `24px`,
  /// CSS variable: `--naki-dialog-padding`).
  Token get dialogPadding => const Token(
    value: '24px',
    name: '--naki-dialog-padding',
  );

  /// Default value for [dialogBarrierBg].
  String get dialogBarrierBgValue => 'rgba(0, 0, 0, 0.5)';

  /// Dialog barrier backdrop color
  /// (default: `rgba(0, 0, 0, 0.5)`,
  /// CSS variable: `--naki-dialog-barrier-bg`).
  Token get dialogBarrierBg => Token(
    value: dialogBarrierBgValue,
    name: '--naki-dialog-barrier-bg',
    color: const Color('var(--naki-dialog-barrier-bg)'),
  );

  /// Default value for [drawerBgColor].
  String get drawerBgColorValue => '#ffffff';

  /// Drawer background color
  /// (default: `#ffffff`, CSS variable: `--naki-drawer-bg`).
  Token get drawerBgColor => Token(
    value: drawerBgColorValue,
    name: '--naki-drawer-bg',
    color: const Color('var(--naki-drawer-bg)'),
  );

  /// Drawer width (default: `320px`, CSS variable: `--naki-drawer-width`).
  Token get drawerWidth => const Token(
    value: '320px',
    name: '--naki-drawer-width',
  );

  /// Default value for [drawerBarrierBg].
  String get drawerBarrierBgValue => 'rgba(0, 0, 0, 0.5)';

  /// Drawer barrier backdrop color
  /// (default: `rgba(0, 0, 0, 0.5)`,
  /// CSS variable: `--naki-drawer-barrier-bg`).
  Token get drawerBarrierBg => Token(
    value: drawerBarrierBgValue,
    name: '--naki-drawer-barrier-bg',
    color: const Color('var(--naki-drawer-barrier-bg)'),
  );

  /// Default value for [bottomSheetBgColor].
  String get bottomSheetBgColorValue => '#ffffff';

  /// BottomSheet background color
  /// (default: `#ffffff`, CSS variable: `--naki-bottom-sheet-bg`).
  Token get bottomSheetBgColor => Token(
    value: bottomSheetBgColorValue,
    name: '--naki-bottom-sheet-bg',
    color: const Color('var(--naki-bottom-sheet-bg)'),
  );

  /// BottomSheet maximum height
  /// (default: `80vh`, CSS variable: `--naki-bottom-sheet-max-height`).
  Token get bottomSheetMaxHeight => const Token(
    value: '80vh',
    name: '--naki-bottom-sheet-max-height',
  );

  /// BottomSheet border radius
  /// (default: `12px 12px 0 0`,
  /// CSS variable: `--naki-bottom-sheet-border-radius`).
  Token get bottomSheetBorderRadius => const Token(
    value: '12px 12px 0 0',
    name: '--naki-bottom-sheet-border-radius',
  );

  /// Default value for [bottomSheetBarrierBg].
  String get bottomSheetBarrierBgValue => 'rgba(0, 0, 0, 0.5)';

  /// BottomSheet barrier backdrop color
  /// (default: `rgba(0, 0, 0, 0.5)`,
  /// CSS variable: `--naki-bottom-sheet-barrier-bg`).
  Token get bottomSheetBarrierBg => Token(
    value: bottomSheetBarrierBgValue,
    name: '--naki-bottom-sheet-barrier-bg',
    color: const Color('var(--naki-bottom-sheet-barrier-bg)'),
  );

  /// Returns a map of all CSS variable names to their values.
  Map<String, String> get variables => {
    // Color scheme
    'color-scheme': colorScheme,

    // Brand color tokens
    primaryColor.name: primaryColor.value,
    secondaryColor.name: secondaryColor.value,
    accentColor.name: accentColor.value,

    // Primary color tokens
    green.name: green.value,
    yellow.name: yellow.value,
    red.name: red.value,

    // Text color tokens
    placeholderColor.name: placeholderColor.value,
    mutedColor.name: mutedColor.value,
    subtitleColor.name: subtitleColor.value,

    // Selected color tokens
    selectedItemColor.name: selectedItemColor.value,
    selectedTextBgColor.name: selectedTextBgColor.value,
    selectedTextColor.name: selectedTextColor.value,
    selectedItemBgColor.name: selectedItemBgColor.value,

    // Background color tokens
    backgroundColor.name: backgroundColor.value,

    // Error color tokens
    errorColor.name: errorColor.value,
    errorWeakColor.name: errorWeakColor.value,

    // Success color tokens
    successColor.name: successColor.value,
    successWeakColor.name: successWeakColor.value,

    // Warning color tokens
    warningColor.name: warningColor.value,
    warningWeakColor.name: warningWeakColor.value,

    // Info color tokens
    infoColor.name: infoColor.value,
    infoWeakColor.name: infoWeakColor.value,

    // Surface tokens
    surfaceVariantColor.name: surfaceVariantColor.value,
    surfaceMutedColor.name: surfaceMutedColor.value,

    // Shadow tokens
    shadowColor.name: shadowColor.value,
    smallShadowColor.name: smallShadowColor.value,
    mediumShadowColor.name: mediumShadowColor.value,
    largeShadowColor.name: largeShadowColor.value,

    // State color tokens
    buttonHoverBgColor.name: buttonHoverBgColor.value,
    hoverColor.name: hoverColor.value,
    focusBorderColor.name: focusBorderColor.value,
    fieldHoverColor.name: fieldHoverColor.value,
    disabledBgColor.name: disabledBgColor.value,
    disabledColor.name: disabledColor.value,

    // Border tokens
    border.name: border.value,
    borderColor.name: borderColor.value,
    fieldHoverBorder.name: fieldHoverBorder.value,
    focusBorder.name: focusBorder.value,
    errorBorder.name: errorBorder.value,

    // FontFamily tokens
    fontFamily.name: fontFamily.value,

    // FontSize tokens
    fontSizeSm.name: fontSizeSm.value,
    fontSizeMd.name: fontSizeMd.value,
    fontSizeLg.name: fontSizeLg.value,
    fontSizeXl.name: fontSizeXl.value,
    fontSize2xl.name: fontSize2xl.value,
    fontSize3xl.name: fontSize3xl.value,
    fontSize4xl.name: fontSize4xl.value,
    fontSize5xl.name: fontSize5xl.value,
    fontSizeSectionHeader.name: fontSizeSectionHeader.value,
    fontSizeInput.name: fontSizeInput.value,
    fontSizeError.name: fontSizeError.value,
    fontSizeHint.name: fontSizeHint.value,
    fontSizeLabel.name: fontSizeLabel.value,
    fontSizeDropdownOption.name: fontSizeDropdownOption.value,

    // FontWeight tokens
    fontWeightNormal.name: fontWeightNormal.value,
    fontWeightMedium.name: fontWeightMedium.value,
    fontWeightSemiBold.name: fontWeightSemiBold.value,
    fontWeightBold.name: fontWeightBold.value,
    fontWeightSectionHeader.name: fontWeightSectionHeader.value,

    // Spinner tokens
    spinnerSize.name: spinnerSize.value,
    spinnerBorderWidth.name: spinnerBorderWidth.value,
    spinnerTrackColor.name: spinnerTrackColor.value,
    spinnerColor.name: spinnerColor.value,
    spinnerSurfaceColor.name: spinnerSurfaceColor.value,
    spinnerBladeColor.name: spinnerBladeColor.value,

    // Spacing tokens
    paddingSm.name: paddingSm.value,
    paddingMd.name: paddingMd.value,
    paddingLg.name: paddingLg.value,
    marginSm.name: marginSm.value,
    marginMd.name: marginMd.value,
    marginLg.name: marginLg.value,

    // Shadow tokens
    boxShadow.name: boxShadow.value,
    smallShadow.name: smallShadow.value,
    mediumShadow.name: mediumShadow.value,
    largeShadow.name: largeShadow.value,

    // Radius tokens
    radiusSm.name: radiusSm.value,
    radiusMd.name: radiusMd.value,
    radiusLg.name: radiusLg.value,

    // Input tokens
    inputHeight.name: inputHeight.value,
    inputTextColor.name: inputTextColor.value,

    // Dropdown tokens
    dropdownHeight.name: dropdownHeight.value,
    dropdownWidth.name: dropdownWidth.value,
    dropdownMenuHeight.name: dropdownMenuHeight.value,
    dropdownMenuBgColor.name: dropdownMenuBgColor.value,
    dropdownOptionFontSize.name: dropdownOptionFontSize.value,
    dropdownOptionPadding.name: dropdownOptionPadding.value,

    // Text tokens
    textMaxLines.name: textMaxLines.value,
    labelColor.name: labelColor.value,
    baseTextColor.name: baseTextColor.value,

    // Button tokens
    buttonBackgroundColor.name: buttonBackgroundColor.value,
    buttonColor.name: buttonColor.value,
    buttonHeight.name: buttonHeight.value,
    buttonWidth.name: buttonWidth.value,

    // Field tokens
    fieldBackgroundColor.name: fieldBackgroundColor.value,

    // Slider tokens
    sliderThumbColor.name: sliderThumbColor.value,
    sliderTrackColor.name: sliderTrackColor.value,
    sliderThumbSize.name: sliderThumbSize.value,

    // Switch tokens
    switchThumbColor.name: switchThumbColor.value,
    radioBtnRadius.name: radioBtnRadius.value,
    radioBtnColor.name: radioBtnColor.value,

    // Appbar tokens
    appbarBgColor.name: appbarBgColor.value,
    appbarHeight.name: appbarHeight.value,

    // Bottom navbar tokens
    bottomNavbarBgColor.name: bottomNavbarBgColor.value,
    bottomNavbarHeight.name: bottomNavbarHeight.value,

    // Carousel tokens
    carouselItemExtent.name: carouselItemExtent.value,
    carouselGap.name: carouselGap.value,

    // Table tokens
    tableHeaderBg.name: tableHeaderBg.value,
    tableRowHoverBg.name: tableRowHoverBg.value,
    tableHeaderBorderColor.name: tableHeaderBorderColor.value,

    // Grid tokens
    gridGap.name: gridGap.value,

    // Snackbar tokens
    snackbarBgColor.name: snackbarBgColor.value,
    snackbarForegroundColor.name: snackbarForegroundColor.value,
    snackbarBorderRadius.name: snackbarBorderRadius.value,
    snackbarPadding.name: snackbarPadding.value,
    snackbarOffset.name: snackbarOffset.value,

    // Banner tokens
    bannerBgColor.name: bannerBgColor.value,
    bannerForegroundColor.name: bannerForegroundColor.value,
    bannerBorderRadius.name: bannerBorderRadius.value,
    bannerPadding.name: bannerPadding.value,
    bannerBorderColor.name: bannerBorderColor.value,

    // Tooltip tokens
    tooltipBgColor.name: tooltipBgColor.value,
    tooltipTextColor.name: tooltipTextColor.value,
    tooltipBorderRadius.name: tooltipBorderRadius.value,
    tooltipPadding.name: tooltipPadding.value,
    tooltipFontSize.name: tooltipFontSize.value,

    // Popover tokens
    popoverBgColor.name: popoverBgColor.value,
    popoverTextColor.name: popoverTextColor.value,
    popoverBorderColor.name: popoverBorderColor.value,
    popoverBorderRadius.name: popoverBorderRadius.value,
    popoverPadding.name: popoverPadding.value,
    popoverShadow.name: popoverShadow.value,

    // Dialog tokens
    dialogBgColor.name: dialogBgColor.value,
    dialogBorderRadius.name: dialogBorderRadius.value,
    dialogPadding.name: dialogPadding.value,
    dialogBarrierBg.name: dialogBarrierBg.value,

    // Drawer tokens
    drawerBgColor.name: drawerBgColor.value,
    drawerWidth.name: drawerWidth.value,
    drawerBarrierBg.name: drawerBarrierBg.value,

    // Bottom sheet tokens
    bottomSheetBgColor.name: bottomSheetBgColor.value,
    bottomSheetMaxHeight.name: bottomSheetMaxHeight.value,
    bottomSheetBorderRadius.name: bottomSheetBorderRadius.value,
    bottomSheetBarrierBg.name: bottomSheetBarrierBg.value,

    // Custom styles
    ...?customVariables,
  };
}
