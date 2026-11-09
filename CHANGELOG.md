## 1.0.6

### Breaking changes

- `Popover.visible` is now nullable and defaults to `null`. Setting it, even to `false`, gives the parent control and turns off opening on hover and focus.
- Replaced the `important` argument of `Dim` constructors with `Dim.px(500).important`.

### Added

- Added `Card.glass` and `Dialog(glass: true)`, translucent surfaces with fallbacks for reduced transparency, higher contrast and forced colors. Added the `glassTint`, `glassRim` and `glassBlur` theme properties.
- Added `BottomNavigationBarType.liquidGlass`, a frosted glass bottom navigation bar that bends the content behind its edges and selection droplet in Chromium browsers. Use `bottomNavbarGlassBlur` theme property to control the blur strength of the liquid glass effect.
- Added the `bottomNavbarGlassRefraction` theme property to scale or turn off `BottomNavigationBarType.liquidGlass` refraction.
- Added `CalendarType.range` to `Calendar`, with `initialRange`, `onSelectedRange` and `rangeValidator`.
- Added `showSnackbar`, `closeSnackbar`, `showDialog` and `closeDialog`, which show a `Snackbar` or `Dialog` without a controller, as in Flutter. `showDialog` completes with the value passed to `closeDialog`. `Snackbar.controller` and `Dialog.controller` are now optional.
- Added `showModalBottomSheet` and `closeModalBottomSheet`. `showModalBottomSheet` shows the content its `builder` returns in a `BottomSheet` and completes with the value passed to `closeModalBottomSheet`. `BottomSheet.controller` is now optional.
- Added `fixed` and `blurBackground` properties to `AppBar`. These properties are now used to determine the behavior of the app bar in the `Scaffold` component.

### Changed

- `Popover` now stays anchored to its trigger inside the safe areas and the Scaffold's bars, flipping or sliding when it would cross an edge. A tap outside its content or scrolling the page closes it.
- `Tooltip` now flips and slides to stay inside the safe areas and the Scaffold's bars.
- `Dialog`, `BottomSheet` and `Drawer` now open and close with Material 3 motion.
- Improved `Spinner.glass`. The glass disc now stays still while only the arc spins, with a clearer surface, a light rim and fallbacks for reduced transparency, higher contrast and forced colors. `surfaceColor` is now optional. Added the `spinnerGlassRim` theme value.
- Improved `BottomNavigationBarType.frostedGlass`. The frosted glass bottom navigation bar is now a clearer glass pill with equal-width tiles, a sliding glass droplet, stronger unselected tile colors, inner rim highlights, more depth, and fallbacks for reduced transparency, higher contrast and forced colors. Added the `bottomNavbarGlassTint`, `bottomNavbarGlassRim`, `bottomNavbarGlassDroplet` and `bottomNavbarGlassBlur` theme properties.

### Fixed

- Removed the dark flash iOS Safari draws on tapped buttons and fields.
- Fixed `Dropdown` and `AutoCompleteField` not closing on a tap outside.
- `Calendar` now closes only from `Cancel`, `Ok` or `Escape` key press, leaving it open on a tap outside.

## 1.0.5

- Fixed component CSS missing from server-rendered pages after the first request in Jaspr's default (inline) styles mode.
- Fixed malformed canonical / Open Graph URLs caused by `PlatformData.baseUrl`.
- Fixed `FormBuilder` validation: validators run on every submit, native constraint messages are shown, and `Enter` moves to the next field (submitting from the last one).
- Added `FormBuilder.onSubmit`, `action` and `method`. Forms no longer submit field values (including passwords) in the URL.
- Fixed `Dialog`, `Drawer`, `BottomSheet` and `Snackbar` open / close animations; `Escape` closes only the top-most overlay, and `Dialog` no longer disposes its controller.
- Fixed `Calendar` validation and `Cancel`. The picker now stays inside the viewport, adapts to small screens, and only one picker is open at a time.
- Fixed `Dropdown` keyboard selection.
- Fixed floating / frosted `BottomNavigationBar` placement (also inside breakpoint wrappers); `Scaffold` body content is no longer hidden behind a floating bar. Fixed the clipped `Scaffold` sidebar, and `ResponsiveBuilder` / `BreakPointWrapper` layout inside flex and grid parents.
- Added `Scaffold.extendBody`: content can scroll behind a floating bottom navigation bar, and vertical scroll views without explicit `padding` pad their content so the last item clears the bar.
- Accessibility: pinch-zoom is no longer disabled, keyboard focus is always visible, and `Switch`, `Slider`, `Icon(onTap:)` and `Button.icon` expose proper roles and labels.
- Added `ComponentScheme.calendar` (`CalendarScheme`) to theme `Calendar` cell, font and time-stepper sizes, including their small-screen caps.
- Added `onError` to `NakiFutureBuilder` and `NakiStreamBuilder`; fixed stream subscription leaks.
- Fixed `Curves` easing values, `RotatedBox`, `Visibility(maintainState: true)`, and `ScrollController` with `NeverScrollableScrollPhysics`.
- A modal `Drawer` always blocks the background; `barrierDismissible` only controls tap-to-close.
- `Container` and `Card` no longer clip their content by default, so pickers, menus and tooltips inside them are not cut off. Use `Card(clip: true)` or `BoxDecoration(clip: true)` to clip to rounded corners.
- Added `FragmentScope` component for grouping children without an intermediate layout box with optional support for inheriting parent display property.

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
