part of 'index.dart';

/// {@template Table}
/// A component that displays rows, columns, borders, and custom
/// cell layouts in a tabular view.
///
/// Supports horizontal scrolling when content exceeds the table container,
/// with custom scrollbar styling via [scrollBarConfiguration].
///
/// ### Example
/// ```dart
/// Table(
///   scrollBarConfiguration: const ScrollBarConfiguration(
///     thumbColor: Color('#888888'),
///     trackColor: Color('#f0f0f0'),
///     height: 6,
///     radius: 3,
///   ),
///   headers: [NakiText('Name'), NakiText('Age')],
///   rows: [
///     TableRow(children: [NakiText('Alice'), NakiText('30')]),
///     TableRow(children: [NakiText('Bob'), NakiText('25')]),
///   ],
/// )
/// ```
/// {@endtemplate}
class Table extends StatelessComponent {
  /// Header cell components.
  /// This could be any component that can have styles applied to it.
  final List<Component> headers;

  /// The default alignment of header cells.
  final TableHeaderCellAlignment? headerAlignment;

  /// List of table rows.
  final List<TableRow> rows;

  /// Border configuration defining both the outer boundaries and interior
  /// cell dividers of the table.
  ///
  /// Controls:
  /// * Outer borders around the table container
  ///   ([TableBorder.top], [TableBorder.right], [TableBorder.bottom],
  ///   [TableBorder.left]).
  /// * Interior dividers between adjacent row and column cells
  ///   ([TableBorder.horizontalInside], [TableBorder.verticalInside]).
  /// * Corner rounding of the table container ([TableBorder.borderRadius]).
  ///
  /// ### Example
  /// ```dart
  /// Table(
  ///   border: TableBorder.all(
  ///     color: Colors.slate.shade300,
  ///     width: Dim.px(1),
  ///     borderRadius: BorderRadiusData.circular(Radius.px(8)),
  ///   ),
  ///   headers: [NakiText('Name'), NakiText('Role')],
  ///   rows: [
  ///     TableRow(children: [NakiText('Jane'), NakiText('Admin')]),
  ///   ],
  /// )
  /// ```
  final TableBorder? border;

  /// Column width behavior specifications per column index (0-indexed).
  ///
  /// Available column width options:
  /// * [FixedColumnWidth]: Sets a fixed size
  ///   (e.g. `FixedColumnWidth(Dim.px(150))`).
  /// * [FlexColumnWidth]: Automatically stretches to fill remaining table space.
  /// * [FractionColumnWidth]: Sizes the column as a fraction of the table
  ///   width (e.g. `FractionColumnWidth(0.3)` for 30%).
  /// * [IntrinsicColumnWidth]: Sizes the column to fit its widest content
  ///   (`max-content`).
  ///
  /// Any column index omitted from this map defaults to `auto`.
  ///
  /// ### Example
  /// ```dart
  /// Table(
  ///   columnWidths: {
  ///     0: FixedColumnWidth(Dim.px(80)),
  ///     1: FlexColumnWidth(),
  ///     2: FractionColumnWidth(0.25),
  ///   },
  ///   headers: [
  ///     NakiText('ID'),
  ///     NakiText('Description'),
  ///     NakiText('Status'),
  ///   ],
  ///   rows: [
  ///     TableRow(
  ///       children: [
  ///         NakiText('#1'),
  ///         NakiText('Setup Jaspr'),
  ///         NakiText('Done'),
  ///       ],
  ///     ),
  ///   ],
  /// )
  /// ```
  final Map<int, TableColumnWidth>? columnWidths;

  /// Scroll bar configuration for the table's scrollable container.
  /// When provided, renders styled scrollbars; when `null`, the scrollbar is hidden.
  final ScrollBarConfiguration? scrollBarConfiguration;

  /// Background color of header cells.
  final Color? headerBackgroundColor;

  /// Color applied to the horizontal border of header cells.
  final Color headerBorderColor;

  /// Background color of row cells when hovered.
  final Color? rowHoverColor;

  /// Title text displayed when the table has no rows.
  final String emptyStateTitle;

  /// Subtitle or descriptive text displayed below [emptyStateTitle]
  /// when the table has no rows.
  final String emptyStateSubtitle;

  /// Custom component displayed when the table has no rows, overriding
  /// [emptyStateTitle] and [emptyStateSubtitle].
  final Component? emptyStateContent;

  /// Additional CSS classes applied to the table component.
  final String? classes;

