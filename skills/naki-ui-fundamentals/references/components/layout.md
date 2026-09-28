# Layout components

## Align

Position one child within the available box.

```dart
const Align(
  alignment: Alignment.bottomRight,
  widthFactor: 1,
  heightFactor: 1,
  child: NakiText('Bottom right'),
)
```

Use `widthFactor` and `heightFactor` only when the aligned box should size relative to its child. Give the parent explicit constraints when alignment needs visible free space.

## AspectRatio

Constrain a child to a predefined ratio.

```dart
const AspectRatio(
  aspectRatio: AspectRatioType.ratio16_9,
  child: Image('images/video-cover.webp', fit: ObjectFit.cover),
)
```

Available ratios include 16:9, 4:3, 1:1, 3:2, 9:16, 4:5, 21:9, and 1:2, plus descriptive aliases such as `youtubeVideo`, `stories`, and `cinematic`.

## Flexible

Allow a direct child of `Row` or `Column` to use available main-axis space without requiring it to fill that space.

```dart
const Row(
  children: [
    Flexible(
      flex: 2,
      fit: FlexFit.loose,
      child: NakiText('Flexible content'),
    ),
    NakiText('Fixed content'),
  ],
)
```

`flex` must be greater than zero. `Flexible` must be a direct child of a non-scrollable `Row` or `Column` because a scrollable main axis is unbounded.

## Expanded

Force a direct flex child to fill its allocated main-axis space.

```dart
const Row(
  children: [
    Expanded(child: NakiText('Fills remaining width')),
    NakiText('Trailing'),
  ],
)
```

`Expanded` is equivalent to `Flexible(fit: FlexFit.tight)`. Do not use it in a scrollable flex container.

## Padding

Inset a child within its box.

```dart
const Padding(
  padding: EdgeInsets.symmetric(
    horizontal: Dim.px(24),
    vertical: Dim.px(12),
  ),
  child: NakiText('Padded content'),
)
```

Use `Padding` for internal spacing and `Margin` for external separation.

## Margin

Add space outside a child.

```dart
const Margin(
  margin: EdgeInsets.only(bottom: Dim.px(16)),
  child: Card(child: NakiText('Card with outer spacing')),
)
```

Avoid stacking adjacent margins when a parent `spacing` or `gap` expresses the layout more clearly.

## SizedBox

Give a child explicit width or height, or insert fixed space.

```dart
const Row(
  children: [
    NakiText('Leading'),
    SizedBox.width(Dim.px(12)),
    SizedBox(
      width: Dim.px(120),
      height: Dim.px(40),
      child: NakiText('Sized'),
    ),
  ],
)
```

Use `SizedBox.fromSize(size: ...)` for a square and `.height` or `.width` for one-axis spacing.

## Stack

Layer children in one positioning context. Supports alignment, sizing constraints (`fit`), and explicit dimensions.

```dart
Stack(
  alignment: Alignment.center,
  fit: StackFit.loose,
  width: Dim.px(320),
  height: Dim.px(200),
  children: [
    Image('images/cover.webp', alt: 'Coastal landscape'),
    Positioned.badge(
      child: Container(
        decoration: const BoxDecoration(
          backgroundColor: Color('rgba(15, 23, 42, 0.8)'),
          padding: EdgeInsets.symmetric(horizontal: Dim.px(8), vertical: Dim.px(4)),
          borderRadius: BorderRadiusData.all(Dim.px(4)),
        ),
        child: const NakiText('New', style: TextStyle(color: Colors.white)),
      ),
    ),
    Positioned.bottom(
      child: Card(child: NakiText('Featured')),
    ),
  ],
)
```

- `alignment`: Controls placement of non-positioned children (`Alignment.topLeft` by default).
- `fit`: Sizing constraint behavior using `StackFit`:
  - `StackFit.loose` (default): Children size to their content/intrinsic size.
  - `StackFit.expand`: Children stretch to fill 100% width and height.
  - `StackFit.passthrough`: Inherits sizing constraints unmodified.
- `width` / `height`: Optional explicit dimensions on the stack container.

## Positioned

Place one stack child by edges, explicit size, or transform offsets.

