# Controllers and scrolling models

## OverlayController

```dart
class _PromptState extends State<Prompt> {
  final controller = OverlayController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return Column(
      children: [
        Button.text('Open', onTap: controller.open),
        Dialog(
          controller: controller,
          title: 'Confirm action',
          actions: [Button.text('Close', onTap: controller.close)],
        ),
      ],
    );
  }
}
```

Read `isOpen`, call `open`, `close`, or `toggle`, and use listeners only when another object must react to state changes. `OverlayState.open(controller)` and related methods are convenience equivalents.

## Show functions

For a one-off overlay, skip the controller. These functions mount the overlay in the closest `NakiApp` or `Scaffold`, give it a controller, and remove it after it closes. They do nothing on the server.

```dart
// Snackbar: replaces any snackbar already open.
showSnackbar(context, const Snackbar(content: NakiText('Saved')));
closeSnackbar();

// Dialog: builder returns the Dialog. Completes with the closeDialog value,
// or null when dismissed another way.
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => Dialog(
    title: 'Delete item?',
    actions: [
      Button.text('Cancel', onTap: () => closeDialog(context, false)),
      Button.text('Delete', onTap: () => closeDialog(context, true)),
    ],
  ),
);

// Bottom sheet: builder returns the content; sheet options are arguments.
final target = await showModalBottomSheet<String>(
  context: context,
  isDismissible: true,
  builder: (context) => Column(
    children: [
      Button.text('Mail', onTap: () => closeModalBottomSheet(context, 'mail')),
    ],
  ),
);
```

- Call `closeDialog` and `closeModalBottomSheet` with the `context` the builder receives, not the page's context. They assert otherwise.
- Leave `controller` out of a `Snackbar` or `Dialog` passed to these functions.
- Check `mounted` after `await` before using the page's `context` again.

## ScrollController

```dart
class _ResultsState extends State<Results> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.addListener(handleScroll);
  }

  @override
  void dispose() {
    controller.removeListener(handleScroll);
    controller.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return ListView(controller: controller, children: component.items);
  }
}
```

The scroll component attaches its DOM element after rendering. Use offset and extent getters only after attachment. Available operations include jumps and animations to offsets, top, end, indices, and components.

## PageController

```dart
final pageController = PageController(initialPage: 0);

PageView(
  controller: pageController,
  children: pages,
)
```

Use `page`, page jumps and animations, `nextPage`, and `previousPage`. Set `viewportFraction` when a page should reveal neighboring content. Dispose an owned controller.

## Scroll physics

Choose behavior explicitly when the default is not suitable:

```dart
ListView(
  physics: const BouncingScrollPhysics(),
  children: items,
)
```

- `NeverScrollableScrollPhysics`: block user scrolling.
- `BouncingScrollPhysics`: overscroll bounce.
- `ClampingScrollPhysics`: clamp at content edges.
- `AlwaysScrollableScrollPhysics`: keep scrolling enabled for short content.
- `SnappingScrollPhysics`: snap to item positions.

## Grid delegates

```dart
const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 3,
  mainAxisSpacing: Dim.px(12),
  crossAxisSpacing: Dim.px(12),
  childAspectRatio: AspectRatioType.ratio1_1,
)
```

Use `SliverGridDelegateWithMaxCrossAxisExtent` when item width should determine responsive column count.

## Table models

```dart
TableBorder(
  horizontalInside: BorderSideData(color: context.borderColor),
  verticalInside: BorderSideData.none,
)
```

Use `TableRow` for row content and `FixedColumnWidth`, `FlexColumnWidth`, `IntrinsicColumnWidth`, or `FractionColumnWidth` for each column's sizing behavior.
