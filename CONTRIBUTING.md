# Contributing to Naki UI

Thank you for contributing to **Naki UI**! This guide covers the repository layout, local setup, and quality checks expected on pull requests.

## Prerequisites

* **Dart SDK** `>=3.10.0 <4.0.0`
* **Google Chrome** (for `@TestOn('browser')` tests run via `dart test -p chrome`)
* **`jaspr_cli`** (optional, for building or serving `example/`):
  ```shell
  dart pub global activate jaspr_cli
  ```

## Repository Structure

```text
naki_ui/
├── assets/          # Branding assets used by README and docs.json
├── bin/             # Thin CLI entrypoints (`naki_ui`, `skills`)
├── docs/            # docs.page MDX documentation
├── example/         # Standalone Jaspr showcase application
├── lib/
│   ├── naki_ui.dart     # Public UI components barrel
│   ├── framework.dart   # Public framework, lifecycle, and model barrel
│   ├── theme.dart       # Public theming and styling barrel
│   └── src/
│       ├── cli/         # CLI implementation and skill installer
│       ├── components/  # UI component implementations
│       ├── framework/   # Lifecycle, inherited scopes, overlay stack
│       ├── models/      # Data, gesture, animation, scrolling, styling models
│       ├── stub/        # Platform conditional exports (client vs server)
│       ├── styles/      # CSS rules, text styles, stylesheet helpers
│       ├── theme/       # Theme provider, tokens, light/dark theme data
│       └── utilities/   # Constants, enums, extensions, helpers, storage
├── skills/          # Bundled AI agent skills installed by the CLI
└── test/            # Tests mirroring `lib/src/`
```

### Public API Boundaries

* Consumer imports should only require `package:naki_ui/naki_ui.dart`, `package:naki_ui/theme.dart`, and `package:naki_ui/framework.dart`.
* Internal implementation belongs under `lib/src/`. Avoid breaking public barrel exports without updating `CHANGELOG.md`, `docs/`, and `skills/`.

## Development & Verification

Install dependencies:

```shell
dart pub get
```

Run formatting, static analysis, and tests before opening a PR:

```shell
dart format .
dart analyze
dart test -p vm
dart test -p chrome
```

To verify the showcase application:

```shell
cd example
dart pub get
dart analyze
jaspr build
```

## Coding Conventions

Rules are enforced via `analysis_options.yaml` (`lints` + `jaspr_lints`):

* Use **relative imports** inside `lib/` (`prefer_relative_imports`) and `package:naki_ui/...` imports inside `bin/` and `test/`.
* Keep directives ordered (`dart:` -> `package:` -> relative) and alphabetically sorted.
* Use single quotes, trailing commas, `const` constructors where possible, and explicit return types.
* Keep tests in `test/` under the subfolder mirroring the corresponding `lib/src/` module.
* Keep `docs/` and `skills/` in sync when adding or changing public components, theme tokens, or framework APIs.

## Submitting a Pull Request

1. Branch from `main` with a focused change set.
2. Ensure all checks above pass locally.
3. Fill out the PR template and link any relevant issue.
