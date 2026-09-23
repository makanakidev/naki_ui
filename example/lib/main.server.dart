import 'package:jaspr/server.dart';

import 'main.dart';
import 'main.server.options.dart';

void main() {
  // Define your application's base path if it is NOT the default '/',
  // or if your application is deployed in a sub-path, i.e. '/app'.
  //
  // For this example app, we define the base path using BASE_PATH environment variable
  // via github actions i.e "jaspr build --dart-define=BASE_PATH=app_base_path".
  const basePath = String.fromEnvironment('BASE_PATH', defaultValue: '/');

  Jaspr.initializeApp(options: defaultServerOptions);

  runApp(
    // Wrap your application root component with Document and pass the
    // base path for SEO and sub-path support.
    //
    // If your application base path is '/', wrapping with Document is
    // not required.
    const Document(
      base: basePath,
      lang: null,
      charset: null,
      viewport: null,
      body: TodoApp(base: basePath),
    ),
  );
}
