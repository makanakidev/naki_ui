import 'dart:async';
import 'package:jaspr/jaspr.dart';

part 'naki_future_builder.dart';
part 'naki_stream_builder.dart';

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

/// Signature for the optional error callbacks of [NakiFutureBuilder] and
/// [NakiStreamBuilder].
typedef SnapshotErrorCallback = void Function(Object error, StackTrace stack);
