import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart' show RouterState;

import '../../components/layout/index.dart';
import '../../models/overlays/index.dart'
    show OverlayEntryScope, OverlayHost, OverlayResultController;

import 'styles.dart';

part 'naki_route.dart';
part 'naki_route_settings.dart';
part 'navigator.dart';
part 'navigator_state.dart';

/// Signature for a predicate used to match routes during
/// [Navigator.popUntil] or [Navigator.pushAndRemoveUntil].
typedef NakiRoutePredicate = bool Function(NakiRoute<dynamic> route);

/// Signature for a function that builds a [NakiRoute] for
/// the given [NakiRouteSettings].
typedef NakiRouteFactory =
    NakiRoute<dynamic>? Function(NakiRouteSettings settings);
