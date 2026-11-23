import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../../framework/inherited/index.dart' show AppScope;
import '../../framework/navigator/index.dart';
import '../../models/naki/index.dart';
import '../../models/styling/index.dart';
import '../../styles/rules.dart';
import '../../styles/text_style.dart';
import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../../utilities/enums/index.dart';
import '../../utilities/extensions/index.dart';
import '../../utilities/helpers/index.dart';

import '../basics/index.dart';
import '../layout/index.dart';
import '../scaffold/index.dart';
import '../styling/index.dart';

part 'naki_app.dart';
part 'page_not_found.dart';

const String _defaultViewport =
    'width=device-width, initial-scale=1.0, viewport-fit=cover';
const String _defaultCharset = 'utf-8';
const String _defaultLocale = 'en';
const String _defaultBasePath = '/';

/// A builder that builds a component given a child.
/// The child should typically be part of the returned component tree.
typedef NakiPageBuilder<T extends Component> =
    T Function(BuildContext context, T? child);
