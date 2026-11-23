import 'dart:async';

import 'package:jaspr/dom.dart' hide Padding;
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_icons_pack/jaspr_icons_pack.dart';
import 'package:universal_web/web.dart' hide Table;

import '../../framework/framework/index.dart';
import '../../framework/inherited/index.dart';
import '../../framework/overlay_stack.dart';
import '../../models/gesture.dart';
import '../../models/naki/index.dart';
import '../../models/scrolling/index.dart' show TableRow;
import '../../models/styling/index.dart';
import '../../styles/text_style.dart';
import '../../theme/tokens.dart' show Tokens;
import '../../utilities/constants.dart';
import '../../utilities/debounce.dart';
import '../../utilities/enums/index.dart';
import '../../utilities/extensions/index.dart';
import '../../utilities/helpers/index.dart';

import '../basics/index.dart';
import '../layout/index.dart';
import '../overlays/index.dart';
import '../scrolling/index.dart';
import '../selection/index.dart';

import 'styles.dart';

part 'autocomplete_field.dart';
part 'calendar/calendar.dart';
part 'calendar/calendar_grid.dart';
part 'calendar/calendar_header.dart';
part 'calendar/calendar_time_picker.dart';
part 'calendar/calendar_year_month_picker.dart';
part 'form_builder.dart';
part 'label.dart';
part 'segmented_input.dart';
part 'text_field.dart';

// event handlers argument type based on InputType:
//  - `bool` for checkbox and radio
//  - `double` for number and range
//  - `List<File>` for file
//  - `Color` for color
//  - `String` for others

/// Signature for callbacks that validate form field.
typedef FieldValidator<T> = String? Function(T value);
