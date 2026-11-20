part of 'index.dart';

/// Scroll to element with given id.
///
/// * [id] - The ID of the element to scroll to.
/// * [offset] - The offset to scroll by (in pixels).
///   - This could be the height of the target element.
/// * [animate] - Whether to animate the scroll.
/// * [useAncestor] - Whether to use the nearest scrollable ancestor
///   to scroll the target element into view.
/// * [center] - Whether to vertically center the element in viewport.
///   - This makes the browser to scroll to the element and
///     center it in the viewport.
/// * [direction] - The direction of scroll.
void scrollToView({
  required String id,
  double offset = 0,
  bool animate = false,
  bool center = false,
  bool useAncestor = true,
  ScrollDirection direction = ScrollDirection.vertical,
}) {
  if (kIsServer) return;

  // SCROLL OPTIONS:
  // behavior:
  //   smooth: Animates the scroll.
  //   auto: Jumps immediately (default).
  // block: (defines vertical alignment)
  //   start: Aligns the top of the element with the top of the viewport.
  //   center: Centers the element vertically in the viewport.
  //   end: Aligns the bottom of the element with the bottom of the viewport.
  //   nearest: Aligns the element to the nearest edge of the viewport.
  // inline: (defines horizontal alignment)
  //   start: Aligns the start of the element with the start of the viewport.
  //   center: Centers the element horizontally in the viewport.
  //   end: Aligns the end of the element with the end of the viewport.
  //   nearest: Aligns the element to the nearest edge of the viewport.

  final elem = document.getElementById(id) as HTMLElement?;

  if (elem != null) {
    final scrollableElement = useAncestor
        ? _findScrollableAncestor(elem)
        : null;

    if (scrollableElement != null) {
      // scroll within the scrollable element
      scrollableElement.scrollTo(
        ScrollToOptions(
          top: direction == ScrollDirection.vertical
              ? (elem.offsetTop - offset).clamp(0, double.infinity)
              : 0,
          left: direction == ScrollDirection.horizontal
              ? (elem.offsetLeft - offset).clamp(0, double.infinity)
              : 0,
          behavior: animate ? 'smooth' : 'auto',
        ),
      );
    } else {
      // fallback to default scroll
      elem.scrollIntoView(
        ScrollIntoViewOptions(
          behavior: animate ? 'smooth' : 'auto',
          block: center ? 'center' : 'nearest',
          inline: center ? 'center' : 'nearest',
        ),
      );
    }
  }
}

/// Helper function to find the nearest scrollable ancestor
HTMLElement? _findScrollableAncestor(HTMLElement elem) {
  Element? parent = elem.parentElement;

  while (parent != null) {
    final style = window.getComputedStyle(parent);

    // check if the parent element is scrollable
    final isScrollable =
        style.overflow == 'auto' ||
        style.overflow == 'scroll' ||
        style.overflowY == 'auto' ||
        style.overflowY == 'scroll' ||
        style.overflowX == 'auto' ||
        style.overflowX == 'scroll';

    // check if the parent element has scrollable content
    final hasScrollableContent =
        parent.scrollHeight > parent.clientHeight ||
        parent.scrollWidth > parent.clientWidth;

    if (isScrollable && hasScrollableContent) {
      return parent as HTMLElement;
    }

    parent = parent.parentElement;
  }

  return null;
}

/// Triggers device haptic feedback or vibration on non-iOS devices only
/// since iOS doesn't support vibration via Web Vibration API.
///
/// * [duration]: Single pulse duration (default: 15ms).
///   - Ignored when [vibrationPattern] is provided.
/// * [vibrationPattern]: Custom vibration pattern of alternating vibration
///   and pause intervals in milliseconds (e.g. `[100, 200, 100]`).
///
/// ### Example
/// ```dart
/// hapticFeedback(duration: const Duration(milliseconds: 50));
/// hapticFeedback(vibrationPattern: [100, 200, 100]);
/// ```
void hapticFeedback({
  Duration duration = const Duration(milliseconds: 15),
  List<int>? vibrationPattern,
}) {
  if (kIsServer || !window.matchMedia('(pointer: coarse)').matches) return;

  final isAppleTouch =
      PlatformData.current.isiOS || PlatformData.current.isiPad;

  try {
    if (!isAppleTouch) {
      // custom vibration pattern
      if (vibrationPattern != null && vibrationPattern.isNotEmpty) {
        final jsPattern = vibrationPattern.map((d) => d.toJS).toList().toJS;
        window.navigator.vibrate(jsPattern);
        return;
      }

      // default vibration duration
      final durationMs = duration.inMilliseconds
          .clamp(0, double.infinity)
          .toInt();

      window.navigator.vibrate(durationMs.toJS);
    } else {
      final label = document.createElement('label') as HTMLLabelElement;
      label.setAttribute('aria-hidden', 'true');
      label.style.cssText =
          'position:fixed;width:1px;height:1px;overflow:hidden;opacity:0;pointer-events:none;left:-9px;top:-9px';

      final input = document.createElement('input') as HTMLInputElement;
      input.type = 'checkbox';
      input.setAttribute('switch', '');
      input.tabIndex = -1;

      label.append(input);
      document.body?.append(label);
      label.click();

      Timer(const Duration(milliseconds: 100), () => label.remove());
    }
  } catch (_) {}
}

