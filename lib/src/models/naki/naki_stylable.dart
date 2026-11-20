part of 'index.dart';

/// Abstract class that represents a styleable object.
abstract class NakiStylable {
  /// The style properties map.
  Map<String, String> get props;

  /// Returns the CSS text from the style properties.
  String get cssText;
}
