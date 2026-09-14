# Overlay components

Create each `OverlayController` once in state, pass it to the overlay, and dispose it from the same owner. Overlay behavior requires client execution.

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

Provide either `text` or `content`. Tooltips must not contain essential information unavailable through another interaction, and the wrapped control still needs its own accessible name.

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

Use `content` to replace the title/subtitle presentation and provide `semanticLabel` when custom content has no suitable textual name. Test focus entry, trapping, Escape, close callbacks, and focus restoration.

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

Inside a `Scaffold`, call `Scaffold.maybeOf(context)?.openDrawer()` to open its modal drawer. Use `Drawer.sidebar` for persistent large-screen navigation:

```dart
const Drawer.sidebar(
  semanticLabel: 'Section navigation',
  width: Dim.px(280),
  child: NakiText('Persistent navigation'),
)
```

Do not use a modal controller with `Drawer.sidebar`.

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

Use `barrierDismissible: false` only when an explicit close action is present. Synchronize external state in `onClose` when needed.

## Popover

Anchor controlled contextual content to a child.

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

The parent owns the `visible` state. Close the popover after an action and test outside-click behavior, placement near viewport edges, focus, and keyboard access.
