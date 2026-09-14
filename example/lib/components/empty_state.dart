import 'package:jaspr/dom.dart' hide Padding, Position, Transform, Visibility;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart' show MaterialIcons;
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import '../models/todo_item.dart';

class EmptyState extends StatelessComponent {
  final TodoFilter filter;

  const EmptyState({super.key, required this.filter});

  @override
  Component build(BuildContext context) {
    final String message;
    final String submessage;

    switch (filter) {
      case TodoFilter.all:
        message = 'No tasks yet';
        submessage = 'Add a task above to get started with your day';
        break;
      case TodoFilter.active:
        message = 'No active tasks';
        submessage = 'All tasks have been completed or none added yet';
        break;
      case TodoFilter.completed:
        message = 'No completed tasks';
        submessage = 'Check off tasks as you finish them';
        break;
    }

    return Card.outlined(
      borderRadius: BorderRadiusData.all(const Dim.px(16)),
      padding: const EdgeInsets.symmetric(
        horizontal: Dim.px(24),
        vertical: Dim.px(36),
      ),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Container(
              decoration: BoxDecoration(
                backgroundColor: context.surfaceMutedColor,
                borderRadius: BorderRadiusData.all(const Dim.px(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Dim.px(16)),
                child: Icon(
                  MaterialIcons.icon_round_checklist,
                  size: 32,
                  color: context.subtitleColor,
                ),
              ),
            ),
            const SizedBox.height(Dim.px(4)),
            NakiText(
              message,
              style: TextStyle(
                color: context.textColor,
                fontWeight: FontWeight.w600,
                fontSize: const Dim.rem(1.0),
              ),
            ),
            NakiText(
              submessage,
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: const Dim.rem(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
