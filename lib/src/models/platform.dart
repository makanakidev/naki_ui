import 'dart:convert';

import '../../theme.dart';

/// A class that represents the browser platform data in
/// the client and server environment.
abstract class BrowserPlatform {
  /// Default const constructor for [BrowserPlatform].
  const BrowserPlatform();

  /// Browser platform name.
  String get name;

  /// Base URL. If server-side, it's just '/'.
  String get baseUrl;

  /// Current URL without the [baseUrl].
  /// Always starts with a leading '/'.
  String get currentUrl;

  /// Device name.
  String get device;

  /// Language.
  String get language;

  /// User agent.
  String get userAgent;

  /// Browser screen height.
  int get height;

  /// Browser screen width.
  int get width;

  /// Returns `true` if the platform is mobile.
  bool get isMobile;

  /// Returns `true` if the platform is tablet.
  bool get isTablet;

  /// Returns `true` if the platform is a desktop or laptop.
  bool get isDesktop;

  /// Returns `true` if the application is running
  /// as a Progressive Web App.
  bool get isPWA;

  /// Returns `true` if the platform is an iPhone.
  bool get isIphone;

  /// Returns `true` if the platform is an iPad.
  bool get isiPad;

  /// Returns `true` if the platform is MacOS.
  bool get isMacOS;

  /// Returns `true` if the platform is Windows.
  bool get isWindows;

  /// Returns `true` if the platform is Android.
  bool get isAndroid;

  /// Returns `true` if the platform is iOS.
  bool get isiOS;

  /// Returns `true` if the application is running on
  /// a mobile browser but not as a PWA.
  bool get isMobileBrowser;

  /// Convert the platform data to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseUrl': baseUrl,
      'currentUrl': currentUrl,
      'device': device,
      'language': language,
      'userAgent': userAgent,
      'height': height.toPx,
      'width': width.toPx,
      'isMobile': isMobile,
      'isTablet': isTablet,
      'isDesktop': isDesktop,
      'isPWA': isPWA,
      'isIphone': isIphone,
      'isiPad': isiPad,
      'isMacOS': isMacOS,
      'isWindows': isWindows,
      'isAndroid': isAndroid,
      'isiOS': isiOS,
      'isMobileBrowser': isMobileBrowser,
    };
  }

  /// Convert the platform data to a JSON string.
  @override
  String toString() => jsonEncode(toJson());
}
