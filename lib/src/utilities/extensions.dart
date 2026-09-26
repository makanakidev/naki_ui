import 'dart:async';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../theme/theme.dart';
import '../theme/tokens.dart';

import 'enums.dart';

/// Extension on [Map] providing CSS property manipulation utilities.
extension CssPropsExtension on Map<String, String> {
  /// Converts raw CSS style properties to inline CSS string.
  ///
  /// Example:
  /// ```dart
  /// final css = {'display': 'block', 'color': 'red'};
  /// final cssText = css.cssText;
  /// // returns: 'display: block; color: red'
  /// ```
  String get cssText => entries.map((e) => '${e.key}: ${e.value};').join(' ');

  /// Combines this map with [other].
  ///
  /// If the same key exists, the value from [other] is used.
  ///
  /// Example:
  /// ```dart
  /// final style1 = {'color': 'red', 'font-size': '10px'};
  /// final style2 = {'font-weight': 'bold', 'font-size': '12px'};
  /// final combined = style1.combine(style2);
  /// // returns: {'color': 'red', 'font-weight': 'bold', 'font-size': '12px'}
  /// ```
  Map<String, String> combine(Map<String, String> other) => {...this, ...other};

  /// Deletes [key] and its value from this map and
  /// returns a new map without it.
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px'};
  /// final withoutColor = style.delete('color');
  /// // returns: {'font-size': '10px'}
  /// ```
  Map<String, String> delete(String key) {
    final map = {...this};
    map.remove(key);
    return map;
  }

  /// Deletes [keys] and their values from this map and
  /// returns a new map without them.
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px', 'font-weight': 'bold'};
  /// final withoutColorAndSize = style.except(['color', 'font-size']);
  /// // returns: {'font-weight': 'bold'}
  /// ```
  Map<String, String> except(List<String> keys) {
    final map = Map<String, String>.of(this);
    for (final key in keys) map.remove(key);
    return map;
  }

  /// Returns a new map containing only the entries in [keys].
  ///
  /// Example:
  /// ```dart
  /// final style = {'color': 'red', 'font-size': '10px', 'font-weight': 'bold'};
  /// final onlyColorAndSize = style.only(['color', 'font-size']);
  /// // returns: {'color': 'red', 'font-size': '10px'}
  /// ```
  Map<String, String> only(List<String> keys) {
    final map = <String, String>{};
    for (final key in keys) if (containsKey(key)) map[key] = this[key]!;
    return map;
  }
}

/// Extension on [ValueListenable] for reactive component rebuilds.
extension ValueListenableExtension<T> on ValueListenable<T> {
  /// Rebuilds a component based on listenable's value changes.
  ///
  /// Example:
  /// ```dart
  /// final counter = ValueNotifier(0);
  /// counter.rebuild((value) => Text(value.toString()));
  /// ```
  Component rebuild(Component Function(T value) builder) {
    return ValueListenableBuilder(
      listenable: this,
      builder: (_, value) => builder(value),
    );
  }
}

/// Extension on [String] providing text formatting,
/// validation, and parsing utilities.
extension StringExtension on String {
  /// Formats text to title case.
  ///
  /// Example:
  /// ```dart
  /// final text = 'hello there';
  /// final formatted = text.toTitleCase();
  /// // returns: 'Hello There'
  /// ```
  String toTitleCase() {
    final value = trim()
        .split(' ')
        .map((s) {
          s = s.withoutSymbols;
          if (s.isEmpty) return '';

          if (s.length == 1) return s.toUpperCase();

          final first = s[0].toUpperCase();
          final rest = s.substring(1).toLowerCase();

          return '$first$rest';
        })
        .join(' ')
        .trim();

    return value.isEmpty ? this : value;
  }

  /// Normalizes currency symbol (e.g NGN -> ₦, USD -> $)
  ///
  /// Example:
  /// ```dart
  /// final text = 'USD';
  /// final normalized = text.normalizeCurrency;
  /// // returns: '$'
  /// ```
  String get normalizeCurrency => switch (toUpperCase()) {
    'NGN' || '₦' => r'₦',
    'USD' || '\$' => r'$',
    'EUR' || '€' => r'€',
    'GBP' || '£' => r'£',
    _ => this,
  };

