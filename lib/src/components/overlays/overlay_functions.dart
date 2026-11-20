part of 'index.dart';

/// Invokes [close] only when the barrier itself (not overlay content) was
/// clicked, so content clicks keep bubbling for outside-click handlers.
void _onBarrierClick(Event event, VoidCallback close) {
  if (identical(event.target, event.currentTarget)) close();
}

/// Gets the [OverlayHost] from the [context].
OverlayHostState _hostOf(BuildContext context, String caller) {
  final host = OverlayHost.maybeOf(context);
  assert(host != null, '$caller needs a NakiApp or Scaffold above context');
  return host!;
}

/// Shows [snackbar] above the page, closing any snackbar already open.
///
/// ### Example
/// ```dart
/// showSnackbar(context, Snackbar(content: NakiText('Item saved')));
/// ```
void showSnackbar(BuildContext context, Snackbar snackbar) {
  if (!kIsWeb) return;

  closeSnackbar();

  // The host may sit above the Scaffold (NakiApp's), so hand the snackbar
  // the caller's Scaffold: it offsets itself past the app bar and navbar.
  final scaffold = Scaffold.maybeOf(context);

  _hostOf(context, 'showSnackbar').show(
    scaffold == null
        ? snackbar
        : ScaffoldScope(state: scaffold, child: snackbar),
    controller: OverlayController(isOpen: true),
    exitDuration: snackbar.duration,
  );
}

/// Closes the snackbar that is currently open, if any.
void closeSnackbar() => SnackbarRegistry.closeCurrent();

/// Shows the dialog [builder] returns and completes with the result passed
/// to [closeDialog], or `null` when it is dismissed another way.
///
/// Leave [Dialog.controller] out: the dialog is controlled automatically
/// and removed once it closes.
///
/// ### Example
/// ```dart
/// final confirmed = await showDialog<bool>(
///   context: context,
///   builder: (context) => Dialog(
///     title: 'Delete item?',
///     barrierDismissible: true,
///     actions: [
///       Button.text('Cancel', onTap: () => closeDialog(context, false)),
///       Button.text('Delete', onTap: () => closeDialog(context, true)),
///     ],
///   ),
/// );
/// ```
Future<T?> showDialog<T>({
  required BuildContext context,
  required Component Function(BuildContext context) builder,
}) => _showWithResult<T>(context, 'showDialog', Builder(builder: builder));

/// Closes the dialog [context] belongs to, completing its [showDialog]
/// future with [result].
void closeDialog<T>(BuildContext context, [T? result]) =>
    _closeWithResult(context, result, 'closeDialog', 'showDialog');

/// Shows a modal [BottomSheet] holding the content [builder] returns and
/// completes with the result passed to [closeModalBottomSheet], or `null`
/// when it is dismissed another way.
///
/// The other arguments are passed to the [BottomSheet].
///
/// ### Example
/// ```dart
/// final choice = await showModalBottomSheet<String>(
///   context: context,
///   builder: (context) => Column(
///     children: [
///       Button.text('Share', onTap: () => closeModalBottomSheet(context, 'share')),
///       Button.text('Delete', onTap: () => closeModalBottomSheet(context, 'delete')),
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
void closeModalBottomSheet<T>(BuildContext context, [T? result]) =>
    _closeWithResult(
      context,
      result,
      'closeModalBottomSheet',
      'showModalBottomSheet',
    );

/// Mounts [overlay] in the host and completes with the value it closed with.
Future<T?> _showWithResult<T>(
  BuildContext context,
  String caller,
  Component overlay,
) {
  final completer = Completer<T?>();
  if (!kIsWeb) return completer.future;

  final controller = _ResultController<T>();

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
    controller is _ResultController,
    '$caller needs the context of an overlay shown with $opener',
  );

  if (controller is _ResultController) {
    controller.closeWith(result);
  } else {
    controller?.close();
  }
}

/// An [OverlayController] that keeps the value its overlay closed with.
class _ResultController<T> extends OverlayController {
  _ResultController() : super(isOpen: true);

  /// The value [closeWith] closed the overlay with.
  T? result;

  /// Closes the overlay with [value], kept when it is a [T].
  void closeWith(Object? value) {
    if (value is T) result = value;
    close();
  }
}
