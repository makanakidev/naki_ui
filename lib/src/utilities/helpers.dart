import 'dart:convert';
import 'dart:math';
import 'package:jaspr/jaspr.dart' hide Element;
import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart';

import '../framework/inherited.dart';
import '../stub/index.dart';
import '../styles/css.dart';

import 'constants.dart';
import 'enums.dart';
import 'extensions.dart';
import 'storage.dart';

/// Builds a DOM id from an explicit id, or allocates one from the root
/// [NakiDomIdScope]. Generated ids never depend on labels, values, or other
/// nullable content and are stable across matching server/client renders.
String nakiDomId(
  BuildContext context,
  String prefix, {
  String? id,
}) {
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

  final cleaned = explicit!.replaceAll(
    RegExp(r'[^a-zA-Z0-9_-]'),
    '-',
  );
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
Future<void> cacheImage(String src) async {
  // Use the complete URL to derive a stable cache key and avoid suffix
  // collisions between unrelated image hosts and paths.
  final id = nakiStableKey('image', src);

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
              debugPrint(
                'Image "$src" cache skipped: payload exceeds 2MB',
              );
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

/// Updates the position of a slider tooltip relative to its thumb.
///
/// [id] - The ID of the slider element.
/// [hide] - Whether to hide the tooltip.
String updateSliderTooltip(String id, {bool hide = true}) {
  if (kIsServer) return '-100%';

  final slider = document.getElementById(id) as HTMLInputElement?;
  if (slider == null) return '-100%';

  final tooltip = document.getElementById('$id-tooltip') as HTMLOutputElement?;
  if (tooltip == null) return '-100%';

  // get slider values
  final val = double.parse(slider.value);
  final min = double.parse(slider.min);
  final max = double.parse(slider.max);

  // calculate position percentage
  final percent = ((val - min) * 100) / (max - min);
  final position = 'calc($percent% + (${8 - percent * 0.15}px))';
  // tooltip.style.left = position;

  // hide the tooltip
  if (hide) tooltip.style.opacity = '0';

  return hide ? '-100%' : position;
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

  // remove previous validation error
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

  // apply error styles
  validationElem.style.cssText = Css.nakiErrorTextStyle
      .copyWith(extra: {'margin-top': '8px'})
      .cssText;

  // place validation error as the last child of the field
  fieldWrapper.insertAdjacentElement('beforeend', validationElem);

  // scroll the field into viewport
  scrollToView(id: fieldId, highlight: true);

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
    final elems = document.getElementsByTagName(
      'naki-error',
    );

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
String themeSwitchingScript(
  String currentMode,
  bool cache,
) {
  return kThemeSwitchingScript
      .replaceAll('{{MODE}}', currentMode)
      .replaceAll('{{CACHE}}', '$cache');
}

/// Updates the root element data attribute with theme mode class.
void updateRootTheme(String mode) {
  if (kIsWeb) {
    void applyTheme() {
      final root = document.documentElement as HTMLElement;
      root.setAttribute('data-naki-theme', mode);
    }

    try {
      document.startViewTransition(applyTheme.toJS);
    } catch (_) {
      final root = document.documentElement as HTMLElement;

      root.classList.add('switching-theme');
      applyTheme();

      Future.delayed(const Duration(milliseconds: 500), () {
        root.classList.remove('switching-theme');
        if (root.classList.length < 1) root.removeAttribute('class');
      });
    }
  }
}

/// Scroll to element with given id.
///
/// * [id] - The ID of the element to scroll to.
/// * [offset] - The offset to scroll by (in pixels).
/// * [animate] - Whether to animate the scroll.
/// * [highlight] - Whether to vertically center the element in viewport.
///   - This makes the browser to scroll to the element and
///     center it in the viewport.
/// * [direction] - The direction of scroll.
void scrollToView({
  required String id,
  double offset = 0,
  bool animate = false,
  bool highlight = false,
  ScrollDirection direction = ScrollDirection.vertical,
}) {
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

  if (kIsWeb) {
    final elem = document.getElementById(id) as HTMLElement?;

    if (elem != null) {
      final scrollableElement = _findScrollableAncestor(elem);

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
            block: highlight ? 'center' : 'nearest',
            inline: highlight ? 'center' : 'nearest',
          ),
        );
      }
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
/// - `mimeType` must match the file extension
void saveAsFile(
  String content,
  String fileName, {
  FileType mimeType = .txt,
}) {
  if (kIsServer) return;

  // convert content to a data URL
  final url = Uri.dataFromString(
    content,
    mimeType: mimeType.value,
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
