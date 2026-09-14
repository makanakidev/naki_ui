# Basic components

Assume the public imports from `references/imports-and-conventions.md`. Add `package:jaspr_icons_pack/jaspr_icons_pack.dart` when using the icon examples.

## Column

Arrange children vertically with flex alignment and optional spacing.

```dart
const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  spacing: 12,
  children: [
    Heading('Account', level: 2),
    NakiText('Signed in'),
  ],
)
```

Use `scrollable: true` only when the column itself should own scrolling. Prefer `ListView` for long collections and avoid nesting it inside another vertical scroller without constraints.

## Row

Arrange children horizontally. Use `Expanded` or `Flexible` for responsive allocation.

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  spacing: 8,
  children: [
    const Expanded(child: NakiText('Quarterly report.pdf')),
    Button.text('Download', onTap: downloadReport),
  ],
)
```

Set `scrollable: true` for an intentional horizontal rail. Use `Wrap` when items should move onto additional lines.

## Image

Render a network, asset, data, or SVG source with sizing and fit controls.

```dart
Image(
  '/images/profile.webp',
  alt: 'Portrait of Ada Lovelace',
  size: SizeConstraints(
    width: Dim.px(96),
    height: Dim.px(96),
  ),
  fit: BoxFit.cover,
  radius: BorderRadiusData.all(Dim.percent(50)),
)
```

Images lazy-load by default. Set `lazyLoad: false` only for above-the-fold content that must load immediately. Use meaningful `alt` text for informative images and an empty alt value for decorative images. Enable `cache` only when the source and application caching behavior make it appropriate.

## NakiText

Render plain text with a typed `TextStyle`.

```dart
NakiText(
  'Updated 5 minutes ago',
  style: TextStyle(
    color: context.subtitleColor,
    fontSize: const Dim.rem(0.875),
    lineHeight: const Dim.em(1.5),
  ),
)
```

Use `RichText` when different spans need distinct styling or recognizers. Use `Heading` for actual document headings instead of visually enlarging ordinary body text.

## Button

Use `Button` for actions. It supports async callbacks, disabled and loading states, native button types, form validation, dimensions, decoration, and accessibility attributes.

```dart
Button.filled(
  context.primaryColor,
  id: 'save-profile',
  showLoadingIndicator: true,
  onTap: () async => saveProfile(),
  child: const NakiText('Save profile'),
)
```

Available constructors:

- `Button(...)` for the standard style.
- `Button.filled(color, ...)` for a filled action.
- `Button.outlined(border, ...)` for an outlined action.
- `Button.icon(icon, ...)` for an icon-only action.
- `Button.iconText(...)` for combined icon and text.
- `Button.text(text, ...)` for a text action.

For icon-only actions, pass an accessible name through `attributes`, for example `{'aria-label': 'Delete message'}`. Inside `FormBuilder`, use `type: ButtonType.button` and `validateForm: true` for submission, or `resetForm: true` for reset behavior. Do not enable both validation and reset on the same button.

## Icon

Render an `IconData` value, optionally as an action.

```dart
Icon(
  LucideIcons.icon_search,
  size: 20,
  color: context.textColor,
  onTap: openSearch,
  semanticLabel: 'Open search',
)
```

Always provide `semanticLabel` when `onTap` is set or when the glyph conveys information not repeated in visible text. Prefer `Button.icon` when full button behavior and styling are required.

## Spinner

Show indeterminate progress.

```dart
const Spinner(
  size: Dim.px(32),
  thickness: 3,
  semanticLabel: 'Saving changes',
)
```

Use `Spinner.ios` for the iOS-style variant and `Spinner.glass(surfaceColor: ...)` over translucent surfaces. Keep a meaningful semantic label and pair long operations with explanatory text.

## GestureDetector

Attach typed gestures to one child.

```dart
GestureDetector(
  semanticRole: 'button',
  semanticLabel: 'Open message details',
  gestures: Gestures(
    onClick: (_) => openMessage(),
    onDoubleClick: (_) => archiveMessage(),
  ),
  child: const Card(
    child: NakiText('Message from Support'),
  ),
)
```

Prefer a semantic `Button` for ordinary activation. When wrapping a non-interactive child, provide an appropriate role, accessible name, focusability, and keyboard equivalent through supported properties and attributes.

## Banner

Display persistent informational, success, warning, or error feedback.

```dart
Banner(
  severity: BannerType.warning,
  dismissible: true,
  primary: const NakiText('Your session expires soon.'),
  secondary: const NakiText('Save your work before continuing.'),
  actions: [Button.text('Extend session', onTap: extendSession)],
  onClose: dismissWarning,
)
```

Use `primary` for the concise message and `secondary` for supporting detail. Match `severity` to meaning, not decoration. Provide `onClose` when dismissible state must be synchronized with application state.