  /// {@macro Table}
  const Table({
    super.key,
    required this.headers,
    this.rows = const [],
    this.headerBorderColor = Colors.transparent,
    this.emptyStateTitle = 'No data available',
    this.emptyStateSubtitle = '',
    this.border,
    this.columnWidths,
    this.headerAlignment,
    this.headerBackgroundColor,
    this.scrollBarConfiguration,
    this.rowHoverColor,
    this.classes,
    this.emptyStateContent,
  }) : assert(headers.length > 0, 'Table headers cannot be empty');

  @override
  Component build(BuildContext context) {
    final _id = nakiDomId(context, 'table');

    final List<th> headCells = [];
    final List<tr> bodyRows = [];
    final List<col> colGroup = [];

    Component emptyState =
        emptyStateContent ??
        Column(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Heading(emptyStateTitle, level: 3),
            if (emptyStateSubtitle.isNotEmpty) SubHeading(emptyStateSubtitle),
          ],
        );

    emptyState = .wrapElement(classes: 'naki-table__empty', child: emptyState);

    emptyState = tr([
      td(colspan: min(headers.length, 7), id: 'no-data', [emptyState]),
    ]);

    // Column widths
    if (columnWidths != null && columnWidths!.isNotEmpty) {
      final maxColIndex = columnWidths!.keys.fold(
        0,
        (max, k) => k > max ? k : max,
      );

      for (int i = 0; i <= maxColIndex; i++) {
        final width = columnWidths!.containsKey(i)
            ? columnWidths![i]!.cssWidth
            : null;

        colGroup.add(col(styles: Styles(raw: {'width': ?width})));
      }
    }

    // Header
    if (headers.isNotEmpty) {
      for (int i = 0; i < headers.length; i++) {
        final alignment = headerAlignment?.name;
        final border =
            '1px solid var(${Tokens.current.tableHeaderBorderColor})';

        headCells.add(
          th(
            styles: Styles(
              raw: {
                'text-align': ?alignment,
                if (headerBorderColor.value != 'transparent') ...{
                  if (i < headers.length - 1) 'border-right': border,
                  'border-bottom': border,
                },
              },
            ),
            [headers[i]],
          ),
        );
      }
    }

    // Rows
    if (rows.isNotEmpty) {
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
        final row = rows[rowIndex];
        final List<Component> rowCells = [];

        for (int i = 0; i < row.children.length; i++) {
          final cell = row.children[i];
          final alignment = row.alignment?.name;
          rowCells.add(
            td(
              styles: Styles(
                raw: {
                  'text-align': ?alignment,
                  if (border != null && i < row.children.length - 1)
                    'border-right': border!.verticalInside.value,
                  if (border != null && rowIndex < rows.length - 1)
                    'border-bottom': border!.horizontalInside.value,
                },
              ),
              [cell],
            ),
          );
        }

        bodyRows.add(
          tr(
            id: row.id,
            classes: row.classes,
            attributes: {
              if (row.onClick != null) ...{'role': 'button', 'tabindex': '0'},
              if (rowHoverColor != null) 'hvr': '',
            },
            events: row.onClick == null
                ? null
                : {
                    'click': (_) => row.onClick!.call(),
                    'keydown': (event) {
                      final key = (event as KeyboardEvent).key;
                      if (key == 'Enter' || key == ' ') {
                        event.preventDefault();
                        row.onClick!.call();
                      }
                    },
                  },
            rowCells,
          ),
        );
      }
    }

    const baseClass = 'naki-table';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final effectiveStyles = {
      Tokens.current.tableHeaderBg.name: ?headerBackgroundColor?.value,
      Tokens.current.tableRowHoverBg.name: ?rowHoverColor?.value,
      Tokens.current.tableHeaderBorderColor.name: headerBorderColor.value,
      ...?border?.props,
    };

    final Component child = .element(
      key: key,
      id: _id,
      tag: 'naki-table',
      styles: Styles(raw: effectiveStyles),
      children: [
        table(classes: effectiveClasses, [
          if (colGroup.isNotEmpty) colgroup(colGroup),
          if (headers.isNotEmpty) thead([tr(headCells)]),
          tbody(rows.isEmpty ? [emptyState] : bodyRows),
        ]),
      ],
    );

    return ScrollBarWrapper(
      selector: '#$_id',
      configuration: scrollBarConfiguration,
      child: child,
    );
  }

  @css
  static List<StyleRule> get styles =>
      NakiStyleRegistry.once('Table', [Rules.nakiTableRules]);
}
