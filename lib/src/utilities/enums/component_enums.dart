part of 'index.dart';

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

  /// Selects a range of dates (start date and end date).
  range,
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
  frostedGlass('navbar__frosted-glass'),

  /// A [frostedGlass] bar that also bends the content behind its edges and
  /// selection droplet. Refraction needs a Chromium browser, so other
  /// browsers show the regular [frostedGlass] bar.
  liquidGlass('navbar__frosted-glass navbar__liquid-glass')
  ;

  /// The CSS class name representing the bottom navigation bar style.
  /// example: 'navbar__floating'
  final String className;
  const BottomNavigationBarType(this.className);

  /// Whether the bar has a glass surface and a selection droplet.
  bool get isGlass => this == frostedGlass || this == liquidGlass;

  /// Whether the bar is centered on the screen
  /// and `Scaffold.extendBody` should be `true`.
  bool get isElevated => this != fixed;
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

  /// Translucent card with a blurred backdrop and a light rim.
  glass,
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

  final String mime;
  final String value;
  const FileType(this.mime, this.value);
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
