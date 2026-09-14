# Scrolling components

Create a `ScrollController` or `PageController` in state when programmatic navigation or observation is required, pass it to the component, and dispose it from the same owner.

## SingleChildScrollView

Scroll one child along one axis.

```dart
SingleChildScrollView(
  direction: ScrollDirection.vertical,
  padding: const EdgeInsets.all(Dim.px(16)),
  physics: const ClampingScrollPhysics(),
  controller: scrollController,
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [NakiText('Long content')],
  ),
)
```

Do not make the child `Column` scrollable as well. Constrain the scroll view when it is nested in flex or grid layout.

## ListView

Render a linear scrollable list.

```dart
ListView(
  padding: const EdgeInsets.all(Dim.px(12)),
  itemExtent: const Dim.px(48),
  children: const [
    NakiText('First'),
    NakiText('Second'),
  ],
)
```

Use `shrinkWrap` when the list should size to its content rather than fill available space. Use `reverse` only when both visual and interaction order are intentionally reversed.

For large data sets, use incremental builders:

```dart
ListView.builder(
  itemCount: messages.length,
  initialItemCount: 20,
  loadMoreItemCount: 20,
  loadMoreThreshold: 240,
  itemBuilder: (context, index) => MessageTile(messages[index]),
)
```

Use `ListView.separated` when separators are part of list presentation:

```dart
ListView.separated(
  itemCount: messages.length,
  itemBuilder: (context, index) => MessageTile(messages[index]),
  separatorBuilder: (context, index) => const SizedBox.height(Dim.px(8)),
)
```

Provide stable keys within item components when identity must survive incremental rendering.

## GridView

Render a regular scrolling grid.

```dart
GridView.count(
  3,
  mainAxisSpacing: const Dim.px(12),
  crossAxisSpacing: const Dim.px(12),
  childAspectRatio: AspectRatioType.ratio1_1,
  children: products.map(ProductCard.new).toList(),
)
```

Use `GridView.extent(maxCrossAxisExtent, ...)` for responsive columns constrained by maximum item width. Use `GridView.builder` for large collections:

```dart
GridView.builder(
  itemCount: products.length,
  initialItemCount: 12,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: Dim.px(12),
    crossAxisSpacing: Dim.px(12),
  ),
  itemBuilder: (context, index) => ProductCard(products[index]),
)
```

Use `expandLastItem` only when a partially filled final row should span remaining columns.

## GridTile

Override one grid child's row or column span.

```dart
const GridTile(
  columnSpan: 2,
  rowSpan: 1,
  child: Card(child: NakiText('Featured item')),
)
```

Use `fullWidth: true` to span the complete grid width. Place `GridTile` inside `GridView`; outside a grid its span metadata has no useful effect.

## PageView

Present full pages with optional snapping and page change callbacks.

```dart
PageView(
  controller: pageController,
  pageSnapping: true,
  onPageChanged: (index) => setState(() => currentPage = index),
  children: const [
    OnboardingPageOne(),
    OnboardingPageTwo(),
    OnboardingPageThree(),
  ],
)
```

Use `PageView.builder` when page creation should be deferred:

```dart
PageView.builder(
  itemCount: articles.length,
  controller: pageController,
  itemBuilder: (context, index) => ArticlePage(articles[index]),
)
```

Use `PageController.nextPage`, `previousPage`, or page-aware animation methods instead of calculating offsets manually.

## CarouselView

Render cards with a fixed main-axis extent and optional snapping.

```dart
CarouselView(
  itemExtent: const Dim.px(280),
  itemSnapping: true,
  onTap: openFeaturedItem,
  children: featured.map(ProductCard.new).toList(),
)
```

Use `CarouselView.weighted` when items should have relative widths:

```dart
CarouselView.weighted(
  flexWeights: const [1, 2, 1],
  itemExtent: const Dim.px(160),
  children: const [
    Card(child: NakiText('Small')),
    Card(child: NakiText('Featured')),
    Card(child: NakiText('Small')),
  ],
)
```

Keep weights positive and aligned with the intended child pattern. Use `PageView` when each item represents a full logical page.

## Table

Render headers and typed `TableRow` models.

```dart
Table(
  headers: const [Bold('ID'), Bold('Customer'), Bold('Status')],
  headerAlignment: TableHeaderCellAlignment.center,
  headerBorderColor: context.borderColor,
  border: TableBorder(
    horizontalInside: BorderSideData(color: context.borderColor),
  ),
  columnWidths: const {
    0: FixedColumnWidth(Dim.px(64)),
    1: FlexColumnWidth(),
    2: IntrinsicColumnWidth(),
  },
  rows: const [
    TableRow(
      alignment: TableRowCellAlignment.center,
      children: [
        NakiText('#1042'),
        NakiText('Amina Yusuf'),
        NakiText('Paid'),
      ],
    ),
  ],
)
```

Use `FixedColumnWidth`, `FlexColumnWidth`, `IntrinsicColumnWidth`, or `FractionColumnWidth` per column. Provide `emptyStateContent` for a custom empty state, or set the empty title and subtitle. Keep headers meaningful and row cell counts consistent.

## StaggeredView

Render masonry-like content in columns or rows.

```dart
StaggeredView.count(
  3,
  mainAxisSpacing: const Dim.px(12),
  crossAxisSpacing: const Dim.px(12),
  expandLastItem: true,
  children: cards,
)
```

`crossAxisCount` must be greater than zero. Supply scrolling physics and a controller as needed. For a regular grid with aligned rows, use `GridView`.

## StaggeredTile

Mark a staggered child as full width.

```dart
const StaggeredTile(
  fullWidth: true,
  child: Banner(
    severity: BannerType.info,
    primary: NakiText('Featured announcement'),
  ),
)
```

Place it inside `StaggeredView`. Without `fullWidth`, it behaves like the wrapped child.
