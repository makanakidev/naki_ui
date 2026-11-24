part of 'index.dart';

/// Invokes [close] only when the barrier itself
/// (not overlay content) was clicked, so content clicks keep
/// bubbling for outside-click handlers.
void _onBarrierClick(Event event, VoidCallback close) {
  if (identical(event.target, event.currentTarget)) close();
}

/// Gets the [OverlayHost] from the [context].
OverlayHostState _hostOf(BuildContext context, String caller) {
  final host = OverlayHost.maybeOf(context);
  assert(host != null, '$caller needs a NakiApp or Scaffold above context');
  return host!;
}

/// Finds the active [ScaffoldState] below [context] when
/// [context] sits above a [Scaffold] (for example, a
/// [NakiPageRoute] builder context or a scoped [Navigator] wrapper).
ScaffoldState? _descendantScaffoldOf(
  BuildContext context, {
  bool stopAtNavigator = false,
}) {
  ScaffoldState? found;

  void visit(jaspr.Element element) {
    if (found != null) return;

    final key = element.component.key;

    if (key case final ValueKey<NakiRoute<dynamic>> routeKey
        when !routeKey.value.isCurrent) {
      return;
    }

    if (key case final ValueKey<NavigatorState> navKey
        when navKey.value.currentRoute != null) {
      return;
    }

    if (element is StatefulElement && element.state is ScaffoldState) {
      found = element.state as ScaffoldState;
      return;
    }

    if (stopAtNavigator &&
        element is StatefulElement &&
        element.state is NavigatorState) {
      return;
    }

    element.visitChildElements(visit);
  }

  context.visitChildElements(visit);
  return found;
}

ScaffoldState? _resolveScaffold(BuildContext context) {
  final ancestor = Scaffold.maybeOf(context);
  if (ancestor == null) return _descendantScaffoldOf(context);

  final route = NakiRoute.maybeOf(context);
  if (route != null && NakiRoute.maybeOf(ancestor.context) != route) {
    return _descendantScaffoldOf(context, stopAtNavigator: true) ?? ancestor;
  }

  return ancestor;
}

/// Shows [snackbar] above the page, closing any snackbar already open.
///
/// ### Example
/// ```dart
/// showSnackbar(context, Snackbar(content: NakiText('Item saved')));
/// ```
void showSnackbar(BuildContext context, Snackbar snackbar) {
  if (!kIsWeb) return;

  final controller = OverlayController(isOpen: true);
  SnackbarRegistry.onOpen(controller);

  final scaffold = _resolveScaffold(context);
  _hostOf(context, 'showSnackbar').show(
    scaffold == null
        ? snackbar
        : ScaffoldScope(state: scaffold, child: snackbar),
    controller: controller,
    exitDuration: snackbar.duration,
  );
}

/// Closes the snackbar that is currently open, if any.
void closeSnackbar() => SnackbarRegistry.closeCurrent();

/// Shows a [Dialog] configured with the given properties
/// and completes with the result passed to [Navigator.pop]
/// (or [closeDialog]), or `null` when it is dismissed another way.
///
/// Use [builder] for custom body content or pass [title] and [subtitle].
/// Use [actions] to build action buttons with the dialog's own
/// [BuildContext] so they can call [Navigator.pop] (or [closeDialog]).
///
/// For full control over the root dialog component
/// (for example wrapping or providing a custom dialog subtree
/// directly), use [showCustomDialog].
///
/// ### Example
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   title: 'Delete item?',
///   barrierDismissible: true,
///   actions: (context) => [
///     Button.text('Cancel', onTap: () => Navigator.pop(context, false)),
///     Button.text('Delete', onTap: () => Navigator.pop(context, true)),
///   ],
/// );
/// ```
Future<T?> showDialog<T>({
  required BuildContext context,
  Component Function(BuildContext context)? builder,
  String? title,
  String? subtitle,
  List<Component> Function(BuildContext context)? actions,
  DialogPosition position = DialogPosition.center,
  bool barrierDismissible = false,
  bool glass = false,
  String? semanticLabel,
  SizeConstraints? sizeConstraints,
  Color? backgroundColor,
  Color? barrierColor,
  Gradient? gradient,
  BorderRadiusData? borderRadius,
  EdgeInsets? padding,
  String? classes,
  VoidCallback? onClose,
}) => _showWithResult<T>(
  context,
  'showDialog',
  Builder(
    builder: (context) => Dialog(
      position: position,
      barrierDismissible: barrierDismissible,
      glass: glass,
      title: title,
      semanticLabel: semanticLabel,
      subtitle: subtitle,
      actions: actions?.call(context),
      content: builder?.call(context),
      sizeConstraints: sizeConstraints,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      gradient: gradient,
      borderRadius: borderRadius,
      padding: padding,
      classes: classes,
      onClose: onClose,
    ),
  ),
);

