part of 'index.dart';

/// {@template Stack}
/// A component that positions its children relative
/// to the edges of its box.
///
/// ### Example
/// ```dart
/// Stack(
///   children: [
///     Positioned(
///       top: Dim.px(10),
///       left: Dim.px(10),
///       child: NakiText('Padded Content'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class Stack extends StatelessComponent {
  /// Components to display in the stack. These components are rendered
  /// on top of each other, with later components appearing on top of
  /// earlier components.
  ///
  /// Typically [Positioned] components, but accepts any [Component].
  final List<Component> children;

  /// How to align the non-positioned components in the stack.
  final Alignment alignment;

  /// How the size of the stack children are constrained.
  final StackFit fit;

  /// Width of the stack component.
  final Dim? width;

  /// Height of the stack component.
  final Dim? height;

  /// Additional CSS classes applied to the stack component.
  final String? classes;

  /// {@macro Stack}
  const Stack({
    super.key,
    required this.children,
    this.alignment = Alignment.topLeft,
    this.fit = StackFit.loose,
    this.width,
    this.height,
    this.classes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-stack';
    final effectiveClasses = joinClasses([?classes, baseClass]);
    final alignStyles = NakiAlignProps.mapGridAlignment(alignment, fit);

    return StackScope(
      child: .element(
        tag: 'naki-stack',
        key: key,
        classes: effectiveClasses,
        styles: Styles(
          raw: {
            'width': ?width?.cssText,
            'height': ?height?.cssText,
            ...alignStyles,
          },
        ),
        children: children,
      ),
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Stack', [Rules.nakiStackRules]);
}
