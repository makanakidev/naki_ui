part of 'index.dart';

/// Returns the theme switching script for the current theme mode.
String themeSwitchingScript(String currentMode, bool cache) {
  return kThemeSwitchingScript
      .replaceAll('{{MODE}}', currentMode)
      .replaceAll('{{CACHE}}', '$cache');
}

/// Updates the root element data attribute with theme mode class.
void updateRootTheme(String mode) {
  if (kIsServer) return;

  void applyTheme() {
    final root = document.documentElement as HTMLElement;
    root.setAttribute('data-naki-theme', mode);
  }

  // WebKit paints the transition from flat snapshots: they drop backdrop
  // blurs, tint Safari's bars, and sit off-screen while its toolbar is hidden.
  final isWebKit = PlatformData.current.isWebKit;

  // Fades the theme's color variables on <html> instead of every element's
  // colors: `color` is inherited, so per-element transitions chain and a deeply
  // nested heading lags ~120ms behind each ancestor that is fading too.
  void fadeTheme() {
    final root = document.documentElement as HTMLElement;
    final colorVars = _registerThemeColorVars();

    root.classList.add('switching-theme');
    root.style.setProperty(
      'transition',
      [for (final name in colorVars) '$name 120ms ease-out'].join(', '),
    );
    // Start from the current values rather than the pre-registration ones.
    window.getComputedStyle(root).getPropertyValue('transition');

    applyTheme();

    Future.delayed(const Duration(milliseconds: 150), () {
      root.classList.remove('switching-theme');
      if (root.classList.length < 1) root.removeAttribute('class');
      root.style.removeProperty('transition');
      if (root.style.length < 1) root.removeAttribute('style');
    });
  }

  if (isWebKit) return fadeTheme();

  try {
    document.startViewTransition(applyTheme.toJS);
  } catch (_) {
    fadeTheme();
  }
}

/// Theme color variables registered as `<color>`, so they can transition.
List<String>? _themeColorVars;

/// Registers the variables the light and dark themes both set to a plain
/// color, and returns their names. A registered variable must always hold a
/// color, so those set to anything else (a var(), currentcolor) are skipped;
/// they still follow the registered ones they reference.
List<String> _registerThemeColorVars() {
  if (_themeColorVars case final names?) return names;

  final light = <String, String>{};
  final dark = <String, String>{};

  final sheets = document.styleSheets;
  for (var i = 0; i < sheets.length; i++) {
    final CSSRuleList rules;
    try {
      rules = sheets.item(i)!.cssRules;
    } catch (_) {
      continue; // cross-origin sheet
    }

    for (var j = 0; j < rules.length; j++) {
      final rule = rules.item(j);
      if (rule == null || !rule.isA<CSSStyleRule>()) continue;
      rule as CSSStyleRule;

      final selector = rule.selectorText;
      final target = selector.contains('data-naki-theme="light"')
          ? light
          : selector.contains('data-naki-theme="dark"')
          ? dark
          : null;
      if (target == null) continue;

      final style = rule.style as CSSStyleDeclaration;
      for (var k = 0; k < style.length; k++) {
        final name = style.item(k);
        if (name.startsWith('--')) {
          target[name] = style.getPropertyValue(name).trim();
        }
      }
    }
  }

  bool isPlainColor(String? value) =>
      value != null &&
      !value.contains('var(') &&
      value.toLowerCase() != 'currentcolor' &&
      CSS.supports('color', value);

  final names = <String>[];
  for (final name in light.keys) {
    if (!isPlainColor(light[name]) || !isPlainColor(dark[name])) continue;
    try {
      CSS.registerProperty(
        PropertyDefinition(
          name: name,
          syntax: '<color>',
          inherits: true,
          initialValue: 'transparent',
        ),
      );
      names.add(name);
    } catch (_) {
      // already registered by the app
    }
  }

  return _themeColorVars = names;
}
