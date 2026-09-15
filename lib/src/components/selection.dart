import 'dart:async';

import 'package:jaspr/dom.dart' hide Position;
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart';

import '../framework/framework.dart';
import '../models/gesture.dart';
import '../models/naki.dart';
import '../models/styling.dart';
import '../styles/rules.dart';
import '../styles/text_style.dart';
import '../theme/tokens.dart';
import '../utilities/debounce.dart';
import '../utilities/enums.dart';
import '../utilities/extensions.dart';
import '../utilities/helpers.dart';
import 'input.dart';

// /////////////////////////////////////////////////////////////////////////////
// SELECTION COMPONENTS
// /////////////////////////////////////////////////////////////////////////////

/// {@template Checkbox}
/// A component that displays a standard checkbox with an optional
/// text label placed on either the left or right side.
///
/// ### Example
/// ```dart
/// Checkbox(
///   label: 'Accept Terms & Conditions',
///   isChecked: true,
///   labelPosition: Position.right,
///   onChange: (checked) {
///     print('Checkbox is now: $checked');
///   },
/// )
/// ```
/// {@endtemplate}
class Checkbox extends StatelessComponent {
  /// The label text displayed beside the checkbox.
  final String? label;

  /// Unique identifier of the checkbox.
  final String? id;

  /// Name used when this checkbox participates in a native form.
  final String? name;

  /// Value submitted when this checkbox is checked.
  final String? value;

  /// Style applied to [label].
  final TextStyle? labelStyle;

  /// Position of the [label] relative to the checkbox
  /// (defaults to [Position.left]).
  final Position labelPosition;

  /// Color applied to the checkbox tick.
  final Color? color;

  /// Whether the checkbox is currently checked.
  final bool isChecked;

  /// Callback invoked when the user toggles the checkbox.
  final ValueChanged<bool> onChange;

  /// Whether the checkbox is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the checkbox component.
  final String? classes;

  /// Force this component to occupy the entire available horizontal
  /// space (the `label` and `checkbox` will be evenly spaced).
  final bool expand;

  /// {@macro Checkbox}
  Checkbox({
    super.key,
    required this.onChange,
    this.labelPosition = Position.left,
    this.disabled = false,
    this.isChecked = false,
    this.expand = false,
    this.id,
    this.name,
    this.value,
    this.classes,
    this.label,
    this.color,
    this.labelStyle,
  }) : assert(
         labelPosition == Position.left || labelPosition == Position.right,
         'Unsupported label position: $labelPosition',
       );

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(
      context,
      'checkbox',
      id: id,
    );
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-checkbox';
    final String effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    // Add checkbox
    children.add(
      span(
        classes: 'naki-control-hitbox',
        [
          input<bool>(
            key: key,
            id: _id,
            name: name,
            value: value,
            type: InputType.checkbox,
            attributes: !disabled ? {'fcs': ''} : null,
            classes: effectiveClasses,
            styles: Styles(color: color),
            checked: isChecked,
            disabled: disabled,
            onChange: disabled ? null : onChange,
          ),
        ],
      ),
    );

    // Add label
    if (label.isNotNullAndEmpty) {
      final cleanedStyle = (labelStyle ?? const TextStyle()).copyWith(margin: .zero);
      final labelUi = Label(
        label!,
        fieldId: _id,
        style: cleanedStyle,
      );

      if (labelPosition == Position.right) {
        children.add(labelUi);
      } else if (labelPosition == Position.left) {
        children.insert(0, labelUi);
      }
    }

    return .element(
      tag: 'naki-checkbox',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Checkbox', [Rules.nakiCheckboxRules, Rules.nakiHitboxRules]);
}

/// {@template Switch}
/// A component that displays a toggle switch, with support
/// for an optional text label placed on either the left or the right side.
///
/// ### Example
/// ```dart
/// Switch(
///   label: 'Enable Notifications',
///   isActive: true,
///   labelPosition: Position.left,
///   expand: true,
///   onChange: (active) {
///     print('Switch is active: $active');
///   },
/// )
/// ```
/// {@endtemplate}
class Switch extends StatelessComponent {
  /// The label text displayed next to the switch.
  final String? label;

