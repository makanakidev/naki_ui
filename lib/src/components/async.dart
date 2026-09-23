import 'dart:async';
import 'package:jaspr/jaspr.dart';

import '../utilities/helpers.dart' show onComponentRendered;

/// Signature for [NakiFutureBuilder] and [NakiStreamBuilder] builder functions.
///
/// They are provided with the current [context], the latest [data] from the
/// asynchronous computation (or null if there is no data), a boolean indicating
/// whether an [hasError] has occurred, and a boolean indicating whether the
/// computation is currently [loading].
typedef SnapshotBuilder<T> =
    Component Function(
      BuildContext context,
      T? data,
      bool hasError,
      bool loading,
    );

/// {@template NakiFutureBuilder}
/// A Naki component that builds a component tree based on the
/// asynchronous state of a `Future`.
///
/// ### Example
/// ```dart
/// NakiFutureBuilder<String>(
///   future: fetchUsername(),
///   builder: (context, data, hasError, loading) {
///     if (loading) return NakiText('Loading...');
///     if (hasError) return NakiText('Failed to load');
///     return NakiText('User: $data');
///   },
/// )
/// ```
/// {@endtemplate}
class NakiFutureBuilder<T> extends StatefulComponent {
  /// Future to listen to.
  final Future<T> future;

  /// Initial data to display before the future completes.
  final T? initialData;

  /// Builder function used to construct the component tree
  /// based on snapshot state.
  final SnapshotBuilder<T> builder;

  /// {@macro NakiFutureBuilder}
  const NakiFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
  });

  @override
  State<NakiFutureBuilder<T>> createState() => _NakiFutureBuilderState<T>();
}

class _NakiFutureBuilderState<T> extends State<NakiFutureBuilder<T>> {
  T? _snapshotData;
  Future<T>? _future;
  int _generation = 0;

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
    _future = component.future;

    hasData = _snapshotData != null;
    loading = true;

    final generation = ++_generation;
    onComponentRendered(() => _fetch(generation, _future!));
  }

  @override
  void didUpdateComponent(
    NakiFutureBuilder<T> oldComponent,
  ) {
    super.didUpdateComponent(oldComponent);

    if (oldComponent.future != component.future) {
      _snapshotData = component.initialData;
      _future = component.future;

      hasError = false;
      hasData = _snapshotData != null;
      loading = true;

      final generation = ++_generation;
      onComponentRendered(
        () => _fetch(generation, _future!),
      );
    }
  }

  Future<void> _fetch(
    int generation,
    Future<T> future,
  ) async {
    try {
      final data = await future;
      if (generation != _generation) return;

      _snapshotData = data;
      hasData = _snapshotData != null;
      hasError = false;
    } catch (_) {
      if (generation != _generation) return;

      _snapshotData = null;
      hasError = true;
      hasData = false;
    } finally {
      if (generation == _generation) setState(() => loading = false);
    }
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

  /// {@macro NakiStreamBuilder}
  const NakiStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
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

    onComponentRendered(_startStream);
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

      onComponentRendered(_startStream);
    }
  }

  void _startStream() {
    _subscription = _stream?.listen(
      (data) {
        setState(() {
          _snapshotData = data;
          hasData = true;
          hasError = false;
          loading = false;
        });
      },
      onError: (_) {
        setState(() {
          _snapshotData = null;
          hasError = true;
          hasData = false;
          loading = false;
        });
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
