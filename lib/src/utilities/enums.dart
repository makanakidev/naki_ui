import '../models/styling.dart';
import 'constants.dart';

/// Alias for [Placement].
typedef Position = Placement;

/// Represents placement/position of a component relative to another.
enum Placement {
  /// Place above another component.
  top,

  /// Place to the right of another component.
  right,

  /// Place below another component.
  bottom,

  /// Place to the left of another component.
  left,
}

/// Represents standard display aspect ratios.
enum AspectRatioType {
  /// 16:9 widescreen ratio (e.g. standard HD TVs).
  ratio16_9('16/9'),

  /// 4:3 standard display ratio (e.g. standard definition TVs).
  ratio4_3('4/3'),

  /// 1:1 square ratio (e.g. profile photos).
  ratio1_1('1/1'),

  /// 3:2 standard ratio (e.g. 3x2 or 6x4 photos).
  ratio3_2('3/2'),

  /// 9:16 vertical content ratio (e.g. reels, shorts, stories).
  ratio9_16('9/16'),

  /// 4:5 content ratio (e.g. instagram post).
  ratio4_5('4/5'),

  /// 21:9 cinematic ratio (e.g. ultrawide monitors).
  ratio21_9('21/9'),

  /// 1:2 vertical ratio (e.g. phone screenshots).
  ratio1_2('1/2')
  ;

  /// Suitable for Instagram stories, Instagram reels,
  /// YouTube shorts, TikTok videos related content.
  static const stories = AspectRatioType.ratio9_16;

  /// Suitable for Instagram posts related content.
  static const instagramPost = AspectRatioType.ratio4_5;

  /// Suitable for YouTube videos, Twitter videos,
  /// LinkedIn videos, Facebook videos related content.
  static const youtubeVideo = AspectRatioType.ratio16_9;

  /// Suitable for cinematic movies related content.
  static const cinematic = AspectRatioType.ratio21_9;

  /// Suitable for icons, avatars, logos related content.
  static const profile = AspectRatioType.ratio1_1;

  /// The standard CSS value representing the ratio type.
  final String value;
  const AspectRatioType(this.value);
}

/// Represents the style of glyphs in a font (upright vs. italicized).
enum FontStyle {
  /// Use upright glyphs.
  normal,

  /// Use glyphs designed for slanting (italicized).
  italic,
}

/// Represents the layout direction of a component.
enum Direction {
  /// Lay out children vertically.
  vertical,

  /// Lay out children horizontally.
  horizontal,
}

/// Represents the orientation of the browser viewport or a component.
enum Orientation {
  /// Lay out children vertically.
  portrait,

  /// Lay out children horizontally.
  landscape,

  /// Unknown orientation.
  unknown,
}

/// Represents the style of text decoration lines.
enum TextDecorationStyle {
  /// Draw a single solid line.
  solid,

  /// Draw a double line.
  double,

  /// Draw a dotted line.
  dotted,

  /// Draw a dashed line.
  dashed,

  /// Draw a wavy line.
  wavy,

  /// The border appears raised depending on the
  /// `border-style` and `border-color` properties.
  ridge,

  /// The border appears indented depending on the
  /// `border-style` and `border-color` properties.
  groove,

  /// Display no border.
  none,

  /// The border appears as if it is coming out of the page.
  outset,

  /// The border appears as if it is going into the page.
  inset,
}

/// How the children within a Flex container (Row or Column)
/// should be placed along the main axis.
enum MainAxisAlignment {
  /// Place the children as close to the start of the main axis as possible.
  start,

  /// Place the children as close to the end of the main axis as possible.
  end,

  /// Place the children as close to the middle of the main axis as possible.
  center,

  /// Place the free space evenly between the children.
  spaceBetween,

  /// Place the free space evenly between the children as well
  /// as half of that space before the first and after the last child.
  spaceAround,

  /// Place the free space evenly between the children
  /// as well as before the first and after the last child.
  spaceEvenly,
}

/// How the children within a Flex container (Row or Column)
/// should be placed along the cross axis.
enum CrossAxisAlignment {
  /// Place the children with their start edges aligned
  /// with the start side of the cross axis.
  start,

  /// Place the children as close to the end of the cross axis as possible.
  end,

  /// Place the children aligned with the middle of the cross axis.
  center,

  /// Require the children to fill the cross axis.
  stretch,

  /// Align the children along their baselines.
  baseline,
}

