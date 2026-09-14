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
  final VoidCallback onClearCompleted;

  const TodoFilterBar({
    super.key,
    required this.activeCount,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.hasCompleted,
    required this.onClearCompleted,
  });

  @override
  Component build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        NakiText(
          '$activeCount ${activeCount <= 1 ? 'item' : 'items'} left',
          style: TextStyle(
            color: context.subtitleColor,
            fontSize: const Dim.rem(0.875),
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          spacing: 6,
          children: TodoFilter.values.map((filter) {
            final isSelected = filter == currentFilter;
            if (isSelected) {
              return Button.filled(
                context.primaryColor,
                key: ValueKey('filter-${filter.name}'),
                hoverColor: context.primaryColor.withOpacity(0.8),
                padding: const EdgeInsets.symmetric(
                  horizontal: Dim.px(20),
                  vertical: Dim.px(6),
                ),
                onTap: () => onFilterChanged(filter),
                child: NakiText(
                  filter.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: Dim.rem(0.85),
                  ),
                ),
              );
            } else {
              return Button.text(
                filter.label,
                key: ValueKey('filter-${filter.name}'),
                style: TextStyle(
                  color: context.subtitleColor,
                  fontWeight: FontWeight.w500,
                  fontSize: const Dim.rem(0.85),
                ),
                onTap: () => onFilterChanged(filter),
              );
            }
          }).toList(),
        ),

        if (hasCompleted && currentFilter == TodoFilter.completed)
          Button.text(
            'Clear All',
            border: BorderData.only(
              radius: BorderRadiusData.all(const Dim.px(8)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dim.px(20),
              vertical: Dim.px(6),
            ),
            style: TextStyle(
              color: context.errorColor,
              fontWeight: FontWeight.w500,
              fontSize: const Dim.rem(0.85),
            ),
            onTap: onClearCompleted,
          ),
      ],
    );
  }
}
