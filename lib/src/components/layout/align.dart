part of 'index.dart';

/// {@template Align}
/// A component that positions its child within itself using an
/// alignment value. Optionally, [widthFactor] and [heightFactor]
/// shrink the component to a fraction of the child's intrinsic size.
///
/// ### Example
/// ```dart
/// Align(
///   alignment: Alignment.center,
///   widthFactor: 0.5,
///   heightFactor: 0.5,
///   child: Container(
///     decoration: BoxDecoration(backgroundColor: Colors.red),
///     size: SizeConstraints(width: Dim.px(200), height: Dim.px(200)),
///     child: NakiText('Centered Content'),
///   ),
/// )
/// ```
/// {@endtemplate}
class Align extends StatefulComponent {
  /// Component to align.
  final Component child;

  /// How to align the child.
  final Alignment alignment;

  /// If non-null, shrinks the align component to its child's
  /// intrinsic width multiplied by this factor
  /// (e.g. `0.5` → half the child's natural width).
  ///
  /// Note: Must be non-negative. Values greater than 1 expand
  /// the component.
  final double? widthFactor;

  /// If non-null, shrinks the align component to its child's
  /// intrinsic height multiplied by this factor
  /// (e.g. `0.5` → half the child's natural height).
  ///
  /// Note: Must be non-negative. Values greater than 1 expand
  /// the component.
  final double? heightFactor;

  /// Additional CSS classes applied to the align component.
  final String? classes;

  /// {@macro Align}
  const Align({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    this.classes,
  }) : assert(
         widthFactor == null || widthFactor >= 0.0,
         'widthFactor must be non-negative',
       ),
       assert(
         heightFactor == null || heightFactor >= 0.0,
         'heightFactor must be non-negative',
       );

  @override
  State<Align> createState() => _AlignState();

  static List<StyleRule> get styles => LayoutStyles.align;
}

class _AlignState extends State<Align> with NakiStatefulMixin {
  late String _id;

  double? _width;
  double? _height;

  bool _isOverflowing = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'align');
  }

  /// Returns the component html element
  HTMLElement? get _rootNode => component.key is GlobalNodeKey<HTMLElement>
      ? (component.key as GlobalNodeKey<HTMLElement>).currentNode
      : document.getElementById(_id) as HTMLElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final wf = component.widthFactor;
    final hf = component.heightFactor;

    // If no factors are provided, reset overflow flag and exit
    if (wf == null && hf == null) {
      if (_isOverflowing) setState(() => _isOverflowing = false);
      return null;
    }

    // Locate and measure the first child element's intrinsic size
    final child = _rootNode?.firstElementChild as HTMLElement?;
    if (child == null) return null;

    final newWidth = wf != null ? child.offsetWidth * wf : null;
    final newHeight = hf != null ? child.offsetHeight * hf : null;

    // If factors changed, update dimensions and set overflow flag
    if (newWidth != _width || newHeight != _height) {
      setState(() {
        _width = newWidth;
        _height = newHeight;
        _isOverflowing = (wf != null && wf < 1) || (hf != null && hf < 1);
      });
    }

    return null;
  }

  @override
  void didUpdateComponent(Align oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.widthFactor != component.widthFactor ||
        oldComponent.heightFactor != component.heightFactor ||
        oldComponent.child != component.child) {
      refreshAfterRender();
    }
  }

  @override
  Component build(BuildContext context) {
    final alignment = NakiAlignProps.mapAlignment(component.alignment);
    final width = _width?.toPx;
    final height = _height?.toPx;

    const baseClass = 'naki-align';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    return .element(
      tag: 'naki-align',
      key: component.key,
      id: _id,
      classes: effectiveClasses,
      styles: Styles(
        raw: {
          'overflow': ?(_isOverflowing ? 'hidden' : null),
          'width': ?width,
          'height': ?height,
          ...alignment,
        },
      ),
      children: [component.child],
    );
  }
}
