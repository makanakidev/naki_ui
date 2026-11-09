import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:jaspr/dom.dart' show link, meta;
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:jaspr_router/jaspr_router.dart';
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../framework/inherited.dart';
import '../models/naki.dart' show SEO;
import '../stub/index.dart';
import '../styles/css.dart';

import 'constants.dart';
import 'enums.dart';
import 'extensions.dart';
import 'storage.dart';

/// Listens for taps outside the element [anchor] returns.
///
/// Safari only sends `document` a click on a plain element when that element
/// listens for it, and a scrolling touch ends without a pointerup.
StreamSubscription<Event> listenTapOutside(
  Element? Function() anchor,
  void Function(Event event) onTap,
) => const EventStreamProvider<Event>('pointerup')
    .forTarget(document, useCapture: true)
    .listen((event) {
      if (!event.composedPath().toDart.contains(anchor())) onTap(event);
    });

/// Whether [a] and [b] hold equal elements in the same order.
/// Two nulls are equal.
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Whether [a] and [b] hold equal values under the same keys.
/// Two nulls are equal.
bool mapEquals<K, V>(Map<K, V>? a, Map<K, V>? b) {
  if (identical(a, b)) return true;
  if (a == null || b == null || a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || b[key] != a[key]) return false;
  }
  return true;
}

/// Builds a DOM id from an explicit id, or allocates one from the root
/// [NakiDomIdScope]. Generated ids never depend on labels, values, or other
/// nullable content and are stable across matching server/client renders.
String nakiDomId(BuildContext context, String prefix, {String? id}) {
  final explicit = nakiExplicitDomId(prefix, id);
  if (explicit != null) return explicit;

  final scope = NakiDomIdScope.maybeOf(context);
  if (scope == null) {
    final randomId = (Random.secure().nextInt(9000) + 100).toString();
    return nakiStableKey(prefix, id ?? randomId);
  }

  return scope.registry.resolve(context, prefix);
}

/// Normalizes a caller-provided id without allocating an automatic id.
String? nakiExplicitDomId(String prefix, String? id) {
  final explicit = id?.trim();
  if (explicit.isNullOrEmpty) return null;

  final cleaned = explicit!.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
  return '${prefix}_$cleaned';
}

/// Builds a deterministic non-DOM key for caches and storage.
String nakiStableKey(String prefix, String source) {
  final normalized = source.trim();
  if (normalized.isEmpty) return prefix;

  var hash = 0;
  for (final codeUnit in normalized.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0xffffffff;
  }

  return '${prefix}_${hash.toRadixString(16).padLeft(8, '0')}';
}

/// Callback function that gets executed after the component
/// is fully rendered in DOM (does nothing in server side).
void onComponentRendered(VoidCallback action) {
  if (kIsWeb) window.requestAnimationFrame(action.toJS);
}

/// Download image and save as DataURL to local storage for offline use
Future<void> cacheImage(String src, [String? baseUrl]) async {
  // use the complete URL to derive a stable cache key and avoid suffix
  // collisions between unrelated image hosts and paths.
  final id = nakiStableKey('image', src);

  src = normaliseLink(src, baseUrl);

  if (kIsWeb && src.startsWith('http') && NakiStorage.get<String>(id) == null) {
    try {
      final res = await window.fetch(src.toJS).toDart;

      if (res.ok) {
        final blob = await res.blob().toDart;
        final reader = FileReader();

        reader.onLoadEnd.listen((_) {
          if (reader.result != null) {
            final data = reader.result.dartify();

            if (data is String && data.length <= 2 * 1024 * 1024) {
              NakiStorage.set(id, data);
              debugPrint('Image cached: $src');
            } else {
              debugPrint('Image "$src" cache skipped: payload exceeds 2MB');
            }
          }
        });

        reader.readAsDataURL(blob);
      }
    } catch (e) {
      debugPrint('Failed to cache image:\n$e');
    }
  }
}

/// Print `content` to console in debug mode (or when `force` is set to true)
void debugPrint(dynamic content, [bool force = false]) {
  if (kDebugMode || force) print(content);
}

