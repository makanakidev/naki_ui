# Overlay components

Create each `OverlayController` once in state, pass it to the overlay, and dispose it from the same owner. Overlay behavior requires client execution.

For a one-off snackbar, dialog or sheet, use `showSnackbar`, `showDialog` or `showModalBottomSheet` instead. They need no controller, only a `NakiApp` or `Scaffold` above `context`.

```dart
class _OverlayPageState extends State<OverlayPage> {
  final dialogController = OverlayController();

  @override
  void dispose() {
    dialogController.dispose();
    super.dispose();
  }
}
```

## Snackbar

Show transient status feedback.

```dart
Column(
  children: [
    Button.text('Save', onTap: () async {
      await saveChanges();
      snackbarController.open();
    }),
    Snackbar(
      controller: snackbarController,
      position: SnackbarPosition.bottom,
      duration: const Duration(seconds: 5),
      showCloseIcon: true,
      content: const NakiText('Changes saved.'),
      onClose: trackDismissal,
    ),
  ],
)
```

Or show one without a controller. `showSnackbar` replaces any snackbar already open, and `closeSnackbar()` closes it early:

```dart
showSnackbar(
  context,
  const Snackbar(showCloseIcon: true, content: NakiText('Changes saved.')),
);
```

Use a snackbar for brief, non-blocking feedback. Only one registered snackbar remains active at a time. Use a `Banner` for persistent messages that should remain in document flow.

## Tooltip

Provide concise supplementary information on hover and focus.

```dart
Tooltip(
  id: 'settings-help',
  text: 'Open account settings',
  position: TooltipPosition.bottom,
  child: Button.icon(
    LucideIcons.icon_settings,
    attributes: {'aria-label': 'Open account settings'},
  ),
)
```

Provide either `text` or `content`. Like `Popover`, a tooltip flips and slides to stay inside the safe areas and the Scaffold's bars, and its arrow keeps pointing at the child. Tooltips must not contain essential information unavailable through another interaction, and the wrapped control still needs its own accessible name.

## Dialog

Present a focused decision or task in a modal surface.

```dart
Column(
  children: [
    Button.text('Delete account', onTap: dialogController.open),
    Dialog(
      controller: dialogController,
      title: 'Delete account?',
      subtitle: 'This action cannot be undone.',
      barrierDismissible: false,
      actions: [
        Button.text('Cancel', onTap: dialogController.close),
        Button.filled(
          Colors.red,
          onTap: deleteAccount,
          child: const NakiText('Delete'),
        ),
      ],
    ),
  ],
)
```

Or show one without a controller. `showDialog` completes with the value passed to `closeDialog`, or `null` when the barrier dismisses it:

```dart
final confirmed = await showDialog<bool>(
  context: context,
  builder: (context) => Dialog(
    title: 'Delete account?',
    barrierDismissible: true,
    actions: [
      Button.text('Cancel', onTap: () => closeDialog(context, false)),
      Button.text('Delete', onTap: () => closeDialog(context, true)),
    ],
  ),
);
```

Use `content` to replace the title/subtitle presentation and provide `semanticLabel` when custom content has no suitable textual name. Test focus entry, trapping, Escape, close callbacks, and focus restoration.

Set `glass: true` for a translucent dialog. `backgroundColor` sets the tint, and the barrier stops blurring so the glass can see the page. See `Card.glass` for the `glassTint`, `glassRim` and `glassBlur` theme values and the accessibility fallbacks.

## Drawer

Use the default constructor for a modal drawer and provide a controller when it is not managed through `Scaffold`.

```dart
Drawer(
  controller: drawerController,
  position: DrawerPosition.left,
  semanticLabel: 'Primary navigation',
  width: const Dim.px(320),
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Heading('Navigation', level: 2),
      NakiText('Dashboard'),
      NakiText('Settings'),
    ],
  ),
)
```

Inside a `Scaffold`, call `Scaffold.maybeOf(context)?.openDrawer()` to open its modal drawer. Use `Sidebar` for persistent large-screen navigation:

```dart
const Sidebar(
  semanticLabel: 'Section navigation',
  width: Dim.px(280),
  child: NakiText('Persistent navigation'),
)
```

## BottomSheet

Present contextual actions or compact content from the bottom edge.

```dart
BottomSheet(
  controller: sheetController,
  semanticLabel: 'Share options',
  showHandle: true,
  maxWidth: const Dim.px(640),
  maxHeight: const Dim.vh(70),
  child: const Column(
    children: [
      Heading('Share', level: 2),
      NakiText('Copy link'),
    ],
  ),
)
```

Or show one without a controller. `builder` returns the content, the sheet options are arguments (`isDismissible` maps to `barrierDismissible`), and the future completes with the value passed to `closeModalBottomSheet`, or `null` when dismissed:

```dart
final target = await showModalBottomSheet<String>(
  context: context,
  semanticLabel: 'Share options',
  maxWidth: const Dim.px(640),
  builder: (context) => Column(
    children: [
      Button.text('Copy link', onTap: () => closeModalBottomSheet(context, 'link')),
      Button.text('Mail', onTap: () => closeModalBottomSheet(context, 'mail')),
    ],
  ),
);
```

Pass the builder's `context` to `closeDialog` and `closeModalBottomSheet`, not the page's.

`Dialog`, `BottomSheet` and `Drawer` animate with Material 3 motion: a dialog grows in over 500ms and closes in 150ms, and sheets and drawers slide in over 210ms and out over 120ms. Don't add your own open or close animations to them.

Use `barrierDismissible: false` only when an explicit close action is present. Synchronize external state in `onClose` when needed.

## Popover

Anchor contextual content to a child. Leave `visible` out and the popover opens on hover and focus:

```dart
Popover(
  position: PopoverPosition.bottomLeft,
  child: Button.text('Options', onTap: () {}),
  content: const NakiText('More options'),
)
```

Set `visible`, even to `false`, to control it from the parent instead; hover and focus then do nothing:

```dart
Popover(
  visible: popoverOpen,
  position: PopoverPosition.bottomLeft,
  semanticLabel: 'Profile actions',
  onClose: () => setState(() => popoverOpen = false),
  child: Button.text(
    'Profile',
    onTap: () => setState(() => popoverOpen = !popoverOpen),
  ),
  content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Button.text('Settings', onTap: openSettings),
      Button.text('Sign out', onTap: signOut),
    ],
  ),
)
```

When `visible` is set, the parent owns it: a tap outside the content or scrolling the page calls `onClose`, so update `visible` there, and close the popover after an action.

A popover opens at `position` and stays anchored to its child inside the safe areas and the Scaffold's bars. It flips to the opposite side when only that side fits, and slides along the child when it would cross an edge. Test focus and keyboard access.