  /// Unique identifier of the switch.
  final String? id;

  /// Name used when this switch participates in a native form.
  final String? name;

  /// Value submitted when the switch is active.
  final String? value;

  /// Style applied to [label].
  final TextStyle? labelStyle;

  /// Position of the [label] relative to the switch
  /// (defaults to [Position.left]).
  final Position labelPosition;

  /// Custom color applied to the switch thumb.
  final Color? thumbColor;

  /// Whether the switch is currently active (toggled `on`).
  final bool isActive;

  /// Callback invoked when the user toggles the switch.
  final ValueChanged<bool> onChange;

  /// Whether the switch is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the switch component.
  final String? classes;

  /// Force this component to occupy the entire available horizontal
  /// space (the `label` and `switch` will be evenly spaced).
  final bool expand;

  /// {@macro Switch}
  Switch({
    super.key,
    required this.onChange,
    this.labelPosition = Position.left,
    this.disabled = false,
    this.expand = false,
    this.isActive = false,
    this.id,
    this.name,
    this.value,
    this.classes,
    this.label,
    this.thumbColor,
    this.labelStyle,
  }) : assert(
         labelPosition == Position.left || labelPosition == Position.right,
         'Unsupported label position: $labelPosition',
       );

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(context, 'switch', id: id);
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-switch';
    final String effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    // Add switch
    children.add(
      span(
        classes: 'naki-control-hitbox',
        [
          input<bool>(
            id: _id,
            key: key,
            name: name,
            value: value,
            type: InputType.checkbox,
            classes: effectiveClasses,
            styles: Styles(
              raw: {
                Tokens.current.switchThumbColor.name: ?thumbColor?.value,
              },
            ),
            attributes: !disabled ? {'fcs': ''} : null,
            checked: isActive,
            disabled: disabled,
            onChange: disabled ? null : onChange,
          ),
        ],
      ),
    );

    // Add label
    if (label.isNotNullAndEmpty) {
      final cleanedStyle = (labelStyle ?? const TextStyle()).copyWith(margin: .zero);
      final labelUi = Label(
        label!,
        fieldId: _id,
        style: cleanedStyle,
      );

      if (labelPosition == Position.right) {
        children.add(labelUi);
      } else if (labelPosition == Position.left) {
        children.insert(0, labelUi);
      }
    }

    return .element(
      tag: 'naki-switch',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Switch', [Rules.nakiSwitchRules, Rules.nakiHitboxRules]);
}

/// {@template Slider}
/// A component that displays a range slider, with support for custom
/// ranges, snapping divisions, custom track and thumb colors,
/// and an optional value indicator.
///
/// ### Example
/// ```dart
/// Slider(
///   value: 45,
///   minValue: 0,
///   maxValue: 100,
///   divisions: 10,
///   showValueIndicator: true,
///   expand: true,
///   onChange: (value) {
///     print('Slider value: $value');
///   },
/// )
/// ```
/// {@endtemplate}
class Slider extends StatelessComponent {
  /// Width of the slider track.
  final Dim width;

  /// Unique identifier of the slider.
  final String id;

  /// Name used when the slider participates in a native form.
  final String? name;

  /// The height of the slider.
  final Dim height;

  /// Custom color applied to the slider track.
  final Color? color;

  /// Custom color applied to the slider thumb.
  final Color? thumbColor;

  /// The current value of the slider.
  final double value;

  /// Whether to display a floating value indicator tooltip when the
  /// user interacts with the slider.
  final bool showValueIndicator;

  /// The minimum selectable value for the slider.
  final double minValue;

  /// The maximum selectable value for the slider.
  final double maxValue;

  /// The number of discrete intervals between [minValue] and [maxValue]
  /// to snap the value to.
  ///
  /// When `null`, the slider is continuous otherwise it snaps
  /// to the nearest division.
  final int? divisions;

  /// Callback invoked when the slider value changes.
  final ValueChanged<double>? onChange;

  /// Whether user interaction with the slider is allowed.
  final bool allowInteraction;

  /// Additional CSS classes applied to the slider component.
  final String? classes;

