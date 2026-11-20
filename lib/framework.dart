/// NAKI UI - FRAMEWORK API
///
/// Exports framework lifecycle, models, gestures, animations,
/// and utilities.
library;

export 'package:universal_web/web.dart' hide Table;

export 'src/framework/framework/index.dart'
    hide
        NakiAccessibleOverlayMixin,
        NakiOverlayVisibilityMixin,
        NakiPlacementMixin,
        NakiTextScope;
export 'src/framework/lifecycle.dart';

export 'src/models/animation.dart';
export 'src/models/gesture.dart';
export 'src/models/naki/index.dart' hide NakiAlignProps, NakiStylable;
export 'src/models/overlays/index.dart'
    hide OverlayEntryScope, OverlayHost, OverlayHostState, SnackbarRegistry;
export 'src/models/scrolling/index.dart';

export 'src/stub/index.dart';

export 'src/utilities/debounce.dart';
export 'src/utilities/enums/index.dart'
    hide BackdropFilterType, CardVariant, GradientType;
