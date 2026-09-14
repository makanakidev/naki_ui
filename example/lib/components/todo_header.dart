import 'package:jaspr/dom.dart' hide Padding, Position, Transform, Visibility;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

class TodoHeader extends StatelessComponent {
  final int totalCount;
  final int completedCount;

  const TodoHeader({
    super.key,
    required this.totalCount,
    required this.completedCount,
  });

  @override
  Component build(BuildContext context) {
    final double percent = totalCount == 0 ? 0.0 : (completedCount / totalCount);
    final int percentInt = (percent * 100).round();

    return Card.filled(
      borderRadius: BorderRadiusData.all(const Dim.px(16)),
      padding: const EdgeInsets.all(Dim.px(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Heading('My Tasks'),
                  SubHeading(
                    'Keep track of your daily priorities',
                    style: TextStyle(fontSize: Dim.rem(0.875)),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  backgroundColor: context.withOpacity(
                    context.primaryColor,
                    0.12,
                  ),
                  borderRadius: BorderRadiusData.all(const Dim.px(20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dim.px(12),
                    vertical: Dim.px(6),
                  ),
                  child: NakiText(
                    '$completedCount of $totalCount done',
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: const Dim.rem(0.8125),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            height: const Dim.px(6),
            width: const Dim.percent(100),
            clip: true,
            decoration: BoxDecoration(
              backgroundColor: context.surfaceMutedColor,
              borderRadius: BorderRadiusData.all(const Dim.px(3)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: const Dim.px(6),
                width: Dim.percent(percentInt.toDouble()),
                decoration: BoxDecoration(
                  backgroundColor: context.primaryColor,
                  borderRadius: BorderRadiusData.all(const Dim.px(3)),
                ),
                child: const .empty(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
