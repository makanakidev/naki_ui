part of 'index.dart';

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
  /// Unique identifier of the dropdown.
  final String? id;

  /// Custom component that opens/closes the dropdown.
  ///
  /// ### Important notes
  /// - No `click` event listeners should be attached to
  ///   the [child] component, as the dropdown states are
  ///   managed internally.
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

  /// When [enableSearch] is `true`, this will be the text
  /// displayed in the search field before the user starts typing.
  final String searchPlaceholder;

  /// Additional CSS classes applied to the dropdown menu.
  final String? classes;

  /// Size of the dropdown default trigger component
  /// (**supported properties**: `width`, `height`).
  final SizeConstraints? size;

  /// Maximum height of the dropdown menu.
  final Dim? menuHeight;

  /// Decoration of the dropdown default trigger component
  /// (**supported properties**: `backgroundColor`, `border`,
  /// `padding`, `margin`).
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
  }) : assert(placeholder.isNotEmpty, 'placeholder text must be set.'),
       assert(options.isNotEmpty, 'Dropdown must have at least one option.'),
       assert(
         options.where((i) => i.selected).length <= 1,
         'Only one option can be marked as selected.',
       );

  @override
  State<Dropdown<T>> createState() => _DropdownState<T>();

  static List<StyleRule> get styles => SelectionStyles.dropdown;
}

class _DropdownState<T> extends State<Dropdown<T>> with NakiStatefulMixin {
  late final String _id = nakiDomId(context, 'nkd', id: component.id);

  final _searchFieldHeight = 38.0;
  final _filteredOptions = ValueNotifier<List<DropdownItem<T>>>([]);

  final _optionsKey = GlobalNodeKey<HTMLElement>();
  final _searchKey = GlobalNodeKey<HTMLElement>();

  DropdownItem<T> _selectedOption = DropdownItem();
  List<DropdownItem<T>> _options = [];
  DropdownItem<T>? _activeOption;

  bool _isOpen = false;
  bool _isSearching = false;
  bool _hasSearchFocus = false;
  bool _showUpward = false;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
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
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    final tapSubscription = listenTapOutside(
      () => document.getElementById('${_id}__dropdown'),
      (_) {
        if (!_isOpen) return;

        setState(() {
          _isOpen = false;
          _activeOption = null;
        });
      },
    );

