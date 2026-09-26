import 'package:jaspr/dom.dart' hide Padding, Position, Transform, Visibility;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import '../models/todo_item.dart';

class TodoItemTile extends StatelessComponent {
  final TodoItem todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const TodoItemTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Component build(BuildContext context) {
    return Card.outlined(
      key: ValueKey(todo.id),
      borderRadius: BorderRadiusData.all(const Dim.px(12)),
      padding: const EdgeInsets.symmetric(
        horizontal: Dim.px(8),
        vertical: Dim.px(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          Checkbox(
            id: 'checkbox-${todo.id}',
            isChecked: todo.isCompleted,
            label: todo.title,
            labelPosition: Position.right,
            labelStyle: todo.isCompleted
                ? TextStyle(
                    color: context.subtitleColor,
                    decorationLine: TextDecorationLine.lineThrough,
                  )
                : TextStyle(
                    color: context.textColor,
                    fontWeight: FontWeight.w500,
                  ),
            onChange: onToggle,
          ),

          Icon(
            MaterialIcons.icon_round_delete,
            size: 20,
            color: context.subtitleColor,
            semanticLabel: 'Delete task: ${todo.title}',
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
