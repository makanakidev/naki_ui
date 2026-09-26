import 'dart:io';

import '../cli/naki_command_runner.dart';

Future<void> main(List<String> args) async {
  final runner = NakiCommandRunner();
  // Ensure the skills subcommand is executed
  final fullArgs =
      args.contains('skills') ||
          args.contains('help') ||
          args.contains('--help')
      ? args
      : ['skills', ...args];
  final exitCode = await runner.run(fullArgs);
  exit(exitCode);
}
