import 'dart:io';

import '../cli/naki_command_runner.dart';

Future<void> main(List<String> args) async {
  final runner = NakiCommandRunner();
  final exitCode = await runner.run(args);
  exit(exitCode);
}
