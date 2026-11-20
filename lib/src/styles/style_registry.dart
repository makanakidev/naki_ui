part of 'rules.dart';

extension StyleRulesExtension on Iterable<StyleRule> {
  /// Converts a list of style rules into raw css.
  String toCss() {
    final imports = StringBuffer();
    final rules = StringBuffer();
    const indent = kDebugMode || kGenerateMode ? '\n' : ' ';

    for (final rule in this) {
      final css = rule.toCss() + indent;

      if (css.trim().startsWith('@import')) {
        imports.write(css);
      } else {
        rules.write(css);
      }
    }

    return (imports.toString() + rules.toString()).trimRight();
  }
}

/// A component utility for rendering a list of [StyleRule] objects
/// into a `<style>` element.
class StyleRules extends StatelessComponent {
  /// The style rules to render.
  final List<StyleRule> rules;

  /// An optional id for the style element.
  final String? id;

  /// Optional attributes to set on the style element.
  final Map<String, String>? attributes;

  /// Creates a new instance of [StyleRules].
  const StyleRules(this.rules, {super.key, this.id, this.attributes});

  @override
  Component build(BuildContext context) {
    return .element(
      tag: 'style',
      id: id,
      attributes: attributes,
      children: [RawText(rules.toCss())],
    );
  }
}

/// Central registry to ensure style rules are emitted exactly once per
/// stylesheet.
///
/// Jaspr evaluates every `@css` getter synchronously each time it builds a
/// stylesheet; in the default inline-styles mode that happens on *every*
/// server request. Deduplication is therefore scoped to a single synchronous
/// pass and reset in a microtask, so later requests receive the full set of
/// rules again instead of an empty list.
final class NakiStyleRegistry {
  final Set<String> _registeredKeys = {};
  final Set<String> _generatedCss = {};
  bool _resetScheduled = false;

  /// Cache of rendered css per rule instance (rules are static finals).
  static final Expando<String> _cssCache = Expando('naki-css');

  /// Global static registry used for compile-time `@css` getters.
  static final NakiStyleRegistry global = NakiStyleRegistry();

  /// Static helper for `@css` getters
  static List<StyleRule> once(String key, List<StyleRule> rules) =>
      global.register(key, rules);

  /// Static helper to dedupe rules.
  static List<StyleRule> dedupe(List<StyleRule> rules) => global._dedupe(rules);

  /// Registers [rules] once per [key] within the current stylesheet pass.
  List<StyleRule> register(String key, List<StyleRule> rules) {
    _scheduleReset();
    if (_registeredKeys.contains(key)) return const [];
    _registeredKeys.add(key);
    return _dedupe(rules);
  }

  /// Deduplicate css rules and return unique rules
  List<StyleRule> _dedupe(List<StyleRule> rules) {
    _scheduleReset();
    final uniqueRules = <StyleRule>[];

    for (final rule in rules) {
      final css = _cssCache[rule] ??= rule.toCss();
      if (_generatedCss.contains(css)) continue;
      _generatedCss.add(css);
      uniqueRules.add(rule);
    }

    return uniqueRules;
  }

  /// Resets the registry once the current synchronous pass completes.
  void _scheduleReset() {
    if (_resetScheduled) return;
    _resetScheduled = true;
    scheduleMicrotask(clear);
  }

  /// Clears the registry.
  void clear() {
    _registeredKeys.clear();
    _generatedCss.clear();
    _resetScheduled = false;
  }
}