/// How much space should be occupied by the main
/// axis in a Flex container (Row or Column).
enum MainAxisSize {
  /// Minimize the amount of free space along the main axis.
  min,

  /// Maximize the amount of free space along the main axis.
  max,
}

/// How a flexible child component sizes itself along the main axis in a
/// Flex container ([Row] or [Column]).
enum FlexFit {
  /// The child is forced to expand to fill the available space along
  /// the main axis.
  tight,

  /// The child can be at most as large as the available space along
  /// the main axis (and may begin smaller).
  loose,
}

/// How an image should fit within its bounds.
enum BoxFit {
  /// Fill the target box by distorting the image's aspect ratio.
  fill('fill'),

  /// As large as possible while still containing the
  /// image within the target box.
  contain('contain'),

  /// As small as possible while still covering the entire target box.
  cover('cover'),

  /// Display the image's source at its natural size.
  none('none'),

  /// Align the image within the target box and,
  /// if necessary, scale the image down to fit.
  scaleDown('scale-down')
  ;

  /// The standard CSS value representing the box fit type.
  final String name;
  const BoxFit(this.name);
}

/// Alignment points relative to a 2D box.
enum Alignment {
  /// The top-left corner.
  topLeft('top-left'),

  /// The top edge, centered horizontally.
  topCenter('top-center'),

  /// The top-right corner.
  topRight('top-right'),

  /// The center of the left edge.
  centerLeft('center-left'),

  /// The center point.
  center('center'),

  /// The center of the right edge.
  centerRight('center-right'),

  /// The bottom-left corner.
  bottomLeft('bottom-left'),

  /// The bottom edge, centered horizontally.
  bottomCenter('bottom-center'),

  /// The bottom-right corner.
  bottomRight('bottom-right')
  ;

  /// The standard CSS value representing the alignment type.
  final String value;
  const Alignment(this.value);
}

/// Types of autofill suggestions for input fields.
enum Autofill {
  /// Full name.
  name('name'),

  /// Prefix or title (e.g. "Mr.", "Ms.", "Dr.", "Mlle").
  honorificPrefix('honorific-prefix'),

  /// Given name (also known as the first name).
  givenName('given-name'),

  /// Additional names (also known as middle names).
  additionalName('additional-name'),

  /// Family name (also known as the last name or surname).
  familyName('family-name'),

  /// Suffix (e.g. "Jr.", "B.Sc.", "MBASW", "II").
  honorificSuffix('honorific-suffix'),

  /// Nickname, screen name.
  nickname('nickname'),

  /// A username.
  username('username'),

  /// A new password (e.g. when creating an account
  /// or changing a password).
  newPassword('new-password'),

  /// The current password for the account identified by
  /// the username field (e.g. when logging in).
  currentPassword('current-password'),

  /// One-time code used for verifying user identity.
  oneTimeCode('one-time-code'),

  /// Job title (e.g. "Software Engineer", "Senior
  /// Vice President", "Deputy Managing Director").
  organizationTitle('organization-title'),

  /// Company name corresponding to the person,
  /// address, or contact information in the other
  /// fields associated with this field.
  organization('organization'),

  /// Street address (multiple lines, newlines preserved).
  streetAddress('street-address'),

  /// Street address (one line per field, line 1).
  addressLine1('address-line1'),

  /// Street address (one line per field, line 2).
  addressLine2('address-line2'),

  /// Street address (one line per field, line 3).
  addressLine3('address-line3'),

  /// The most fine-grained administrative level,
  /// in addresses with four administrative levels.
  addressLevel4('address-level4'),

  /// The third administrative level, in addresses
  /// with three or more administrative levels.
  addressLevel3('address-level3'),

  /// The second administrative level, in addresses with two
  /// or more administrative levels (typically city,
  /// town, or locality).
  addressLevel2('address-level2'),

  /// The broadest administrative level in the address
  /// (e.g. province, state, canton, or post town).
  addressLevel1('address-level1'),

  /// Country code.
  country('country'),

  /// Country name.
  countryName('country-name'),

  /// Postal code, post code, ZIP code, CEDEX code.
  postalCode('postal-code'),

  /// Full name as given on the payment card.
  ccName('cc-name'),

  /// Given name as given on the payment card.
  ccGivenName('cc-given-name'),

  /// Additional names given on the payment card.
  ccAdditionalName('cc-additional-name'),

