/// NAKI UI - FRAMEWORK API
///
/// Exports framework lifecycle, models, gestures, animations,
/// and utilities.
library;

export 'package:universal_web/web.dart' hide Table;

export 'src/framework/framework.dart';
export 'src/framework/lifecycle.dart';

export 'src/models/animation.dart';
export 'src/models/gesture.dart';
export 'src/models/naki.dart' hide NakiAlignProps, NakiStylable, NakiTextScope;
export 'src/models/overlays.dart' hide SnackbarRegistry;
export 'src/models/scrolling.dart';

export 'src/stub/index.dart';

export 'src/utilities/debounce.dart';
export 'src/utilities/enums.dart'
    hide BackdropFilterType, CardVariant, GradientType;
