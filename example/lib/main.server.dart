import 'package:jaspr/server.dart';

import 'main.dart';
import 'main.server.options.dart';

void main() {
  Jaspr.initializeApp(options: defaultServerOptions);
  runApp(
    const Document(
      base: '/naki_ui',
      body: TodoApp(),
    ),
  );
}
