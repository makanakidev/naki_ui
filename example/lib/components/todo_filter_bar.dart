import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import '../models/todo_item.dart';

class TodoFilterBar extends StatelessComponent {
  final int activeCount;
  final TodoFilter currentFilter;
  final ValueChanged<TodoFilter> onFilterChanged;
  final bool hasCompleted;
  final VoidCallback? toggle;

  const TodoFilterBar({
    super.key,
    required this.activeCount,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.hasCompleted,
    this.toggle,
  });

  @override
  Component build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      scrollable: true,
      children: [
        // item counter
        BreakPointWrapper(
          minWidth: 480,
          child: NakiText(
            '$activeCount ${activeCount <= 1 ? 'item' : 'items'} left',
            style: TextStyle(
              color: context.subtitleColor,
              fontSize: const Dim.rem(0.875),
              fontWeight: FontWeight.w500,
              lineHeight: Dim.normal,
            ),
          ),
        ),

        // filters buttons
        Row(
          spacing: 6,
          mainAxisSize: MainAxisSize.min,
          children: [
            // toggle scroll physics button
            Button.text(
              'Toggle scroll physics',
              gradient: Gradient.oceanBreeze,
              margin: const EdgeInsets.only(right: Dim.px(5)),
              padding: const EdgeInsets.all(Dim.px(10)),
              style: const TextStyle(
                color: Colors.white,
                fontSize: Dim.rem(0.9),
                lineHeight: Dim.normal,
              ),
              onTap: toggle,
            ),

            ...TodoFilter.values.map((filter) {
              if (filter == currentFilter) {
                return Button.filled(
                  context.primaryColor,
                  key: ValueKey('filter-${filter.name}'),
                  hoverColor: context.primaryColor.withOpacity(0.8),
                  padding: const EdgeInsets.all(Dim.px(10)),
                  onTap: () => onFilterChanged(filter),
                  child: NakiText(
                    filter.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: Dim.rem(0.9),
                      lineHeight: Dim.normal,
                    ),
                  ),
                );
              } else {
                return Button.text(
                  filter.label,
                  key: ValueKey('filter-${filter.name}'),
                  padding: const EdgeInsets.all(Dim.px(10)),
                  style: const TextStyle(
                    fontSize: const Dim.rem(0.9),
                    lineHeight: Dim.normal,
                  ),
                  onTap: () => onFilterChanged(filter),
                );
              }
            }),
          ],
        ),
      ],
    );
  }
}
