part of 'index.dart';

/// {@template NakiStreamBuilder}
/// A Naki component that builds a component tree based on the
/// asynchronous state of a `Stream`.
///
/// ### Example
/// ```dart
/// NakiStreamBuilder<int>(
///   stream: counterStream,
///   builder: (context, data, hasError, loading) {
///     if (loading) return NakiText('Connecting...');
///     if (hasError) return NakiText('Stream Error');
///     return NakiText('Count: $data');
///   },
/// )
/// ```
/// {@endtemplate}
class NakiStreamBuilder<T> extends StatefulComponent {
  /// Stream to listen to.
  final Stream<T> stream;

  /// Initial data to display before any stream events are received.
  final T? initialData;

  /// Builder function used to construct the component tree
  /// based on snapshot state.
  final SnapshotBuilder<T> builder;

  /// Called with the error and stack trace when [stream] emits an error.
  final SnapshotErrorCallback? onError;

  /// {@macro NakiStreamBuilder}
  const NakiStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.onError,
  });

  @override
  State<NakiStreamBuilder<T>> createState() => _NakiStreamBuilderState<T>();
}

class _NakiStreamBuilderState<T> extends State<NakiStreamBuilder<T>> {
  T? _snapshotData;
  Stream<T>? _stream;
  StreamSubscription<T>? _subscription;

  bool hasError = false;
  bool hasData = false;
  bool loading = true;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  void initState() {
    super.initState();

    _snapshotData = component.initialData;
    _stream = component.stream;

    hasData = _snapshotData != null;
    loading = true;

    _startStream();
  }

  @override
  void didUpdateComponent(
    NakiStreamBuilder<T> oldComponent,
  ) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.stream != component.stream) {
      _subscription?.cancel();

      _snapshotData = component.initialData;
      _stream = component.stream;

      hasError = false;
      hasData = _snapshotData != null;
      loading = true;

      _startStream();
    }
  }

  /// Subscribes synchronously (client only) so no events are missed and no
  /// subscription can outlive [dispose] or be created twice.
  void _startStream() {
    _subscription?.cancel();
    _subscription = null;

    // streams are not consumed during server rendering
    if (!kIsWeb) return;

    _subscription = _stream?.listen(
      (data) {
        setState(() {
          _snapshotData = data;
          hasData = true;
          hasError = false;
          loading = false;
        });
      },
      onError: (Object error, StackTrace stack) {
        setState(() {
          _snapshotData = null;
          hasError = true;
          hasData = false;
          loading = false;
        });
        component.onError?.call(error, stack);
      },
      onDone: () {
        setState(() => loading = false);
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    return component.builder(
      context,
      _snapshotData,
      hasError,
      loading,
    );
  }
}
