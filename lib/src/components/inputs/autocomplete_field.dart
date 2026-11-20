part of 'index.dart';

/// {@template AutoCompleteField}
/// A component with live-filtering dropdown — the user types,
/// picks from [options], and [onSelected] fires.
///
/// ### Example
/// ```dart
/// AutoCompleteField(
///   id: 'autocomplete-field',
///   options: ['Apple', 'Banana', 'Cherry', 'Date', 'Fig'],
///   onSelected: (value) {
///     print('Selected: $value');
///   },
/// )
/// ```
/// {@endtemplate}
class AutoCompleteField extends StatefulComponent {
  /// Unique identifier of the autocomplete field.
  final String? id;

  /// Initial value of the autocomplete field.
  final String? initialValue;

  /// Options to display in the autocomplete dropdown list.
  final List<String> options;

  /// Autocomplete field height.
  final Dim? height;

  /// Autocomplete field width.
  final Dim? width;

  /// Maximum height of the dropdown container.
  final Dim? dropdownMaxHeight;

  /// Background color of the dropdown container.
  final Color? dropdownBackgroundColor;

  /// Style applied to the dropdown options.
  ///
  /// Note: Only `fontSize` and `padding` are supported.
  final TextStyle? optionStyle;

  /// Function called when an option is selected.
  final ValueChanged<String> onSelected;

  /// Decoration of the autocomplete field.
  final InputDecoration? decoration;

  /// When [autoValidate] is enabled and [validator] returns an error
  /// message, the autocomplete field will display the validation message on
  /// typing, submitting, or when the autocomplete field loses focus.
  ///
  /// Note: [validator] must be provided when [autoValidate] is true.
  final bool autoValidate;

  /// Whether the autocomplete field is required in form validation.
  final bool required;

  /// When `true`, the autocomplete field will be automatically
  /// focused after being rendered in client environment.
  final bool autoFocus;

  /// Callback that returns an error message if the autocomplete field's
  /// value is invalid, or `null` otherwise.
  final FieldValidator<String>? validator;

  /// When `true`, the autocomplete field will not accept user input.
  final bool disable;

  /// Additional CSS classes applied to the autocomplete field.
  final String? classes;

  /// {@macro AutoCompleteField}
  AutoCompleteField({
    super.key,
    required this.options,
    required this.onSelected,
    this.disable = false,
    this.autoValidate = false,
    this.required = false,
    this.autoFocus = false,
    this.id,
    this.decoration,
    this.initialValue,
    this.height,
    this.width,
    this.validator,
    this.classes,
    this.optionStyle,
    this.dropdownBackgroundColor,
    this.dropdownMaxHeight,
  }) : assert(options.isNotEmpty, 'options must have at least 1 option'),
       assert(
         !autoValidate || validator != null,
         'validator is required when autoValidate is true',
       );

  @override
  State<AutoCompleteField> createState() => _AutoCompleteFieldState();

  @css
  static List<StyleRule> get styles => NakiStyleRegistry.once(
    'AutoCompleteField',
    Rules.nakiAutoCompleteFieldRules,
  );
}

