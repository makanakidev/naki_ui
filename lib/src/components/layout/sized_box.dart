part of 'index.dart';

/// {@template SizedBox}
/// A component that provides a bounded size for its descendants when
/// [child] is provided.
///
/// It can also act as an empty spacer when [child] is not provided.
///
/// ### Example
/// ```dart
/// SizedBox(
///   width: Dim.px(100),
///   height: Dim.px(100),
///   child: NakiText('Padded Content'),
/// )
/// ```
/// {@endtemplate}
class SizedBox extends StatelessComponent {
  /// Component to size.
  final Component? child;

  /// Width of the sized box.
  final Dim? width;

  /// Height of the sized box.
  final Dim? height;

  /// Additional CSS classes applied to the sized box.
  final String? classes;

  /// {@macro SizedBox}
  const SizedBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.classes,
  });

  /// Creates a SizedBox of the given size.
  const SizedBox.fromSize({required Dim size, this.child, this.classes})
    : width = size,
      height = size;

  /// Creates a SizedBox that is an empty spacer of the given height.
  const SizedBox.height(this.height)
    : width = null,
      child = null,
      classes = null;

  /// Creates a SizedBox that is an empty spacer of the given width.
  const SizedBox.width(this.width)
    : height = null,
      child = null,
      classes = null;

  @override
  Component build(BuildContext context) {
    if (width == null &&
        height == null &&
        child == null &&
        classes.isNullOrEmpty) {
      return const .empty();
    }

    const baseClass = 'naki-sizedbox';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    return .element(
      tag: 'naki-sizedbox',
      key: key,
      classes: effectiveClasses,
      styles: Styles(
        raw: {'width': ?width?.cssText, 'height': ?height?.cssText},
      ),
      children: [?child],
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('SizedBox', [Rules.nakiSizedBoxRules]);
}