  /// Truncates string with ellipsis, collapses multiple spaces to one.
  ///
  /// Example:
  /// ```dart
  /// final text = 'hello there, how are you?';
  /// final compact = text.truncate(10);
  /// // returns: 'Hello there...'
  /// ```
  String truncate([int maxLength = 90]) {
    final text = trim().replaceAll(RegExp(r'\s+'), ' ');
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Currency formatter.
  ///
  /// Example:
  /// ```dart
  /// final text = '2500.56';
  /// final currency = text.toCurrency();
  /// // returns: '$2,500.56'
  /// ```
  String toCurrency([String symbol = '\$']) {
    if (isEmpty) return this;

    symbol = symbol.normalizeCurrency;

    // remove letters and symbols except dot
    final value = replaceAll(RegExp(r'[^0-9.]'), '');
    final doubleValue = double.tryParse(value) ?? 0.0;
    final fixedValue = doubleValue.toStringAsFixed(2);
    final parts = fixedValue.split('.');

    String mathFunc(Match match) => '${match[1]},';

    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final result = parts[0].replaceAllMapped(reg, mathFunc);

    return parts[1] == '00' ? '$symbol$result' : '$symbol$result.${parts[1]}';
  }

  /// Removes `data:*/*;base64,` from a Data URL.
  ///
  /// Example:
  /// ```dart
  /// final text = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFC';
  /// final base64 = text.base64Only;
  /// // returns: 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFC'
  /// ```
  String get base64Only => startsWith('data:') ? split(',').last : this;

  /// Extracts URL from this string.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Please visit https://example.com';
  /// final url = text.extractLink;
  /// // returns: 'https://example.com'
  /// ```
  String? get extractLink =>
      RegExp(r'(https?://[^\s]+)').firstMatch(this)?.group(0);

  /// Returns true if this is a valid url.
  ///
  /// Example:
  /// ```dart
  /// final text = 'https://example.com';
  /// final isUrl = text.isUrl;
  /// // returns: true
  /// ```
  bool get isUrl => RegExp(
    r'^(?:(?:https?|ftp):\/\/)?' // optional scheme
    r'(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}' // domain
    r'(?::\d{1,5})?' // optional port
    r'(?:[/?#][^\s]*)?$', // optional path, query, or fragment
    caseSensitive: false,
  ).hasMatch(trim());

  /// Returns true if this is a valid email address.
  ///
  /// Example:
  /// ```dart
  /// final text = 'example@example.com';
  /// final isEmail = text.isEmail;
  /// // returns: true
  /// ```
  bool get isEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    caseSensitive: false,
  ).hasMatch(trim());

  /// Returns the first two letters.
  ///
  /// Example:
  /// ```dart
  /// final text = 'John Doe';
  /// final initials = text.initials;
  /// // returns: 'JD'
  /// ```
  String get initials {
    // check if the string is empty or just whitespace
    if (trim().isEmpty) return '-';

    try {
      return split(' ')
          .map((part) => part.withoutSymbols)
          .where((part) => part.isNotEmpty)
          .map((part) => part[0])
          .take(2)
          .join()
          .toUpperCase();
    } catch (_) {
      return '-';
    }
  }

  /// Returns this string without numbers and white spaces.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World 123';
  /// final withoutNumbersAndSpaces = text.withoutNumbersAndSpaces;
  /// // returns: 'HelloWorld'
  /// ```
  String get withoutNumbersAndSpaces => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Returns this string without special characters and symbols.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World! 123';
  /// final withoutSpecialCharactersAndSymbols = text.withoutSymbols;
  /// // returns: 'HelloWorld123'
  /// ```
  String get withoutSymbols => replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
}

