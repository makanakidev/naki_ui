# Typed styling models

## Dimensions

`Dim` represents CSS dimension values:

```dart
const SizedBox(
  width: Dim.rem(20),
  height: Dim.dvh(50),
  child: ProductList(),
)
```

Common constructors include pixels, rem, em, percentages, viewport units, dynamic viewport units, variables, angles, content sizing, `auto`, and zero. Match the unit to intent: `rem` for a user-scalable layout scale, percentages for parent-relative sizing, and viewport units only for viewport-relative layout.

## Spacing and constraints

```dart
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: Dim.rem(1.25),
    vertical: Dim.rem(1),
  ),
  constraints: const SizeConstraints(
    maxWidth: Dim.rem(42),
  ),
  child: const CheckoutForm(),
)
```

Use `EdgeInsets.all`, `symmetric`, `only`, or the directional constructors exposed by the current API. Prefer `SizeConstraints` to ad hoc width checks.

## Boxes, borders, and shadows

```dart
Container(
  decoration: BoxDecoration(
    backgroundColor: context.surfaceColor,
    border: BorderData(
      color: context.borderColor,
      width: const Dim.px(1),
    ),
    borderRadius: BorderRadiusData.all(const Dim.rem(0.75)),
    shadow: Shadow(
      color: context.shadowColor.withOpacity(0.16),
      blurRadius: 18,
      offsetY: 6,
    ),
  ),
  child: const NakiText('Order summary'),
)
```

Use `BorderSideData.none` for an absent side. Prefer semantic colors from context so decorations adapt with the active mode.

## Gradients and filters

Use `Gradient` and `Filter` builders to define composable background fills and visual effects:

```dart
final gradient = Gradient()
  ..applyLinear(
    colors: [context.primaryColor, context.secondaryColor],
    direction: LinearGradientDirection.toBottomRight,
  );

final filter = Filter()
  ..applyBlur(8)
  ..applyContrast(120);
```

## Input decoration and labels

Input components that accept `InputDecoration` render their own `Label`; do not add a standalone `Label` sibling:

```dart
TextField(
  id: 'email',
  type: InputType.email,
  decoration: const InputDecoration(
    labelText: 'Email address',
    placeholderText: 'name@example.com',
    helperText: 'Used for receipts.',
  ),
)
```

Use standalone `Label` only when composing a custom native control and explicitly connect `forId` to the control ID.

## Text styles

```dart
NakiText(
  'Payment confirmed',
  style: TextStyle(
    color: context.successColor,
    fontSize: const Dim.rem(1.125),
    fontWeight: FontWeight.w600,
    lineHeight: const Dim.em(1.4),
  ),
)
```

Use `DefaultTextStyle` for an inherited subtree default. Keep heading semantics in heading components rather than creating visually large body text.

## Runtime versus reusable styling

Use typed inline models for values calculated from component state or theme context. For stable styles shared across many instances, define reusable CSS rules and use class names. This keeps output smaller and preserves hover, focus, media-query, and forced-colors behavior that cannot be expressed well as one-off inline values.

## Composing styling models in a component

```dart
class GlassmorphicPromoCard extends StatelessComponent {
  const GlassmorphicPromoCard({super.key});

  @override
  Component build(BuildContext context) {
    return BackdropFilter(
      filter: Filter()
        ..applyBlur(16)
        ..applyContrast(110),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dim.px(24),
          vertical: Dim.px(20),
        ),
        constraints: const SizeConstraints(
          maxWidth: Dim.px(420),
        ),
        decoration: BoxDecoration(
          gradient: Gradient()
            ..applyLinear(
              colors: [
                context.primaryColor.withOpacity(0.15),
                context.surfaceColor.withOpacity(0.4),
              ],
              direction: LinearGradientDirection.toBottomRight,
            ),
          borderRadius: const BorderRadiusData.all(Dim.px(16)),
          border: BorderData(
            color: const Color('rgba(255, 255, 255, 0.25)'),
            width: const Dim.px(1),
          ),
          shadow: Shadow(
            color: context.shadowColor.withOpacity(0.12),
            offsetY: 8,
            blurRadius: 24,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            NakiText(
              'Premium Membership',
              style: TextStyle(
                fontSize: const Dim.rem(1.25),
                fontWeight: FontWeight.bold,
                color: context.textColor,
                letterSpacing: const Dim.px(-0.2),
              ),
            ),
            NakiText(
              'Unlock advanced theme customization and cloud synchronization.',
              style: TextStyle(
                fontSize: const Dim.rem(0.875),
                lineHeight: const Dim.em(1.5),
                color: context.subtitleColor,
              ),
            ),
            Button.filled(
              context.primaryColor,
              onTap: () {},
              child: const NakiText('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
```
