## 1.0.4

- Added smooth exit animations and graceful dismissal handling for `Snackbar`, `Dialog`, `Drawer`, and `BottomSheet`.
- Enhanced `NakiApp` component with improved viewport settings and browser zoom prevention on touch devices when typing.
- Fixed `TextField` component focus styling when `leadingIcon` or `trailingIcon` is present.

## 1.0.3

- Bumped `jaspr` dependency to the latest version.
- Added `OverlayRegion` and `OverlayScope` components for portal-based overlay rendering (`Snackbar`, `Dialog`, `Drawer`, `BottomSheet`), projecting active overlays to the root DOM layer for proper z-indexing and unclipped rendering.
- Integrated `OverlayRegion` automatically into `NakiApp` and as an automatic fallback in standalone `Scaffold` configurations.
- Enhanced `Scaffold` with dynamic lifecycle observers (`BrowserLifecycleListeners`) to track and synchronize CSS variables used to dynamically resolve `Snackbar` positioning when app bar and bottom navigation bar are present.
- Added `alignment`, `fit`, `width`, and `height` properties to `Stack` component, utilizing a CSS Grid layout model for layered stacking.
- Added `StackFit` enum (`loose`, `expand`, `passthrough`) for flexible child sizing constraints in `Stack`.
- Added `transform` property and named convenience constructors (`fill`, `center`, `centerHorizontal`, `centerVertical`, `badge`, `topLeft`, `topRight`, `bottomLeft`, `bottomRight`, `top`, `bottom`) to `Positioned` component.
- Enhanced `Transform.translate` constructor to accept `Dim? offsetX` and `Dim? offsetY` with support for all CSS units.
- Updated `Transform` component to map `alignment` to CSS `transform-origin`.
- Enhanced `Flexible` component with `FlexFit.loose` for proportional flexible space distribution.
- Deprecated `autoValidate` property in `FormBuilder` component and replaced with `bypassValidation` property. Native browser validation will now be done by default on submission and only skipped when `bypassValidation` is set to `true` - allowing for more explicit control over the validation process.
- Deprecated `Drawer.sidebar` constructor in favor of `Sidebar` component - `Drawer` is now only for modal drawers.

## 1.0.2

- Added `leadingIcon` and `trailingIcon` properties to `TextField` component.
- Added `position` property to `Image` component.
- Added new `Sidebar` component for persistent side navigation in large screens.
- Improved `BoxDecoration` model to support `gradient`, `backgroundImage`, `imagePosition` and `imageFit` properties for `Card` and `Container` components.

## 1.0.1

- Added `head` property to `Scaffold` component for injecting page-specific head elements like script, style, meta tags, etc.
- Refactored SEO meta tag generation in `NakiApp` and `Scaffold` to prevent duplicate tags across route transitions.
- Added `PlatformData` class for accessing platform-specific data and utilities in both client and server-side.
- Added `ResponsiveBuilder` and `BreakPointWrapper` components for declarative responsive design.

## 1.0.0

- Initial release.