/// Extension on nullable [String] for null and empty checks.
extension NullishStringExtension on String? {
  /// Returns true if this string is null or empty.
  ///
  /// Example:
  /// ```dart
  /// final text = '  ';
  /// final isNullOrEmpty = text.isNullOrEmpty;
  /// // returns: true
  /// ```
  bool get isNullOrEmpty {
    final trim = this?.trim();
    return trim == null || trim.isEmpty;
  }

  /// Returns true if this string is not null and not empty.
  ///
  /// Example:
  /// ```dart
  /// final text = 'Hello World';
  /// final isNotNullAndEmpty = text.isNotNullAndEmpty;
  /// // returns: true
  /// ```
  bool get isNotNullAndEmpty => !isNullOrEmpty;
}

/// Extension on [num] providing currency formatting,
/// rounding, and type check utilities.
extension NumExtension on num {
  /// Currency formatter (e.g '2500.56' -> '$2,500.56').
  ///
  /// Example:
  /// ```dart
  /// final number = 2500.56;
  /// final currency = number.toCurrency();
  /// // returns: '$2,500.56'
  /// ```
  String toCurrency([String? symbol]) => toString().toCurrency(symbol ?? '\$');

  /// Rounds up to nearest integer (e.g 4.123456789.roundUp -> 5).
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundUp = number.roundUp;
  /// // returns: 5
  /// ```
  int get roundUp => ceil();

  /// Rounds down to nearest integer (e.g 4.123456789.roundDown -> 4)
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundDown = number.roundDown;
  /// // returns: 4
  /// ```
  int get roundDown => floor();

  /// Rounds to [places] decimal places (e.g 4.123456789.roundTo(4) -> 4.1235)
  ///
  /// Example:
  /// ```dart
  /// final number = 4.123456789;
  /// final roundTo = number.roundTo(4);
  /// // returns: 4.1235
  /// ```
  double roundTo(int places) => double.tryParse(toStringAsFixed(places)) ?? 0.0;

  /// Returns true if this number is an integer.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4;
  /// final number2 = 4.0;
  /// final number3 = 4.1;
  ///
  /// final isInteger1 = number1.isInteger;
  /// // returns: true
  ///
  /// final isInteger2 = number2.isInteger;
  /// // returns: true
  ///
  /// final isInteger3 = number3.isInteger;
  /// // returns: false
  /// ```
  bool get isInteger => this % 1 == 0;

  /// Returns true if this number is a double.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4.0;
  /// final number2 = 4.1;
  ///
  /// final isDouble1 = number1.isDouble;
  /// // returns: false
  ///
  /// final isDouble2 = number2.isDouble;
  /// // returns: true
  /// ```
  bool get isDouble => !isInteger;

  /// Returns a string representation of this number without
  /// unnecessary trailing decimal places.
  ///
  /// Example:
  /// ```dart
  /// final number1 = 4.0;
  /// final number2 = 4.123;
  ///
  /// final string1 = number1.toCleanString;
  /// // returns: '4'
  ///
  /// final string2 = number2.toCleanString;
  /// // returns: '4.123'
  /// ```
  String get toCleanString => isDouble ? toString() : toStringAsFixed(0);

  /// Returns a CSS-formatted dimension string with 'px' unit.
  ///
  /// Example:
  /// ```dart
  /// final number = 12.34;
  /// final pxString = number.toPx;
  /// // returns: '12.34px'
  /// ```
  String get toPx => '${toCleanString}px';
}

/// Extension on [BuildContext] for accessing Naki
/// theme state and properties.
extension ContextExtension on BuildContext {
  /// Toggles between dark, light and system theme modes.
  ///
  /// The component where this method is used must be a descendant of
  /// [NakiThemeProvider], otherwise this operation will silently fail.
  void toggleTheme() => NakiThemeProvider.toggleMode(this);

  /// Sets the global theme to the provided [mode].
  ///
  /// The component where this method is used must be a descendant of
  /// [NakiThemeProvider], otherwise this operation will silently fail.
  void setTheme(ThemeMode mode) => NakiThemeProvider.setMode(this, mode);

  /// Returns the active theme mode for this context.
  ///
  /// Defaults to [ThemeMode.system] if no [NakiThemeProvider] ancestor is found.
  ThemeMode get themeMode => NakiThemeProvider.modeOf(this);

