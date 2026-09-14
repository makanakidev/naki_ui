import 'dart:async';
import 'package:universal_web/web.dart';

/// Alias for [GestureRecognizer].
typedef Gestures = GestureRecognizer;

/// Alias for [GestureRecognizer].
typedef Events = GestureRecognizer;

/// {@template GestureRecognizer}
/// A helper class that simplifies binding DOM gestures and
/// user interaction events to Jaspr and Naki components.
///
/// Converts high-level interaction callbacks (taps, double clicks,
/// long presses, pointer events, keyboard input, drag & drop, and
/// focus events) into a clean DOM event listener map compatible with
/// Jaspr's `events` attribute.
///
/// ### Basic Usage Example
/// ```dart
/// final gestures = GestureRecognizer(
///   onClick: (e) => print('Element clicked!'),
///   onDoubleClick: (e) => print('Element double-clicked!'),
///   onLongPress: (e) => print('Element long-pressed!'),
/// );
///
/// return NakiGestureDetector(
///   gestures: gestures,
///   child: NakiText('Interactive Component'),
/// );
/// ```
///
/// ### Input & Keyboard Handling Example
/// ```dart
/// final inputGestures = InputEventRecognizer(
///   onInput: (e) => print('Input changed'),
///   onKeyDown: (e) {
///     if (e.key == 'Enter') print('Enter pressed');
///   },
///   onFocus: (e) => print('Field focused'),
///   onBlur: (e) => print('Field lost focus'),
/// );
/// ```
/// {@endtemplate}
class GestureRecognizer {
  /// Callback invoked when a standard click gesture occurs.
  final void Function(Event e)? onClick;

  /// Callback invoked when a double-click gesture occurs.
  final void Function(MouseEvent e)? onDoubleClick;

  /// Callback invoked when a pointer is held down for longer
  /// than [longPressDuration].
  final void Function(PointerEvent e)? onLongPress;

  /// Callback invoked when a pointer device
  /// (mouse, touch, pen) presses down.
  final void Function(PointerEvent e)? onPointerDown;

  /// Callback invoked when a pointer device is released.
  final void Function(PointerEvent e)? onPointerUp;

  /// Callback invoked when a pointer event is canceled
  /// (e.g. system interrupt).
  final void Function(PointerEvent e)? onPointerCancel;

  /// Callback invoked when a pointer enters the element boundaries.
  final void Function(PointerEvent e)? onPointerEnter;

  /// Callback invoked when a pointer leaves the element boundaries.
  final void Function(PointerEvent e)? onPointerLeave;

  /// Callback invoked when a pointer moves across the element.
  final void Function(PointerEvent e)? onPointerMove;

  /// Callback invoked when a pointer is moved onto the
  /// element or its descendants.
  final void Function(PointerEvent e)? onPointerOver;

  /// Callback invoked when a pointer is moved out of the
  /// element or its descendants.
  final void Function(PointerEvent e)? onPointerOut;

  /// Callback invoked when an input element's value
  /// changes synchronously (e.g. while typing).
  final void Function(Event e)? onInput;

  /// Callback invoked when an input element's value
  /// change is committed (e.g. on blur/submit).
  final void Function(Event e)? onChange;

  /// Callback invoked when the user selects some text
  /// (for input/textarea elements).
  final void Function(Event e)? onSelect;

  /// Callback invoked when a mouse button is pressed.
  final void Function(MouseEvent e)? onMouseDown;

  /// Callback invoked when a mouse button is released.
  final void Function(MouseEvent e)? onMouseUp;

  /// Callback invoked when the mouse cursor enters the element.
  final void Function(MouseEvent e)? onMouseEnter;

  /// Callback invoked when the mouse cursor leaves the element.
  final void Function(MouseEvent e)? onMouseLeave;

  /// Callback invoked when the mouse cursor moves within the element.
  final void Function(MouseEvent e)? onMouseMove;

  /// Callback invoked when a key is pressed down.
  final void Function(KeyboardEvent e)? onKeyDown;

  /// Callback invoked when a key is released.
  final void Function(KeyboardEvent e)? onKeyUp;

  /// Callback invoked periodically during an active drag operation.
  final void Function(DragEvent e)? onDrag;

  /// Callback invoked when a drag operation completes or is canceled.
  final void Function(DragEvent e)? onDragEnd;

  /// Callback invoked when a dragged item enters the drop target.
  final void Function(DragEvent e)? onDragEnter;

  /// Callback invoked when a dragged item leaves the drop target.
  final void Function(DragEvent e)? onDragLeave;

