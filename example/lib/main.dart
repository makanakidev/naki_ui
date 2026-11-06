import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';

import 'package:naki_ui/framework.dart';
import 'package:naki_ui/naki_ui.dart';
import 'package:naki_ui/theme.dart';

import 'components/app_shell.dart';

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
      seo: SEO(
        title: 'Minimalist Task App — Naki UI',
        description:
            'A sleek, minimalist to-do application built with Naki UI.',
        url: PlatformData().baseUrl,
        logo: 'https://makanakidev.github.io/naki_ui/assets/icon-dark.jpg',
      ),
      pageBuilder: (context, child) => const AppShell(),
    );
  }
}