/// File saver in vm and browser environment
/// - `fileName` must include extension e.g. "file.txt"
/// - `fileType` must match the file extension
void saveAsFile(String content, String fileName, [FileType fileType = .txt]) {
  if (kIsServer) return;

  // convert content to a data URL
  final url = Uri.dataFromString(
    content,
    mimeType: fileType.value,
    encoding: utf8,
  ).toString();

  // create an anchor element to trigger download
  final anchor = document.createElement('a') as HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;

  // programmatically click the anchor element to start the download
  anchor.click();

  // revoke the object URL to free up memory
  URL.revokeObjectURL(url);
}

/// Normalises a given link.
String normaliseLink(String link, [String? siteUrl]) {
  final trimmed = link.trim();
  if (trimmed.isEmpty) return '';

  // preserve special schemes, protocol-relative links,
  // anchors, and query strings
  if (trimmed.startsWith('//') ||
      trimmed.startsWith('#') ||
      trimmed.startsWith('?') ||
      trimmed.startsWith('data:') ||
      trimmed.startsWith('mailto:') ||
      trimmed.startsWith('tel:') ||
      trimmed.startsWith('sms:') ||
      trimmed.startsWith('javascript:') ||
      trimmed.startsWith('blob:')) {
    return trimmed;
  }

  // check if link already contains a full URI
  // scheme (e.g. https://, http://, file://)
  final linkUri = Uri.tryParse(trimmed);
  if (linkUri != null && linkUri.hasScheme) return trimmed;

  siteUrl ??= PlatformData.current.baseUrl;
  siteUrl = siteUrl.trim();

  // if siteUrl is empty or just root, return cleaned link directly
  if (siteUrl.isEmpty || siteUrl == '/') {
    return trimmed.startsWith('/')
        ? '/${trimmed.replaceFirst(RegExp(r'^/+'), '')}'
        : (trimmed.startsWith('./') ? trimmed.substring(2) : trimmed);
  }

  final siteUri = Uri.tryParse(siteUrl);

  // extract origin only when siteUrl has valid scheme and authority
  final origin = (siteUri != null && siteUri.hasScheme && siteUri.hasAuthority)
      ? siteUri.origin
      : '';

  // extract base path (e.g. '/app' from 'https://example.com/app/' or '/app/')
  String basePath = '';
  if (siteUri != null && siteUri.path.isNotEmpty && siteUri.path != '/') {
    basePath = siteUri.path;
  } else if (origin.isEmpty && siteUrl.isNotEmpty && siteUrl != '/') {
    basePath = siteUrl;
  }

  // if basePath is not empty, normalise it
  if (basePath.isNotEmpty) {
    if (!basePath.startsWith('/')) basePath = '/$basePath';
    basePath = basePath.replaceFirst(RegExp(r'/+$'), '');
  }

  // normalise the link
  String cleanedLink = trimmed;
  final isRootRelative = cleanedLink.startsWith('/');

  // remove leading './'
  if (cleanedLink.startsWith('./')) {
    cleanedLink = cleanedLink.substring(2);
  }

  // handle root relative links
  if (isRootRelative) {
    cleanedLink = '/${cleanedLink.replaceFirst(RegExp(r'^/+'), '')}';

    // prevent duplicate base path insertion if link already begins with it
    if (basePath.isNotEmpty) {
      final alreadyHasBase =
          cleanedLink == basePath ||
          cleanedLink.startsWith('$basePath/') ||
          cleanedLink.startsWith('$basePath?') ||
          cleanedLink.startsWith('$basePath#');

      if (!alreadyHasBase) cleanedLink = '$basePath$cleanedLink';
    }
  } else {
    // relative link without leading slash (e.g. 'about' or 'img.png')
    if (basePath.isNotEmpty) {
      cleanedLink = '$basePath/$cleanedLink';
    } else if (origin.isNotEmpty) {
      cleanedLink = '/$cleanedLink';
    }
  }

  if (origin.isNotEmpty) return '$origin$cleanedLink';

  return cleanedLink;
}

