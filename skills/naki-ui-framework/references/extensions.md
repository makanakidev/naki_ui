# Framework extensions

Extensions provided by `package:naki_ui/theme.dart` (and imported across Naki UI components) offer ergonomic utilities for context theme access, string formatting and validation, number calculations, date/time manipulation, reactive listening, and CSS property maps.

---

## `ContextExtension` on `BuildContext`

Directly access active theme modes, tokens, and semantic color values from the widget tree:

```dart
@override
Component build(BuildContext context) {
  final isDark = context.themeMode == ThemeMode.dark;
  final primary = context.primaryColor;
  final borderColor = context.borderColor;
  final surface = context.surfaceColor;

  return Container(
    padding: const EdgeInsets.all(Dim.px(16)),
    decoration: BoxDecorationData(
      color: surface,
      border: BorderData.all(BorderSideData(color: borderColor)),
      borderRadius: const BorderRadiusData.all(Dim.px(8)),
    ),
    child: Row(
      children: [
        NakiText('Current mode: ${context.themeMode.name}'),
        Button.filled(
          primary,
          child: const NakiText('Toggle Theme'),
          onTap: () => context.toggleTheme(),
        ),
      ],
    ),
  );
}
```

### Theme mode & token operations

- `context.themeMode`: Returns the active `ThemeMode` (`ThemeMode.light`, `dark`, or `system`).
- `context.themeTokens`: Access all raw `Tokens` configured in `NakiThemeProvider`.
- `context.toggleTheme()`: Toggles between dark and light modes.
- `context.setTheme(ThemeMode mode)`: Sets a specific theme mode.
- `context.withOpacity(Color color, double opacity)`: Applies opacity to a given color.

### Direct semantic color getters

- **Brand**: `primaryColor`, `secondaryColor`, `accentColor`.
- **Accents**: `green`, `yellow`, `red`.
- **Text**: `textColor`, `placeholderColor`, `mutedColor`, `subtitleColor`.
- **Surfaces**: `backgroundColor`, `surfaceColor`, `surfaceVariantColor`, `surfaceMutedColor`.
- **Status & Borders**: `borderColor`, `errorColor`, `successColor`, `warningColor`, `infoColor`.
- **Weak Callouts**: `errorWeakColor`, `successWeakColor`, `warningWeakColor`, `infoWeakColor`.
- **Shadows**: `shadowColor`, `smallShadowColor`, `mediumShadowColor`, `largeShadowColor`.
- **Component Specific**: `buttonHoverColor`, `fieldHoverColor`, `focusBorderColor`, `disabledBgColor`, `inputTextColor`, `labelColor`, `tableHeaderBg`, `dialogBgColor`, `drawerBgColor`, `snackbarBgColor`, `tooltipBgColor`, `popoverBgColor`, `bottomSheetBgColor`.

---

## `StringExtension` on `String` & `NullishStringExtension` on `String?`

Text formatting, case conversion, validation, and data sanitization:

```dart
final title = 'hello world dashboard'.toTitleCase(); // 'Hello World Dashboard'
final sentence = 'welcome user. please review.'.toSentenceCase(); // 'Welcome user. Please review.'
final currency = '12500.5'.toCurrency('USD'); // '$12,500.50'
final truncated = 'Very long description text here'.truncate(20); // 'Very long descriptio...'
final initials = 'John Doe'.initials; // 'JD'

// Validations
final validEmail = 'user@example.com'.isEmail; // true
final validUrl = 'https://nakiverse.com'.isUrl; // true
final link = 'Check https://dart.dev now'.extractLink; // 'https://dart.dev'

// Sanitization
final rawNumbers = 'Order #123-456!'.withoutSymbols; // 'Order123456'
final base64Clean = 'data:image/png;base64,iVBORw...'.base64Only; // 'iVBORw...' the base64 string without the data prefix

// Null & empty checks on String?
String? input = '   ';
if (input.isNullOrEmpty) {
  // true for null, empty, or whitespace-only strings
}
if (input.isNotNullAndEmpty) {
  // true only when string has non-whitespace characters
}
```

---

## `NumExtension` on `num`

Currency formatting, precision rounding, and CSS unit conversion:

```dart
final amount = 4500.5.toCurrency('₦'); // '₦4,500.50'
final rounded = 4.12879.roundTo(2); // 4.13
final up = 4.2.roundUp; // 5
final down = 4.9.roundDown; // 4

final isInt = 4.0.isInteger; // true
final isDbl = 4.25.isDouble; // true

final clean = 4.0.toCleanString; // '4'
final pxVal = 16.toPx; // '16px'
```

---

## `DateTimeExtension` on `DateTime`

Comprehensive date, time, and relative duration formatters:

```dart
final now = DateTime.now();

// Formatted date strings
final shortDate = now.toDdMmmYyyy; // '28th, Sep 2026'
final fullDate = now.toDdMmmmYyyy; // '28 September 2026'
final monthYear = now.toMonthYear; // 'September 2026'
final slashedDate = now.toDateWithSlashes; // '28/09/2026'
final dayMonthYear = now.toDayMonthYear; // 'Mon Sep 28, 2026'

// Formatted time strings
final timeAmPm = now.toTimeAmPm; // '10:30 PM'
final militaryTime = now.toTime; // '22:30'
final fullTime = now.toFullTimeAmPm; // '10:30:45 PM'
final timeWithTz = now.toTimeWithTimeZone('UTC'); // '10:30 PM UTC'

// Combined date and time
final fullDateTime = now.toDateTime; // '28th, Sep 2026 - 10:30 PM'
final longDateTime = now.toDateTimeLong; // 'September 28, 2026, 10:30 PM'
final slashedDateTime = now.toDateAndTimeWithSlashes; // '28/09/2026 10:30 PM'

// Date comparisons
final isToday = now.isToday; // true
final isSame = now.isSameAs(otherDate);
final isBefore = now.isBeforeOrSameAs(deadline);

// Relative & duration utilities
final dueText = deadline.timeRemaining(beforeDueDate: 'remaining', afterDueDate: 'overdue');
final countdown = deadline.timeRemainingUntil(); // '04:39:01:58'

// Reactive client-side time ago notifier (updates automatically every second for recent dates)
final timeAgoNotifier = messageDate.timeAgoNotifier; // ValueNotifier('2m ago')
```

---

## `ValueListenableExtension<T>` on `ValueListenable<T>`

Inline reactive UI rebuilds from a `ValueListenable` or `ValueNotifier`:

```dart
final counter = ValueNotifier<int>(0);

// Declarative rebuild helper wrapping ValueListenableBuilder
counter.rebuild((count) => NakiText('Count: $count'))
```

---

## `CssPropsExtension` on `Map<String, String>`

Manipulate inline style maps and convert them to valid CSS string declarations:

```dart
final baseStyles = {'display': 'flex', 'gap': '12px'};
final extraStyles = {'align-items': 'center', 'color': 'red'};

final merged = baseStyles.combine(extraStyles);
// {'display': 'flex', 'gap': '12px', 'align-items': 'center', 'color': 'red'}

final filtered = merged.except(['color']);
// {'display': 'flex', 'gap': '12px', 'align-items': 'center'}

final picked = merged.only(['display', 'gap']);
// {'display': 'flex', 'gap': '12px'}

final cssString = merged.cssText;
// 'display: flex; gap: 12px; align-items: center; color: red;'
```
