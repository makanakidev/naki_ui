# Events, models, enums, and utilities

## GestureRecognizer, Gestures, and Events

`Gestures` and `Events` are aliases of `GestureRecognizer`.

```dart
GestureDetector(
  semanticRole: 'button',
  semanticLabel: 'Open item',
  gestures: Gestures(
    onClick: (_) => openItem(),
    onDoubleClick: (_) => pinItem(),
    onKeyDown: (event) => handleKey(event),
  ),
  child: const Card(child: NakiText('Item')),
)
```

The recognizer supports click, double click, long press, pointer, mouse, keyboard, drag, focus, input, change, select, invalid, paste, and submit callbacks. Convert it to a DOM event map with `toMap` when a component expects raw event mappings.

## InputEvents

Use `InputEvents` for higher-level typed input values and merge independent configurations when needed.

```dart
final events = InputEvents(
  onKeyDown: handleKeyDown,
  onFocus: handleFocus,
  onBlur: handleBlur,
);

TextField(
  id: 'search',
  type: InputType.search,
  events: events,
)
```

Prefer direct component callbacks such as `onTyping`, `onSubmit`, or `onChange` when they already represent the required behavior.

## Shared component models

```dart
const DropdownItem<String>(
  value: 'ng',
  label: 'Nigeria',
  selected: true,
)
```

```dart
const SEO(
  title: 'Orders',
  description: 'Review customer orders.',
  keywords: ['orders', 'customers'],
)
```

```dart
const BottomNavigationBarItem(
  icon: LucideIcons.icon_house,
  label: 'Home',
  tooltip: 'Open home',
)
```

`CalendarDay` and `CalendarMonth` describe calendar data. `InlineSpan` is implemented by Naki inline span components. Use these types at public component boundaries instead of duplicating their shape.

## NakiDebounce

The debounce utility is static and keyed by tag:

```dart
void search(String query) {
  NakiDebounce.run(
    'catalog-search',
    const Duration(milliseconds: 250),
    () => loadResults(query),
  );
}

void disposeSearch() {
  NakiDebounce.cancel('catalog-search');
}
```

Use `fire(tag)` to immediately run pending work and `cancelAll()` only when the caller truly owns every pending Naki debounce operation. Prefer unique, feature-scoped tags.

## Enum groups

- Layout: `Placement`, `Position`, `AspectRatioType`, `Direction`, `Orientation`, `MainAxisAlignment`, `CrossAxisAlignment`, `MainAxisSize`, `FlexFit`, `ObjectFit`, `ObjectPosition`, `Alignment`, `Baseline`, `BreakPoint`, `Shape`.
- Text: `FontStyle`, `TextDecorationStyle`.
- Forms: `Autofill`, `ValidationPattern`, `SegmentedInputType`, `SegmentedInputShape`, `CalendarType`, `FileType`.
- Scrolling and data: `ScrollDirection`, `ScrollPhysicsType`, `CarouselAlignment`, `TableRowCellAlignment`, `TableHeaderCellAlignment`.
- Theme and feedback: `ThemeMode`, `Brightness`, `BannerType`.
- Overlays: `SnackbarPosition`, `DrawerPosition`, `TooltipPosition`, `PopoverPosition`, `DialogPosition`.
- Navigation: `BottomNavigationBarType`, `BottomNavigationBarLandscapeLayout`.
- Painting: `Filter`, `Gradient`, `LinearGradientDirection`, `RadialGradientPosition`, `ConicGradientPosition`.

Use enum values instead of hand-written strings so generated code remains aligned with the package API.
