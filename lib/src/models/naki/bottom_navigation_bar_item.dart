part of 'index.dart';

/// Represents an item in [BottomNavigationBar.items].
class BottomNavigationBarItem {
  /// Icon to display.
  final IconData icon;

  /// Text displayed below the icon.
  final String? label;

  /// Custom label to display instead of [label].
  final Component? labelComponent;

  /// Additional CSS classes applied to the item.
  final String? classes;

  /// Tooltip for the item which shows up on hover.
  final String? tooltip;

  /// An optional key for the item.
  final Key? key;

  const BottomNavigationBarItem({
    required this.icon,
    this.label,
    this.labelComponent,
    this.classes,
    this.tooltip,
    this.key,
  });
}
