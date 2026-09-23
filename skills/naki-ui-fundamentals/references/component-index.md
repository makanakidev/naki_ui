# Component index

Use this index to load the smallest relevant reference file. Every component exported by `package:naki_ui/naki_ui.dart` is listed.

| Component | Purpose | Reference |
| --- | --- | --- |
| `NakiApp`, `PageNotFound` | Application root, metadata, theming, routing, fallback page | [application.md](components/application.md) |
| `MediaQueryProvider`, `MediaQueryData` | Viewport or component-size observation | [application.md](components/application.md) |
| `NakiFutureBuilder`, `NakiStreamBuilder` | Render futures and streams | [async.md](components/async.md) |
| `Column`, `Row` | Vertical and horizontal flex layout | [basics.md](components/basics.md) |
| `Image` | Responsive image rendering | [basics.md](components/basics.md) |
| `NakiText` | Styled plain text | [basics.md](components/basics.md) |
| `Button` | Semantic action control | [basics.md](components/basics.md) |
| `Icon` | Icon rendering and optional action | [basics.md](components/basics.md) |
| `Spinner` | Loading progress | [basics.md](components/basics.md) |
| `GestureDetector` | Typed gestures around a child | [basics.md](components/basics.md) |
| `Banner` | Persistent status or alert message | [basics.md](components/basics.md) |
| `RichText`, `TextSpan`, `ComponentSpan` | Mixed inline text and components | [rich-text.md](components/rich-text.md) |
| `Bold`, `Italic`, `Underline`, `Strikethrough` | Inline typography helpers | [rich-text.md](components/rich-text.md) |
| `Heading`, `SubHeading` | Heading text | [rich-text.md](components/rich-text.md) |
| `Label` | Low-level label for custom controls | [inputs.md](components/inputs.md) |
| `TextField` | Text, number, password, email, search, and multiline input | [inputs.md](components/inputs.md) |
| `FormBuilder` | Native form composition and validation scope | [inputs.md](components/inputs.md) |
| `AutoCompleteField` | Filtered text suggestions | [inputs.md](components/inputs.md) |
| `SegmentedInput` | OTP and PIN entry | [inputs.md](components/inputs.md) |
| `Calendar` | Date, time, or combined selection | [inputs.md](components/inputs.md) |
| `Checkbox`, `Switch`, `Slider`, `RadioButton`, `Dropdown` | Selection controls | [selection.md](components/selection.md) |
| `Align`, `AspectRatio` | Alignment and ratio constraints | [layout.md](components/layout.md) |
| `Flexible`, `Expanded` | Flex sizing | [layout.md](components/layout.md) |
| `Padding`, `Margin`, `SizedBox` | Spacing and fixed sizing | [layout.md](components/layout.md) |
| `Stack`, `Positioned` | Layered layout | [layout.md](components/layout.md) |
| `Wrap` | Multi-run flex layout | [layout.md](components/layout.md) |
| `SafeArea` | Browser safe-area insets | [layout.md](components/layout.md) |
| `Container`, `Card` | Sized and decorated surfaces | [layout.md](components/layout.md) |
| `ResponsiveBuilder`, `BreakPointWrapper` | Declarative CSS responsive breakpoints | [responsive.md](components/responsive.md) |
| `ExpansionPanel`, `ExpansionPanelList`, `ExpansionTile` | Disclosure and accordion UI | [layout.md](components/layout.md) |
| `Snackbar`, `Tooltip`, `Dialog`, `Drawer`, `BottomSheet`, `Popover` | Overlay UI | [overlays.md](components/overlays.md) |
| `Opacity`, `Visibility`, `ClipRect`, `DecoratedBox`, `ClipOval` | Paint and clipping | [painting.md](components/painting.md) |
| `BackdropFilter`, `ColoredBox`, `RotatedBox`, `Transform` | Filters, color, rotation, and transforms | [painting.md](components/painting.md) |
| `AppBar`, `BottomNavigationBar`, `Scaffold` | Application page structure | [scaffold.md](components/scaffold.md) |
| `SingleChildScrollView`, `ListView` | Linear scrolling | [scrolling.md](components/scrolling.md) |
| `GridView`, `GridTile` | Regular grid scrolling | [scrolling.md](components/scrolling.md) |
| `PageView`, `CarouselView` | Paged and carousel content | [scrolling.md](components/scrolling.md) |
| `Table` | Structured tabular content | [scrolling.md](components/scrolling.md) |
| `StaggeredView`, `StaggeredTile` | Masonry-style layout | [scrolling.md](components/scrolling.md) |

## Exported supporting types

The component entrypoint also exports callback and configuration types used by these components, including `NakiPageBuilder`, `SnapshotBuilder`, `FieldValidator`, `ExpansionPanelHeaderBuilder`, and `ExpansionPanelCallback`. Their usage is documented beside the component that consumes them.
