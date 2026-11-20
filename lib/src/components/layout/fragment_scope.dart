part of 'index.dart';

/// {@template FragmentScope}
/// A Naki component that renders its children as if they were direct
/// children of the parent component.
///
/// This component simply renders its children like [Component.fragment]
/// but without the SSR complexities and hydration issues.
///
/// ### Example
/// ```dart
/// FragmentScope(
///   inherit: false,
///   [
///     NakiText('Hello'),
///     Container(
///       child: Column(
///         children: [
///           NakiText('About Us'),
///         ],
///       ),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class FragmentScope extends StatelessComponent {
  /// Components to render.
  final List<Component> children;

  /// Whether to inherit display property from the parent component.
  ///
  /// When `true`, fragment scope will inherit display property
  /// from the parent component, which can be useful for forcing
  /// consistency with parent layout.
  final bool inherit;

  /// {@macro FragmentScope}
  const FragmentScope(this.children, {super.key, this.inherit = false});

  @override
  Component build(BuildContext context) {
    if (children.isEmpty) return const Component.empty();

    return .element(
      tag: 'naki-fragment',
      children: children,
      styles: Styles(display: inherit ? Display.inherit : null),
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Fragment', [Rules.nakiFragmentRules]);
}
