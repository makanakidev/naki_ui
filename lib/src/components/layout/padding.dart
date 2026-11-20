part of 'index.dart';

/// {@template Padding}
/// A component that insets its child by the given padding.
///
/// ### Example
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(Dim.px(8)),
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class Padding extends StatelessComponent {
  /// Component to inset with padding.
  final Component child;

  /// Padding applied to the child.
  final EdgeInsets padding;

  /// Additional CSS classes applied to the padding component.
  final String? classes;

  /// {@macro Padding}
  const Padding({
    super.key,
    required this.child,
    required this.padding,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    return .wrapElement(
      key: key,
      classes: classes,
      styles: Styles(raw: padding.pProps),
      child: child,
    );
  }
}
