# Painting components

## Opacity

Apply opacity from 0 to 1 to a child.

```dart
const Opacity(
  opacity: 0.6,
  child: NakiText('Secondary information'),
)
```

Opacity changes presentation, not semantics or interactivity. Use `Visibility` when content should be hidden or replaced.

## Visibility

Show a child or replacement.

```dart
Visibility(
  visible: signedIn,
  replacement: const NakiText('Sign in to continue.'),
  maintainState: true,
  child: const AccountDashboard(),
)
```

Set `maintainState` only when preserving the hidden subtree is necessary. Confirm hidden content is not reachable by keyboard or assistive technology in the chosen configuration.

## ClipRect

Clip a child to a rectangle, optionally with rounded corners.

```dart
ClipRect(
  borderRadius: BorderRadiusData.all(Dim.px(12)),
  child: Image('/images/cover.webp', fit: BoxFit.cover),
)
```

Use clipping when overflow must not escape the boundary; do not use it to mask layout errors.

## DecoratedBox

Apply color, border, radius, and shadow around one child.

```dart
DecoratedBox(
  color: context.surfaceColor,
  border: BorderData(
    color: context.borderColor,
    width: const Dim.px(1),
    style: BorderStyle.solid,
  ),
  borderRadius: BorderRadiusData.all(Dim.px(12)),
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText('Decorated content'),
  ),
)
```

Use `Container` when decoration and size constraints belong together.

## ClipOval

Clip a child to an oval or circle.

```dart
const ClipOval(
  child: SizedBox.fromSize(
    size: Dim.px(64),
    child: Image('/images/avatar.webp', alt: 'Amina Yusuf'),
  ),
)
```

Use equal width and height for a circle and ensure the image fit produces the desired crop.

## BackdropFilter

Apply a filter to content behind the child.

```dart
BackdropFilter(
  filter: FilterBuilder()..applyBlur(8),
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText('Frosted overlay'),
  ),
)
```

Use the typed `FilterBuilder` API and provide a translucent child background for a visible glass effect. Treat large blur areas as a performance cost and verify browser support.

## ColoredBox

Apply one background color to a child.

```dart
const ColoredBox(
  color: Colors.blue,
  child: Padding(
    padding: EdgeInsets.all(Dim.px(12)),
    child: NakiText('Blue surface'),
  ),
)
```

Use `DecoratedBox` or `Container` when borders, radius, shadows, or constraints are also required.

## RotatedBox

Rotate a child by whole quarter turns.

```dart
const RotatedBox(
  quarterTurns: 1,
  child: NakiText('Rotated 90 degrees'),
)
```

Use integer quarter turns for layout-aware right-angle rotation. Use `Transform.rotate` for arbitrary angles.

## Transform

Apply a raw CSS transform or a typed rotate, scale, or translate factory.

```dart
Transform.rotate(
  8,
  alignment: Alignment.center,
  child: Card(child: NakiText('Rotated card')),
)
```

```dart
Transform.scale(
  1.05,
  child: NakiText('Scaled'),
)
```

```dart
Transform.translate(
  offsetX: 8,
  offsetY: -4,
  child: NakiText('Translated'),
)
```

Transforms affect painting rather than document flow. Ensure transformed content does not overlap controls or disappear outside clipping ancestors.
