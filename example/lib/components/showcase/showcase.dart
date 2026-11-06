import 'package:jaspr/dom.dart' show FontWeight;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

/// Scrollable page of [ShowcaseGroup]s inside the app's [PageView].
class ShowcasePage extends StatelessComponent {
  const ShowcasePage({super.key, required this.groups});

  final List<ShowcaseGroup> groups;

  @override
  Component build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dim.px(16),
        vertical: Dim.px(24),
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: const Dim.percent(100),
          constraints: const SizeConstraints(maxWidth: Dim.px(540)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: 32,
            children: groups,
          ),
        ),
      ),
    );
  }
}

class ShowcaseGroup extends StatelessComponent {
  const ShowcaseGroup({
    super.key,
    required this.title,
    required this.subtitle,
    required this.demos,
  });

  final String title;
  final String subtitle;
  final List<Component> demos;

  @override
  Component build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Heading(title, level: 2),
            NakiText(subtitle, style: TextStyle(color: context.subtitleColor)),
          ],
        ),
        ...demos,
      ],
    );
  }
}

class Demo extends StatelessComponent {
  const Demo({super.key, required this.name, required this.child});

  final String name;
  final Component child;

  @override
  Component build(BuildContext context) {
    return Card.outlined(
      padding: const EdgeInsets.all(Dim.px(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          NakiText(
            name,
            style: TextStyle(
              fontSize: const Dim.rem(0.9),
              fontWeight: FontWeight.w600,
              color: context.primaryColor,
            ),
          ),
          child,
        ],
      ),
    );
  }
}