  /// Callback invoked while a dragged item is over the drop target.
  final void Function(DragEvent e)? onDragOver;

  /// Callback invoked when a drag operation is initiated.
  final void Function(DragEvent e)? onDragStart;

  /// Callback invoked when the element gains focus.
  final void Function(FocusEvent e)? onFocus;

  /// Callback invoked when focus moves into the element or any descendant.
  final void Function(FocusEvent e)? onFocusIn;

  /// Callback invoked when focus moves out of the element or any descendant.
  final void Function(FocusEvent e)? onFocusOut;

  /// Callback invoked when the element loses focus.
  final void Function(FocusEvent e)? onBlur;

  /// Callback invoked when the input is invalid.
  final void Function(Event e)? onInvalid;

  /// Callback invoked when a user pastes data into the element.
  final void Function(ClipboardEvent e)? onPaste;

  /// Callback invoked when the form is submitted.
  final void Function(Event e)? onSubmit;

  /// Duration threshold required to trigger [onLongPress] (default: 500ms).
  final Duration longPressDuration;

  /// {@macro GestureRecognizer}
  const GestureRecognizer({
    this.longPressDuration = const Duration(
      milliseconds: 500,
    ),
    this.onClick,
    this.onDoubleClick,
    this.onLongPress,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerCancel,
    this.onPointerEnter,
    this.onPointerLeave,
    this.onPointerMove,
    this.onPointerOver,
    this.onPointerOut,
    this.onInput,
    this.onChange,
    this.onMouseDown,
    this.onMouseUp,
    this.onMouseEnter,
    this.onMouseLeave,
    this.onMouseMove,
    this.onKeyDown,
    this.onKeyUp,
    this.onDrag,
    this.onDragEnd,
    this.onDragEnter,
    this.onDragLeave,
    this.onDragOver,
    this.onDragStart,
    this.onFocus,
    this.onFocusIn,
    this.onFocusOut,
    this.onBlur,
    this.onSelect,
    this.onInvalid,
    this.onPaste,
    this.onSubmit,
  });

