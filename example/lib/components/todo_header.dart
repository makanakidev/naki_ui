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
    final double percent = totalCount == 0
        ? 0.0
        : (completedCount / totalCount);
    final percentInt = (percent * 100).roundTo(2);

    return Card.filled(
      borderRadius: BorderRadiusData.all(const Dim.px(16)),
      padding: const EdgeInsets.all(Dim.px(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          // title content row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // title and subtitle
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Heading('Tasks'),
                  SubHeading(
                    'Keep track of your daily priorities',
                    style: TextStyle(fontSize: Dim.rem(0.875)),
                  ),
                ],
              ),

              // badge
              Container(
                decoration: BoxDecoration(
                  backgroundColor: context.primaryColor.withOpacity(0.12),
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
                      fontWeight: FontWeight.w500,
                      lineHeight: const Dim(1),
                      fontSize: const Dim.rem(0.85),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // progress bar
          Container(
            height: const Dim.px(6),
            width: const Dim.percent(100),
            clip: true,
            decoration: BoxDecoration(
              backgroundColor: context.secondaryColor.withOpacity(0.2),
              borderRadius: BorderRadiusData.all(const Dim.px(3)),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: const Dim.percent(100),
                width: Dim.percent(percentInt),
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
