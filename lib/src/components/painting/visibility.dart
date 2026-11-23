part of 'index.dart';

/// {@template Visibility}
/// A component that conditionally shows or hides its child.
///
/// ### Example
/// ```dart
/// Visibility(
///   visible: isVisible,
///   child: NakiText('Visible text'),
/// )
/// ```
/// {@endtemplate}
class Visibility extends StatelessComponent {
  /// The component to conditionally display.
  final Component child;

  /// Whether the [child] is visible.
  final bool visible;

  /// Component to render when [visible] is `false`
  /// and [maintainState] is `false`.
  final Component replacement;

  /// Whether to maintain [child]'s state when hidden.
  final bool maintainState;

  /// Optional CSS Classes applied to the visibility component.
  final String? classes;

  /// {@macro Visibility}
  const Visibility({
    super.key,
    required this.child,
    this.visible = true,
    this.replacement = const SizedBox(),
    this.maintainState = false,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    if (!visible && !maintainState) return replacement;

    final Component effectiveChild = !visible && maintainState
        ? .wrapElement(classes: 'hide', child: child)
        : child;

    return .element(
      tag: 'naki-visibility',
      key: key,
      classes: classes,
      children: [effectiveChild],
    );
  }

  static List<StyleRule> get styles => PaintingStyles.visibility;
}