/// Shows the custom dialog component [builder] returns and
/// completes with the result passed to [Navigator.pop] (or
/// [closeDialog]), or `null` when it is dismissed another way.
///
/// Leave [Dialog.controller] out when returning a [Dialog]: it is
/// controlled automatically and removed once it closes.
///
/// ### Example
/// ```dart
/// final accepted = await showCustomDialog<bool>(
///   context: context,
///   builder: (context) => Card(
///     padding: const EdgeInsets.all(Dim.px(24)),
///     child: Column(
///       mainAxisSize: MainAxisSize.min,
///       spacing: 12,
///       children: [
///         const Heading('Notice', level: 3),
///         const NakiText('Custom overlay content'),
///         Button.text('Accept', onTap: () => Navigator.pop(context, true)),
///       ],
///     ),
///   ),
/// );
/// ```
Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Component Function(BuildContext context) builder,
}) =>
    _showWithResult<T>(context, 'showCustomDialog', Builder(builder: builder));

/// Closes the dialog [context] belongs to, completing its [showDialog] or
/// [showCustomDialog] future with [result].
///
/// Use [Navigator.pop] unless you want a dialog-specific helper.
void closeDialog<T>(BuildContext context, [T? result]) => _closeWithResult(
  context,
  result,
  'closeDialog',
  'showDialog or showCustomDialog',
);

/// Shows a modal [BottomSheet] holding the content [builder]
/// returns and completes with the result passed to [Navigator.pop]
/// (or [closeModalBottomSheet]), or `null` when it is dismissed
/// another way.
///
/// The other arguments are passed to the [BottomSheet].
///
/// ### Example
/// ```dart
/// final choice = await showModalBottomSheet<String>(
///   context: context,
///   builder: (context) => Column(
///     children: [
///       Button.text('Share', onTap: () => Navigator.pop(context, 'share')),
///       Button.text('Delete', onTap: () => Navigator.pop(context, 'delete')),
///     ],
///   ),
/// );
/// ```
Future<T?> showModalBottomSheet<T>({
  required BuildContext context,
  required Component Function(BuildContext context) builder,
  bool showHandle = true,
  bool isDismissible = true,
  Dim? maxHeight,
  Dim? maxWidth,
  Color? backgroundColor,
  Gradient? gradient,
  BorderRadiusData? borderRadius,
  String? classes,
  String semanticLabel = 'Bottom sheet',
}) => _showWithResult<T>(
  context,
  'showModalBottomSheet',
  Builder(
    builder: (context) => BottomSheet(
      showHandle: showHandle,
      barrierDismissible: isDismissible,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      backgroundColor: backgroundColor,
      gradient: gradient,
      borderRadius: borderRadius,
      classes: classes,
      semanticLabel: semanticLabel,
      child: builder(context),
    ),
  ),
);

/// Closes the bottom sheet [context] belongs to, completing its
/// [showModalBottomSheet] future with [result].
///
/// Use [Navigator.pop] unless you want a sheet-specific helper.
void closeModalBottomSheet<T>(BuildContext context, [T? result]) =>
    _closeWithResult(
      context,
      result,
      'closeModalBottomSheet',
      'showModalBottomSheet',
    );

/// Shows a modal dialog containing a calendar date picker and completes
/// with the selected [DateTime], or `null` if cancelled or dismissed.
///
/// The other arguments configure bounds, title, and dialog styling.
///
/// ### Example
/// ```dart
/// final date = await showDatePicker(
///   context: context,
///   initialDate: DateTime.now(),
///   firstDate: DateTime(2000),
///   lastDate: DateTime(2100),
/// );
/// ```
Future<DateTime?> showDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select date',
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  String semanticLabel = 'Date picker',
}) {
  final minDate =
      firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 10));
  final maxDate = lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));
  assert(
    !minDate.isAfter(maxDate),
    'firstDate ($minDate) must not be after lastDate ($maxDate).',
  );

  return _showWithResult<DateTime>(
    context,
    'showDatePicker',
    NakiDatePickerDialog(
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
      isRange: false,
      title: title,
      barrierDismissible: barrierDismissible,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      semanticLabel: semanticLabel,
    ),
  );
}

