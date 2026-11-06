import 'package:ua_parser/ua_parser.dart';
import 'package:universal_web/web.dart';

import '../../theme.dart';
import '../models/platform.dart';

/// Client-side implementation of [BrowserPlatform] for web browsers.
final class PlatformData extends BrowserPlatform {
  /// Creates a client-side [PlatformData] instance.
  PlatformData({
    String baseUrl = '',
    String currentPath = '',
    String userAgent = '',
    int width = 0,
    int height = 0,
    String? language,
  }) : _baseUrl = baseUrl.trim().isEmpty ? null : baseUrl,
       _currentPath = currentPath.trim().isEmpty ? null : currentPath,
       _userAgent = userAgent.trim().isEmpty ? null : userAgent.toLowerCase(),
       _width = width == 0 ? null : width,
       _height = height == 0 ? null : height,
       _language = language.isNullOrEmpty ? null : language;

  final String? _baseUrl;
  final String? _currentPath;
  final String? _userAgent;
  final int? _width;
  final int? _height;
  final String? _language;

  final navigator = window.navigator;
  final location = window.location;

  String get _ua => _userAgent ?? navigator.userAgent.toLowerCase();
  UaParserResult get _parsedAgent => UaParser.parse(_ua);

  @override
  String get name => _parsedAgent.browser.name ?? 'Chrome';

  /// Raw `href` of the document's `<base>` element.
  ///
  /// `HTMLBaseElement.href` resolves to an absolute URL, so the attribute is
  /// read instead to recover the configured base path (e.g. `/` or `/app/`).
  String get _baseHref =>
      document.querySelector('base')?.getAttribute('href')?.trim() ?? '';

  /// Base path without a trailing slash (`''` for the site root).
  String get _basePath {
    final href = _baseHref;
    if (href.isEmpty) return '';

    final path = Uri.tryParse(href)?.path ?? href;
    return path.replaceFirst(RegExp(r'/+$'), '');
  }

  @override
  String get baseUrl {
    if (_baseUrl != null) return _baseUrl;

    final href = _baseHref;
    if (Uri.tryParse(href)?.hasScheme ?? false) {
      return href.replaceFirst(RegExp(r'/+$'), '');
    }

    return location.origin + _basePath;
  }

  @override
  String get currentPath {
    if (_currentPath != null) return _currentPath;

    final path = location.pathname + location.search + location.hash;
    final basePath = _basePath;
    if (basePath.isEmpty || !path.startsWith(basePath)) return path;

    final relative = path.substring(basePath.length);
    if (relative.isNotEmpty && !'/?#'.contains(relative[0])) return path;

    return relative.startsWith('/') ? relative : '/$relative';
  }

  @override
  String get os => _parsedAgent.os.name ?? 'Unknown';

  @override
  String get device {
    final model = _parsedAgent.device.model;
    if (model != null) return model;
    if (isIphone) return 'iPhone';
    if (isiPad) return 'iPad';
    if (isAndroid) return 'Android';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'MacOS';
    return 'Unknown';
  }

  @override
  String get language => _language ?? navigator.language.split('.').first;

  @override
  String get userAgent => _ua;

  @override
  int get height => _height ?? window.innerHeight;

  @override
  int get width => _width ?? window.innerWidth;

  @override
  bool get isMobile =>
      window.matchMedia('(max-width: 768px) and (pointer: coarse)').matches;

  @override
  bool get isTablet =>
      window.matchMedia('(pointer: coarse) and (hover: none)').matches;

  @override
  bool get isDesktop =>
      window.matchMedia('(pointer: fine) and (hover: hover)').matches;

  @override
  bool get isPWA => window.matchMedia('(display-mode: standalone)').matches;

  @override
  bool get isIphone => device == 'iPhone';

  @override
  bool get isiPad => device == 'iPad';

  @override
  bool get isMacOS => os == 'macOS';

  @override
  bool get isWindows => os == 'Windows';

  @override
  bool get isAndroid => os == 'Android';

  @override
  bool get isiOS => os == 'iOS';

  @override
  bool get isMobileBrowser => isMobile && !isPWA;
}
