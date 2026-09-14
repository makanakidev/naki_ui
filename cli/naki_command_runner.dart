import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';

import 'logger.dart';
import 'package_resolver.dart';
import 'skills_command.dart';

/// Command runner for the Naki UI CLI.
class NakiCommandRunner extends CommandRunner<int> {
  final CliLogger logger;
  final PackageResolver resolver;

  NakiCommandRunner({
    CliLogger? customLogger,
    this.resolver = const PackageResolver(),
  }) : logger = customLogger ?? CliLogger(),
       super(
         'naki_ui',
         'A modern CLI for Naki UI components, design utilities, and AI agent skills.',
       ) {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the current version of Naki UI.',
    );

    argParser.addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Enable detailed verbose logging.',
    );

    SkillsCommand.configureParser(argParser);

    addCommand(SkillsCommand(resolver: resolver, customLogger: logger));
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final argList = args.toList();

      // If user invoked `naki_ui --antigravity` or `naki_ui --cursor` directly without `skills` subcommand,
      // route gracefully to `skills` subcommand.
      if (argList.isNotEmpty &&
          !argList.contains('help') &&
          !argList.contains('-h') &&
          !argList.contains('--help') &&
          !argList.contains('--version') &&
          !commands.containsKey(argList.first)) {
        // If the first argument is an option like --antigravity or -a
        if (argList.first.startsWith('-')) {
          argList.insert(0, 'skills');
        }
      }

      final argResults = parse(argList);

      if (argResults['version'] == true) {
        final version = await resolver.resolvePackageVersion();
        logger.info('naki_ui version: ${version ?? 'unknown'}');
        return 0;
      }

      return await runCommand(argResults) ?? 0;
    } on UsageException catch (e) {
      logger.error(e.message);
      logger.info('\n${e.usage}');
      return 64; // EX_USAGE
    } catch (e, stackTrace) {
      logger.error('An unexpected error occurred: $e');
      if (logger.isVerbose) {
        logger.error('$stackTrace');
      }
      return 1;
    }
  }

  /// Prints styled header when help is displayed.
  @override
  void printUsage() {
    stdout.writeln(
      '''
${styleBold.wrap(cyan.wrap('Naki UI CLI')!)} - Material-inspired UI & agent skills for Jaspr.

$usage
''',
    );
  }
}
