part of 'index.dart';

/// {@template Image}
/// A component that displays an image.
///
/// ### Example
/// ```dart
/// Image(
///   'https://example.com/image.png',
///   alt: 'Image',
///   size: SizeConstraints(
///     width: Dim.px(100),
///     height: Dim.px(100),
///   ),
///   cache: true,
///   lazyLoad: true,
///   fit: ObjectFit.cover,
/// )
/// ```
/// {@endtemplate}
class Image extends StatelessComponent with NakiStatelessMixin {
  /// Image source can be a remote url, base64 encoded string
  /// or an asset path.
  final String src;

  /// Semantic description of the image for accessibility.
  ///
  /// When omitted, the image is rendered with an empty `alt`
  /// attribute and is treated as decorative by assistive
  /// technologies.
  final String? alt;

  /// Image size.
  final SizeConstraints? size;

  /// When `true` and [src] is a remote URL, the image will be
  /// cached. Future rendering will use the cached source
  /// provided that cache is enabled.
  final bool cache;

  /// How to inscribe the image into the space allocated.
  final ImageFit? fit;

  /// Defines the alignment of the image within its container.
  ///
  /// When provided, it controls how the image is positioned when its
  /// dimensions do not match the container's dimensions
  /// (and `object-fit` is set to a value other than `fill`).
  ///
  /// Defaults to `ImagePosition.center`, ensuring the image is
  /// centered within its container.
  final ImagePosition position;

  /// Additional CSS classes applied to the image.
  final String? classes;

  /// Radius of the image corners.
  final BorderRadiusData? radius;

  /// Background color applied to the image container.
  final Color? backgroundColor;

  /// Background gradient applied to the image container.
  ///
  /// ### Example
  /// ```dart
  /// Image(
  ///   'https://example.com/avatar.png',
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.blue]),
  /// )
  /// ```
  final Gradient? gradient;

  /// When `true`, image loading will be deferred until
  /// it is scrolled into view.
  final bool lazyLoad;

  /// Padding applied to the image container when
  /// [backgroundColor] or [gradient] is set.
  final EdgeInsets? padding;

  /// {@macro Image}
  const Image(
    this.src, {
    super.key,
    this.lazyLoad = false,
    this.cache = false,
    this.position = ImagePosition.center,
    this.fit,
    this.size,
    this.alt,
    this.backgroundColor,
    this.gradient,
    this.radius,
    this.padding,
    this.classes,
  });

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (cache) cacheImage(src, PlatformData.current.baseUrl);
    return null;
  }

  @override
  Component build(BuildContext context) {
    final _id = nakiStableKey('image', src);
    final cachedSource = NakiStorage.get<String>(_id);

    final shouldWrap =
        backgroundColor != null || gradient != null || padding != null;

    const baseClass = 'naki-image';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final image = img(
      key: shouldWrap ? null : key,
      src: cachedSource ?? src,
      alt: alt,
      classes: effectiveClasses,
      loading: lazyLoad ? MediaLoading.lazy : MediaLoading.eager,
      styles: Styles(
        raw: {
          'object-fit': ?fit?.css,
          'object-position': position.css,
          ...?size?.props,
          if (!shouldWrap) ...?radius?.props,
        },
      ),
    );

    return shouldWrap
        ? Container(
            key: key,
            child: image,
            decoration: BoxDecoration(
              borderRadius: radius,
              backgroundColor: backgroundColor,
              gradient: gradient,
              padding: padding,
              alignment: Alignment.center,
            ),
          )
        : image;
  }
}
