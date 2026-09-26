# Painting components

Assume the public imports from `references/imports-and-conventions.md`.

## DecoratedBox

Apply background color, gradient, border, corner radius, and shadow around one child.

```dart
// 1. Solid color surface with border and shadow
DecoratedBox(
  color: context.surfaceColor,
  border: BorderData(
    color: context.borderColor,
    width: const Dim.px(1),
    style: BorderStyle.solid,
  ),
  borderRadius: const BorderRadiusData.all(Dim.px(12)),
  shadow: Shadow.medium,
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText('Decorated content'),
  ),
)
```

```dart
// 2. Multi-color gradient decoration
DecoratedBox(
  gradient: Gradient()
    ..applyLinear(
      colors: const [Color('#3b82f6'), Color('#8b5cf6')],
      direction: LinearGradientDirection.toBottomRight,
    ),
  borderRadius: const BorderRadiusData.all(Dim.px(12)),
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText(
      'Gradient card',
      style: TextStyle(color: Color('#ffffff')),
    ),
  ),
)
```

Use `DecoratedBox` when only decorative styling is required without sizing constraints. Use `Container` when decoration, padding, margin, and size constraints belong together.

## ColoredBox

Apply a single background color or gradient directly behind a child.

```dart
// 1. Solid color background
const ColoredBox(
  color: Colors.blue,
  child: Padding(
    padding: EdgeInsets.all(Dim.px(12)),
    child: NakiText('Blue surface'),
  ),
)
```

```dart
// 2. Linear or radial gradient background
ColoredBox(
  gradient: Gradient()
    ..applyLinear(
      colors: const [Color('#0f766e'), Color('#14b8a6')],
      angle: 90,
    ),
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText(
      'Teal gradient background',
      style: TextStyle(color: Color('#ffffff')),
    ),
  ),
)
```

`ColoredBox` requires either `color` or `gradient`. Use `DecoratedBox` or `Container` when borders, radii, or shadows are also required.

## BackdropFilter

Apply CSS filter effects (such as frosted glass blurs, brightness, grayscale, contrast) to content behind the child.

```dart
BackdropFilter(
  filter: Filter()
    ..applyBlur(8)
    ..applyContrast(120),
  child: const Padding(
    padding: EdgeInsets.all(Dim.px(16)),
    child: NakiText('Frosted overlay'),
  ),
)
```

You can also use the built-in preset `Filter.frostedGlass`:

```dart
BackdropFilter(
  filter: Filter.frostedGlass,
  child: Container(
    decoration: BoxDecoration(
      backgroundColor: const Color('rgba(255, 255, 255, 0.4)'),
    ),
    child: const NakiText('Frosted glass card'),
  ),
)
```

Use the typed `Filter` API and pair with a translucent child background for visible glass effects. Treat large blur areas as a performance cost.

## Opacity

Apply opacity from 0.0 (transparent) to 1.0 (opaque) to a child.

```dart
const Opacity(
  opacity: 0.6,
  child: NakiText('Secondary information'),
)
```

Opacity alters visual transparency without altering document layout or accessibility tree presence. Use `Visibility` when content should be hidden or substituted.

## Visibility

Conditionally show a child, replace it, or maintain state while hidden.

```dart
Visibility(
  visible: signedIn,
  replacement: const NakiText('Sign in to continue.'),
  maintainState: true,
  child: const AccountDashboard(),
)
```

Set `maintainState: true` only when preserving the hidden subtree's state is required. Confirm hidden content is not accessible to screen readers or keyboard navigation when hidden.

## ClipRect

Clip a child to rectangular bounds, optionally with rounded corners.

```dart
ClipRect(
  borderRadius: const BorderRadiusData.all(Dim.px(12)),
  child: Image(
    '/images/cover.webp',
    fit: ObjectFit.cover,
    position: ObjectPosition.center,
  ),
)
```

Use clipping when overflow must not escape the boundary; do not use it to mask layout errors.

## ClipOval

Clip a child to an oval or circular silhouette.

```dart
const ClipOval(
  child: SizedBox.fromSize(
    size: Dim.px(64),
    child: Image('/images/avatar.webp', alt: 'Amina Yusuf'),
  ),
)
```

Use equal width and height on the child for a circle and ensure the image fit produces the desired crop.

## RotatedBox

Rotate a child by whole 90-degree quarter turns, updating the layout geometry accordingly.

```dart
const RotatedBox(
  quarterTurns: 1, // 1 = 90 deg, 2 = 180 deg, 3 = 270 deg
  child: NakiText('Rotated 90 degrees'),
)
```

Use integer quarter turns for layout-aware right-angle rotation. Use `Transform.rotate` for arbitrary angles.

## Transform

Apply CSS 2D or 3D transformations via named constructors or raw transform expressions.

```dart
// Rotation by degrees
Transform.rotate(
  8,
  alignment: Alignment.center,
  child: const Card(child: NakiText('Rotated card')),
)
```

```dart
// Scale
Transform.scale(
  1.05,
  alignment: Alignment.center,
  child: const NakiText('Scaled'),
)
```

```dart
// Pixel translation
Transform.translate(
  offsetX: 8,
  offsetY: -4,
  child: const NakiText('Translated'),
)
```

```dart
// Custom CSS transform matrix
Transform(
  transform: 'skewX(10deg)',
  alignment: Alignment.center,
  child: const NakiText('Skewed box'),
)
```

Transforms affect painting rather than document flow. Ensure transformed content does not unintentionally overlap controls or disappear outside clipping ancestors.
