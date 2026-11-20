part of 'index.dart';

/// Signature for [ExpansionPanel] header builder.
typedef ExpansionPanelHeaderBuilder =
    Component Function(BuildContext context, bool isExpanded);

/// Signature for [ExpansionPanelList] expansion callback.
typedef ExpansionPanelCallback = void Function(int panelIndex, bool isExpanded);

/// {@template ExpansionPanel}
/// An item in an [ExpansionPanelList].
///
/// Holds the header and body components of a collapsible panel.
///
/// ### Example
/// ```dart
/// ExpansionPanel(
///   header: const NakiText('General Settings'),
///   body: const NakiText('Account preferences and details.'),
///   isExpanded: true,
/// )
/// ```
/// {@endtemplate}
class ExpansionPanel {
  /// The component that will be displayed in the header.
  final Component? header;

  /// Optional header builder function that constructs the header
  /// based on whether the panel is expanded.
  final ExpansionPanelHeaderBuilder? headerBuilder;

  /// The body of the expansion panel that is shown when the
  /// panel is expanded.
  final Component body;

  /// Whether the panel is expanded (for controlled mode).
  final bool isExpanded;

  /// Whether tapping on the header will expand or collapse the panel.
  final bool canTapOnHeader;

  /// Background color for this panel.
  final Color? backgroundColor;

  /// Background gradient for this panel.
  ///
  /// ### Example
  /// ```dart
  /// ExpansionPanel(
  ///   header: NakiText('Gradient Panel'),
  ///   body: NakiText('Panel content'),
  ///   gradient: Gradient()..applyLinear(colors: [Colors.purple, Colors.pink]),
  /// )
  /// ```
  final Gradient? gradient;

  /// Optional leading component in the header (e.g. an icon).
  final Component? leading;

  /// Optional trailing component in the header.
  ///
  /// If `null`, an animated rotating chevron is displayed.
  final Component? trailing;

  /// Whether this panel is disabled.
  final bool disabled;

  /// Custom padding for the header.
  final EdgeInsets? headerPadding;

  /// Custom padding for the body.
  final EdgeInsets? bodyPadding;

  /// Additional CSS classes applied to this panel.
  final String? classes;

  /// Value identifying this panel in an [ExpansionPanelList.radio].
  final dynamic value;

  /// {@macro ExpansionPanel}
  const ExpansionPanel({
    this.header,
    this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.canTapOnHeader = true,
    this.disabled = false,
    this.backgroundColor,
    this.gradient,
    this.leading,
    this.trailing,
    this.headerPadding,
    this.bodyPadding,
    this.classes,
    this.value,
  }) : assert(
         header != null || headerBuilder != null,
         'Either header or headerBuilder must be provided.',
       );

  /// Creates a radio expansion panel item with a unique [value].
  const ExpansionPanel.radio({
    required this.value,
    this.header,
    this.headerBuilder,
    required this.body,
    this.canTapOnHeader = true,
    this.disabled = false,
    this.backgroundColor,
    this.gradient,
    this.leading,
    this.trailing,
    this.headerPadding,
    this.bodyPadding,
    this.classes,
  }) : isExpanded = false,
       assert(
         header != null || headerBuilder != null,
         'Either header or headerBuilder must be provided.',
       );
}
