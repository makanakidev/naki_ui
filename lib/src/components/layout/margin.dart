part of 'index.dart';

/// {@template Margin}
/// A component that surrounds its child by the given margin.
///
/// ### Example
/// ```dart
/// Margin(
///   margin: EdgeInsets.all(Dim.px(8)),
///   child: NakiText('Margined Content'),
/// )
/// ```
/// {@endtemplate}
class Margin extends StatelessComponent {
  /// Component to surround with margin.
  final Component child;

  /// Margin applied around the child.
  final EdgeInsets margin;

  /// Additional CSS classes applied to the margin component.
  final String? classes;

  /// {@macro Margin}
  const Margin({
    super.key,
    required this.child,
    required this.margin,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    return .wrapElement(
      key: key,
      classes: classes,
      styles: Styles(raw: margin.mProps),
      child: child,
    );
  }
}
