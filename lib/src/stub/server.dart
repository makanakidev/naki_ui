import 'dart:io';

import '../models/platform.dart';
import '../utilities/constants.dart';
import '../utilities/extensions.dart';

/// Server-side implementation of [BrowserPlatform] for SSR / SSG pre-rendering.
final class PlatformData extends BrowserPlatform {
  /// Creates a server-side [PlatformData] instance.
  PlatformData({
    this.baseUrl = '/',
    this.currentPath = '/',
    this.userAgent = '',
    this.width = 0,
    this.height = 0,
    String? language,
  }) : _language = language.isNullOrEmpty ? null : language;

  final String? _language;

  @override
  String get name => Platform.operatingSystem;

  @override
  final String baseUrl;

  @override
  final String currentPath;

  @override
  String get device {
    if (isMacOS) return 'MacOS';
    if (isWindows) return 'Windows';
    if (isAndroid) return 'Android';
    if (isiOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    return 'Server';
  }

  @override
  String get language => _language ?? Platform.localeName.split('.').first;

  @override
  final String userAgent;

  @override
  final int height;

  @override
  final int width;

  @override
  bool get isMobile => isIphone || isAndroid;

  @override
  bool get isTablet => !isMobile && !isDesktop;

  @override
  bool get isDesktop => isMacOS || isWindows || Platform.isLinux;

  @override
  bool get isPWA => false;

  @override
  bool get isIphone => isiOS && height >= 300 && height < kBreakpointMedium;

  @override
  bool get isiPad => isiOS && isTablet;

  @override
  bool get isMacOS => Platform.isMacOS;

  @override
  bool get isWindows => Platform.isWindows;

  @override
  bool get isAndroid => Platform.isAndroid;

  @override
  bool get isiOS => Platform.isIOS;

  @override
  bool get isMobileBrowser => isMobile && !isPWA;
}