```dart
// Standard insets
const Positioned(
  top: Dim.px(8),
  right: Dim.px(8),
  width: Dim.px(96),
  transform: 'translate(50%, -50%)',
  child: NakiText('Top right'),
)

// Convenient named constructors
Positioned.fill(child: BackdropFilter(...))
Positioned.center(child: Spinner())
Positioned.centerHorizontal(top: Dim.px(16), child: NakiText('Centered Title'))
Positioned.centerVertical(left: Dim.px(16), child: Icon(MaterialIcons.arrow_back))
Positioned.badge(child: NotificationDot())
Positioned.topLeft(child: Icon(MaterialIcons.menu))
Positioned.topRight(child: Icon(MaterialIcons.close))
Positioned.bottomLeft(child: NakiText('Bottom Left'))
Positioned.bottomRight(child: NakiText('Bottom Right'))
Positioned.top(height: Dim.px(56), child: HeaderBar())
Positioned.bottom(height: Dim.px(48), child: ActionBar())
```

Use only as a direct `Stack` child. Avoid setting conflicting edge and size combinations unless the intended stretch behavior is clear.

## Wrap

Move children onto additional runs when the main axis has insufficient space.

```dart
const Wrap(
  direction: Direction.horizontal,
  spacing: 8,
  runSpacing: 8,
  children: [
    Card(child: NakiText('Design')),
    Card(child: NakiText('Engineering')),
    Card(child: NakiText('Research')),
  ],
)
```

Use `alignment` for placement along each run and `crossAxisAlignment` within a run. Prefer `Row` when wrapping must never occur.

## SafeArea

Apply browser environment safe-area insets around content.

```dart
const SafeArea(
  left: true,
  top: true,
  right: true,
  bottom: true,
  child: Scaffold(body: NakiText('Safe content')),
)
```

Disable an edge only when another layout layer already handles that inset.

## Container

Combine constraints and a typed `BoxDecoration` around one child.

```dart
Container(
  constraints: const SizeConstraints(
    width: Dim.percent(100),
    maxWidth: Dim.px(720),
  ),
  decoration: BoxDecoration(
    backgroundColor: context.surfaceColor,
    borderRadius: BorderRadiusData.all(Dim.px(12)),
    padding: const EdgeInsets.all(Dim.px(20)),
  ),
  child: const NakiText('Container content'),
)
```

## Card

Create an elevated, outlined, or filled Material-inspired surface.

```dart
Card.outlined(
  padding: const EdgeInsets.all(Dim.px(16)),
  decoration: BoxDecoration(borderRadius: BorderRadiusData.all(Dim.px(12))),
  onTap: openInvoice,
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 4,
    children: [
      Bold('Invoice #1042'),
      NakiText('Due 30 September'),
    ],
  ),
)
```

Use `Card()` for elevation, `Card.outlined` for a flat bordered surface, and `Card.filled` for a tonal surface. If `onTap` makes the whole card interactive, ensure the content and surrounding context expose its role and accessible name; prefer a naki Button when appropriate.

## ExpansionPanel

Configure one item consumed by `ExpansionPanelList`. It is a data object rather than a standalone rendered component.

```dart
const ExpansionPanel(
  header: NakiText('Shipping details'),
  body: NakiText('Delivery takes two to four business days.'),
  isExpanded: true,
)
```

Provide either `header` or `headerBuilder`. Use `headerBuilder` when header content changes with expansion state. Use `ExpansionPanel.radio(value: ...)` with a radio list and provide a unique value.

## ExpansionPanelList

Render controlled or internally managed accordion panels.

```dart
ExpansionPanelList(
  allowMultiple: true,
  expansionCallback: (index, expanded) {
    logExpansion(index, expanded);
  },
  children: const [
    ExpansionPanel(
      header: NakiText('Account'),
      body: NakiText('Account settings'),
    ),
    ExpansionPanel(
      header: NakiText('Privacy'),
      body: NakiText('Privacy settings'),
    ),
  ],
)
```

Use `ExpansionPanelList.radio(initialOpenPanelValue: ...)` with `ExpansionPanel.radio` when exactly one item can be open and items have stable values. Use `allowMultiple` only on the default constructor.

## ExpansionTile

Create one self-contained disclosure with optional leading, subtitle, trailing, and child content.

```dart
const ExpansionTile(
  title: NakiText('Advanced settings'),
  subtitle: NakiText('Network and cache controls'),
  childrenPadding: EdgeInsets.all(Dim.px(16)),
  children: [
    NakiText('Advanced content'),
  ],
)
```

Use `initiallyExpanded` only for initial state. Observe changes with `onExpansionChanged`. Use `ExpansionPanelList` when coordinating several related panels.