/// Joins non-empty CSS classes in reverse order.
String joinClasses(List<String> classes) {
  classes = List.from(classes.reversed);
  classes.removeWhere((c) => c.trim().isEmpty);
  return classes.join(' ');
}

/// Builds a list of SEO meta and link components for `<head>`.
///
/// Constructs canonical URL, description, keywords, robots,
/// Open Graph preview tags, and X (Twitter) card tags based on [seo].
List<Component> seoTagBuilder(
  SEO? seo, {
  BuildContext? context,
  String? defaultTitle,
}) {
  if (seo == null) return const <Component>[];

  final base = seo.url ?? PlatformData.current.baseUrl;
  String? route;

  if (context != null) {
    final loc = RouteState.maybeOf(context)?.location;
    if (loc != null && loc.trim().isNotEmpty) {
      route = loc.trim();
    } else {
      final currentUrl = context.binding.currentUrl.trim();
      if (currentUrl.isNotEmpty) route = currentUrl;
    }
  }

  route ??= PlatformData.current.currentPath;
  if (route.isEmpty) route = '/';

  // Strip query parameters and hash fragments for the canonical URL
  final cleanRoute = route.split('?').first.split('#').first;
  final routeToUse = cleanRoute.isEmpty ? '/' : cleanRoute;

  final pageUrl = normaliseLink(routeToUse, base);
  final logoUrl = normaliseLink(seo.logo ?? '', base);
  final pageTitle = seo.title ?? defaultTitle ?? '';

  final smTitle = seo.socialMediaTitle ?? pageTitle;
  final smDesc = seo.socialMediaDescription ?? seo.description ?? '';
  final smImg = normaliseLink(seo.socialMediaBanner ?? logoUrl, base);

  final isValidLogo = logoUrl.isNotEmpty && logoUrl.startsWith('http');
  final isValidSmImg = smImg.isNotEmpty && smImg.startsWith('http');
  final isValidPageUrl = pageUrl.isNotEmpty && pageUrl.startsWith('http');

  final ogImage = isValidSmImg ? smImg : (isValidLogo ? logoUrl : null);

  return [
    if (isValidPageUrl) link(href: pageUrl, rel: 'canonical', id: 'cnl'),

    if (seo.description.isNotNullAndEmpty)
      meta(name: 'description', content: seo.description),

    if (seo.keywords != null && seo.keywords!.isNotEmpty)
      meta(name: 'keywords', content: seo.keywords!.join(', ')),

    if (seo.robots != null && seo.robots!.isNotEmpty)
      meta(name: 'robots', content: seo.robots!.join(', ')),

    // Link Preview Tags (Open Graph)
    if (pageTitle.isNotEmpty) ...[
      meta(
        attributes: const {'property': 'og:title'},
        content: pageTitle,
        id: 'ogti',
      ),

      meta(
        attributes: const {'property': 'og:site_name'},
        content: pageTitle,
        id: 'ogn',
      ),
    ],

    if (seo.description.isNotNullAndEmpty)
      meta(
        attributes: const {'property': 'og:description'},
        content: seo.description,
        id: 'ogd',
      ),

    const meta(
      attributes: {'property': 'og:type'},
      content: 'website',
      id: 'ogty',
    ),

    if (isValidPageUrl)
      meta(
        attributes: const {'property': 'og:url'},
        content: pageUrl,
        id: 'ogu',
      ),

    if (ogImage != null) ...[
      meta(
        attributes: const {'property': 'og:image'},
        content: ogImage,
        id: 'ogi',
      ),

      if (pageTitle.isNotEmpty)
        meta(
          attributes: const {'property': 'og:image:alt'},
          content: pageTitle,
          id: 'ogia',
        ),
    ],

    // X(Twitter) Card Preview Tags
    if (smTitle.isNotEmpty) ...[
      meta(name: 'twitter:title', content: smTitle),

      if (smDesc.isNotEmpty) meta(name: 'twitter:description', content: smDesc),

      if (isValidSmImg) ...[
        meta(name: 'twitter:image', content: smImg),

        if (smTitle.isNotEmpty)
          meta(name: 'twitter:image:alt', content: smTitle),

        const meta(name: 'twitter:card', content: 'summary_large_image'),
      ],
    ],
  ];
}
