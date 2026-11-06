import 'package:jaspr/dom.dart' hide Padding, Position;
import 'package:jaspr/jaspr.dart';
import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'showcase.dart';

/// Button, RichText, Icon, Spinner and Banner.
class BasicsPage extends StatefulComponent {
  const BasicsPage({super.key});

  @override
  State<BasicsPage> createState() => _BasicsPageState();
}

class _BasicsPageState extends State<BasicsPage> {
  bool _showBanner = true;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  Component build(BuildContext context) {
    return ShowcasePage(
      groups: [
        ShowcaseGroup(
          title: 'Basics',
          subtitle: 'The widgets every screen starts with.',
          demos: [
            Demo(
              name: 'Button',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Button.filled(
                    context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(10),
                    ),
                    child: const NakiText('Filled'),
                  ),
                  Button.outlined(
                    BorderData(
                      color: context.primaryColor,
                      width: const Dim.px(2),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                    backgroundColor: Colors.transparent,
                    foregroundColor: context.primaryColor,
                    child: const NakiText('Outlined'),
                  ),
                  Button.text(
                    'Text',
                    foregroundColor: context.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  Button.iconText(
                    icon: MaterialIcons.icon_round_add,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dim.px(12),
                    ),
                    text: 'With icon',
                    iconSize: 18,
                    iconPosition: Position.left,
                  ),
                  Button.icon(
                    MaterialIcons.icon_round_favorite,
                    border: const BorderData.only(
                      radius: BorderRadiusData.circular,
                    ),
                    semanticLabel: 'Favorite',
                  ),
                ],
              ),
            ),
            Demo(
              name: 'RichText',
              child: RichText(
                text: TextSpan(
                  text: 'Compose ',
                  style: TextStyle(color: context.subtitleColor),
                  children: [
                    TextSpan(
                      text: 'styled spans',
                      style: TextStyle(
                        color: context.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: ' just like in Flutter.'),
                  ],
                ),
              ),
            ),
            Demo(
              name: 'Icon',
              child: Row(
                spacing: 16,
                children: [
                  Icon(
                    MaterialIcons.icon_round_star,
                    size: 28,
                    color: context.primaryColor,
                  ),
                  const Icon(
                    MaterialIcons.icon_round_check_circle,
                    size: 28,
                    color: Color('#10b981'),
                  ),
                  const Icon(
                    MaterialIcons.icon_round_favorite,
                    size: 28,
                    color: Color('#ef4444'),
                  ),
                  const Icon(
                    MaterialIcons.icon_round_notifications,
                    size: 28,
                    color: Color('#f59e0b'),
                  ),
                ],
              ),
            ),
            const Demo(
              name: 'Spinner',
              child: Row(
                spacing: 24,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spinner(size: Dim.px(32)),
                  Spinner.ios(size: Dim.px(32)),
                  Spinner.glass(size: Dim.px(32)),
                ],
              ),
            ),
            Demo(
              name: 'Banner',
              child: _showBanner
                  ? Banner(
                      severity: BannerType.info,
                      icon: const Icon(MaterialIcons.icon_round_info),
                      primary: const NakiText('Update available'),
                      secondary: const NakiText('Dismiss me to see it go.'),
                      dismissible: true,
                      onClose: () => setState(() => _showBanner = false),
                    )
                  : Button.text(
                      'Show banner',
                      height: const Dim.px(40),
                      onTap: () => setState(() => _showBanner = true),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
