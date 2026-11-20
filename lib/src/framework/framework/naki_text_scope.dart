part of 'index.dart';

/// Mixin on Naki text components.
mixin NakiTextScope on StatelessComponent {
  /// Style applied to the text.
  TextStyle? get style;

  /// Additional CSS classes applied to the text.
  String? get classes;

  /// Additional HTML attributes applied to the text.
  Map<String, String>? get attributes;
}
