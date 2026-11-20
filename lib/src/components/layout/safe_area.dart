part of 'index.dart';

/// {@template SafeArea}
/// A component that insets its child by sufficient padding to avoid
/// system intrusions (notches, toolbars).
///
/// ### Example
/// ```dart
/// SafeArea(
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class SafeArea extends StatelessComponent {
  /// Component to display inside the safe area.
  final Component child;

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions on the top.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom.
  final bool bottom;

  /// Additional CSS classes applied to the safe area component.
  final String? classes;

  /// {@macro SafeArea}
  const SafeArea({
    super.key,
    required this.child,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    final styles = Css.nakiSafeAreaStyles;

    return .element(
      tag: 'naki-safearea',
      key: key,
      classes: classes,
      styles: Styles(
        raw: {
          'padding-top': ?(top ? styles['padding-top'] : null),
          'padding-left': ?(left ? styles['padding-left'] : null),
          'padding-right': ?(right ? styles['padding-right'] : null),
          'padding-bottom': ?(bottom ? styles['padding-bottom'] : null),
          'display': 'block',
          'box-sizing': 'border-box',
        },
      ),
      children: [child],
    );
  }
}
