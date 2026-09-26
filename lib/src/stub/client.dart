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
       _userAgent = userAgent.trim().isEmpty ? null : userAgent,
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

  String get _ua => userAgent.toLowerCase();
  String get _platform => navigator.platform.toLowerCase();

  // bool get _isAndroidTablet => _ua.contains('android') && !_ua.contains('mobile');

  @override
  String get name => _platform.contains('win') ? 'windows' : _platform;

  @override
  String get baseUrl {
    final baseElem = document.querySelector('base') as HTMLBaseElement?;
    String path = baseElem?.href ?? '';
    if (path == '/') path = '';
    return _baseUrl ?? location.origin + path;
  }

  @override
  String get currentPath =>
      _currentPath ?? location.href.replaceFirst(baseUrl, '');

  @override
  String get device {
    if (isIphone) return 'iPhone';
    if (isiPad) return 'iPad';
    if (isAndroid) return 'Android';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'MacOS';
    if (_ua.contains('linux')) return 'Linux';
    return 'PC';
  }

  @override
  String get language => _language ?? navigator.language.split('.').first;

  @override
  String get userAgent => _userAgent ?? navigator.userAgent;

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
  bool get isIphone => _ua.contains('iphone');

  @override
  bool get isiPad =>
      _ua.contains('ipad') || (isMacOS && navigator.maxTouchPoints > 1);

  @override
  bool get isMacOS => _ua.contains('macintosh') || _ua.contains('mac os');

  @override
  bool get isWindows => _ua.contains('windows') || name.contains('win');

  @override
  bool get isAndroid => _ua.contains('android');

  @override
  bool get isiOS => isiPad || isIphone;

  @override
  bool get isMobileBrowser => isMobile && !isPWA;
}
