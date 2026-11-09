import 'package:jaspr/jaspr.dart';

/// List of supported TextField input types.
const List<String> kInputTypes = [
  'text',
  'number',
  'email',
  'url',
  'password',
  'tel',
  'search',
];

/// Returns `true` if the application is running on the server.
const bool kIsServer = !kIsWeb;

/// List of months in a year.
const List<String> kMonths = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

/// List of days in a week.
const List<String> kDays = [
  'MON',
  'TUE',
  'WED',
  'THU',
  'FRI',
  'SAT',
  'SUN',
];

/// Theme switching script.
const String kThemeSwitchingScript = '''
!(function (t) {
  const e = localStorage.getItem("naki-theme-mode"),
    i = "{{MODE}}",
    s = (t && e) || i,
    n = document.documentElement;
  n.setAttribute("data-naki-theme", s);
  t && !e && localStorage.setItem("naki-theme-mode", i);
  setTimeout(() => {
    const b = document.querySelectorAll("base");
    b.length > 1 && b.forEach((i, index) => index > 0 && i.remove());
  }, 1000);
})({{CACHE}});
''';

/// Breakpoint width `480px` for mobile phones.
const double kBreakpointXSmall = 480.0;

/// Breakpoint width `576px` for larger phones.
const double kBreakpointSmall = 576.0;

/// Breakpoint width `768px` for tablets.
const double kBreakpointMedium = 768.0;

/// Breakpoint width `1024px` for laptops.
const double kBreakpointLarge = 1024.0;

/// Breakpoint width `1280px` for desktops.
const double kBreakpointXLarge = 1280.0;