  /// Returns only the active event handlers for non-null callbacks.
  Map<String, void Function(Event)> get toMap {
    final map = <String, void Function(Event)>{};
    bool longPressConsumed = false;
    Timer? longPressTimer;

    void cancelLongPress({bool resetConsumed = false}) {
      longPressTimer?.cancel();
      longPressTimer = null;
      if (resetConsumed) longPressConsumed = false;
    }

    if (onClick != null) {
      map['click'] = (e) {
        if (longPressConsumed) {
          longPressConsumed = false;
          return;
        }
        onClick!.call(e);
      };
    }

    if (onLongPress != null) {
      map['pointerdown'] = (e) {
        cancelLongPress(resetConsumed: true);

        final event = e as PointerEvent;
        onPointerDown?.call(event);

        longPressTimer = Timer(longPressDuration, () {
          longPressConsumed = true;
          onLongPress!.call(event);
        });
      };

      map['pointerup'] = (e) {
        cancelLongPress();
        onPointerUp?.call(e as PointerEvent);
      };

      map['pointercancel'] = (e) {
        cancelLongPress(resetConsumed: true);
        onPointerCancel?.call(e as PointerEvent);
      };
    } else {
      if (onPointerDown != null) {
        map['pointerdown'] = (e) => onPointerDown!(e as PointerEvent);
      }

      if (onPointerUp != null) {
        map['pointerup'] = (e) => onPointerUp!(e as PointerEvent);
      }

      if (onPointerCancel != null) {
        map['pointercancel'] = (e) => onPointerCancel!(e as PointerEvent);
      }
    }

    if (onDoubleClick != null) {
      map['dblclick'] = (e) => onDoubleClick!(e as MouseEvent);
    }

    if (onPointerEnter != null) {
      map['pointerenter'] = (e) => onPointerEnter!(e as PointerEvent);
    }

    if (onPointerLeave != null) {
      map['pointerleave'] = (e) {
        if (onLongPress != null) cancelLongPress(resetConsumed: true);
        onPointerLeave!(e as PointerEvent);
      };
    } else if (onLongPress != null) {
      map['pointerleave'] = (_) => cancelLongPress(resetConsumed: true);
    }

    if (onPointerMove != null) {
      map['pointermove'] = (e) => onPointerMove!(e as PointerEvent);
    }

    if (onPointerOver != null) {
      map['pointerover'] = (e) => onPointerOver!(e as PointerEvent);
    }

    if (onPointerOut != null) {
      map['pointerout'] = (e) => onPointerOut!(e as PointerEvent);
    }

    if (onInput != null) map['input'] = (e) => onInput!(e);

    if (onChange != null) map['change'] = (e) => onChange!(e);

    if (onMouseDown != null) {
      map['mousedown'] = (e) => onMouseDown!(e as MouseEvent);
    }

    if (onMouseUp != null) {
      map['mouseup'] = (e) => onMouseUp!(e as MouseEvent);
    }

    if (onMouseEnter != null) {
      map['mouseenter'] = (e) => onMouseEnter!(e as MouseEvent);
    }

    if (onMouseLeave != null) {
      map['mouseleave'] = (e) => onMouseLeave!(e as MouseEvent);
    }

    if (onMouseMove != null) {
      map['mousemove'] = (e) => onMouseMove!(e as MouseEvent);
    }

    if (onKeyDown != null) {
      map['keydown'] = (e) => onKeyDown!(e as KeyboardEvent);
    }

    if (onKeyUp != null) {
      map['keyup'] = (e) => onKeyUp!(e as KeyboardEvent);
    }

    if (onDrag != null) {
      map['drag'] = (e) => onDrag!(e as DragEvent);
    }

    if (onDragEnd != null) {
      map['dragend'] = (e) => onDragEnd!(e as DragEvent);
    }

    if (onDragEnter != null) {
      map['dragenter'] = (e) => onDragEnter!(e as DragEvent);
    }

    if (onDragLeave != null) {
      map['dragleave'] = (e) => onDragLeave!(e as DragEvent);
    }

    if (onDragOver != null) {
      map['dragover'] = (e) => onDragOver!(e as DragEvent);
    }

    if (onDragStart != null) {
      map['dragstart'] = (e) => onDragStart!(e as DragEvent);
    }

    if (onFocus != null) {
      map['focus'] = (e) => onFocus!(e as FocusEvent);
    }

    if (onFocusIn != null) {
      map['focusin'] = (e) => onFocusIn!(e as FocusEvent);
    }

    if (onFocusOut != null) {
      map['focusout'] = (e) => onFocusOut!(e as FocusEvent);
    }

    if (onBlur != null) {
      map['blur'] = (e) => onBlur!(e as FocusEvent);
    }

    if (onSelect != null) {
      map['select'] = (e) => onSelect!(e);
    }

    if (onInvalid != null) {
      map['invalid'] = (e) => onInvalid!(e);
    }

    if (onPaste != null) {
      map['paste'] = (e) => onPaste!(e as ClipboardEvent);
    }

    if (onSubmit != null) {
      map['submit'] = (e) => onSubmit!(e);
    }

    return map;
  }
}

/// {@template InputEvents}
/// A helper class that simplifies binding DOM input, change, select, focus,
/// focusin, focusout, and blur events to input components.
///
/// Example
/// ```dart
/// final eventsHandler = InputEvents(
///   onInput: (e) => print('Input event!'),
///   onChange: (e) => print('Change event!'),
///   onSelect: (e) => print('Select event!'),
///   onFocus: (e) => print('Focus event!'),
///   onFocusIn: (e) => print('Focusin event!'),
///   onFocusOut: (e) => print('Focusout event!'),
///   onBlur: (e) => print('Blur event!'),
///   onInvalid: (e) => print('Invalid event!'),
///   onPaste: (e) => print('Paste event!'),
/// );
/// ```
/// {@endtemplate}
class InputEvents extends GestureRecognizer {
  /// Add custom events to the event recognizer.
  ///
  /// Example:
  /// ```dart
  /// final eventsHandler = InputEvents(
  ///   onInput: (e) => print('Input event!'),
  ///   onChange: (e) => print('Change event!'),
  ///   customEvents: {
  ///     'customEvent': (e) => print('Custom event!'),
  ///   },
  /// );
  /// ```
  final Map<String, void Function(Event)>? customEvents;

  /// {@macro InputEvents}
  InputEvents({
    super.onInput,
    super.onChange,
    super.onSelect,
    super.onFocus,
    super.onFocusIn,
    super.onFocusOut,
    super.onBlur,
    super.onInvalid,
    super.onKeyDown,
    super.onKeyUp,
    super.onPaste,
    this.customEvents,
  });

