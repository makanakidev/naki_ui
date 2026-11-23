# Navigator & routing

`Navigator`, `NavigatorState`, `NakiRoute`, `NakiPageRoute`, and `NakiRouteSettings` are exported by both `package:naki_ui/naki_ui.dart` and `package:naki_ui/framework.dart`.

`NakiApp` and `NakiApp.router` mount a `Navigator` automatically around the application's `OverlayHost`.

## Push & pop imperative routes

```dart
final saved = await Navigator.push<bool>(
  context,
  NakiPageRoute(
    settings: const NakiRouteSettings(name: '/edit', arguments: 'item-1'),
    builder: (context) {
      final args = NakiRoute.of<bool>(context)?.settings.arguments;
      return EditPage(
        itemId: args as String?,
        onSave: () => Navigator.pop(context, true),
      );
    },
  ),
);
```

- `Navigator.push`, `Navigator.pushNamed`, `Navigator.pushReplacement`, `Navigator.pushReplacementNamed`, `Navigator.pushAndRemoveUntil`, and `Navigator.pushNamedAndRemoveUntil` manage the imperative stack.
- `Navigator.pop(context, [result])`, `Navigator.maybePop`, `Navigator.canPop`, and `Navigator.popUntil(context, Navigator.withName('/route'))` unwind routes cleanly.
- Use `Navigator.of(context, rootNavigator: true)` when a nested `Navigator` exists and you need the outermost stack.

## Precedence of `Navigator.pop`

1. If `context` sits inside an active modal overlay (`showDialog`, `showModalBottomSheet`, `showDatePicker`, `showDateRangePicker`, `showTimePicker`, or declarative `Dialog`, `BottomSheet`, and modal `Drawer`), `Navigator.pop(context, result)` closes that overlay first and resolves its returned `Future` with `result`.
2. Otherwise, if the nearest `Navigator` has imperative routes (`canPop() == true`), it pops the top `NakiRoute` and completes `route.completed` with `result`.
3. Otherwise, inside `NakiApp.router`, it delegates to `RouterState.back()` (just as unmatched `pushNamed` and `pushReplacementNamed` delegate to `RouterState.push` and `RouterState.replace`).

