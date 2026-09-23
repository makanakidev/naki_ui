import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../framework/framework.dart' show NakiStatefulMixin;
import '../framework/lifecycle.dart';
import '../models/styling.dart' show Dim;
import '../utilities/enums.dart' show Orientation;
import '../utilities/extensions.dart';

/// {@template MediaQueryProvider}
/// A Naki component that propagates browser and component width, height, and
/// orientation to its children.
///
/// It observes the browser window size and orientation, and optionally the size
/// and orientation of a specific component identified by [id]. The observed
/// values are then made available to descendant components through
/// [MediaQueryProvider.of].
///
/// > [!IMPORTANT]
/// > [MediaQueryProvider] must be used inside a `@client` annotated component.
///
/// ### Example
/// ```dart
/// @client // required
///
/// @override
/// Component build(BuildContext context) {
///   return NakiApp(
///     child: MediaQueryProvider(
///       builder: (context) {
///         final mq1 = MediaQueryProvider.of(context)!;
///
///         return Column(
///           children: [
///             NakiText('Width: ${mq1.width}'),
///             NakiText('Height: ${mq1.height}'),
///             NakiText('Orientation: ${mq1.orientation}'),
///             MediaQueryProvider(
///               id: 'unique-id', // this id is used to identify the Row
///               builder: (context) {
///                 final mq2 = MediaQueryProvider.of(context)!;
///
///                 return Row(
///                   children: [
///                     NakiText('Component Width: ${mq2.width}'),
///                     NakiText('Component Height: ${mq2.height}'),
///                     NakiText('Component Orientation: ${mq2.orientation}'),
///                   ],
///                 );
///               },
///             ),
///           ],
///         );
///       },
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
class MediaQueryProvider extends StatefulComponent {
  /// The builder function that builds the component whose media query data
  /// can be observed and propagated to its children when [id] is set.
  final ComponentBuilder builder;

  /// The unique identifier of the component to observe.
  ///
  /// When [id] is non-empty, [MediaQueryProvider] observes and propagates
  /// the media query data of the component returned by [builder]. Otherwise,
  /// it observes and propagates the media query data of the browser viewport.
  ///
  /// > [!IMPORTANT]
  /// > The component returned by [builder] must not have an `id` different
  /// > from this [id].
  /// > It is advisable to not set the component's id.
  ///
  /// ### Example
  /// ```dart
  ///   MediaQueryProvider(
  ///     id: 'unique-id', // this ensures that the Column is observed
  ///     builder: (context) {
  ///       return Column(
  ///         children: [
  ///           NakiText('Width: ${MediaQueryProvider.widthOf(context)}'),
  ///           NakiText('Height: ${MediaQueryProvider.heightOf(context)}'),
  ///           NakiText(
  ///             'Orientation: ${MediaQueryProvider.orientationOf(context)}',
  ///           ),
  ///         ],
  ///       );
  ///     },
  ///   )
  /// ```
  final String? id;

  /// {@macro MediaQueryProvider}
  const MediaQueryProvider({
    super.key,
    required this.builder,
    this.id,
  });

  /// Returns the nearest [MediaQueryData] instance in the component
  /// tree, `null` otherwise.
  static MediaQueryData? _maybeOf(BuildContext context) {
    return context.dependOnInheritedComponentOfExactType<MediaQueryData>();
  }

  /// Returns the nearest [MediaQueryData] ancestor in the component tree.
  ///
  /// It scans the component tree upwards from the parent of [context]
  /// until it finds an instance of [MediaQueryData].
  ///
  /// Returns `null` if no [MediaQueryData] is in the component tree.
  static MediaQueryData? of(BuildContext context) => _maybeOf(context);

  /// Returns width (in px) from the nearest [MediaQueryProvider] ancestor.
  ///
  /// Returns `null` if no [MediaQueryProvider] is in the component tree.
  static double? width(BuildContext context) => _maybeOf(context)?.width?.value;

  /// Returns height (in px) from the nearest [MediaQueryProvider] ancestor.
  ///
  /// Returns `null` if no [MediaQueryProvider] is in the component tree.
  static double? height(BuildContext context) =>
      _maybeOf(context)?.height?.value;