  @override
  Map<String, void Function(Event)> get toMap {
    final map = <String, void Function(Event)>{};

    if (customEvents != null) map.addAll(customEvents!);

    if (onInput != null) map['input'] = (e) => onInput!(e);
    if (onChange != null) map['change'] = (e) => onChange!(e);
    if (onSelect != null) map['select'] = (e) => onSelect!(e);

    if (onFocus != null) {
      map['focus'] = (e) => onFocus!(e as FocusEvent);
    }

    if (onFocusIn != null) {
      map['focusin'] = (e) => onFocusIn!(e as FocusEvent);
    }

    if (onFocusOut != null) {
      map['focusout'] = (e) => onFocusOut!(e as FocusEvent);
    }

    if (onBlur != null) {
      map['blur'] = (e) => onBlur!(e as FocusEvent);
    }

    if (onInvalid != null) {
      map['invalid'] = (e) => onInvalid!(e);
    }

    if (onKeyDown != null) {
      map['keydown'] = (e) => onKeyDown!(e as KeyboardEvent);
    }

    if (onKeyUp != null) {
      map['keyup'] = (e) => onKeyUp!(e as KeyboardEvent);
    }

    if (onPaste != null) {
      map['paste'] = (e) => onPaste!(e as ClipboardEvent);
    }

    return map;
  }

  /// If you have multiple InputEvents, you can merge them using this method.
  ///
  /// Example:
  /// ```dart
  /// final events = InputEvents(
  ///   onInput: (e) => print('Input event!'),
  ///   onChange: (e) => print('Change event!'),
  ///   customEvents: {
  ///     'customEvent': (e) => print('Custom event!'),
  ///   },
  /// );
  ///
  /// final otherEvents = InputEvents(
  ///   onInput: (e) => print('Other input event!'),
  ///   onChange: (e) => print('Other change event!'),
  ///   customEvents: {
  ///     'customEvent': (e) => print('Other custom event!'),
  ///   },
  /// );
  ///
  /// final mergedEvents = events.merge(otherEvents);
  /// ```
  InputEvents merge(InputEvents? other) {
    final effectiveOnInput = onInput != null
        ? (Event e) {
            onInput!(e);
            other?.onInput?.call(e);
          }
        : other?.onInput;

    final effectiveOnChange = onChange != null
        ? (Event e) {
            onChange!(e);
            other?.onChange?.call(e);
          }
        : other?.onChange;

    final effectiveOnSelect = onSelect != null
        ? (Event e) {
            onSelect!(e);
            other?.onSelect?.call(e);
          }
        : other?.onSelect;

    final effectiveOnFocus = onFocus != null
        ? (FocusEvent e) {
            onFocus!(e);
            other?.onFocus?.call(e);
          }
        : other?.onFocus;

    final effectiveOnFocusIn = onFocusIn != null
        ? (FocusEvent e) {
            onFocusIn!(e);
            other?.onFocusIn?.call(e);
          }
        : other?.onFocusIn;

    final effectiveOnFocusOut = onFocusOut != null
        ? (FocusEvent e) {
            onFocusOut!(e);
            other?.onFocusOut?.call(e);
          }
        : other?.onFocusOut;

    final effectiveOnBlur = onBlur != null
        ? (FocusEvent e) {
            onBlur!(e);
            other?.onBlur?.call(e);
          }
        : other?.onBlur;

    final effectiveOnInvalid = onInvalid != null
        ? (Event e) {
            onInvalid!(e);
            other?.onInvalid?.call(e);
          }
        : other?.onInvalid;

    final effectiveOnKeyDown = onKeyDown != null
        ? (KeyboardEvent e) {
            onKeyDown!(e);
            other?.onKeyDown?.call(e);
          }
        : other?.onKeyDown;

    final effectiveOnKeyUp = onKeyUp != null
        ? (KeyboardEvent e) {
            onKeyUp!(e);
            other?.onKeyUp?.call(e);
          }
        : other?.onKeyUp;

    final effectiveOnPaste = onPaste != null
        ? (ClipboardEvent e) {
            onPaste!(e);
            other?.onPaste?.call(e);
          }
        : other?.onPaste;

    final effectiveCustomEvents = customEvents != null
        ? {...customEvents!, ...?other?.customEvents}
        : other?.customEvents;

    return InputEvents(
      onInput: effectiveOnInput,
      onChange: effectiveOnChange,
      onSelect: effectiveOnSelect,
      onFocus: effectiveOnFocus,
      onFocusIn: effectiveOnFocusIn,
      onFocusOut: effectiveOnFocusOut,
      onBlur: effectiveOnBlur,
      onInvalid: effectiveOnInvalid,
      onKeyDown: effectiveOnKeyDown,
      onKeyUp: effectiveOnKeyUp,
      onPaste: effectiveOnPaste,
      customEvents: effectiveCustomEvents,
    );
  }
}
