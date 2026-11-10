import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart'
    show HTMLElement, HTMLFormElement, document, window;

import '../components/scaffold.dart' show Scaffold, ScaffoldState;
import '../styles/rules.dart' show NakiStyleRegistry;

/// {@template FlexScope}
/// An inherited component created by flex containers such as [Row]
/// or [Column] to provide layout scope information to descendant
/// components.
/// {@endtemplate}
class FlexScope extends InheritedComponent {
  /// Whether the flex container is scrollable.
  final bool scrollable;

  /// {@macro FlexScope}
  const FlexScope({required super.child, this.scrollable = false});

  /// Finds the nearest [FlexScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [FlexScope].
  ///
  /// If no [FlexScope] is found, it returns `null`.
  static FlexScope? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<FlexScope>();
  }

  @override
  bool updateShouldNotify(FlexScope oldComponent) =>
      scrollable != oldComponent.scrollable;
}

/// {@template FormScope}
/// An inherited component that exposes the state of
/// a `FormBuilder` to its descendant components.
/// {@endtemplate}
class FormScope extends InheritedComponent {
  /// {@macro FormScope}
  const FormScope({required super.child});

  /// The global key of the form.
  GlobalNodeKey<HTMLFormElement>? get _formKey {
    if (child case form(key: final GlobalNodeKey<HTMLFormElement> key)) {
      return key;
    }

    return null;
  }

  /// Finds the nearest [FormScope] ancestor in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an ancestor that is an instance of [FormScope].
  ///
  /// If no [FormScope] is found, it returns `null`.
  static FormScope? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<FormScope>();
  }

  /// Validates all fields within the form.
  ///
  /// Every registered field validator (e.g. `TextField.validator`) runs
  /// synchronously first, so pending debounced validation can never let
  /// invalid input through; native constraint validation then reports the
  /// first invalid field.
  ///
  /// Returns `true` if all fields pass validation, otherwise `false`.
  ///
  /// Note: This is only supported in client-side.
  bool validate() {
    if (kIsWeb && _formKey != null) {
      final formElement = _formKey!.currentNode;
      if (formElement == null) return false;

      NakiFormFields.validateWithin(formElement);
      return formElement.reportValidity();
    }

    return false;
  }

  /// This will clear all the values and validation errors in the form fields.
  ///
  /// Note: This is only supported in client-side.
  void reset() {
    if (kIsWeb && _formKey != null) {
      final formElement = _formKey!.currentNode;
      if (formElement == null) return;

      formElement.reset();
      NakiFormFields.resetWithin(formElement);
    }
  }

  @override
  bool updateShouldNotify(FormScope oldComponent) =>
      _formKey != oldComponent._formKey;
}

/// Callbacks a form field registers so [FormScope] can validate and reset
/// it synchronously.
final class NakiFormField {
  /// Creates a [NakiFormField].
  const NakiFormField({required this.validate, required this.reset});

  /// Runs the field's validators and updates its custom validity.
  final void Function() validate;

  /// Clears the field's custom validity and visible error.
  final void Function() reset;
}

/// Registry of mounted form fields keyed by their input element id.
abstract final class NakiFormFields {
  static final Map<String, NakiFormField> _fields = {};

  /// Registers [field] for the input element with [id].
  static void register(String id, NakiFormField field) => _fields[id] = field;

  /// Removes the field registered for [id] if it is still [field].
  static void unregister(String id, NakiFormField field) {
    if (identical(_fields[id], field)) _fields.remove(id);
  }

  static Iterable<NakiFormField> _within(HTMLFormElement form) sync* {
    for (final entry in _fields.entries.toList()) {
      final element = document.getElementById(entry.key) as HTMLElement?;
      if (element != null && form.contains(element)) yield entry.value;
    }
  }

  /// Validates every registered field inside [form].
  static void validateWithin(HTMLFormElement form) {
    for (final field in _within(form)) field.validate();
  }

  /// Resets every registered field inside [form].
  static void resetWithin(HTMLFormElement form) {
    for (final field in _within(form)) field.reset();
  }

  /// Input types that are not data-entry fields for Enter navigation.
  static const _skippedTypes = {
    'hidden',
    'submit',
    'button',
    'reset',
    'image',
    'file',
  };

