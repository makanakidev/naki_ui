part of 'index.dart';

/// {@template naki_ui.overlay_region}
/// A component that acts as a DOM portal container where all active [OverlayScope]
/// child components (modals, dialogs, drawers, tooltips) are rendered.
///
/// > **Note:** `NakiApp` and `Scaffold` automatically include an `OverlayRegion`.
/// > You only need to declare this manually if you are building a custom
/// > application shell without `NakiApp` or `Scaffold`.
/// {@endtemplate}
class OverlayRegion extends StatelessComponent {
  /// {@macro naki_ui.overlay_region}
  const OverlayRegion({super.key});

  @override
  Component build(BuildContext context) {
    return _OverlayScopeRegistry.notifier.rebuild((map) {
      return .fragment([
        for (final entry in map.entries)
          .wrapElement(key: ValueKey(entry.key), child: entry.value),
      ]);
    });
  }
}
