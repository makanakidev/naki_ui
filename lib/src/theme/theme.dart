import 'dart:async';

import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/layout/index.dart' show NakiFragment;
import '../framework/framework/index.dart' show NakiStatefulMixin;
import '../framework/inherited/index.dart'
    show AppScope, NakiDomIdRegistry, NakiDomIdScope;
import '../framework/lifecycle.dart' show BrowserLifecycleListeners;
import '../styles/rules.dart';
import '../utilities/enums/index.dart' show Brightness, ThemeMode;
import '../utilities/helpers/index.dart' show updateRootTheme;
import '../utilities/storage.dart';

import 'styles.dart';
import 'theme_data.dart';
import 'tokens.dart';

export 'theme_data.dart';

part 'theme_provider.dart';
