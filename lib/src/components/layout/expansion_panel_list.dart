part of 'index.dart';

/// {@template ExpansionPanelList}
/// A Naki component that creates a list of expandable accordions/panels
/// that can be expanded or collapsed.
///
/// Supports both traditional single-open mode when [allowMultiple] is
/// `false` and multi-open mode when [allowMultiple] is `true`.
///
/// ### Example
/// ```dart
/// ExpansionPanelList(
///   allowMultiple: false,
///   expansionCallback: (index, isExpanded) {
///     print('Panel $index isExpanded: $isExpanded');
///   },
///   children: [
///     ExpansionPanel(
///       header: const NakiText('What is Naki UI?'),
///       body: const NakiText('A Material-inspired design system for Jaspr.'),
///       isExpanded: true,
///     ),
///     ExpansionPanel(
///       header: const NakiText('Does it support dark mode?'),
///       body: const NakiText('Yes, with full CSS variable theming.'),
///     ),
///   ],
/// )
/// ```
/// {@endtemplate}
class ExpansionPanelList extends StatefulComponent {
  /// The expansion panel children.
  final List<ExpansionPanel> children;

  /// Callback called when any panel expands or collapses.
  final ExpansionPanelCallback? expansionCallback;

  /// Whether multiple panels can be expanded at the same time.
  ///
  /// Set to `true` to allow multiple panels to stay open.
  final bool allowMultiple;

  /// The initially expanded panel value for radio mode.
  final dynamic initialOpenPanelValue;

  /// Custom elevation shadow of the expansion panel list.
  final double? elevation;

  /// Custom border for the expansion panel list.
  final BorderData? border;

  /// Custom border radius for the expansion panel list container.
  final BorderRadiusData? borderRadius;

  /// Divider color between panels.
  final Color? dividerColor;

  /// Color of the text and icon in the panels' header when hovered.
  final Color? hoverColor;

  /// Background color of the expansion panel list.
  final Color? color;

  /// Outer margin surrounding the list.
  final EdgeInsets? margin;

  /// Additional CSS classes.
  final String? classes;

  /// {@macro ExpansionPanelList}
  const ExpansionPanelList({
    super.key,
    this.children = const [],
    this.expansionCallback,
    this.allowMultiple = false,
    this.elevation,
    this.border,
    this.borderRadius,
    this.hoverColor,
    this.dividerColor,
    this.color,
    this.margin,
    this.classes,
  }) : initialOpenPanelValue = null;

  /// Creates an expansion panel list where only one panel can be
  /// open at a time.
  const ExpansionPanelList.radio({
    super.key,
    this.children = const [],
    this.expansionCallback,
    this.initialOpenPanelValue,
    this.elevation,
    this.border,
    this.borderRadius,
    this.hoverColor,
    this.dividerColor,
    this.color,
    this.margin,
    this.classes,
  }) : allowMultiple = false;

  @override
  State<ExpansionPanelList> createState() => _ExpansionPanelListState();

  static List<StyleRule> get styles => LayoutStyles.expansionPanelList;
}

class _ExpansionPanelListState extends State<ExpansionPanelList> {
  final Set<int> _openIndices = {};
  late final String _id = nakiDomId(context, 'expansion-panel-list');

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _syncInitialState();
  }

  @override
  void didUpdateComponent(ExpansionPanelList oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.children != component.children) {
      _syncInitialState();
    }
  }

  /// Syncs the initial state of the expansion panel list.
  void _syncInitialState() {
    _openIndices.clear();

    for (int i = 0; i < component.children.length; i++) {
      final child = component.children[i];

      final isInitialPanel =
          component.initialOpenPanelValue != null &&
          child.value == component.initialOpenPanelValue;

      if (child.isExpanded || isInitialPanel) {
        _openIndices.add(i);

        if (!component.allowMultiple) break;
      }
    }
  }

  /// Handles the toggle event of an expansion panel.
  void _handleToggle(int index) {
    final currentlyOpen = _openIndices.contains(index);
    final willBeOpen = !currentlyOpen;

    setState(() {
      if (willBeOpen) {
        if (!component.allowMultiple) _openIndices.clear();
        _openIndices.add(index);
      } else {
        _openIndices.remove(index);
      }
    });

    component.expansionCallback?.call(index, willBeOpen);
  }

  /// Creates a default chevron component for the expansion panel.
  static Component _defaultChevron(bool isExpanded) {
    return Icon(
      LucideIcons.icon_chevron_down,
      size: 20,
      classes:
          'naki-expansion-panel__chevron${isExpanded ? " is-expanded" : ""}',
    );
  }

  @override
  Component build(BuildContext context) {
    final panels = <Component>[];

    const baseClass = 'naki-expansion-panel-list';
    final effectiveClasses = joinClasses([?component.classes, baseClass]);

    final effectiveStyles = {
      Tokens.current.hoverColor.name: component.hoverColor?.value ?? 'initial',
      'background-color': ?component.color?.value,
      ...?component.borderRadius?.props,
      ...?component.border?.props,
      ...?component.margin?.mProps,
      if (component.elevation != null && component.elevation! > 0)
        'box-shadow':
            '0 ${component.elevation! * 2}px ${component.elevation! * 4}px '
            'var(${Tokens.current.shadowColor.name}, ${Tokens.current.shadowColor.value})',
    };

    for (int i = 0; i < component.children.length; i++) {
      final panel = component.children[i];
      final isExpanded = _openIndices.contains(i);
      final headerId = '${_id}_header_$i';
      final bodyId = '${_id}_body_$i';

      final header = panel.headerBuilder != null
          ? panel.headerBuilder!(context, isExpanded)
          : panel.header!;

      final trailing = panel.trailing ?? _defaultChevron(isExpanded);

      final panelClasses = joinClasses([
        ?panel.classes,
        if (isExpanded) 'is-expanded',
        'naki-expansion-panel',
      ]);

      panels.add(
        div(
          classes: panelClasses,
          styles: Styles(
            raw: {
              'background-color': ?panel.backgroundColor?.value,
              'border-bottom-color': ?component.dividerColor?.value,
              ...?panel.gradient?.props,
            },
          ),
          [
            // Header button
            .wrapElement(
              child: Button(
                id: headerId,
                classes: 'naki-expansion-panel__header',
                child: Row(
                  classes: 'naki-expansion-panel__header-content',
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Row(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ?panel.leading,
                          DefaultTextStyle(
                            child: header,
                            style: const TextStyle(truncate: true),
                          ),
                        ],
                      ),
                    ),

                    trailing,
                  ],
                ),
                hoverColor: panel.backgroundColor ?? Colors.transparent,
                disabled: panel.disabled,
                attributes: {
                  'aria-expanded': '$isExpanded',
                  'aria-controls': bodyId,
                },
                onTap: panel.canTapOnHeader && !panel.disabled
                    ? () => _handleToggle(i)
                    : null,
              ),
              styles: Styles(raw: panel.headerPadding?.pProps),
            ),

            // Collapsible body
            div(
              id: bodyId,
              classes: 'naki-expansion-panel__body-wrapper',
              attributes: {
                'role': 'region',
                'aria-labelledby': headerId,
                'aria-hidden': '${!isExpanded}',
              },
              [
                div(classes: 'naki-expansion-panel__body-content', [
                  div(
                    classes: 'naki-expansion-panel__body-inner',
                    styles: Styles(raw: panel.bodyPadding?.pProps),
                    [panel.body],
                  ),
                ]),
              ],
            ),
          ],
        ),
      );
    }

    return .element(
      key: component.key,
      tag: 'naki-expansion-panel',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: panels,
    );
  }
}
