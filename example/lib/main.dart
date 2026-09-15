import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart' show MaterialIcons;

import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'components/content.dart';

@client
class TodoApp extends StatelessComponent {
  final String base;
  const TodoApp({super.key, required this.base});

  @override
  Component build(BuildContext context) {
    return NakiApp(
      title: 'Minimalist Tasks',
      locale: 'en',
      themeMode: ThemeMode.system,
      cacheThemeMode: true,
      basePath: base,
      favicon: 'assets/favicon.png',
      lightTheme: const LightThemeData(
        colorSeed: ColorSeed(
          primary: Color('#2563eb'),
          backgroundColor: Color('#f8fafc'),
          baseTextColor: Color('#0f172a'),
        ),
        typography: TypographyScheme(
          fontFamily: ['Inter', 'system-ui', 'sans-serif'],
        ),
      ),
      darkTheme: const DarkThemeData(
        colorSeed: ColorSeed(
          primary: Color('#60a5fa'),
          backgroundColor: Color('#090d16'),
          baseTextColor: Color('#f8fafc'),
        ),
        typography: TypographyScheme(
          fontFamily: ['Inter', 'system-ui', 'sans-serif'],
        ),
      ),
      seo: const SEO(
        title: 'Minimalist Task App — Naki UI',
        description: 'A sleek, minimalist to-do application built with Naki UI.',
        logo: 'assets/icon-dark.jpg',
        socialMediaBanner: 'assets/logo-dark.jpg',
      ),
      pageBuilder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            titleText: 'Sample Task App',
            actions: [
              Button.icon(
                context.themeMode == ThemeMode.dark
                    ? MaterialIcons.icon_round_dark_mode
                    : context.themeMode == ThemeMode.light
                    ? MaterialIcons.icon_round_light_mode
                    : MaterialIcons.icon_round_lightbulb,
                size: 28,
                padding: EdgeInsets.zero,
                border: const BorderData.only(radius: BorderRadiusData.circular),
                attributes: const {'aria-label': 'Toggle theme mode'},
                onTap: context.toggleTheme,
              ),
            ],
          ),
          body: const Content(),
        );
      },
    );
  }
}
