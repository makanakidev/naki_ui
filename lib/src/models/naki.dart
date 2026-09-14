import 'package:jaspr/dom.dart' show Color;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';

import '../components/scaffold.dart' show BottomNavigationBar;
import '../styles/text_style.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';

/// Abstract class that represents a styleable object.
abstract class NakiStylable {
  /// The style properties map.
  Map<String, String> get props;

  /// Returns the CSS text from the style properties.
  String get cssText;
}

/// Used internally by Naki components to map alignment
/// properties to CSS values.
class NakiAlignProps {
  /// Maps [MainAxisAlignment] to its CSS equivalent.
  static String mapMainAxisAlignment(
    MainAxisAlignment alignment,
  ) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return 'flex-start';
      case MainAxisAlignment.end:
        return 'flex-end';
      case MainAxisAlignment.center:
        return 'center';
      case MainAxisAlignment.spaceBetween:
        return 'space-between';
      case MainAxisAlignment.spaceAround:
        return 'space-around';
      case MainAxisAlignment.spaceEvenly:
        return 'space-evenly';
    }
  }

  /// Maps [CrossAxisAlignment] to its CSS equivalent.
  static String mapCrossAxisAlignment(
    CrossAxisAlignment alignment,
  ) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return 'flex-start';
      case CrossAxisAlignment.end:
        return 'flex-end';
      case CrossAxisAlignment.center:
        return 'center';
      case CrossAxisAlignment.stretch:
        return 'stretch';
      case CrossAxisAlignment.baseline:
        return 'baseline';
    }
  }

  /// Maps [Alignment] to its CSS equivalent.
  static Map<String, String> mapAlignment(
    Alignment alignment,
  ) {
    switch (alignment) {
      case Alignment.topLeft:
        return {
          'justify-content': 'flex-start',
          'align-items': 'flex-start',
        };
      case Alignment.topCenter:
        return {
          'justify-content': 'center',
          'align-items': 'flex-start',
        };
      case Alignment.topRight:
        return {
          'justify-content': 'flex-end',
          'align-items': 'flex-start',
        };
      case Alignment.centerLeft:
        return {
          'justify-content': 'flex-start',
          'align-items': 'center',
        };
      case Alignment.center:
        return {
          'justify-content': 'center',
          'align-items': 'center',
        };
      case Alignment.centerRight:
        return {
          'justify-content': 'flex-end',
          'align-items': 'center',
        };
      case Alignment.bottomLeft:
        return {
          'justify-content': 'flex-start',
          'align-items': 'flex-end',
        };
      case Alignment.bottomCenter:
        return {
          'justify-content': 'center',
          'align-items': 'flex-end',
        };
      case Alignment.bottomRight:
        return {
          'justify-content': 'flex-end',
          'align-items': 'flex-end',
        };
    }
  }
}

/// Represents a single item in the Dropdown component.
class DropdownItem<T> {
  /// The value of the item (usually a string or int).
  final T? value;

  /// The display text of the item.
  final String? label;

  /// If true, the item will be visually highlighted.
  final bool selected;

  /// If true, the item will be displayed as a section header (not selectable).
  final bool section;

  /// If true, the item will be displayed as a placeholder (not selectable).
  final bool placeholder;

  /// Cannot be selected if [section] or [placeholder] is `true`.
  final bool disabled;

  const DropdownItem({
    this.value,
    this.label,
    this.selected = false,
    this.section = false,
    this.placeholder = false,
  }) : disabled = section || placeholder;

  DropdownItem<T> copyWith({
    T? value,
    String? label,
    bool? selected,
    bool? section,
    bool? placeholder,
  }) {
    return DropdownItem<T>(
      value: value ?? this.value,
      label: label ?? this.label,
      selected: selected ?? this.selected,
      section: section ?? this.section,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  /// Returns the string representation of the item value.
  /// If the value is null, it returns the label, or 'n/a' if label is null.
  @override
  String toString() => value?.toString() ?? label ?? 'n/a';

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DropdownItem<T> && value == other.value && label == other.label;
  }
}

/// Abstract class that represents a single inline text span.
abstract class InlineSpan {
  /// Text style of the inline span.
  final TextStyle? style;

  /// An optional screen-reader description or ARIA label for this span.
  final String? semanticsLabel;

  const InlineSpan({this.style, this.semanticsLabel});

  /// Flattens this span and its children into a plain text string.
  String toPlainText();

  /// Walks this span and all nested child spans in pre-order traversal.
  /// Stops recursion early if [visitor] returns `false`.
  bool visitChildren(
    bool Function(InlineSpan span) visitor,
  );
}

/// Mixin on Naki text components.
mixin NakiTextScope on Component {
  /// Default text style
  TextStyle? get style;

  /// Additional CSS classes applied to the text
  String? get classes;
}

/// A helper class to represent SEO tags for a page.
class SEO {
  /// Page description.
  final String? description;

  /// Keywords for search engines.
  final List<String>? keywords;

  /// SEO robots directives (e.g. ['index', 'follow']).
  final List<String>? robots;

  /// Page title (e.g. 'Home | My Awesome Site').
  final String? title;

  /// Page url (e.g. 'https://www.example.com').
  final String? url;

  /// Logo url (e.g. 'https://www.example.com/image.jpg').
  final String? logo;

  /// Page title displayed on social media platforms.
  ///
  /// When `null`, [title] will be used.
  final String? socialMediaTitle;

  /// Page description displayed on social media platforms.
  ///
  /// When `null`, [description] will be used.
  final String? socialMediaDescription;

  /// Image displayed on social media platforms.
  ///
  /// When `null`, [logo] will be used if provided.
  final String? socialMediaBanner;

  const SEO({
    this.description,
    this.keywords,
    this.robots,
    this.title,
    this.url,
    this.logo,
    this.socialMediaTitle,
    this.socialMediaDescription,
    this.socialMediaBanner,
  });
}

/// A calendar day.
class CalendarDay {
  final DateTime date;
  final bool isSelected;
  final bool isDisabled;
  final bool isToday;

  const CalendarDay({
    required this.date,
    this.isSelected = false,
    this.isDisabled = false,
    this.isToday = false,
  });

  CalendarDay copyWith({
    DateTime? date,
    bool? isSelected,
    bool? isDisabled,
    bool? isToday,
  }) {
    return CalendarDay(
      date: date ?? this.date,
      isSelected: isSelected ?? this.isSelected,
      isDisabled: isDisabled ?? this.isDisabled,
      isToday: isToday ?? this.isToday,
    );
  }

  @override
  String toString() => date.toDayMonthYear;
}

/// A calendar month.
class CalendarMonth {
  final DateTime date;
  final List<CalendarDay?> days;

  const CalendarMonth({
    required this.date,
    required this.days,
  });
}

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

/// Scroll bar configuration.
class ScrollBarConfiguration {
  /// Color of the scroll bar thumb.
  final Color thumbColor;

  /// Color of the scroll bar track.
  final Color trackColor;

  /// Color of the scroll bar thumb when hovered.
  final Color? hoverColor;

  /// Border radius of the scroll bar thumb in pixels.
  final double? radius;

  /// Width of the scroll bar thumb in pixels (for vertical scrollbar).
  final double? width;

  /// Height of the scroll bar thumb in pixels (for horizontal scrollbar).
  final double? height;

  const ScrollBarConfiguration({
    required this.thumbColor,
    required this.trackColor,
    this.hoverColor,
    this.radius,
    this.width,
    this.height,
  });
}
