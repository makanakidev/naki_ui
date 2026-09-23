# Imports and conventions

## Choose public imports

```dart
import 'package:jaspr/dom.dart' hide Padding, Table, Transform, Visibility;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';
```

- `naki_ui.dart` exports visual components.
- `framework.dart` exports enums, controllers, lifecycle helpers, gestures, scrolling models, and shared data models.
- `theme.dart` exports theme configuration, dimensions, decorations, text styles, and context extensions.
- Add `jaspr_router` only for routing. Add an icon pack only when the selected `IconData` comes from that package.
- Never import a `naki_ui/src` path from application code.

## Build a minimal app

```dart
@client
class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return NakiApp(
      title: 'Storefront',
      themeMode: ThemeMode.system,
      home: const Scaffold(
        appBar: AppBar(titleText: 'Storefront'),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dim.px(24)),
            child: NakiText('Welcome'),
          ),
        ),
      ),
    );
  }
}
```

Use an `@client` boundary for interactive UI and browser-backed state in static or server-mode applications. Keep constructor fields crossing a server-to-client boundary serializable: primitives, lists, maps, or explicitly encodable values. Do not pass callbacks or component instances across that boundary.

## Compose components

Return one component from `build`:

```dart
@override
Component build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: const [
      Heading('Profile', level: 2),
      NakiText('Manage your public information.'),
    ],
  );
}
```

Use `child` for one descendant and `children` for a list. Prefer `const` where every argument is constant. Keep stateful resources as fields on `State`, not local variables created during every build.

## Label fields correctly

Naki inputs that accept `InputDecoration` render their label internally:

```dart
TextField(
  id: 'profile-email',
  type: InputType.email,
  required: true,
  autofill: Autofill.email,
  decoration: const InputDecoration(
    labelText: 'Email address',
    placeholderText: 'name@example.com',
    helperText: 'Used for account notifications.',
  ),
)
```

Do not add a sibling `Label`. Use `InputDecoration.labelText` for `TextField`, `AutoCompleteField`, `SegmentedInput`, and `Calendar`. Use the direct `label` property on `Checkbox`, `Switch`, and `RadioButton`.

## Style with typed values

```dart
Container(
  blockBox: true,
  constraints: const SizeConstraints(maxWidth: Dim.px(640)),
  decoration: BoxDecoration(
    backgroundColor: context.surfaceColor,
    borderRadius: BorderRadiusData.all(Dim.px(12)),
    padding: const EdgeInsets.all(Dim.px(20)),
  ),
  child: const NakiText('Account settings'),
)
```

Prefer `Dim`, `EdgeInsets`, `SizeConstraints`, `BorderData`, `BorderRadiusData`, `BoxDecoration`, `Filter`, `Gradient`, and `TextStyle` to raw style strings. Resolve active colors from `BuildContext` so theme changes rebuild correctly.

## Own controllers and listeners

```dart
class _PageState extends State<Page> {
  final dialogController = OverlayController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    dialogController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
```

Dispose only resources created by the state. A descendant must not dispose a controller supplied by an ancestor.

## Check accessibility and web behavior

- Use `Button` for actions and `Link` for navigation/routing.
- Provide `semanticLabel` for icon-only actions, spinners whose purpose is not obvious, and custom interactive regions.
- Keep IDs unique and preserve label-to-input association.
- Test keyboard activation, focus order, focus restoration after overlays, Escape dismissal, and visible focus styles.
- Do not communicate status by color alone.
- Provide useful image `alt` text, or an empty value for decorative images when supported by the surrounding semantics.
- Constrain scroll areas and test narrow, wide, zoomed, and reduced-motion environments.

## Verify

Run formatting, static analysis, tests, and a Jaspr build appropriate to the consuming project. Exercise both the initial render and hydrated interactions when an application uses static or server rendering.