  /// Returns the design tokens for the active theme in this context.
  ///
  /// Defaults to global tokens if no [NakiThemeProvider] ancestor is found.
  Tokens get themeTokens => NakiThemeProvider.tokensOf(this);

  // /////////////////////
  // ACCESS COLOR TOKEN VALUES
  // /////////////////////

  /// Applies opacity to a [Color].
  ///
  /// Example:
  /// ```dart
  /// final color = context.primaryColor;
  /// final withOpacity = context.withOpacity(color, 0.5);
  /// // returns: Color(0x80FF0000) (50% opacity)
  /// ```
  Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);

  // Brand Colors

  /// Primary color.
  Color get primaryColor => themeTokens.primaryColor.color!;

  /// Secondary color.
  Color get secondaryColor => themeTokens.secondaryColor.color!;

  /// Accent color.
  Color get accentColor => themeTokens.accentColor.color!;

  // Base Accent Colors

  /// Green accent color.
  Color get green => themeTokens.green.color!;

  /// Yellow accent color.
  Color get yellow => themeTokens.yellow.color!;

  /// Red accent/danger color.
  Color get red => themeTokens.red.color!;

  // Text & Background Colors

  /// Default text color.
  Color get textColor => themeTokens.baseTextColor.color!;

  /// Default text placeholder color.
  Color get placeholderColor => themeTokens.placeholderColor.color!;

  /// Muted background/foreground color.
  Color get mutedColor => themeTokens.mutedColor.color!;

  /// Subtitle or secondary text color.
  Color get subtitleColor => themeTokens.subtitleColor.color!;

  // Selection Colors

  /// Selected item color.
  Color get selectedItemColor => themeTokens.selectedItemColor.color!;

  /// Selected text background color.
  Color get selectedTextBgColor => themeTokens.selectedTextBgColor.color!;

  /// Selected text color.
  Color get selectedTextColor => themeTokens.selectedTextColor.color!;

  /// Selected item background color.
  Color get selectedItemBgColor => themeTokens.selectedItemBgColor.color!;

  // Surface & Background Colors

  /// Root background color.
  Color get backgroundColor => themeTokens.backgroundColor.color!;

  /// Alias for surface variant color.
  Color get surfaceColor => themeTokens.surfaceVariantColor.color!;

  /// Secondary surface background color variation.
  Color get surfaceVariantColor => themeTokens.surfaceVariantColor.color!;

  /// Muted background color for container surfaces.
  Color get surfaceMutedColor => themeTokens.surfaceMutedColor.color!;

  // Border & Status Colors

  /// Default border color.
  Color get borderColor => themeTokens.borderColor.color!;

  /// Error state color.
  Color get errorColor => themeTokens.errorColor.color!;

  /// Success state color.
  Color get successColor => themeTokens.successColor.color!;

  /// Warning state color.
  Color get warningColor => themeTokens.warningColor.color!;

  /// Info state color.
  Color get infoColor => themeTokens.infoColor.color!;

  // Weak Callout Colors

  /// Weak background color for error callouts.
  Color get errorWeakColor => themeTokens.errorWeakColor.color!;

  /// Weak background color for success callouts.
  Color get successWeakColor => themeTokens.successWeakColor.color!;

  /// Weak background color for warning callouts.
  Color get warningWeakColor => themeTokens.warningWeakColor.color!;

  /// Weak background color for info callouts.
  Color get infoWeakColor => themeTokens.infoWeakColor.color!;

  // Shadow Colors

  /// Shadow overlay color.
  Color get shadowColor => themeTokens.shadowColor.color!;

  /// Small shadow overlay color.
  Color get smallShadowColor => themeTokens.smallShadowColor.color!;

  /// Medium shadow overlay color.
  Color get mediumShadowColor => themeTokens.mediumShadowColor.color!;

  /// Large shadow overlay color.
  Color get largeShadowColor => themeTokens.largeShadowColor.color!;

  // Interactive & State Component Colors

  /// Hover background color for buttons.
  Color get buttonHoverColor => themeTokens.buttonHoverBgColor.color!;

  /// Hover color for components.
  Color get hoverColor => themeTokens.hoverColor.color!;

  /// Border color for focused components.
  Color get focusBorderColor => themeTokens.focusBorderColor.color!;

  /// Border color for hovered inputs.
  Color get fieldHoverColor => themeTokens.fieldHoverColor.color!;

  /// Background color for disabled components.
  Color get disabledBgColor => themeTokens.disabledBgColor.color!;

  /// Color for disabled components.
  Color get disabledColor => themeTokens.disabledColor.color!;

  /// Spinner track color.
  Color get spinnerTrackColor => themeTokens.spinnerTrackColor.color!;

  /// Spinner surface color.
  Color get spinnerSurfaceColor => themeTokens.spinnerSurfaceColor.color!;

  /// Background color for dropdown menu.
  Color get dropdownMenuBgColor => themeTokens.dropdownMenuBgColor.color!;

  /// Text color inside input fields.
  Color get inputTextColor => themeTokens.inputTextColor.color!;

  /// Form field label color.
  Color get labelColor => themeTokens.labelColor.color!;

  /// Button background color.
  Color get buttonBackgroundColor => themeTokens.buttonBackgroundColor.color!;

  /// Button foreground color.
  Color get buttonColor => themeTokens.buttonColor.color!;

  /// Form field background color.
  Color get fieldBackgroundColor => themeTokens.fieldBackgroundColor.color!;

  /// Slider thumb color.
  Color get sliderThumbColor => themeTokens.sliderThumbColor.color!;

  /// Slider track color.
  Color get sliderTrackColor => themeTokens.sliderTrackColor.color!;

  /// Switch thumb color.
  Color get switchThumbColor => themeTokens.switchThumbColor.color!;

  /// Radio button color.
  Color get radioBtnColor => themeTokens.radioBtnColor.color!;

  /// Appbar background color.
  Color get appbarBgColor => themeTokens.appbarBgColor.color!;

  /// Bottom navigation bar background color.
  Color get bottomNavbarBgColor => themeTokens.bottomNavbarBgColor.color!;

  // Table & Overlay Colors

  /// Table header background color.
  Color get tableHeaderBg => themeTokens.tableHeaderBg.color!;

  /// Table row hover background color.
  Color get tableRowHoverBg => themeTokens.tableRowHoverBg.color!;

  /// Table header border color.
  Color get tableHeaderBorderColor => themeTokens.tableHeaderBorderColor.color!;

  /// Snackbar background color.
  Color get snackbarBgColor => themeTokens.snackbarBgColor.color!;

  /// Snackbar foreground color.
  Color get snackbarForegroundColor =>
      themeTokens.snackbarForegroundColor.color!;

  /// Banner background color.
  Color get bannerBgColor => themeTokens.bannerBgColor.color!;

  /// Banner foreground color.
  Color get bannerForegroundColor => themeTokens.bannerForegroundColor.color!;

  /// Banner border color.
  Color get bannerBorderColor => themeTokens.bannerBorderColor.color!;

  /// Tooltip background color.
  Color get tooltipBgColor => themeTokens.tooltipBgColor.color!;

  /// Tooltip text color.
  Color get tooltipTextColor => themeTokens.tooltipTextColor.color!;

  /// Popover background color.
  Color get popoverBgColor => themeTokens.popoverBgColor.color!;

  /// Popover text color.
  Color get popoverTextColor => themeTokens.popoverTextColor.color!;

  /// Popover border color.
  Color get popoverBorderColor => themeTokens.popoverBorderColor.color!;

  /// Dialog background color.
  Color get dialogBgColor => themeTokens.dialogBgColor.color!;

  /// Dialog barrier backdrop color.
  Color get dialogBarrierBg => themeTokens.dialogBarrierBg.color!;

  /// Drawer background color.
  Color get drawerBgColor => themeTokens.drawerBgColor.color!;

  /// Drawer barrier backdrop color.
  Color get drawerBarrierBg => themeTokens.drawerBarrierBg.color!;

  /// BottomSheet background color.
  Color get bottomSheetBgColor => themeTokens.bottomSheetBgColor.color!;

  /// BottomSheet barrier backdrop color.
  Color get bottomSheetBarrierBg => themeTokens.bottomSheetBarrierBg.color!;
}