  /// Family name given on the payment card.
  ccFamilyName('cc-family-name'),

  /// Code identifying the payment card
  /// (e.g. the credit card number).
  ccNumber('cc-number'),

  /// Expiration date of the payment card.
  ccExp('cc-exp'),

  /// Month component of the expiration date of the payment card.
  ccExpMonth('cc-exp-month'),

  /// Year component of the expiration date of the payment card.
  ccExpYear('cc-exp-year'),

  /// Security code for the payment card (CSC, CVC, CVV, etc.).
  ccCsc('cc-csc'),

  /// The payment card type.
  ccType('cc-type'),

  /// The currency that the user would prefer the transaction to use.
  transactionCurrency('transaction-currency'),

  /// The amount that the user would like for the transaction.
  transactionAmount('transaction-amount'),

  /// Preferred language.
  language('language'),

  /// Birthday.
  bday('bday'),

  /// Day component of birthday.
  bdayDay('bday-day'),

  /// Month component of birthday.
  bdayMonth('bday-month'),

  /// Year component of birthday.
  bdayYear('bday-year'),

  /// Gender identity.
  sex('sex'),

  /// Home page or other web page corresponding to the
  /// company, person, address, or contact information.
  url('url'),

  /// Photograph, icon, or other image corresponding to
  /// the company, person, address, or contact information.
  photo('photo'),

  /// Full telephone number, including country code.
  tel('tel'),

  /// Telephone country code.
  telCountryCode('tel-country-code'),

  /// Telephone number with country-internal prefix.
  telNational('tel-national'),

  /// Area code component of the telephone number,
  /// with a country-internal prefix applied if applicable.
  telAreaCode('tel-area-code'),

  /// Telephone number without the country code
  /// and area code components.
  telLocal('tel-local'),

  /// First part of the component of the telephone number
  /// that follows the area code, when that component is split
  /// into two components.
  telLocalPrefix('tel-local-prefix'),

  /// Last part of the component of the telephone number
  /// that follows the area code, when that component is split
  /// into two components.
  telLocalSuffix('tel-local-suffix'),

  /// Telephone number internal extension code.
  telExtension('tel-extension'),

  /// Email address.
  email('email'),

  /// URL representing an instant messaging protocol endpoint
  /// (for example, "aim:goim?screenname=example" or
  /// "xmpp:fred@example.net").
  impp('impp'),

  /// Autocomplete is disabled.
  off('off'),

  /// Autocomplete is enabled.
  on('on')
  ;

  /// The standard CSS value representing the autofill type.
  final String value;
  const Autofill(this.value);
}

/// Represents standard CSS vertical alignment baseline
/// options for inline text and components.
enum Baseline {
  /// Aligns the baseline of the element with
  /// the baseline of its parent (CSS: `baseline`).
  baseline('baseline'),

  /// Lowers the baseline of the element to
  /// the subscript position (CSS: `sub`).
  sub('sub'),

  /// Raises the baseline of the element to
  /// the superscript position (CSS: `super`).
  super_('super'),

  /// Aligns the top of the element with
  /// the top of the line (CSS: `top`).
  top('top'),

  /// Aligns the top of the element with
  /// the top of the parent font (CSS: `text-top`).
  textTop('text-top'),

  /// Aligns the middle of the element with
  /// the baseline plus half the x-height of the parent (CSS: `middle`).
  middle('middle'),

  /// Aligns the bottom of the element with
  /// the bottom of the line (CSS: `bottom`).
  bottom('bottom'),

  /// Aligns the bottom of the element with
  /// the bottom of the parent font (CSS: `text-bottom`).
  textBottom('text-bottom')
  ;

  /// The CSS value representing the vertical alignment type.
  final String value;
  const Baseline(this.value);
}

/// The direction of scrolling.
enum ScrollDirection {
  /// Scroll along the horizontal ScrollDirection.
  horizontal,

  /// Scroll along the vertical ScrollDirection.
  vertical,
}

/// Determines the scrolling physics behavior.
enum ScrollPhysicsType {
  /// Standard browser scrolling behavior.
  adaptive('adaptive'),

  /// Prevents scrolling.
  neverScrollable('never_scrollable'),

  /// Allows scrolling beyond content bounds with bounce (iOS-like).
  bouncing('bouncing'),

  /// Clamps scrolling strictly to content bounds (Android-like).
  clamping('clamping'),

  /// Snaps scrolling to the nearest item.
  snapping('snapping')
  ;

