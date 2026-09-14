# Minimalist To-Do — Naki UI Example

A minimalist, responsive to-do application built with [Naki UI](https://github.com/makanakidev/naki_ui) and [Jaspr](https://docs.page/schultek/jaspr).

## Features

- **100% Native Naki UI Components**: Built using `NakiApp`, `Scaffold`, `AppBar`, `SafeArea`, `Container`, `Card`, `Column`, `Row`, `Expanded`, `SizedBox`, `Padding`, `Heading`, `NakiText`, `Button`, `Icon`, `Checkbox`, `TextField`, and `Snackbar`.
- **Theme-Aware & Responsive**: Seamless light and dark mode support with instant toggle via `context.toggleTheme` and `cacheThemeMode`.
- **Typed Design Tokens & Styling**: Styled using `Dim`, `EdgeInsets`, `BorderRadiusData`, `TextStyle`, and `ColorSeed`.
- **Local Storage Persistence**: Persists tasks automatically in `localStorage` in web environments while supporting static SSR hydration without crashing.
- **Task Management**: Create tasks (via keyboard Enter or button click), filter by status (`All`, `Active`, `Completed`), toggle completion, delete tasks, and bulk clear completed tasks.
- **Feedback Overlays**: Integrated `Snackbar` notifications managed via `OverlayController`.

## Run locally

```bash
cd example
dart pub get
jaspr serve
```

Or build statically:

```bash
cd example
jaspr build
```