/// Show validation error and return true if validation error
/// is shown, otherwise return false
bool showValidationError(
  String id,
  String text, {
  bool isAutoComplete = false,
  bool isDropdown = false,
  bool isCalendar = false,
  bool isFileUploader = false,
  bool isSegmentedInput = false,
}) {
  if (kIsServer) return false;

  // remove previous validation error if present
  final validationId = '${id}_validation';
  removeValidationError(validationId);

  if (text.isEmpty) return false;

  final fieldId = id.contains('__')
      ? id
      : isAutoComplete
      ? '${id}__autocomplete'
      : isDropdown
      ? '${id}__dropdown'
      : isCalendar
      ? '${id}__calendar'
      : isFileUploader
      ? '${id}__fileuploader'
      : isSegmentedInput
      ? '${id}__segmentedfield'
      : '${id}__textfield';

  final fieldWrapper = document.getElementById(fieldId) as HTMLElement?;
  if (fieldWrapper == null) return false;

  // link input element to validation error element
  final inputElem =
      document.getElementById(isSegmentedInput ? '${id}_0' : id)
          as HTMLElement?;

  <String, String>{
    'aria-describedby': validationId,
    'aria-invalid': 'true',
  }.forEach((key, value) => inputElem?.setAttribute(key, value));

  // create validation error element
  final validationElem = document.createElement('naki-error') as HTMLElement;
  validationElem.id = validationId;
  validationElem.role = 'alert';
  validationElem.textContent = text;
  validationElem.style.cssText = {'margin-top': '8px'}.cssText;

  // place validation error as the last child of the field
  fieldWrapper.insertAdjacentElement('beforeend', validationElem);

  // scroll the field into viewport
  scrollToView(id: fieldId, useAncestor: false);

  return true;
}

/// Remove validation error from a field
void removeValidationError(String id) {
  if (kIsWeb) {
    final validationId = id.endsWith('_validation') ? id : '${id}_validation';
    document.getElementById(validationId)?.remove();

    final rawId = id.replaceAll('_validation', '');
    final targetInput =
        document.getElementById(rawId) ?? document.getElementById('${rawId}_0');

    targetInput?.removeAttribute('aria-describedby');
    targetInput?.setAttribute('aria-invalid', 'false');
  }
}

/// Clear all visible validation errors
void clearAllValidationErrors() {
  if (kIsWeb) {
    final elems = document.getElementsByTagName('naki-error');

    for (int i = elems.length - 1; i >= 0; i--) {
      final elem = elems.item(i);

      if (elem != null) {
        final rawId = elem.id.replaceAll('_validation', '');
        final targetInput =
            document.getElementById(rawId) ??
            document.getElementById('${rawId}_0');

        targetInput?.removeAttribute('aria-describedby');
        targetInput?.setAttribute('aria-invalid', 'false');

        elem.remove();
      }
    }
  }
}

/// Returns the theme switching script for the current theme mode.
String themeSwitchingScript(String currentMode, bool cache) {
  return kThemeSwitchingScript
      .replaceAll('{{MODE}}', currentMode)
      .replaceAll('{{CACHE}}', '$cache');
}

/// Updates the root element data attribute with theme mode class.
void updateRootTheme(String mode) {
  if (kIsServer) return;

  void applyTheme() {
    final root = document.documentElement as HTMLElement;
    root.setAttribute('data-naki-theme', mode);
  }

  // WebKit paints the transition from flat snapshots: they drop backdrop
  // blurs, tint Safari's bars, and sit off-screen while its toolbar is hidden.
  // Every iOS browser runs WebKit, and only Chromium names itself 'Chrome/'.
  final ua = window.navigator.userAgent;
  final isWebKit = ua.contains('AppleWebKit') && !ua.contains('Chrome/');

  // Fades the theme's color variables on <html> instead of every element's
  // colors: `color` is inherited, so per-element transitions chain and a deeply
  // nested heading lags ~120ms behind each ancestor that is fading too.
  void fadeTheme() {
    final root = document.documentElement as HTMLElement;
    final colorVars = _registerThemeColorVars();

    root.classList.add('switching-theme');
    root.style.setProperty(
      'transition',
      [for (final name in colorVars) '$name 120ms ease-out'].join(', '),
    );
    // Start from the current values rather than the pre-registration ones.
    window.getComputedStyle(root).getPropertyValue('transition');

    applyTheme();

    Future.delayed(const Duration(milliseconds: 150), () {
      root.classList.remove('switching-theme');
      if (root.classList.length < 1) root.removeAttribute('class');
      root.style.removeProperty('transition');
      if (root.style.length < 1) root.removeAttribute('style');
    });
  }

  if (isWebKit) return fadeTheme();

  try {
    document.startViewTransition(applyTheme.toJS);
  } catch (_) {
    fadeTheme();
  }
}

