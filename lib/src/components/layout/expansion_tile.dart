part of 'index.dart';

/// {@template ExpansionTile}
/// A Naki component that renders an expandable card with a header
/// and collapsible content.
///
/// ### Example
/// ```dart
/// ExpansionTile(
///   title: const NakiText('Account Details'),
///   leading: const Icon(MaterialIcons.icon_round_person),
///   children: const [
///     NakiText('Username: @johndoe'),
///     NakiText('Email: user@example.com'),
///   ],
/// )
/// ```
/// {@endtemplate}
class ExpansionTile extends StatefulComponent {
  /// The primary content of the tile header.
  final Component title;

  /// Additional subtitle displayed below [title].
  final Component? subtitle;

  /// Leading component displayed before the title (e.g. an [Icon]).
  final Component? leading;

  /// Trailing component displayed after the title (defaults to a
  /// rotating chevron icon).
  final Component? trailing;

  /// The components that are displayed when the tile expands.
  final List<Component> children;

  /// Callback invoked when the expansion state changes.
  final ValueChanged<bool>? onExpansionChanged;

  /// Whether the tile should be initially expanded.
  final bool initiallyExpanded;

  /// Background color of the tile.
  final Color? backgroundColor;

  /// Color applied to [children] background.
  final Color? contentBackgroundColor;

  /// Background color of the tile when collapsed.
  final Color? collapsedBackgroundColor;

  /// Background gradient of the tile.
  ///
  /// ### Example
  /// ```dart
  /// ExpansionTile(
  ///   title: NakiText('Gradient ExpansionTile'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.blue, Colors.teal]),
  ///   children: [NakiText('Expanded content')],
  /// )
  /// ```
  final Gradient? gradient;

  /// Background gradient of the tile when collapsed.
  final Gradient? collapsedGradient;

  /// Color of the title and leading icon when hovered.
  final Color? hoverColor;

  /// Shape of the tile.
  final BorderData? shape;

  /// Shape of the tile when collapsed.
  final BorderData? collapsedShape;

  /// Radius of the tile.
  final BorderRadiusData? radius;

  /// Padding applied to tile header.
  final EdgeInsets? tilePadding;

  /// Padding applied to [children].
  final EdgeInsets? contentPadding;

  /// Additional CSS classes applied to the expansion tile.
  final String? classes;

  /// {@macro ExpansionTile}
  const ExpansionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.children = const [],
    this.initiallyExpanded = false,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.contentBackgroundColor,
    this.gradient,
    this.collapsedGradient,
    this.onExpansionChanged,
    this.hoverColor,
    this.shape,
    this.collapsedShape,
    this.radius,
    this.tilePadding,
    this.contentPadding,
    this.classes,
  });

  @override
  State<ExpansionTile> createState() => _ExpansionTileState();

  static List<StyleRule> get styles => LayoutStyles.expansionTile;
}

class _ExpansionTileState extends State<ExpansionTile> {
  late bool _isExpanded;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _isExpanded = component.initiallyExpanded;
  }

  @override
  void didUpdateComponent(ExpansionTile oldComponent) {
    super.didUpdateComponent(oldComponent);
    if (oldComponent.initiallyExpanded != component.initiallyExpanded) {
      _isExpanded = component.initiallyExpanded;
    }
  }

  /// Toggles expansion state of the tile.
  void _toggle() {
    final next = !_isExpanded;
    setState(() => _isExpanded = next);
    component.onExpansionChanged?.call(next);
  }

  @override
  Component build(BuildContext context) {
    final activeBg =
        (!_isExpanded
            ? component.collapsedBackgroundColor
            : component.backgroundColor) ??
        component.backgroundColor;

    final activeGradient =
        (!_isExpanded ? component.collapsedGradient : component.gradient) ??
        component.gradient;

    final activeShape =
        (!_isExpanded ? component.collapsedShape : component.shape) ??
        component.shape;

    final effectiveClasses = joinClasses([
      ?component.classes,
      if (_isExpanded) 'is-expanded',
      'naki-expansion-tile',
    ]);

    final effectiveStyles = {
      'background-color': ?activeBg?.value,
      ...?component.radius?.props,
      ...?activeShape?.props,
      ...?activeGradient?.props,
    };

    final trailing =
        component.trailing ??
        _ExpansionPanelListState._defaultChevron(_isExpanded);

    return .element(
      key: component.key,
      tag: 'naki-expansion-tile',
      classes: effectiveClasses,
      styles: Styles(raw: effectiveStyles),
      children: [
        // Header
        Button(
          classes: 'naki-expansion-panel__header',
          attributes: {'aria-expanded': _isExpanded ? 'true' : 'false'},
          hoverColor: component.hoverColor,
          padding: component.tilePadding,
          child: Row(
            classes: 'naki-expansion-panel__header-content',
            spacing: 12,
            crossAxisAlignment: component.subtitle != null
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    ?component.leading,

                    DefaultTextStyle(
                      style: const TextStyle(truncate: true),
                      child: Column(
                        spacing: 2,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [component.title, ?component.subtitle],
                      ),
                    ),
                  ],
                ),
              ),

              trailing,
            ],
          ),
          onTap: _toggle,
        ),

        // Collapsible body
        div(
          classes: 'naki-expansion-panel__body-wrapper',
          attributes: {
            'role': 'region',
            if (_isExpanded) 'aria-expanded': 'true',
          },
          [
            div(classes: 'naki-expansion-panel__body-content', [
              div(
                classes: 'naki-expansion-panel__body-inner',
                styles: Styles(
                  raw: {
                    ...?component.contentPadding?.pProps,
                    'background-color':
                        ?component.contentBackgroundColor?.value,
                  },
                ),
                component.children,
              ),
            ]),
          ],
        ),
      ],
    );
  }
}