  /// Returns orientation from the nearest [MediaQueryProvider] ancestor.
  ///
  /// Returns `null` if no [MediaQueryProvider] is in the component tree.
  static Orientation? orientation(BuildContext context) =>
      _maybeOf(context)?.orientation;

  /// Returns width (in px) of the nearest [MediaQueryProvider] ancestor whose
  /// child is identified by [MediaQueryProvider.id].
  ///
  /// Returns `null` if no such [MediaQueryProvider] is found.
  static double? widthOf(BuildContext context) =>
      _maybeOf(context)?.isComponent ?? false
      ? _maybeOf(context)?.width?.value
      : null;

  /// Returns height (in px) of the nearest [MediaQueryProvider] ancestor whose
  /// child is identified by [MediaQueryProvider.id].
  ///
  /// Returns `null` if no such [MediaQueryProvider] is found.
  static double? heightOf(BuildContext context) =>
      _maybeOf(context)?.isComponent ?? false
      ? _maybeOf(context)?.height?.value
      : null;

  /// Returns orientation of the nearest [MediaQueryProvider] ancestor whose
  /// child is identified by [MediaQueryProvider.id].
  ///
  /// Returns `null` if no such [MediaQueryProvider] is found.
  static Orientation? orientationOf(BuildContext context) =>
      _maybeOf(context)?.isComponent ?? false
      ? _maybeOf(context)?.orientation
      : null;

  @override
  State createState() => _MediaQueryState();
}

class _MediaQueryState extends State<MediaQueryProvider>
    with NakiStatefulMixin {
  Dim? _width, _height;

  Orientation? _orientation, _componentOrientation;

  final BrowserLifecycleListeners _lifecycle = BrowserLifecycleListeners();

  bool get _isObservingComponent => component.id.isNotNullAndEmpty;

  @override
  void setState(VoidCallback fn) {
    if (mounted && kIsWeb) super.setState(fn);
  }

  @override
  FutureOr<VoidCallback?> afterRender(
    BuildContext context,
  ) {
    if (!_isObservingComponent) {
      _lifecycle.whenResized = (height, width, layout) {
        setState(() {
          _height = height;
          _width = width;
          _orientation = layout;
        });
      };
    } else {
      _lifecycle.observeComponentSize((
        height,
        width,
        layout,
      ) {
        setState(() {
          _height = height;
          _width = width;
          _orientation = layout;
        });
      }, id: component.id);
    }

    _lifecycle.register();

    return _lifecycle.dispose;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Returns width (in px) of the browser viewport or observed component.
  double? get width => _width?.value;

  /// Returns height (in px) of the browser viewport or observed component.
  double? get height => _height?.value;

  /// Returns orientation of the browser viewport or observed component.
  Orientation get orientation => _orientation ?? Orientation.unknown;

  @override
  Component build(BuildContext context) {
    final Component child = _isObservingComponent
        ? .wrapElement(
            id: component.id!,
            child: Builder(builder: component.builder),
          )
        : Builder(builder: component.builder);

    return MediaQueryData(
      width: _width,
      height: _height,
      orientation: _orientation,
      isComponent: _isObservingComponent,
      child: child,
    );
  }
}

/// Used internally by [MediaQueryProvider] to propagate media query values.
class MediaQueryData extends InheritedComponent {
  /// Width of the browser viewport or the observed component.
  final Dim? width;

  /// Height of the browser viewport or the observed component.
  final Dim? height;

  /// Orientation of the browser viewport or the observed component.
  final Orientation? orientation;

  /// Whether the media query data is for the browser or a component.
  final bool isComponent;

  /// {@macro MediaQueryProvider}
  const MediaQueryData({
    super.key,
    required super.child,
    this.width,
    this.height,
    this.orientation,
    this.isComponent = false,
  });

  @override
  bool updateShouldNotify(MediaQueryData oldComponent) =>
      width != oldComponent.width ||
      height != oldComponent.height ||
      orientation != oldComponent.orientation;
}
