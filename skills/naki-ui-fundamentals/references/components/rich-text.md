# Rich text and typography components

## RichText

Render a tree of inline spans with shared alignment and base styling.

```dart
RichText(
  textAlign: TextAlign.start,
  style: const TextStyle(lineHeight: Dim.em(1.5)),
  text: TextSpan(
    text: 'Your plan renews on ',
    children: const [
      TextSpan(
        text: '30 September',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: '.'),
    ],
  ),
)
```

The root `text` is an inline span. Use `NakiText` for plain text without mixed inline formatting.

## TextSpan

Combine text, child spans, a local `TextStyle`, semantics, and an optional recognizer.

```dart
TextSpan(
  text: 'Read the ',
  children: [
    TextSpan(
      text: 'privacy policy',
      style: const TextStyle(
        color: Colors.blue,
        decorationLine: TextDecorationLine.underline,
      ),
      semanticsLabel: 'Open the privacy policy',
      recognizer: Gestures(onClick: (_) => openPrivacyPolicy()),
    ),
  ],
)
```

Keep interactive text recognizable as an action, supply a semantic label when the visible wording is insufficient, and support the expected keyboard behavior.

## ComponentSpan

Insert a component into inline text and choose its baseline alignment.

```dart
const RichText(
  text: TextSpan(
    text: 'Verified ',
    children: [
      ComponentSpan(
        baseline: Baseline.middle,
        semanticsLabel: 'verified account',
        child: Icon(LucideIcons.icon_badge_check, size: 16),
      ),
    ],
  ),
)
```

Use `Baseline.baseline` for text-like content and `Baseline.middle` when the inserted component should align visually with the line center. Add the icon package import for the selected icon set.

## Bold

```dart
const Bold(
  'Important',
  style: TextStyle(color: Colors.red),
)
```

Use `Bold` for inline emphasis, not as a substitute for heading structure.

## Italic

```dart
const Italic('Estimated delivery: 2–3 days')
```

Use italic styling sparingly and keep essential distinctions available without relying on font style alone.

## Underline

```dart
const Underline('Reference number A-1042')
```

Avoid making non-interactive underlined text look like a link.

## Strikethrough

```dart
const Strikethrough('₦12,000')
```

Pair a struck-through price or status with the replacement value or explanatory text.

## Heading

Render a semantic heading with a level from 1 through 6.

```dart
const Heading(
  'Billing settings',
  level: 2,
  style: TextStyle(fontSize: Dim.rem(1.5)),
)
```

Keep heading levels hierarchical. Use one page-level heading and do not choose a level only for its visual size.

## SubHeading

Render Naki UI's standard subheading treatment.

```dart
const SubHeading('Payment methods')
```

Use `Heading(level: ...)` when the document outline requires a specific semantic level; use `SubHeading` for the library's predefined subordinate heading presentation.