  /// The CSS value representing the scrolling physics type.
  final String name;
  const ScrollPhysicsType(this.name);
}

/// Defines the alignment of items in a carousel view.
enum CarouselAlignment {
  /// Align items to the start of the scroll view.
  start,

  /// Center items within the scroll view.
  center,

  /// Align items to the end of the scroll view.
  end,
}

/// Alignment of content within a table row cell.
enum TableRowCellAlignment {
  /// Align cell content to the left edge.
  left,

  /// Align cell content to the right edge.
  right,

  /// Justify cell content.
  justify,

  /// Align cell content to the start edge.
  start,

  /// Align cell content to the end edge.
  end,

  /// Align cell content to the center edge.
  center,
}

/// Alignment for table header cells.
enum TableHeaderCellAlignment {
  /// Align cell content to the left edge.
  left,

  /// Align cell content to the right edge.
  right,

  /// Justify cell content.
  justify,

  /// Align cell content to the start edge.
  start,

  /// Align cell content to the end edge.
  end,

  /// Align cell content to the center edge.
  center,
}

/// Theme mode options.
enum ThemeMode {
  /// Dark theme mode.
  dark,

  /// Light theme mode.
  light,

  /// Browser/device theme mode.
  system
  ;

  /// Converts a string to a ThemeMode.
  ///
  /// If [value] is not a valid theme mode,
  /// it defaults to [ThemeMode.system].
  ///
  /// Example:
  /// ```dart
  /// final mode = ThemeMode.from('dark');
  /// ```
  factory ThemeMode.from(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

/// Represents CSS backdrop filter functions.
enum BackdropFilterType {
  /// Blurs the background.
  /// Requires a unit like 'Dim.px(10)'.
  blur._('blur'),

  /// Makes the background brighter (under 100%) or darker (over 100%).
  /// Requires a value like 'Dim.percent(50)'.
  brightness._('brightness'),

  /// Adjusts the contrast of the background.
  /// Requires a value like 'Dim.percent(50)'.
  contrast._('contrast'),

  /// Converts the background to black and white.
  /// Requires a value like 'Dim.percent(50)'.
  grayscale._('grayscale'),

  /// Rotates the hue of the background.
  /// Requires a value like 'Dim.deg(90)'.
  hueRotate._('hue-rotate'),

  /// Inverts the background colors.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  invert._('invert'),

  /// Adjusts the opacity of the background.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  opacity._('opacity'),

  /// Adjusts the saturation of the background.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  saturate._('saturate'),

  /// Converts the background to a warm, vintage brown tint.
  /// Requires a value like 'Dim.percent(50)', 'Dim(1.5)', or 'Dim(0.4)'.
  sepia._('sepia')
  ;

  /// The standard CSS value representing the backdrop filter type.
  final String cssName;
  const BackdropFilterType._(this.cssName);

  /// Converts the filter type and value to a CSS string
  /// (e.g., "blur(10px)").
  String cssText(Dim value) => '$cssName($value)';
}

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

/// Defines the allowed input character types for `SegmentedInput` component.
enum SegmentedInputType {
  /// Numeric input only (digits 0-9).
  /// Recommended for OTP/PIN fields.
  number,

  /// Alphanumeric input (any single text character).
  text,

  /// Obscured input for sensitive codes or password PINs.
  password,
}

/// Represents the visual shape of individual segment
/// fields in `SegmentedInput` component.
enum SegmentedInputShape {
  /// Standard rectangular/square box with rounded corners.
  box,

  /// Underlined input style.
  underline,

  /// Circular segment input style.
  circle,
}

/// Represents standard HTML input validation regex patterns.
enum ValidationPattern {
  /// Digits / numbers only (0-9).
  /// Example: '12345'
  digitsOnly('[0-9]*'),

  /// Optional negative sign followed by digits only.
  /// Example: '-42' or '100'
  signedIntegers(r'^-?[0-9]*$'),

  /// Optional leading plus or minus sign followed by digits.
  /// Example: '+42' or '-10'
  signedIntegersAllowLeadingPlus(r'^[+-]?[0-9]*$'),

  /// Positive decimal numbers with optional leading zero.
  /// Example: '3.14' or '0.5'
  positiveDecimals(r'^(0|[1-9]\d*)(\.\d+)?$'),

  /// Signed decimal numbers (positive or negative)
  /// with optional leading plus or minus sign and optional decimal part.
  /// Example: '-12.34' or '+0.99'
  signedDecimals(r'^[+-]?(\d+(\.\d*)?|\.\d+)$'),

  /// Non-negative numbers with optional decimal part.
  /// Example: '0' or '25.50'
  nonNegative(r'^\d+(\.\d+)?$'),

  /// Negative numbers with optional decimal part.
  /// Example: '-5' or '-19.99'
  negative(r'^-\d+(\.\d+)?$'),

  /// Positive integers (numbers without decimal part).
  /// Example: '1' or '42'
  positiveIntegers(r'^[1-9]\d*$'),

  /// Negative integers (numbers without decimal part).
  /// Example: '-1' or '-100'
  negativeIntegers(r'^-\d+$'),

  /// Letters only (a-z, A-Z).
  /// Example: 'John' or 'hello'
  lettersOnly('[a-zA-Z]*'),

  /// Letters and digits only.
  /// Example: 'Code123'
  alphanumeric('[a-zA-Z0-9]*'),

  /// Letters, digits, and spaces.
  /// Example: 'John Doe 123'
  alphanumericWithSpaces('[a-zA-Z0-9 ]*'),

  /// Integer or decimal numbers.
  /// Example: '10.5' or '42'
  decimal(r'[0-9]*\.?[0-9]*'),

  /// Standard email address format.
  /// Example: 'user@example.com'
  email(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'),

  /// Web URL starting with http:// or https://.
  /// Example: 'https://example.com'
  url(r'https?://.+'),

  /// Telephone number digits and symbols (+, -, ()).
  /// Example: '+1 (555) 000-1234'
  phone(r'^\+?[0-9\s\-()]{7,15}$'),

  /// Disallows space characters.
  /// Example: 'no_spaces_here'
  noSpaces(r'^\S+$'),

  /// Hexadecimal color code.
  /// Example: '#FFF' or '#1A2B3C'
  hexColor(r'#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3})'),

  /// Postal / ZIP code format (US).
  /// Example: '90210' or '12345-6789'
  zipCode(r'[0-9]{5}(-[0-9]{4})?'),

  /// Username format (3-30 alphanumeric chars, dots, hyphens, or underscores).
  /// Example: 'john_doe'
  username(r'[a-zA-Z0-9_.-]{3,30}')
  ;

  /// The standard CSS value representing the
  /// input validation pattern.
  final String value;
  const ValidationPattern(this.value);
}

/// Defines `Calendar` type.
enum CalendarType {
  /// Shows date only.
  date,

  /// Shows time only.
  time,

  /// Shows date and time.
  both,
}

/// Controls the overall lighting of a component
/// based on current theme mode or user preference.
enum Brightness {
  /// Light mode.
  /// Use this for components that should
  /// always appear in light mode, regardless
  /// of the current theme mode or user preference.
  light,

  /// Dark mode.
  /// Use this for components that should
  /// always appear in dark mode, regardless
  /// of the current theme mode or user preference.
  dark,
}

/// Defines `BottomNavigationBar` type.
enum BottomNavigationBarType {
  /// The bottom navigation bar is elevated, centered on the screen,
  /// and has a smaller width than the screen width.
  floating('navbar__floating'),

  /// The bottom navigation bar is centered, extends across the entire
  /// width of the screen, and its items have fixed width.
  fixed('navbar__fixed'),

  /// The bottom navigation bar has an iOS-style frosted glass effect,
  /// is elevated, centered on the screen, and has a smaller width
  /// than the screen width.
  frostedGlass('navbar__frosted-glass')
  ;

  /// The CSS class name representing the bottom navigation bar style.
  /// example: 'navbar__floating'
  final String className;
  const BottomNavigationBarType(this.className);
}

/// Refines the landscape layout of a bottom navigation bar.
enum BottomNavigationBarLandscapeLayout {
  /// The navigation bar's items are evenly spaced and spread out
  /// across the available width. Each item's label and icon are
  /// arranged in a column.
  spread('navbar__spread-layout'),

  /// The navigation bar's items are evenly centered within the
  /// available width. Each item's label and icon are arranged
  /// in a column.
  centered('navbar__centered-layout'),

  /// The navigation bar's items are evenly spaced. Each item's icon
  /// and label are lined up in a row instead of a column.
  ///
  /// This layout is suitable on devices/screens that are wide enough
  /// (such as tablets and large desktop screens) in landscape orientation.
  linear('navbar__linear-layout')
  ;

  /// The CSS class name representing the bottom navbar landscape layout.
  /// example: 'navbar__linear-layout'
  final String className;
  const BottomNavigationBarLandscapeLayout(this.className);
}

/// Defines `Card` type.
enum CardVariant {
  /// Default card with elevation shadow.
  elevated,

  /// Card with 1px border and flat elevation.
  outlined,

  /// Card with surface container fill.
  filled,
}

/// File types.
enum FileType {
  /// All image files.
  allImages('image/*', 'Images'),

  /// All video files.
  allVideos('video/*', 'Videos'),

  /// All audio files.
  allAudios('audio/*', 'Audios'),

  /// All document files.
  allDocuments('application/*', 'Documents'),

  /// All text files.
  allTexts('text/*', 'Texts'),

  /// Text file.
  txt('text/plain', 'TXT'),

  /// Doc file.
  doc('application/msword', 'DOC'),

  /// Docx file.
  docx(
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'DOCX',
  ),

  /// Js file.
  js('application/javascript', 'JS'),

  /// Json file.
  json('application/json', 'JSON'),

  /// Css file.
  css('text/css', 'CSS'),

  /// Html file.
  html('text/html', 'HTML'),

  /// Csv file.
  csv('text/csv', 'CSV'),

  /// Pdf file.
  pdf('application/pdf', 'PDF'),

  /// Xls file.
  xls('application/vnd.ms-excel', 'XLS'),

  /// Xlsx file.
  xlsx(
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'XSLX',
  ),

  /// Unknown file type.
  other('application/octet-stream', 'Other'),

  /// Jpeg file.
  jpeg('image/jpeg', 'JPEG'),

  /// Svg file.
  svg('image/svg+xml', 'SVG'),

  /// Zip file.
  zip('application/zip', 'ZIP'),

  /// Wav file.
  wav('audio/wav', 'WAV'),

  /// Mp3 file.
  mp3('audio/mpeg', 'MP3'),

  /// Png file.
  png('image/png', 'PNG'),

  /// WebP file.
  webp('image/webp', 'WEBP'),

  /// GIF file.
  gif('image/gif', 'GIF'),

  /// JPG file.
  jpg('image/jpg', 'JPG'),

  /// MP4 file.
  mp4('video/mp4', 'MP4'),

  /// Mpeg file.
  mpeg('video/mpeg', 'MPEG'),

  /// WebM file.
  webm('video/webm', 'WEBM'),

  /// Ogg file.
  ogg('video/ogg', 'OGG')
  ;

  final String value;
  final String name;
  const FileType(this.value, this.name);
}

/// Defines BreakPoint sizes for responsive design.
enum BreakPoint {
  /// Extra small screens (less than 480px) e.g. mobile phones.
  xs(kBreakpointXSmall, 'br-xs'),

  /// Small screens (480px to 576px) e.g. larger phones.
  sm(kBreakpointSmall, 'br-sm'),

  /// Medium screens (576px to 768px) e.g. tablets.
  md(kBreakpointMedium, 'br-md'),

  /// Large screens (768px to 1024px) e.g. laptops.
  lg(kBreakpointLarge, 'br-lg'),

  /// Extra large screens (1024px and above) e.g. desktops.
  xl(kBreakpointXLarge, 'br-xl')
  ;

  /// Breakpoint for mobile phones (less than 480px).
  static BreakPoint get mobile => BreakPoint.xs;

  /// Breakpoint for larger phones (480px to 576px).
  static BreakPoint get largerPhone => BreakPoint.sm;

  /// Breakpoint for tablets (576px to 768px).
  static BreakPoint get tablet => BreakPoint.md;

  /// Breakpoint for laptops (768px to 1024px).
  static BreakPoint get laptop => BreakPoint.lg;

  /// Breakpoint for desktops (1024px and above).
  static BreakPoint get desktop => BreakPoint.xl;

  /// The width in pixels.
  final double value;

  /// The CSS class name.
  final String className;

  /// Creates a new breakpoint instance.
  const BreakPoint(this.value, this.className);

  /// Returns the [BreakPoint] for the given width.
  ///
  /// ```dart
  /// const width = 420;
  /// final breakpoint = BreakPoint.from(width);
  /// print(breakpoint); // BreakPoint.xs
  /// ```
  ///
  /// [width]: The width in pixels.
  factory BreakPoint.from(double width) {
    if (width <= kBreakpointXSmall) {
      return BreakPoint.xs;
    } else if (width <= kBreakpointSmall) {
      return BreakPoint.sm;
    } else if (width <= kBreakpointMedium) {
      return BreakPoint.md;
    } else if (width <= kBreakpointLarge) {
      return BreakPoint.lg;
    } else {
      return BreakPoint.xl;
    }
  }
}

/// Defines `Gradient` type.
enum GradientType {
  /// Linear gradient.
  linear('linear-gradient'),

  /// Radial gradient.
  radial('radial-gradient'),

  /// Conic gradient.
  conic('conic-gradient'),

  /// Repeating linear gradient.
  repeatingLinear('repeating-linear-gradient'),

  /// Repeating radial gradient.
  repeatingRadial('repeating-radial-gradient'),

  /// Repeating conic gradient.
  repeatingConic('repeating-conic-gradient')
  ;

  /// The CSS class name representing the gradient style.
  final String cssName;

  /// Creates a new gradient type.
  const GradientType(this.cssName);

  /// Converts the gradient type and stops to a CSS string
  /// (e.g., "linear-gradient(to right, red, blue)").
  String cssText(List<String> stops) => '$cssName(${stops.join(", ")})';
}

/// Defines direction for linear gradients.
enum LinearGradientDirection {
  /// Gradients towards the top (`to top`).
  toTop('to top'),

  /// Gradients towards the bottom (`to bottom`).
  toBottom('to bottom'),

  /// Gradients towards the left (`to left`).
  toLeft('to left'),

  /// Gradients towards the right (`to right`).
  toRight('to right'),

  /// Gradients towards the top-left corner (`to top left`).
  toTopLeft('to top left'),

  /// Gradients towards the top-right corner (`to top right`).
  toTopRight('to top right'),

  /// Gradients towards the bottom-left corner (`to bottom left`).
  toBottomLeft('to bottom left'),

  /// Gradients towards the bottom-right corner (`to bottom right`).
  toBottomRight('to bottom right')
  ;

  /// The standard CSS direction value.
  final String value;

  /// Creates a linear gradient direction.
  const LinearGradientDirection(this.value);
}

/// Defines center position for radial gradients.
enum RadialGradientPosition {
  /// Centered position (`center`).
  center('center'),

  /// Top center position (`top`).
  top('top'),

  /// Bottom center position (`bottom`).
  bottom('bottom'),

  /// Left center position (`left`).
  left('left'),

  /// Right center position (`right`).
  right('right'),

  /// Top-left corner (`top left`).
  topLeft('top left'),

  /// Top-right corner (`top right`).
  topRight('top right'),

  /// Bottom-left corner (`bottom left`).
  bottomLeft('bottom left'),

  /// Bottom-right corner (`bottom right`).
  bottomRight('bottom right')
  ;

  /// The standard CSS position value.
  final String value;

  /// Creates a radial gradient position.
  const RadialGradientPosition(this.value);
}

/// Defines center position for conic gradients.
enum ConicGradientPosition {
  /// Centered position (`center`).
  center('center'),

  /// Top center position (`top`).
  top('top'),

  /// Bottom center position (`bottom`).
  bottom('bottom'),

  /// Left center position (`left`).
  left('left'),

  /// Right center position (`right`).
  right('right'),

  /// Top-left corner (`top left`).
  topLeft('top left'),

  /// Top-right corner (`top right`).
  topRight('top right'),

  /// Bottom-left corner (`bottom left`).
  bottomLeft('bottom left'),

  /// Bottom-right corner (`bottom right`).
  bottomRight('bottom right')
  ;

  /// The standard CSS position value.
  final String value;

  /// Creates a conic gradient position.
  const ConicGradientPosition(this.value);
}

/// Defines geometric shape types for components, gradients, and clippings.
enum Shape {
  /// Circular shape (`circle`).
  circle('circle'),

  /// Elliptical shape (`ellipse`).
  ellipse('ellipse'),

  /// Rectangular shape (`rectangle`).
  rectangle('rectangle'),

  /// Square shape (`square`).
  square('square'),

  /// Pill/capsule shape (`pill`).
  pill('pill'),

  /// Triangle shape (`triangle`).
  triangle('triangle')
  ;

  /// The standard CSS value representing the shape.
  final String value;

  /// Creates a shape instance.
  const Shape(this.value);
}
