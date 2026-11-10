import 'dart:io';

import 'package:ua_parser/ua_parser.dart';

import '../models/platform.dart';
import '../utilities/constants.dart';

/// Server-side [BrowserPlatform] implementation for SSR/SSG.
final class PlatformData extends BrowserPlatform {
  static PlatformData _instance = PlatformData._();

  /// Returns the current instance of [PlatformData].
  static PlatformData get current => _instance;

  /// Returns the current instance of [PlatformData].
  factory PlatformData() => _instance;

  PlatformData._({
    this.baseUrl = '/',
    this.currentPath = '/',
    this.userAgent = '',
    this.width = 0,
    this.height = 0,
    String? language,
  }) : _language = language,
       _parsedAgent = userAgent.isEmpty ? null : UaParser.parse(userAgent);

  /// Initializes the [PlatformData] instance with the given values, falling
  /// back to the server defaults for any that are omitted.
  ///
  /// Call once at startup, before the first read of [PlatformData.current].
  /// Each call replaces the instance, so values from an earlier call are not
  /// kept.
  static void init({
    String? baseUrl,
    String? currentPath,
    String? userAgent,
    int? width,
    int? height,
    String? language,
  }) {
    _instance = PlatformData._(
      baseUrl: baseUrl ?? '/',
      currentPath: currentPath ?? '/',
      userAgent: userAgent ?? '',
      width: width ?? 0,
      height: height ?? 0,
      language: language,
    );
  }

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
