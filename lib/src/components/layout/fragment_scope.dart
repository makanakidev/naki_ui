part of 'index.dart';

/// {@template FragmentScope}
/// Use [NakiFragment] instead. [FragmentScope] will be removed
/// in `v2.0.0`.
/// {@endtemplate}
@Deprecated('This will be removed in v2.0.0. Use NakiFragment instead.')
class FragmentScope extends StatelessComponent {
  /// Components to render.
  final List<Component> children;

  /// {@macro FragmentScope}
  const FragmentScope(this.children, {super.key, bool inherit = false});

  @override
  Component build(BuildContext context) => NakiFragment(children);
}