  /// {@macro Slider}
  const Slider({
    super.key,
    required this.id,
    this.width = const Dim.px(300),
    this.height = const Dim.px(24),
    this.value = 0,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.allowInteraction = true,
    this.showValueIndicator = false,
    this.name,
    this.onChange,
    this.divisions,
    this.classes,
    this.thumbColor,
    this.color,
  }) : assert(id != '', 'id cannot be empty'),
       assert(
         minValue < maxValue,
         'maxValue must be greater than minValue',
       ),
       assert(
         value >= minValue && value <= maxValue,
         'value must be between minValue and maxValue',
       ),
       assert(
         divisions == null || divisions >= 1,
         'divisions must be at least 1',
       );

  @override
  Component build(BuildContext context) {
    final String _id = 'nsl_$id';
    final showTooltip = allowInteraction && showValueIndicator;

    final double percent = ((value - minValue) * 100) / (maxValue - minValue);
    final String position = 'calc($percent% + (${8 - percent * 0.15}px))';

    const String baseClass = 'naki-slider';
    final String effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final _style = {
      Tokens.current.sliderThumbSize.name: height.cssText,
      Tokens.current.sliderThumbColor.name: ?thumbColor?.value,
      Tokens.current.sliderTrackColor.name: ?color?.value,
      'width': width.cssText,
    };

    return .element(
      tag: 'naki-slider',
      children: [
        // Input
        input<double>(
          id: _id,
          key: key,
          name: name,
          type: InputType.range,
          classes: effectiveClasses,
          styles: Styles(raw: _style),
          disabled: !allowInteraction,
          value: value.toCleanString,
          attributes: {
            'min': minValue.toCleanString,
            'max': maxValue.toCleanString,
            'step': ?(divisions == null
                ? null
                : ((maxValue - minValue) / divisions!).toCleanString),
          },
          onInput: allowInteraction
              ? (value) {
                  onChange?.call(value);
                  if (showTooltip) updateSliderTooltip(_id, hide: false);
                }
              : null,
          events: showTooltip ? {'blur': (_) => updateSliderTooltip(_id)} : null,
        ),

        // Tooltip
        if (showTooltip)
          .element(
            tag: 'output',
            classes: 'slider-tooltip',
            id: '$_id-tooltip',
            attributes: {'for': _id},
            styles: Styles(raw: {'left': position}),
            children: [.text(value.toCleanString)],
          ),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once('Slider', [
    Rules.nakiSliderRules,
  ]);
}

/// {@template RadioButton}
/// A component that displays a radio button, with support for custom
/// color and size.
///
/// ### Example
/// ```dart
/// RadioButton(
///   isSelected: false,
///   size: Dim.px(30),
///   disabled: false,
///   onChange: (value) {},
/// )
/// ```
/// {@endtemplate}
class RadioButton extends StatelessComponent {
  /// The label text displayed next to the radio button.
  final String? label;

  /// Style applied to the label text.
  final TextStyle? labelStyle;

  /// Unique identifier of the radio button.
  final String? id;

  /// Shared native form name for a mutually-exclusive radio group.
  final String? name;

  /// Value submitted when the radio button is selected.
  final String? value;

  /// Position of the [label] relative to the radio button
  /// (default: [Position.left]).
  final Position labelPosition;

  /// Custom color applied to the radio button.
  final Color? color;

  /// Whether the radio button is currently selected.
  final bool isSelected;

  /// Callback invoked when the user toggles the radio button.
  final ValueChanged<bool> onChange;

  /// Whether the radio button is disabled (non-interactive).
  final bool disabled;

  /// Additional CSS classes applied to the radio button component.
  final String? classes;

  /// The width and height of the radio button.
  final Dim? size;

  /// When `true`, the radio button and [label] will be evenly spaced across
  /// the available horizontal space.
  final bool expand;

  /// {@macro RadioButton}
  const RadioButton({
    super.key,
    required this.onChange,
    this.isSelected = false,
    this.disabled = false,
    this.expand = false,
    this.labelPosition = Position.left,
    this.classes,
    this.id,
    this.name,
    this.value,
    this.size,
    this.color,
    this.label,
    this.labelStyle,
  });

  @override
  Component build(BuildContext context) {
    final String _id = nakiDomId(
      context,
      'radio-btn',
      id: id,
    );
    final bool shouldExpand = label.isNotNullAndEmpty && expand;
    final List<Component> children = [];

    const String baseClass = 'naki-radio-btn';
    final String effectiveClasses = classes.isNotNullAndEmpty ? '$baseClass $classes' : baseClass;

    final styles = {
      Tokens.current.radioBtnRadius.name: ?size?.cssText,
      Tokens.current.radioBtnColor.name: ?color?.value,
    };

    // Add radio
    children.add(
      span(
        classes: 'naki-control-hitbox',
        [
          input<bool>(
            id: _id,
            key: key,
            name: name,
            value: value,
            type: InputType.radio,
            classes: effectiveClasses,
            styles: Styles(raw: styles),
            checked: isSelected,
            disabled: disabled,
            onChange: disabled ? null : onChange,
          ),
        ],
      ),
    );

    // Add label
    if (label.isNotNullAndEmpty) {
      final cleanedStyle = (labelStyle ?? const TextStyle()).copyWith(margin: .zero);
      final labelUi = Label(
        label!,
        fieldId: _id,
        style: cleanedStyle,
      );

      if (labelPosition == Position.right) {
        children.add(labelUi);
      } else if (labelPosition == Position.left) {
        children.insert(0, labelUi);
      }
    }

    return .element(
      tag: 'naki-radiobtn',
      styles: shouldExpand ? const Styles(justifyContent: .spaceBetween) : null,
      children: children,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('RadioButton', [Rules.nakiRadioBtnRules, Rules.nakiHitboxRules]);
}

/// {@template Dropdown}
/// A component that provides a dropdown menu for selecting a single
/// value from a list of options.
///
/// ### Example
/// ```dart
/// Dropdown<String>(
///   id: 'dropdown',
///   placeholder: 'Select an option',
///   items: [
///     DropdownItem<String>(value: 'opt_1', label: 'Option 1'),
///     DropdownItem<String>(value: 'opt_2', label: 'Option 2',
///     selected: true),
///   ],
///   onSelected: (item) {
///     print('Selected value: ${item.value}');
///   },
/// )
/// ```
/// {@endtemplate}
class Dropdown<T> extends StatefulComponent {
  /// Unique identifier of the dropdown component.
  final String? id;

  /// Custom component that opens/closes the dropdown menu.
  ///
  /// ### Important notes
  /// - No `click` event listeners should be attached to the [child] component,
  ///   as the dropdown states are managed internally.
  /// - When `null`, the default trigger component is rendered.
  final Component? child;

  /// Placeholder text rendered in the default trigger component
  /// when no option is selected and [child] is `null`.
  final String placeholder;

  /// Options rendered in the dropdown menu.
  ///
  /// - Mark an option as selected by setting
  ///   [DropdownItem.selected] to `true`.
  /// - Mark an option as section header by setting
  ///   [DropdownItem.section] to `true`.
  ///
  /// ### Example
  /// ```dart
  /// final items = [
  ///   DropdownItem<String>(value: 'opt_1', label: 'Option 1'),
  ///   DropdownItem<String>(value: 'opt_2', label: 'Option 2',
  ///   selected: true),
  ///   DropdownItem<String>(value: 'section-1', label: 'Section 1',
  ///   section: true),
  ///   DropdownItem<String>(value: 'opt_3', label: 'Option 3'),
  ///   DropdownItem<String>(value: 'opt_4', label: 'Option 4'),
  /// ];
  /// ```
  final List<DropdownItem<T>> options;

  /// Callback invoked when an option is selected.
  final ValueChanged<DropdownItem<T>> onSelected;

  /// Whether the dropdown component is disabled (not interactive).
  final bool disabled;

  /// When `true`, the dropdown menu will include a search box.
  final bool enableSearch;

  /// When [enableSearch] is `true`, this will be the text displayed in the
  /// search field before the user starts typing.
  final String searchPlaceholder;

  /// Additional CSS classes applied to the dropdown menu.
  final String? classes;

  /// Size of the dropdown default trigger component
  /// (**supported properties**: `width`, `height`).
  final SizeConstraints? size;

  /// Maximum height of the dropdown menu.
  final Dim? menuHeight;

  /// Decoration of the dropdown default trigger component
  /// (**supported properties**: `backgroundColor`, `border`, `padding`, `margin`).
  final BoxDecoration? decoration;

  /// Style applied to the text in dropdown trigger component
  /// (**supported properties**: `fontSize`, `color`).
  final TextStyle? style;

  /// Style applied to options in the dropdown menu
  /// (**supported properties**: `fontSize`, `padding`).
  final TextStyle? optionStyle;

  /// Style applied to selected options in the dropdown menu
  /// (**supported properties**: `color`, `backgroundColor`).
  final TextStyle? selectedOptionStyle;

  /// Style applied to section headers in the dropdown menu
  /// (**supported properties**: `fontSize`, `fontWeight`).
  final TextStyle? sectionStyle;

  /// Background color of the dropdown menu.
  final Color? menuBackgroundColor;

  /// Colors applied to the dropdown component based on its state.
  final ComponentStatesColor? statesColor;

  /// {@macro Dropdown}
  Dropdown({
    super.key,
    required this.options,
    required this.onSelected,
    this.placeholder = 'Select an option',
    this.disabled = false,
    this.enableSearch = false,
    this.searchPlaceholder = 'Search...',
    this.id,
    this.child,
    this.classes,
    this.size,
    this.decoration,
    this.menuHeight,
    this.style,
    this.optionStyle,
    this.selectedOptionStyle,
    this.sectionStyle,
    this.menuBackgroundColor,
    this.statesColor,
  }) : assert(
         placeholder != '',
         'placeholder text must be set.',
       ),
       assert(
         options.isNotEmpty,
         'Dropdown must have at least one option.',
       ),
       assert(
         options.where((i) => i.selected).length <= 1,
         'Only one option can be marked as selected.',
       );

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'Dropdown',
    Rules.nakiDropdownRules,
  );
}

class _DropdownState<T> extends State<Dropdown<T>> with NakiStatefulMixin {
  late final String _id = nakiDomId(
    context,
    'nkd',
    id: component.id,
  );

  final _searchFieldHeight = 38.0;
  final _filteredOptions = ValueNotifier<List<DropdownItem<T>>>([]);

  final _optionsKey = GlobalNodeKey<HTMLElement>();
  final _searchKey = GlobalNodeKey<HTMLElement>();

  DropdownItem<T> _selectedOption = DropdownItem();
  List<DropdownItem<T>> _options = [];
  DropdownItem<T>? _activeOption;

  bool _isOpen = false;
  bool _isSearching = false;
  bool _showUpward = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _options = _buildOptions();

    _selectedOption = _options.firstWhere(
      (opt) => opt.selected,
      orElse: () => DropdownItem<T>(),
    );
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    // listener that checks if an outside click occurred
    final clickSubscription = EventStreamProviders.clickEvent.forTarget(window).listen((event) {
      if (!_isOpen) return;

      final target = event.target as Node?;
      final parent =
          document.querySelector(
                '#${_id}__dropdown[open]',
              )
              as HTMLElement?;

      if (parent != null && target != null && !parent.contains(target)) {
        event.stopPropagation();

        setState(() {
          _isOpen = false;
          _activeOption = null;
        });
      }
    });

    return clickSubscription.cancel;
  }

  @override
  void didUpdateComponent(Dropdown<T> oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (_compareOptions(oldComponent.options) || oldComponent.id != component.id) {
      _isOpen = false;
      _isSearching = false;
      _showUpward = false;
      _activeOption = null;

      _filteredOptions.value = [];
      _options = _buildOptions();

      _selectedOption = _options.firstWhere(
        (opt) => opt.selected,
        orElse: () => DropdownItem<T>(),
      );
    }
  }

  @override
  void dispose() {
    _filteredOptions.dispose();
    super.dispose();
  }

  /// Reset search box when dropdown box is toggled
  void _resetSearch() {
    if (component.enableSearch) {
      // reset filtered options and search state
      _filteredOptions.value = [];
      _isSearching = false;

      // get search box element
      final searchBox = _searchKey.currentNode as HTMLInputElement?;

      // clear search box and remove focus
      searchBox?.value = '';
      searchBox?.blur();
    }
  }

  /// Checks if dropdown options container should be
  /// displayed in upward direction
  void _setPosition() {
    // get dropdown options element
    final optionsBoxElem = _optionsKey.currentNode;
    if (optionsBoxElem == null) return;

    // get dropdown options bounding box
    final optionsRect = optionsBoxElem.getBoundingClientRect();
    final viewportHeight = window.innerHeight;

    // calculate space available below and above the dropdown
    final spaceAvailableBelow = viewportHeight - optionsRect.bottom;
    final spaceAvailableAbove = optionsRect.top;

    // determine if dropdown should be displayed in upward direction
    _showUpward = spaceAvailableAbove > spaceAvailableBelow;
  }

  /// Returns true if options need to be rebuilt
  bool _compareOptions(List<DropdownItem<T>> old) {
    final current = component.options;
    if (old.length != current.length) return true;

    for (int i = 0; i < old.length; i++) {
      // check value
      if (old[i].value != current[i].value) return true;
      // check label
      if (old[i].label != current[i].label) return true;
      // check selection
      if (old[i].selected != current[i].selected) return true;
      // check disabled
      if (old[i].disabled != current[i].disabled) return true;
      // check placeholder
      if (old[i].placeholder != current[i].placeholder) return true;
      // check section
      if (old[i].section != current[i].section) return true;
    }

    return false;
  }

  // Final options rendered in the dropdown menu
  List<DropdownItem<T>> _buildOptions() => [
    // placeholder
    DropdownItem<T>(
      label: component.placeholder,
      placeholder: true,
    ),
    // user-provided options
    ...component.options.where(
      (i) => !i.placeholder && i.label != null,
    ),
  ];

  /// Toggles dropdown menu visibility
  void _toggleDropdown() {
    if (component.disabled) return;

    // determine if dropdown should be opened or closed
    final willOpen = !_isOpen;

    // reset search box and set position
    // if dropdown is being opened
    if (willOpen) {
      _resetSearch();
      _setPosition();
    }

    // toggle dropdown menu
    _isOpen = willOpen;
    _activeOption = willOpen
        ? (_selectedOption.value != null ? _selectedOption : _firstSelectable(_options))
        : null;

    // update the component state
    setState(() {});

    // scroll to selected option if dropdown is opened
    if (willOpen) {
      final selectedId = _selectedItemId;
      if (selectedId != null) {
        scrollToView(
          id: selectedId,
          offset: component.enableSearch ? _searchFieldHeight : 0,
        );
      }
    }
  }

  /// Get first selectable option
  DropdownItem<T>? _firstSelectable(
    List<DropdownItem<T>> items,
  ) {
    for (final item in items) if (!item.disabled) return item;
    return null;
  }

  List<DropdownItem<T>> get _visibleOptions => _isSearching ? _filteredOptions.value : _options;

  /// Move active option up or down using arrow keys
  void _moveActiveOption(int delta) {
    // get all selectable options
    final selectable = _visibleOptions.where((item) => !item.disabled).toList();
    if (selectable.isEmpty) return;

    // get current active option index
    final active = _activeOption;
    final current = active == null ? -1 : selectable.indexOf(active);

    // calculate next active option index
    final next = current == -1
        ? (delta > 0 ? 0 : selectable.length - 1)
        : (current + delta) % selectable.length;

    // update active option
    setState(() => _activeOption = selectable[next]);
  }

  /// Handles keyboard events
  void _handleDropdownKeyDown(KeyboardEvent event) {
    switch (event.key) {
      case 'ArrowDown':
        event.preventDefault();
        if (!_isOpen) _toggleDropdown();
        _moveActiveOption(1);
        return;
      case 'ArrowUp':
        event.preventDefault();
        if (!_isOpen) _toggleDropdown();
        _moveActiveOption(-1);
        return;
      case 'Enter':
      case ' ':
        event.preventDefault();
        if (_isOpen && _activeOption != null) {
          _updateSelection(_activeOption!);
        } else {
          _toggleDropdown();
        }
        return;
      case 'Escape':
        if (_isOpen) {
          event.preventDefault();
          setState(() {
            _isOpen = false;
            _activeOption = null;
          });
        }
        return;
    }
  }

  /// Updates selection of dropdown options
  void _updateSelection(DropdownItem<T> option) {
    // do nothing if option is disabled
    if (option.disabled) return;

    // close dropdown if option is already selected
    if (option.value == _selectedOption.value) {
      setState(() => _isOpen = false);
      return;
    }

    // invoke user-provided callback
    component.onSelected(option);

    // reset last selection state
    final prevIndex = _options.indexOf(_selectedOption);
    if (prevIndex != -1) {
      _options[prevIndex] = _options[prevIndex].copyWith(
        selected: false,
      );
    }

    // set new selection state
    final index = _options.indexOf(option);
    if (index != -1) {
      _options[index] = _options[index].copyWith(
        selected: true,
      );
    }

    // update selected option
    _selectedOption = option;

    // close dropdown
    _isOpen = false;
    _activeOption = null;

    setState(() {});
  }

  /// Returns the ID of the selected item
  String? get _selectedItemId =>
      _selectedOption.value != null ? '${_id}_item_${_options.indexOf(_selectedOption)}' : null;

  /// Returns the current label of the dropdown
  String get _currentLabel => _selectedOption.label ?? component.placeholder;

  @override
  Component build(BuildContext context) {
    final decoration = component.decoration;
    final triggerTextStyle = component.style;

    final triggerBgColor = decoration?.backgroundColor?.value;
    final triggerWidth = component.size?.width?.cssText;
    final triggerHeight = component.size?.height?.cssText;
    final triggerColor = triggerTextStyle?.color?.value;
    final triggerFontSize = triggerTextStyle?.fontSize?.cssText;
    final triggerBorder = decoration?.border?.props;
    final triggerPadding = decoration?.padding?.pProps;
    final triggerMargin = decoration?.margin?.pProps;

    final menuBgColor = component.menuBackgroundColor?.value;
    final menuHeight = component.menuHeight?.cssText;

    final optionStyle = component.optionStyle;
    final optionFontSize = optionStyle?.fontSize?.cssText;
    final optionPadding = optionStyle?.padding?.pProps.cssText;

    final selectedOptionStyle = component.selectedOptionStyle;
    final selectedOptionFontColor = selectedOptionStyle?.color?.value;
    final selectedOptionBgColor = selectedOptionStyle?.backgroundColor?.value;

    final sectionStyle = component.sectionStyle;
    final sectionFontSize = sectionStyle?.fontSize?.cssText;
    final sectionFontWeight = sectionStyle?.fontWeight?.value;

    final extraMenuClasses = component.classes.isNotNullAndEmpty ? ' ${component.classes}' : '';

    // Default trigger container
    final Component defaultTrigger = div(
      classes: 'default_trigger',
      styles: Styles(
        raw: {
          ...?triggerBorder,
          ...?triggerPadding,
          ...?triggerMargin,
        },
      ),
      [.text(_currentLabel)],
    );

    final effectiveTrigger = Component.wrapElement(
      child: component.child ?? defaultTrigger,
      classes: 'naki-dropdown-trigger',
      attributes: {
        'data-selected': ?(_selectedOption.value != null ? '' : null),
        'role': 'combobox',
        'tabindex': component.disabled ? '-1' : '0',
        'aria-haspopup': 'listbox',
        'aria-expanded': '$_isOpen',
        'aria-controls': '${_id}_options',
        'aria-disabled': '${component.disabled}',
        if (_activeOption != null)
          'aria-activedescendant': '${_id}_item_${_options.indexOf(_activeOption!)}',
      },
      events: Events(
        onClick: (_) => _toggleDropdown(),
        onKeyDown: _handleDropdownKeyDown,
      ).toMap,
    );

    // Search box
    final Component searchBox = TextField(
      key: _searchKey,
      id: '${_id}_search',
      type: InputType.search,
      height: Dim.px(_searchFieldHeight),
      width: const Dim.percent(100),
      decoration: InputDecoration(
        placeholderText: component.searchPlaceholder,
        inputStyle: const TextStyle(fontSize: Dim.px(13)),
        border: BorderData.only(
          bottom: BorderSideData(
            width: const Dim.px(1),
            color: context.borderColor,
            style: BorderStyle.solid,
          ),
          radius: BorderRadiusData.none,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Dim.px(12),
        ),
      ),
      onTyping: (query) {
        NakiDebounce.run(
          'search_$_id',
          const Duration(milliseconds: 150),
          () {
            // reset search
            if (query.isEmpty) {
              setState(() {
                _isSearching = false;
                _activeOption = _firstSelectable(_options);
                _filteredOptions.value = [_options.first];
              });

              return;
            }

            // set searching flag and filter options based on search query
            final filtered = _options
                .where(
                  (item) =>
                      !item.disabled &&
                      item.label!.toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();

            setState(() {
              _isSearching = true;
              _activeOption = _firstSelectable(filtered);
              _filteredOptions.value = filtered;
            });
          },
        );
      },
    );

    // Options menu
    final Component dropdownMenu = section(
      key: _optionsKey,
      classes: 'naki-dropdown-menu${_showUpward ? ' upward' : ''}$extraMenuClasses',
      id: '${_id}_options',
      attributes: {
        'role': 'listbox',
        'data-value': ?_selectedOption.value?.toString(),
        'data-searchable': ?(component.enableSearch ? '' : null),
      },
      styles: Styles(
        raw: {
          Tokens.current.dropdownMenuHeight.name: ?menuHeight,
          Tokens.current.dropdownMenuBgColor.name: ?menuBgColor,
          Tokens.current.dropdownOptionPadding.name: ?optionPadding,
          Tokens.current.dropdownOptionFontSize.name: ?optionFontSize,
          Tokens.current.fontSizeSectionHeader.name: ?sectionFontSize,
          Tokens.current.fontWeightSectionHeader.name: ?sectionFontWeight,
          Tokens.current.selectedItemBgColor.name: ?selectedOptionBgColor,
          Tokens.current.selectedItemColor.name: ?selectedOptionFontColor,
          ...?triggerBorder,
        },
      ),
      [
        // add search box
        if (component.enableSearch) searchBox,

        // options dynamically updated based on search query
        _filteredOptions.rebuild((results) {
          final effectiveOptions = _isSearching ? results : _options;

          // no search results
          if (_isSearching && results.isEmpty) {
            return const span(
              classes: 'naki-dropdown-no-result',
              [
                .text('No results found'),
              ],
            );
          }

          // options list
          return div(
            effectiveOptions
                .map(
                  (item) => span(
                    id: '${_id}_item_${_options.indexOf(item)}',
                    classes: item.placeholder
                        ? 'naki-dropdown-option options-placeholder'
                        : item.section
                        ? 'naki-dropdown-option options-section'
                        : 'naki-dropdown-option',
                    attributes: {
                      'role': item.section ? 'presentation' : 'option',
                      'data-value': ?item.value?.toString(),
                      'aria-disabled': ?(item.disabled ? 'true' : null),
                      'aria-selected': ?(!item.disabled && _currentLabel == item.label
                          ? 'true'
                          : null),
                    },
                    events: Events(
                      onClick: (_) => _updateSelection(item),
                      onPointerEnter: !item.disabled
                          ? (_) => setState(
                              () => _activeOption = item,
                            )
                          : null,
                    ).toMap,
                    [.text(item.label!)],
                  ),
                )
                .toList(),
          );
        }),
      ],
    );

    return .element(
      tag: 'naki-dropdown',
      key: component.key,
      id: '${_id}__dropdown',
      styles: Styles(
        raw: {
          Tokens.current.dropdownHeight.name: ?triggerHeight,
          Tokens.current.dropdownWidth.name: ?triggerWidth,
          Tokens.current.fieldBackgroundColor.name: ?triggerBgColor,
          Tokens.current.inputTextColor.name: ?triggerColor,
          Tokens.current.fontSizeInput.name: ?triggerFontSize,
          ...?component.statesColor?.props,
        },
      ),
      attributes: {
        'open': ?(_isOpen ? '' : null),
        'disabled': ?(component.disabled ? '' : null),
      },
      children: [effectiveTrigger, dropdownMenu],
    );
  }
}
