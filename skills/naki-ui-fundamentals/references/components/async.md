# Async components

`NakiFutureBuilder` and `NakiStreamBuilder` use the shared `SnapshotBuilder<T>` callback shape:

```dart
Component Function(
  BuildContext context,
  T? data,
  bool hasError,
  bool loading,
)
```

The callback reports whether an error exists but does not expose an error object. Keep domain error details in the surrounding state when the UI must display them.

## NakiFutureBuilder

Store the future outside `build` so unrelated rebuilds do not restart the operation.

```dart
class _ProfileState extends State<Profile> {
  late Future<String> profileName = loadProfileName();

  @override
  Component build(BuildContext context) {
    return NakiFutureBuilder<String>(
      future: profileName,
      builder: (context, data, hasError, loading) {
        if (loading) return const Spinner(semanticLabel: 'Loading profile');
        if (hasError) return const Banner(
          severity: BannerType.error,
          primary: NakiText('Could not load the profile.'),
        );
        if (data == null || data.isEmpty) {
          return const NakiText('No profile found.');
        }
        return NakiText('Welcome, $data');
      },
    );
  }
}
```

Use `initialData` only when a meaningful value should be rendered before completion. Replace the stored future deliberately to retry, then call `setState`.

## NakiStreamBuilder

Create or receive the stream outside `build` and render loading, error, empty, and data states.

```dart
NakiStreamBuilder<int>(
  stream: unreadCountStream,
  initialData: 0,
  builder: (context, count, hasError, loading) {
    if (hasError) return const NakiText('Updates unavailable');
    if (loading && count == null) return const Spinner();
    return NakiText('${count ?? 0} unread messages');
  },
)
```

The component manages its stream subscription and replaces it when the `stream` instance changes. The producer remains responsible for closing controllers it owns.
