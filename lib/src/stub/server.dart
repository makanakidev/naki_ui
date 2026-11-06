import 'dart:io';

import 'package:ua_parser/ua_parser.dart';

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
  }) : _language = language.isNullOrEmpty ? null : language,
       _parsedAgent = userAgent.isEmpty ? null : UaParser.parse(userAgent);

  final String? _language;
  final UaParserResult? _parsedAgent;

  @override
  String get name => _parsedAgent?.browser.name ?? 'Chrome';

  @override
  final String baseUrl;

  @override
  final String currentPath;

  @override
  String get os => _parsedAgent?.os.name ?? 'Unknown';

  @override
  String get device => _parsedAgent?.device.model ?? 'Unknown';

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
  bool get isDesktop => isMacOS || isWindows || width >= kBreakpointLarge;

  @override
  bool get isPWA => false;

  @override
  bool get isIphone =>
      isiOS &&
      (device == 'iPhone' || (height >= 300 && height < kBreakpointMedium));

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