final _timeAgoNotifiers = <String, ValueNotifier<String>>{};

/// Extension on [DateTime] providing date and time formatting.
extension DateTimeExtension on DateTime {
  /// Returns this datetime as an ISO-8601 UTC string.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 10, 30);
  /// final utcString = date.toUtcString;
  /// // returns: '2024-02-24T10:30:00.000Z'
  /// ```
  String get toUtcString => toUtc().toIso8601String();

  /// Formats date as '24th, Feb 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toDdMmmYyyy;
  /// // returns: '24th, Feb 2024'
  /// ```
  String get toDdMmmYyyy {
    final day = this.day;
    final month = monthNameShort;
    final year = this.year;
    return '$day$_suffix, $month $year';
  }

  /// Returns day suffix (st, nd, rd, th).
  String get _suffix {
    if (day >= 11 && day <= 13) return 'th';

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Returns full month name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final month = date.monthName;
  /// // returns: 'February'
  /// ```
  String get monthName => [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];

  /// Returns full day name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final dayName = date.dayName;
  /// // returns: 'Friday'
  /// ```
  String get dayName => [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];

  /// Returns short day name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final dayName = date.dayNameShort;
  /// // returns: 'Fri'
  /// ```
  String get dayNameShort =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];

  /// Returns short month name.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final month = date.monthNameShort;
  /// // returns: 'Feb'
  /// ```
  String get monthNameShort => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];

  /// Formats date as '24 February 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toDdMmmmYyyy;
  /// // returns: '24 February 2024'
  /// ```
  String get toDdMmmmYyyy => '$day $monthName $year';

  /// Formats date as 'February 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toMonthYear;
  /// // returns: 'February 2024'
  /// ```
  String get toMonthYear => '$monthName $year';

  /// Formats date as '24/02/2026'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 24);
  /// final formatted = date.toDateWithSlashes;
  /// // returns: '24/02/2026'
  /// ```
  String get toDateWithSlashes =>
      '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';

  /// Formats date and time as '24/02/2026 12:03 AM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 2, 24, 0, 3);
  /// final formatted = date.toDateAndTimeWithSlashes;
  /// // returns: '24/02/2026 12:03 AM'
  /// ```
  String get toDateAndTimeWithSlashes => '$toDateWithSlashes $toTimeAmPm';

  /// Formats date as 'February 24, 2024'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24);
  /// final formatted = date.toMmmmDdYyyy;
  /// // returns: 'February 24, 2024'
  /// ```
  String get toMmmmDdYyyy => '$monthName $day, $year';

  /// Formats time as '10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toTimeAmPm;
  /// // returns: '10:30 PM'
  /// ```
  String get toTimeAmPm {
    final amPm = hour < 12 ? 'AM' : 'PM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $amPm';
  }

  /// Formats time as '20:30'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toTime;
  /// // returns: '20:30'
  /// ```
  String get toTime {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  /// Formats time as '10:30:05 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30, 5);
  /// final formatted = date.toFullTimeAmPm;
  /// // returns: '10:30:05 PM'
  /// ```
  String get toFullTimeAmPm {
    final amPm = hour < 12 ? 'AM' : 'PM';
    final formattedHour = hour % 12 == 0 ? 12 : hour % 12;
    final formattedMinute = minute.toString().padLeft(2, '0');
    final formattedSecond = second.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute:$formattedSecond $amPm';
  }

  /// Formats date and time as '24th, Feb 2024 - 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTime;
  /// // returns: '24th, Feb 2024 - 10:30 PM'
  /// ```
  String get toDateTime => '$toDdMmmYyyy - $toTimeAmPm';

  /// Formats date and time as '24 February 2024 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTimeWithoutComma;
  /// // returns: '24 February 2024 10:30 PM'
  /// ```
  String get toDateTimeWithoutComma => '$toDdMmmmYyyy $toTimeAmPm';

  /// Formats date and time as 'February 24, 2024, 10:30 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 22, 30);
  /// final formatted = date.toDateTimeLong;
  /// // returns: 'February 24, 2024, 10:30 PM'
  /// ```
  String get toDateTimeLong => '$toMmmmDdYyyy, $toTimeAmPm';

  /// Calculates time remaining in seconds until `now` and returns
  /// '04:39:01:58' or '0' if no time remaining.
  ///
  /// Example:
  /// ```dart
  /// final now = DateTime.now();
  /// final date = DateTime(2026, 6, 12, 10, 40);
  /// final remaining = date.timeRemainingUntil(now);
  /// // returns: '00:01:00:00'
  /// ```
  String timeRemainingUntil([DateTime? now]) {
    now ??= DateTime.now();

    final d = difference(now).inSeconds > 0
        ? difference(now)
        : const Duration(seconds: 0);

    if (d.inSeconds <= 0) return '0';

    final days = d.inDays;
    final hours = d.inHours.remainder(24);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    return '${days.toString().padLeft(2, '0')}:'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}'
        ':${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats date as 'Fri June 12, 2026'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12);
  /// final formatted = date.toDayMonthYear;
  /// // returns: 'Fri June 12, 2026'
  /// ```
  String get toDayMonthYear => '$dayNameShort $monthName $day, $year';

  /// Formats time as '05:00 PM WAT'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 2, 24, 17, 0);
  /// final formatted = date.toTimeWithTimeZone('WAT');
  /// // returns: '05:00 PM WAT'
  /// ```
  String toTimeWithTimeZone(String timeZone) => '$toTimeAmPm $timeZone';

  /// Formats date and time as 'Fri June 12, 2026 at 05:00 PM WAT'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12, 17, 0);
  /// final formatted = date.toDateAndTimeWithTimeZone('WAT');
  /// // returns: 'Fri June 12, 2026 at 05:00 PM WAT'
  /// ```
  String toDateAndTimeWithTimeZone(String timeZone) =>
      '$toDayMonthYear at ${toTimeWithTimeZone(timeZone)}';

  /// Formats date and time as 'Fri June 12, 2026 at 05:00 PM'.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2026, 6, 12, 17, 0);
  /// final formatted = date.toDateAndTimeOnly;
  /// // returns: 'Fri June 12, 2026 at 05:00 PM'
  /// ```
  String get toDateAndTimeOnly => '$toDayMonthYear at $toTimeAmPm';

  /// Returns true if this date is same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 24);
  /// final date2 = DateTime(2024, 2, 24);
  /// final isSame = date1.isSameAs(date2);
  /// // returns: true
  /// ```
  bool isSameAs(DateTime date) =>
      millisecondsSinceEpoch == date.millisecondsSinceEpoch;

  /// Returns true if this date is before or same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 24);
  /// final date2 = DateTime(2024, 2, 25);
  /// final isBefore = date1.isBeforeOrSameAs(date2);
  /// // returns: true
  /// ```
  bool isBeforeOrSameAs(DateTime date) => difference(date).inSeconds <= 0;

  /// Returns true if this date is after or same as the given date.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 2, 25);
  /// final date2 = DateTime(2024, 2, 24);
  /// final isAfter = date1.isAfterOrSameAs(date2);
  /// // returns: true
  /// ```
  bool isAfterOrSameAs(DateTime date) => difference(date).inSeconds >= 0;

  /// Returns true if this date is today.
  ///
  /// Example:
  /// ```dart
  /// final today = DateTime.now();
  /// final check = today.isToday;
  /// // returns: true
  /// ```
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns a ValueNotifier that updates the relative
  /// time string periodically.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime.now();
  /// final notifier = date.timeAgoNotifier;
  /// // returns: ValueNotifier('just now')
  /// ```
  ValueNotifier<String> get timeAgoNotifier {
    final key = millisecondsSinceEpoch.toString();

    // get cached notifier if available
    final cachedNotifier = _timeAgoNotifiers[key];
    if (cachedNotifier != null) return cachedNotifier;

    // compute ago time
    String _compute() {
      final d = DateTime.now().difference(this);
      if (d.inSeconds <= 0) return 'just now';

      final weeks = d.inDays ~/ 7;
      final days = d.inDays;
      final hours = d.inHours;
      final minutes = d.inMinutes;
      final seconds = d.inSeconds;

      if (weeks > 0) return '${weeks}w ago';
      if (days > 0) return '${days}d ago';
      if (hours > 0) return '${hours}h ago';
      if (minutes > 0) return '${minutes}m ago';

      return '${seconds}s ago';
    }

    // create notifier
    final notifier = ValueNotifier(_compute());

    final isRecent = DateTime.now().difference(this).inSeconds < 3600;

    // cache notifier and run timer if this date is less than 1 hour old
    if (kIsWeb && isRecent) {
      _timeAgoNotifiers[key] = notifier;

      Timer.periodic(const Duration(seconds: 1), (timer) {
        // if this date is now more than 1 hour old, cancel timer
        // and remove notifier from memory cache
        if (DateTime.now().difference(this).inHours >= 1) {
          timer.cancel();
          _timeAgoNotifiers.remove(key);
          return;
        }

        // update notifier value
        notifier.value = _compute();
      });
    }

    return notifier;
  }

  /// Formats date as '2 hours to go' or '2 days to go'
  /// or '2 minutes overdue' etc.
  ///
  /// - If `dueDate` is in the future, it returns the time
  ///   remaining until the `dueDate`.
  /// - If `dueDate` is in the past, it returns the time
  ///   since the `dueDate`.
  /// - If `dueDate` is not provided, it uses this date.
  ///
  /// Example:
  /// ```dart
  /// final futureDate = DateTime.now().add(const Duration(hours: 2));
  /// final text = futureDate.timeRemaining();
  /// // returns: '2 hours from now'
  /// ```
  String timeRemaining({
    String beforeDueDate = 'from now',
    String afterDueDate = 'overdue',
    DateTime? targetDate,
  }) {
    // get the difference between dates
    final d = (targetDate ?? this).difference(DateTime.now());

    final weeks = d.inDays ~/ 7;
    final days = d.inDays;
    final hrs = d.inHours;
    final mins = d.inMinutes;
    final secs = d.inSeconds;

    final absWeeks = weeks.abs();
    final absDays = days.abs();
    final absHrs = hrs.abs();
    final absMins = mins.abs();
    final absSecs = secs.abs();

    String value;

    // ////////////////////////////////////
    // Time is not due yet
    // ////////////////////////////////////
    if (weeks > 0) {
      value = '$weeks week${weeks > 1 ? 's' : ''} $beforeDueDate';
    } else if (days > 0) {
      value = '$days day${days > 1 ? 's' : ''} $beforeDueDate';
    } else if (hrs > 0) {
      value = '$hrs hour${hrs > 1 ? 's' : ''} $beforeDueDate';
    } else if (mins > 0) {
      value = '$mins minute${mins > 1 ? 's' : ''} $beforeDueDate';
    } else if (secs > 0) {
      value = '$secs second${secs > 1 ? 's' : ''} $beforeDueDate';
    }
    // ////////////////////////////////////
    // Time is overdue
    // ////////////////////////////////////
    else if (weeks < 0) {
      value = '$absWeeks week${absWeeks > 1 ? 's' : ''} $afterDueDate';
    } else if (days < 0) {
      value = '$absDays day${absDays > 1 ? 's' : ''} $afterDueDate';
    } else if (hrs < 0) {
      value = '$absHrs hour${absHrs > 1 ? 's' : ''} $afterDueDate';
    } else if (mins < 0) {
      value = '$absMins minute${absMins > 1 ? 's' : ''} $afterDueDate';
    } else {
      value = '$absSecs second${absSecs > 1 ? 's' : ''} $afterDueDate';
    }

    return value.trim();
  }
}