  /// Whether [element] can receive focus as the "next field".
  static bool _isNavigable(HTMLElement element) {
    if (element.hasAttribute('disabled') ||
        element.hasAttribute('readonly') ||
        element.getAttribute('tabindex') == '-1' ||
        element.getAttribute('aria-hidden') == 'true') {
      return false;
    }

    final type = element.getAttribute('type')?.toLowerCase();
    if (type != null && _skippedTypes.contains(type)) return false;

    // skip elements that are not rendered or visually hidden
    if (element.getClientRects().length == 0) return false;

    return window.getComputedStyle(element).visibility != 'hidden';
  }

  /// Handles `Enter` in a single-line form field: moves focus to the next
  /// field of the enclosing form, or submits the form (running validation)
  /// when [field] is the last one.
  ///
  /// Returns `false` when [field] is not inside a form.
  static bool focusNextOrSubmit(HTMLElement field) {
    final form = field.closest('form') as HTMLFormElement?;
    if (form == null) return false;

    final nodes = form.querySelectorAll('input, select, textarea');
    final fields = <HTMLElement>[
      for (var i = 0; i < nodes.length; i++)
        if (nodes.item(i) case final HTMLElement element
            when identical(element, field) || _isNavigable(element))
          element,
    ];

    final index = fields.indexWhere((element) => identical(element, field));
    if (index != -1 && index < fields.length - 1) {
      fields[index + 1].focus();
      return true;
    }

    // last field: submit through the form so validation and onSubmit run
    form.requestSubmit();

    return true;
  }
}

/// Allocates hydration-stable DOM ids within a root theme tree.
final class NakiDomIdRegistry {
  // Expando keeps component contexts weakly referenced, so unmounted
  // trees do not accumulate in long-lived applications.
  final Expando<Map<String, String>> _ids = Expando('nakiDomIds');
  int _nextId = 0;

  String resolve(BuildContext owner, String prefix) {
    final ownerIds = _ids[owner] ??= <String, String>{};
    return ownerIds.putIfAbsent(
      prefix,
      () => '${prefix}_nakidom_${(_nextId++).toRadixString(36)}',
    );
  }
}

/// Provides one request-local style registry to the complete themed tree.
class NakiStyleScope extends InheritedComponent {
  const NakiStyleScope({required this.registry, required super.child});

  final NakiStyleRegistry registry;

  static NakiStyleScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiStyleScope>();

  @override
  bool updateShouldNotify(NakiStyleScope oldComponent) =>
      registry != oldComponent.registry;
}

/// Provides one request-local DOM id registry to the complete themed tree.
class NakiDomIdScope extends InheritedComponent {
  const NakiDomIdScope({required this.registry, required super.child});

  final NakiDomIdRegistry registry;

  static NakiDomIdScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiDomIdScope>();

  @override
  bool updateShouldNotify(NakiDomIdScope oldComponent) =>
      registry != oldComponent.registry;
}

/// {@template ScaffoldScope}
/// An inherited component created by [Scaffold] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class ScaffoldScope extends InheritedComponent {
  /// The [ScaffoldState] of the enclosing scaffold.
  final ScaffoldState state;

  /// {@macro ScaffoldScope}
  const ScaffoldScope({required super.child, required this.state});

  /// Finds the nearest [ScaffoldScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [ScaffoldScope].
  ///
  /// If no [ScaffoldScope] is found, it returns `null`.
  static ScaffoldScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<ScaffoldScope>();

  @override
  bool updateShouldNotify(ScaffoldScope oldComponent) =>
      state != oldComponent.state;
}

/// {@template AppScope}
/// An inherited component created by [NakiApp] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class AppScope extends InheritedComponent {
  /// {@macro AppScope}
  AppScope({required super.child});

  /// Finds the nearest [AppScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [AppScope].
  ///
  /// If no [AppScope] is found, it returns `null`.
  static AppScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope oldComponent) => false;
}

/// {@template StackScope}
/// An inherited component created by [Stack] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class StackScope extends InheritedComponent {
  /// {@macro StackScope}
  const StackScope({required super.child});

  /// Finds the nearest [StackScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [StackScope].
  ///
  /// If no [StackScope] is found, it returns `null`.
  static StackScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<StackScope>();

  @override
  bool updateShouldNotify(StackScope oldComponent) => false;
}
