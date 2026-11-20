import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/app/index.dart' show NakiApp;
import '../framework/framework/index.dart' show NakiStatefulMixin;
import '../framework/inherited/index.dart'
    show AppScope, NakiDomIdRegistry, NakiDomIdScope;
import '../framework/lifecycle.dart' show BrowserLifecycleListeners;
import '../models/naki/index.dart' show ScrollBarConfiguration;
import '../models/styling/index.dart' show Dim;
import '../styles/rules.dart';
import '../utilities/enums/index.dart' show Brightness, ThemeMode;
import '../utilities/extensions/index.dart';
import '../utilities/helpers/index.dart' show listEquals, updateRootTheme;
import '../utilities/storage.dart';

import 'tokens.dart';

part 'dark_theme_data.dart';
part 'light_theme_data.dart';
part 'mode_tokens.dart';
part 'schemes/border_scheme.dart';
part 'schemes/calendar_scheme.dart';
part 'schemes/color_seed.dart';
part 'schemes/component_scheme.dart';
part 'schemes/elevation_scheme.dart';
part 'schemes/radius_scheme.dart';
part 'schemes/spacing_scheme.dart';
part 'schemes/typography_scheme.dart';
part 'theme_config.dart';
part 'theme_provider.dart';