class _AutoCompleteFieldState extends State<AutoCompleteField>
    with NakiStatefulMixin {
  late String _id;

  final _filteredOptions = ValueNotifier<List<String>>([]);
  int? _activeOptionIndex;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _id = nakiDomId(context, 'nac', id: component.id);
  }

  @override
  void dispose() {
    NakiDebounce.cancel('autocomplete_$_id');
    _filteredOptions.dispose();
    super.dispose();
  }

  /// Returns the input element node
  HTMLInputElement? get inputNode =>
      component.key is GlobalNodeKey<HTMLInputElement>
      ? (component.key as GlobalNodeKey<HTMLInputElement>).currentNode
      : document.getElementById(_id) as HTMLInputElement?;

  @override
  FutureOr<VoidCallback?> afterRender(BuildContext context) {
    if (component.autoFocus) inputNode?.focus();

    final tapSubscription = listenTapOutside(
      () => document.getElementById('${_id}__autocomplete'),
      (_) {
        if (_filteredOptions.value.isEmpty) return;

        setState(() {
          _activeOptionIndex = null;
          _filteredOptions.value = [];
        });
      },
    );

    return tapSubscription.cancel;
  }

  /// Handles typing
  void _onTyping(String value) {
    // clear the filtered options when input is empty
    if (value.isEmpty) {
      NakiDebounce.cancel('autocomplete_$_id');

      setState(() {
        _activeOptionIndex = null;
        _filteredOptions.value = [];
      });

      return;
    }

    // prevent excessive filtering
    NakiDebounce.run(
      'autocomplete_$_id',
      const Duration(milliseconds: 150),
      () {
        final filtered = component.options
            .where((o) => o.toLowerCase().contains(value.toLowerCase()))
            .toList();

        setState(() {
          if (filtered.isEmpty) _activeOptionIndex = null;
          _filteredOptions.value = filtered;
        });
      },
    );
  }

  /// Handles option selection
  void _onSelect(String value) {
    // clear filtered options
    setState(() {
      _filteredOptions.value = [];
      _activeOptionIndex = null;
    });

    // update input value
    inputNode?.value = value;

    // invoke callback
    component.onSelected.call(value);
  }

  /// Handles keyboard events
  void _handleKeyDown(KeyboardEvent event) {
    final options = _filteredOptions.value;

    if (event.key == 'Escape') {
      setState(() {
        _activeOptionIndex = null;
        _filteredOptions.value = [];
      });

      return;
    }

    if (options.isEmpty) return;

    if (event.key == 'ArrowDown' || event.key == 'ArrowUp') {
      event.preventDefault();

      final delta = event.key == 'ArrowDown' ? 1 : -1;
      final current = _activeOptionIndex ?? (delta > 0 ? -1 : 0);

      setState(() => _activeOptionIndex = (current + delta) % options.length);
      return;
    }

    if (event.key == 'Enter' && _activeOptionIndex != null) {
      event.preventDefault();
      _onSelect(options[_activeOptionIndex!]);
    }
  }

  @override
  Component build(BuildContext context) {
    // Dropdown container style properties
    final dropdownHeight = component.dropdownMaxHeight?.cssText;
    final dropdownBgColor = component.dropdownBackgroundColor?.value;

    // Options style properties
    final optionsStyle = component.optionStyle;
    final optionFontSize = optionsStyle?.fontSize?.cssText;
    final optionPadding = optionsStyle?.padding?.pProps.cssText;

    return .element(
      tag: 'naki-autocomplete',
      id: '${_id}__autocomplete',
      children: [
        // Text field
        TextField(
          key: component.key,
          id: _id,
          initialValue: component.initialValue,
          decoration: component.decoration,
          autoValidate: component.autoValidate,
          required: component.required,
          validator: component.validator,
          disable: component.disable,
          classes: component.classes,
          type: InputType.text,
          height: component.height,
          width: component.width,
          backgroundColor: component.dropdownBackgroundColor,
          attributes: {
            'role': 'combobox',
            'aria-autocomplete': 'list',
            'aria-haspopup': 'listbox',
            'aria-expanded': _filteredOptions.value.isNotEmpty.toString(),
            'aria-controls': '${_id}_options',
            if (_activeOptionIndex != null)
              'aria-activedescendant': '${_id}_option_${_activeOptionIndex!}',
          },
          events: InputEvents(onKeyDown: _handleKeyDown),
          onTyping: _onTyping,
        ),

        // Dropdown container
        _filteredOptions.rebuild((filteredOptions) {
          if (filteredOptions.isEmpty) return const .empty();

          return section(
            id: '${_id}_options',
            classes: 'naki-autocomplete-menu',
            attributes: const {'role': 'listbox'},
            styles: Styles(
              raw: {
                Tokens.current.dropdownMenuHeight.name: ?dropdownHeight,
                Tokens.current.dropdownMenuBgColor.name: ?dropdownBgColor,
                Tokens.current.dropdownOptionPadding.name: ?optionPadding,
                Tokens.current.dropdownOptionFontSize.name: ?optionFontSize,
              },
            ),
            filteredOptions.indexed
                .map(
                  (entry) => div(
                    id: '${_id}_option_${entry.$1}',
                    classes: 'naki-autocomplete-option',
                    attributes: {
                      'role': 'option',
                      'aria-selected': (_activeOptionIndex == entry.$1)
                          .toString(),
                    },
                    events: Events(onClick: (_) => _onSelect(entry.$2)).toMap,
                    [.text(entry.$2)],
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }
}