/// Theme color variables registered as `<color>`, so they can transition.
List<String>? _themeColorVars;

/// Registers the variables the light and dark themes both set to a plain
/// color, and returns their names. A registered variable must always hold a
/// color, so those set to anything else (a var(), currentcolor) are skipped;
/// they still follow the registered ones they reference.
List<String> _registerThemeColorVars() {
  if (_themeColorVars case final names?) return names;

  final light = <String, String>{};
  final dark = <String, String>{};

  final sheets = document.styleSheets;
  for (var i = 0; i < sheets.length; i++) {
    final CSSRuleList rules;
    try {
      rules = sheets.item(i)!.cssRules;
    } catch (_) {
      continue; // cross-origin sheet
    }

    for (var j = 0; j < rules.length; j++) {
      final rule = rules.item(j);
      if (rule == null || !rule.isA<CSSStyleRule>()) continue;
      rule as CSSStyleRule;

      final selector = rule.selectorText;
      final target = selector.contains('data-naki-theme="light"')
          ? light
          : selector.contains('data-naki-theme="dark"')
          ? dark
          : null;
      if (target == null) continue;

      final style = rule.style as CSSStyleDeclaration;
      for (var k = 0; k < style.length; k++) {
        final name = style.item(k);
        if (name.startsWith('--')) {
          target[name] = style.getPropertyValue(name).trim();
        }
      }
    }
  }

  bool isPlainColor(String? value) =>
      value != null &&
      !value.contains('var(') &&
      value.toLowerCase() != 'currentcolor' &&
      CSS.supports('color', value);

  final names = <String>[];
  for (final name in light.keys) {
    if (!isPlainColor(light[name]) || !isPlainColor(dark[name])) continue;
    try {
      CSS.registerProperty(
        PropertyDefinition(
          name: name,
          syntax: '<color>',
          inherits: true,
          initialValue: 'transparent',
        ),
      );
      names.add(name);
    } catch (_) {
      // already registered by the app
    }
  }

  return _themeColorVars = names;
}

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
  if (kIsServer) return;

  try {
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

  siteUrl ??= PlatformData().baseUrl;
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

  final base = seo.url ?? PlatformData().baseUrl;
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

  route ??= PlatformData().currentPath.trim();
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

/// The heights of `100svh` and `100lvh`, in pixels.
({double small, double large}) viewportUnitHeights() {
  double measure(String height) {
    final probe = document.createElement('div') as HTMLElement;
    probe.style.cssText =
        'position:fixed;visibility:hidden;pointer-events:none;height:$height';
    document.body?.append(probe);

    final measured = probe.getBoundingClientRect().height;
    probe.remove();
    return measured;
  }

  return (small: measure('100svh'), large: measure('100lvh'));
}

/// Whether Safari's toolbar is hidden.
///
/// The page then fills the largest viewport, while it fills the smallest one
/// with the toolbar showing or the on-screen keyboard open. A Home Screen web
/// app has only one viewport size, and `env()` covers it. Pinch zoom changes
/// the [scale].
bool isToolbarHidden({
  required num pageHeight,
  required num smallHeight,
  required num largeHeight,
  required num scale,
}) {
  final zoomed = (scale - 1).abs() > 0.01;
  return !zoomed && pageHeight > smallHeight && pageHeight >= largeHeight - 0.5;
}

/// Height of the page hidden above the visible viewport, in pixels.
///
/// With its toolbar [hidden], Safari lays the page out taller than what it
/// shows and leaves the rest under the status bar and address bar, while
/// `env(safe-area-inset-top)` stays `0`.
int hiddenViewportInset({
  required bool hidden,
  required num pageHeight,
  required num innerHeight,
  required num offsetTop,
}) {
  if (!hidden) return 0;

  return max(0, min(offsetTop, pageHeight - innerHeight)).round();
}

/// Height of the iPhone home indicator while Safari's toolbar is [hidden].
///
/// The page reaches the bottom of the screen in that state, yet
/// `env(safe-area-inset-bottom)` stays `0` and nothing else reports the
/// indicator, so its height is the system value. Only iPhones without a home
/// button, which are taller than 2:1, have one.
int hiddenToolbarBottomInset({
  required bool hidden,
  required bool iPhone,
  required num screenWidth,
  required num screenHeight,
  required bool landscape,
}) {
  final shortSide = min(screenWidth, screenHeight);
  final longSide = max(screenWidth, screenHeight);
  if (!hidden || !iPhone || longSide < shortSide * 2) return 0;

  return landscape ? 20 : 34;
}

/// Where an open picker of [height] goes between [safeTop] and [safeBottom].
///
/// It stays [gap] below or above its anchor when it fits there, trying above
/// first when [preferAbove] is set. Otherwise [top] overrides that, covering
/// the anchor, and [maxHeight] caps a picker taller than the safe band.
({bool above, double? top, double? maxHeight}) placePicker({
  required double height,
  required double anchorTop,
  required double anchorBottom,
  required double safeTop,
  required double safeBottom,
  required double gap,
  bool preferAbove = false,
}) {
  final fitsBelow = height <= safeBottom - anchorBottom - gap;
  final fitsAbove = height <= anchorTop - safeTop - gap;

  if (fitsAbove && (preferAbove || !fitsBelow)) {
    return (above: true, top: null, maxHeight: null);
  }

  if (fitsBelow) return (above: false, top: null, maxHeight: null);

  final visible = min(height, safeBottom - safeTop);
  final lowestTop = max(safeTop, safeBottom - visible);

  return (
    above: false,
    top: (anchorBottom + gap).clamp(safeTop, lowestTop),
    maxHeight: height > visible ? visible : null,
  );
}

/// How far an open popover moves to stay inside [safe], in pixels.
///
/// [popover] is where its [position] put it against [anchor]. It flips to the
/// opposite side when only that side fits, and otherwise moves as little as
/// it takes, covering the anchor if it has to. [maxHeight] caps a popover
/// taller than the safe band.
({double shiftX, double shiftY, double? maxHeight}) placePopover({
  required PopoverPosition position,
  required ({double top, double right, double bottom, double left}) popover,
  required ({double top, double right, double bottom, double left}) anchor,
  required ({double top, double right, double bottom, double left}) safe,
  required double gap,
}) {
  final vertical =
      position != PopoverPosition.left && position != PopoverPosition.right;
  final before = switch (position) {
    PopoverPosition.top ||
    PopoverPosition.topLeft ||
    PopoverPosition.topRight ||
    PopoverPosition.left => true,
    _ => false,
  };

  // the side it opens towards, then the axis it slides along
  final start = vertical ? popover.top : popover.left;
  final size = vertical
      ? popover.bottom - popover.top
      : popover.right - popover.left;

  final side = placePicker(
    height: size,
    anchorTop: vertical ? anchor.top : anchor.left,
    anchorBottom: vertical ? anchor.bottom : anchor.right,
    safeTop: vertical ? safe.top : safe.left,
    safeBottom: vertical ? safe.bottom : safe.right,
    gap: gap,
    preferAbove: before,
  );

  final anchorStart = vertical ? anchor.top : anchor.left;
  final anchorEnd = vertical ? anchor.bottom : anchor.right;
  final stays = side.top == null && side.above == before;
  final target =
      side.top ?? (side.above ? anchorStart - gap - size : anchorEnd + gap);
  final sideShift = stays ? 0.0 : target - start;

  double slide(double from, double to, double safeFrom, double safeTo) {
    if (to - from > safeTo - safeFrom || from < safeFrom)
      return safeFrom - from;
    return to > safeTo ? safeTo - to : 0;
  }

  final slideShift = vertical
      ? slide(popover.left, popover.right, safe.left, safe.right)
      : slide(popover.top, popover.bottom, safe.top, safe.bottom);

  final band = safe.bottom - safe.top;
  final height = popover.bottom - popover.top;

  return (
    shiftX: vertical ? slideShift : sideShift,
    shiftY: vertical ? sideShift : slideShift,
    maxHeight: vertical ? side.maxHeight : (height > band ? band : null),
  );
}

/// The edges of [element], in viewport coordinates.
({double top, double right, double bottom, double left}) elementEdges(
  Element element,
) {
  final rect = element.getBoundingClientRect();
  return (
    top: rect.top.toDouble(),
    right: rect.right.toDouble(),
    bottom: rect.bottom.toDouble(),
    left: rect.left.toDouble(),
  );
}

/// The band anchored overlays stay in, in viewport coordinates: inside the
/// safe areas and the Scaffold's bars, [margin] away from all of them.
({double top, double right, double bottom, double left}) overlayBounds({
  double margin = 8,
}) {
  final safeArea = safeAreaInsets();

  final viewportWidth =
      (document.documentElement?.clientWidth ?? window.innerWidth).toDouble();
  final viewportHeight = window.innerHeight.toDouble();

  final appBarBottom = getVisibleElement(
    '.naki-appbar-wrapper .naki-appbar',
  )?.getBoundingClientRect().bottom.toDouble();

  final bottomBarTop = getVisibleElement(
    '.naki-navbar-wrapper .naki-bottombar',
  )?.getBoundingClientRect().top.toDouble();

  return (
    top: max(safeArea.top, appBarBottom ?? 0.0) + margin,
    right: viewportWidth - safeArea.right - margin,
    bottom:
        min(viewportHeight - safeArea.bottom, bottomBarTop ?? viewportHeight) -
        margin,
    left: safeArea.left + margin,
  );
}

/// The insets the page can't draw content in, in pixels.
///
/// The top one is only `env(safe-area-inset-top)`: what [hiddenViewportInset]
/// measures is above the viewport, so it doesn't reach into these coordinates.
({double top, double right, double bottom, double left}) safeAreaInsets() {
  if (kIsServer) return (top: 0, right: 0, bottom: 0, left: 0);

  final probe = document.createElement('div') as HTMLElement;
  probe.style.cssText =
      'position:fixed;visibility:hidden;pointer-events:none;padding:'
      'env(safe-area-inset-top,0px) ${Css.safeAreaRight} '
      '${Css.safeAreaBottom} ${Css.safeAreaLeft}';
  document.body?.append(probe);

  final style = window.getComputedStyle(probe);
  double read(String side) =>
      double.tryParse(
        style.getPropertyValue('padding-$side').replaceAll('px', ''),
      ) ??
      0;

  final insets = (
    top: read('top'),
    right: read('right'),
    bottom: read('bottom'),
    left: read('left'),
  );

  probe.remove();

  return insets;
}

/// Returns a visible HTML element that matches the selector.
///
/// When `deepSearch` is true, it returns the last visible element.
/// When `deepSearch` is false, it returns the first visible element.
HTMLElement? getVisibleElement(String selector, {bool deepSearch = false}) {
  if (kIsServer) return null;

  final nodes = document.querySelectorAll(selector);
  if (nodes.length == 0) return null;

  HTMLElement? target;

  for (int i = 0; i < nodes.length; i++) {
    final e = nodes.item(i) as HTMLElement;
    final styles = window.getComputedStyle(e);

    // skip if hidden by CSS
    if (styles.display == 'none' ||
        styles.visibility == 'hidden' ||
        styles.opacity == '0') {
      continue;
    }

    // skip if not rendered
    if (e.getClientRects().length == 0) continue;

    target = e;

    if (!deepSearch) break;
  }

  return target;
}