    return tapSubscription.cancel;
  }

  @override
  void didUpdateComponent(Dropdown<T> oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (_compareOptions(oldComponent.options) ||
        oldComponent.id != component.id) {
      _isOpen = false;
      _isSearching = false;
      _hasSearchFocus = false;
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
    NakiDebounce.cancel('search_$_id');
    _filteredOptions.dispose();
    super.dispose();
  }

  /// Reset search box when dropdown box is toggled
  void _resetSearch() {
    if (component.enableSearch) {
      // reset filtered options and search state
      _filteredOptions.value = [];
      _isSearching = false;
      _hasSearchFocus = false;

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
    final safeArea = safeAreaInsets();

    // calculate space available below and above the dropdown
    final spaceAvailableBelow =
        viewportHeight - safeArea.bottom - optionsRect.bottom;
    final spaceAvailableAbove = optionsRect.top - safeArea.top;

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
    DropdownItem<T>(label: component.placeholder, placeholder: true),
    // user-provided options
    ...component.options.where((i) => !i.placeholder && i.label != null),
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
        ? (_selectedOption.value != null
              ? _selectedOption
              : _firstSelectable(_options))
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
  DropdownItem<T>? _firstSelectable(List<DropdownItem<T>> items) {
    for (final item in items) if (!item.disabled) return item;
    return null;
  }

  List<DropdownItem<T>> get _visibleOptions =>
      _isSearching ? _filteredOptions.value : _options;

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

    // update active (highlighted) option only; selection is committed on
    // Enter / Space or click, like a native listbox.
    setState(() => _activeOption = selectable[next]);

    if (!mounted || _activeOption == null) return;

    // remove focus from search box and return focus to trigger box
    if (_isSearching && _hasSearchFocus) {
      _hasSearchFocus = false;
      (document.getElementById('${_id}_search') as HTMLInputElement).blur();

      final parent = document.getElementById('${_id}__dropdown') as HTMLElement;
      (parent.querySelector('.naki-dropdown-trigger') as HTMLElement).focus();
    }

    final activeId = '${_id}_item_${_options.indexOf(_activeOption!)}';
    scrollToView(
      id: activeId,
      offset: component.enableSearch ? _searchFieldHeight : 0,
      useAncestor: false,
    );
  }

  /// Handles keyboard events
  void _handleDropdownKeyDown(KeyboardEvent event) {
    if (component.disabled) return;

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
          event.stopPropagation();

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

    // invoke callback
    component.onSelected(option);

    // reset last selection state
    final prevIndex = _options.indexOf(_selectedOption);
    if (prevIndex != -1) {
      _options[prevIndex] = _options[prevIndex].copyWith(selected: false);
    }

    // set new selection state
    final index = _options.indexOf(option);
    if (index != -1) {
      _options[index] = _options[index].copyWith(selected: true);
    }

    // update selected option
    _selectedOption = option;

    // close dropdown
    _isOpen = false;
    _activeOption = null;

    setState(() {});
  }

  /// Returns the ID of the selected item
  String? get _selectedItemId => _selectedOption.value != null
      ? '${_id}_item_${_options.indexOf(_selectedOption)}'
      : null;

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

    final extraMenuClasses = component.classes.isNotNullAndEmpty
        ? ' ${component.classes}'
        : '';

    // Default trigger container
    final Component defaultTrigger = div(
      classes: 'default_trigger',
      attributes: {
        'hvr': ?(component.statesColor?.hoverColor != null ? '' : null),
        'fcs': ?(component.statesColor?.focusBorderColor != null ? '' : null),
      },
      styles: Styles(
        raw: {...?triggerBorder, ...?triggerPadding, ...?triggerMargin},
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
          'aria-activedescendant':
              '${_id}_item_${_options.indexOf(_activeOption!)}',
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
        inputStyle: TextStyle(
          fontSize: Dim.variable(
            Tokens.current.dropdownOptionFontSize.name,
            defaultValue: Tokens.current.dropdownOptionFontSize.value,
          ),
        ),
        border: BorderData.only(
          bottom: BorderSideData(color: context.borderColor),
          left: BorderSideData.none,
          right: BorderSideData.none,
          top: BorderSideData.none,
          radius: BorderRadiusData.zero,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dim.variable(
            Tokens.current.paddingSm.name,
            defaultValue: Tokens.current.paddingSm.value,
          ),
        ),
      ),
      onTyping: (query) {
        NakiDebounce.run('search_$_id', const Duration(milliseconds: 150), () {
          // reset search
          if (query.isEmpty) {
            setState(() {
              _isSearching = false;
              _hasSearchFocus = false;
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
                    item.label!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

          setState(() {
            _isSearching = true;
            _hasSearchFocus = true;
            _activeOption = _firstSelectable(filtered);
            _filteredOptions.value = filtered;
          });
        });
      },
      events: InputEvents(
        onKeyDown: _handleDropdownKeyDown,
      ),
    );

    // Options menu
    final Component dropdownMenu = section(
      key: _optionsKey,
      classes:
          'naki-dropdown-menu${_showUpward ? ' upward' : ''}$extraMenuClasses',
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
            return const span(classes: 'naki-dropdown-no-result', [
              .text('No results found'),
            ]);
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
                      'data-active': ?(item == _activeOption ? '' : null),
                      'aria-selected':
                          ?(!item.disabled && _currentLabel == item.label
                          ? 'true'
                          : null),
                    },
                    events: Events(
                      onClick: (_) => _updateSelection(item),
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
