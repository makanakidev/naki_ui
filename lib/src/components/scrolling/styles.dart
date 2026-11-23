import 'package:jaspr/dom.dart';

import '../../styles/rules.dart';

/// Pure CSS rules for scrolling components.
abstract final class ScrollingStyles {
  @css
  static List<StyleRule> get singleChildScrollView => NakiStyleRegistry.once(
    'SingleChildScrollView',
    [Rules.nakiSingleChildScrollViewRules],
  );

  @css
  static List<StyleRule> get listView =>
      NakiStyleRegistry.once('ListView', [Rules.nakiListViewRules]);

  @css
  static List<StyleRule> get table =>
      NakiStyleRegistry.once('Table', [Rules.nakiTableRules]);

  @css
  static List<StyleRule> get pageView =>
      NakiStyleRegistry.once('PageView', [Rules.nakiPageViewRules]);

  @css
  static List<StyleRule> get gridView =>
      NakiStyleRegistry.once('GridView', [Rules.nakiGridViewRules]);

  @css
  static List<StyleRule> get carouselView =>
      NakiStyleRegistry.once('CarouselView', [Rules.nakiCarouselRules]);

  @css
  static List<StyleRule> get staggeredView =>
      NakiStyleRegistry.once('StaggeredView', [Rules.nakiStaggeredRules]);
}
