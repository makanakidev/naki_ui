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

/// A constant that is true if the application was compiled to run on the server.
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