/// Closes the date picker [context] belongs to, completing its
/// [showDatePicker] future with [result].
///
/// Use [Navigator.pop] unless you want a picker-specific helper.
void closeDatePicker(BuildContext context, [DateTime? result]) =>
    _closeWithResult(context, result, 'closeDatePicker', 'showDatePicker');

/// Shows a modal dialog containing a calendar date range picker
/// and completes with the selected dates in chronological order,
/// or `null` if cancelled or dismissed.
///
/// ### Example
/// ```dart
/// final range = await showDateRangePicker(
///   context: context,
///   firstDate: DateTime(2020),
///   lastDate: DateTime(2030),
/// );
/// ```
Future<List<DateTime>?> showDateRangePicker({
  required BuildContext context,
  List<DateTime>? initialDateRange,
  DateTime? firstDate,
  DateTime? lastDate,
  String title = 'Select date range',
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  String semanticLabel = 'Date range picker',
}) {
  final minDate =
      firstDate ?? DateTime.now().subtract(const Duration(days: 365 * 10));
  final maxDate = lastDate ?? DateTime.now().add(const Duration(days: 365 * 5));
  assert(
    !minDate.isAfter(maxDate),
    'firstDate ($minDate) must not be after lastDate ($maxDate).',
  );

  return _showWithResult<List<DateTime>>(
    context,
    'showDateRangePicker',
    NakiDatePickerDialog(
      initialDateRange: initialDateRange,
      firstDate: minDate,
      lastDate: maxDate,
      isRange: true,
      title: title,
      barrierDismissible: barrierDismissible,
      backgroundColor: backgroundColor,
      barrierColor: barrierColor,
      semanticLabel: semanticLabel,
    ),
  );
}

/// Closes the date range picker [context] belongs to, completing its
/// [showDateRangePicker] future with [result].
///
/// Use [Navigator.pop] unless you want a picker-specific helper.
void closeDateRangePicker(BuildContext context, [List<DateTime>? result]) =>
    _closeWithResult(
      context,
      result,
      'closeDateRangePicker',
      'showDateRangePicker',
    );

/// Shows a modal dialog containing a time picker and completes with the
/// selected [DateTime] (using [initialTime] or today's date for year,
/// month, and day), or `null` if cancelled or dismissed.
///
/// ### Example
/// ```dart
/// final time = await showTimePicker(
///   context: context,
///   initialTime: DateTime.now(),
/// );
/// ```
Future<DateTime?> showTimePicker({
  required BuildContext context,
  DateTime? initialTime,
  String title = 'Select time',
  bool barrierDismissible = true,
  Color? backgroundColor,
  Color? barrierColor,
  String semanticLabel = 'Time picker',
}) => _showWithResult<DateTime>(
  context,
  'showTimePicker',
  NakiTimePickerDialog(
    initialTime: initialTime ?? DateTime.now(),
    title: title,
    barrierDismissible: barrierDismissible,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    semanticLabel: semanticLabel,
  ),
);

/// Closes the time picker [context] belongs to, completing its
/// [showTimePicker] future with [result].
///
/// Use [Navigator.pop] unless you want a picker-specific helper.
void closeTimePicker(BuildContext context, [DateTime? result]) =>
    _closeWithResult(context, result, 'closeTimePicker', 'showTimePicker');

/// Mounts [overlay] in the host and completes with the value
/// it closed with.
Future<T?> _showWithResult<T>(
  BuildContext context,
  String caller,
  Component overlay,
) {
  final completer = Completer<T?>();
  if (!kIsWeb) return completer.future;

  final controller = OverlayResultController<T>();

  _hostOf(context, caller).show(
    overlay,
    controller: controller,
    exitDuration: const Duration(milliseconds: 250),
    onClosed: () => completer.complete(controller.result),
  );

  return completer.future;
}

void _closeWithResult(
  BuildContext context,
  Object? result,
  String caller,
  String opener,
) {
  final controller = OverlayEntryScope.maybeOf(context);
  assert(
    controller is OverlayResultController,
    '$caller needs the context of an overlay shown with $opener',
  );

  if (controller is OverlayResultController) {
    controller.closeWith(result);
  } else {
    controller?.close();
  }
}
