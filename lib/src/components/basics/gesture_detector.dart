part of 'index.dart';

/// {@template GestureDetector}
/// A component that detects and handles gestures on its child.
///
/// Example:
/// ```dart
/// GestureDetector(
///   gestures: GestureRecognizer(
///     onClick: (event) => print('Tapped!'),
///   ),
///   child: const NakiText('Click me'),
/// )
/// ```
/// {@endtemplate}
class GestureDetector extends StatelessComponent {
  /// Child component that receives the gestures.
  final Component child;

  /// Set of gestures to recognize.
  final Gestures gestures;

  /// Additional CSS classes applied to the gesture detector.
  final String? classes;

  /// Accessible name for an interactive gesture surface.
  final String? semanticLabel;

  /// ARIA role for the gesture surface. Defaults to `button` when clickable.
  final String? semanticRole;

  /// Additional attributes applied to the gesture surface.
  final Map<String, String>? attributes;

  /// {@macro GestureDetector}
  const GestureDetector({
    super.key,
    required this.child,
    required this.gestures,
    this.classes,
    this.semanticLabel,
    this.semanticRole,
    this.attributes,
  });

  @override
  Component build(BuildContext context) {
    const baseClass = 'naki-gesture-detector';
    final effectiveClasses = joinClasses([?classes, baseClass]);

    final isClickable = gestures.onClick != null;
    final handlers = {...gestures.toMap};
    final existingKeyDown = handlers['keydown'];

    // enable keyboard clicks for web accessibility
    if (isClickable) {
      handlers['keydown'] = (event) {
        existingKeyDown?.call(event);
        final key = (event as KeyboardEvent).key;
        if (key == 'Enter' || key == ' ') {
          event.preventDefault();
          gestures.onClick!.call(event);
        }
      };
    }

    return .element(
      tag: 'naki-gesturedetector',
      classes: effectiveClasses,
      attributes: {
        if (isClickable) ...{'role': semanticRole ?? 'button', 'tabindex': '0'},
        'aria-label': ?semanticLabel,
        ...?attributes,
      },
      events: handlers,
      styles: isClickable ? const Styles(raw: {'cursor': 'pointer'}) : null,
      children: [child],
    );
  }
}
