import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' show HTMLFormElement;

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
  const FlexScope({
    required super.child,
    this.scrollable = false,
  });

  /// Finds the nearest [FlexScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [FlexScope].
  ///
  /// If no [FlexScope] is found, it returns `null`.
  static FlexScope? of(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<FlexScope>();
  }

  @override
  bool updateShouldNotify(FlexScope oldComponent) => scrollable != oldComponent.scrollable;
}

/// {@template FormScope}
/// An inherited component that exposes the state of
/// a [FormBuilder] to its descendant components.
/// {@endtemplate}
class FormScope extends InheritedComponent {
  /// Whether the form should be validated.
  final bool allowValidation;

  /// {@macro FormScope}
  const FormScope({
    required this.allowValidation,
    required super.child,
  });

  /// The global key of the form.
  GlobalNodeKey<HTMLFormElement>? get _formKey {
    if (child case form(
      key: final GlobalNodeKey<HTMLFormElement> key,
    )) {
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
  /// Returns `true` if all fields pass validation and form validation
  /// is enabled, otherwise `false`.
  ///
  /// Note: This is only supported in client-side.
  bool validate() {
    if (allowValidation && kIsWeb && _formKey != null) {
      final formElement = _formKey!.currentNode;
      return formElement?.reportValidity() ?? false;
    }
    return false;
  }

  /// This will clear all the values in the form fields.
  ///
  /// Note: This is only supported in client-side.
  void reset() {
    if (kIsWeb && _formKey != null) {
      final formElement = _formKey!.currentNode;
      formElement?.reset();
      return;
    }
  }

  @override
  bool updateShouldNotify(FormScope oldComponent) =>
      allowValidation != oldComponent.allowValidation || _formKey != oldComponent._formKey;
}

/// Allocates hydration-stable DOM ids within a root theme tree.
final class NakiDomIdRegistry {
  // Expando keeps component contexts weakly referenced, so unmounted
  // trees do not accumulate in long-lived applications.
  final Expando<Map<String, String>> _ids = Expando(
    'nakiDomIds',
  );
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
  const NakiStyleScope({
    required this.registry,
    required super.child,
  });

  final NakiStyleRegistry registry;

  static NakiStyleScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiStyleScope>();

  @override
  bool updateShouldNotify(NakiStyleScope oldComponent) => registry != oldComponent.registry;
}

/// Provides one request-local DOM id registry to the complete themed tree.
class NakiDomIdScope extends InheritedComponent {
  const NakiDomIdScope({
    required this.registry,
    required super.child,
  });

  final NakiDomIdRegistry registry;

  static NakiDomIdScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<NakiDomIdScope>();

  @override
  bool updateShouldNotify(NakiDomIdScope oldComponent) => registry != oldComponent.registry;
}

/// {@template ScaffoldScope}
/// An inherited component created by [Scaffold] that provides layout
/// and state information to descendant components.
/// {@endtemplate}
class ScaffoldScope extends InheritedComponent {
  /// The [ScaffoldState] of the enclosing scaffold.
  final ScaffoldState state;

  /// {@macro ScaffoldScope}
  const ScaffoldScope({
    super.key,
    required super.child,
    required this.state,
  });

  /// Finds the nearest [ScaffoldScope] instance in the component tree.
  /// This scans the component tree upwards from the component [context]
  /// until it finds an instance of [ScaffoldScope].
  ///
  /// If no [ScaffoldScope] is found, it returns `null`.
  static ScaffoldScope? of(BuildContext context) =>
      context.dependOnInheritedComponentOfExactType<ScaffoldScope>();

  @override
  bool updateShouldNotify(ScaffoldScope oldComponent) => state != oldComponent.state;
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
