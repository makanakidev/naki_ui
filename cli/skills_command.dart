import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/ansi.dart';

import 'agent.dart';
import 'logger.dart';
import 'package_resolver.dart';
import 'skill_installer.dart';

/// Command to install, inspect, update, and manage Naki UI skills for AI agents.
class SkillsCommand extends Command<int> {
  final PackageResolver resolver;
  final CliLogger? customLogger;

  @override
  final String name = 'skills';

  @override
  final List<String> aliases = const ['install-skills', 'skill'];

  @override
  final String description = 'Installs and manages Naki UI skills for AI coding agents.';

  @override
  final String invocation = 'naki_ui skills [arguments]';

  SkillsCommand({
    this.resolver = const PackageResolver(),
    this.customLogger,
  }) {
    configureParser(argParser);
  }

  /// Configures CLI options and flags for skills installation on [argParser].
  static void configureParser(ArgParser argParser) {
    argParser.addOption(
      'agent',
      abbr: 'a',
      help: 'The AI agent to install skills for.',
      allowed: TargetAgent.allCliNames,
    );

    // Add direct flags for every agent: --antigravity, --cursor, --claude-code, etc.
    for (final agent in TargetAgent.values) {
      if (!argParser.options.containsKey(agent.cliName)) {
        argParser.addFlag(
          agent.cliName,
          negatable: false,
          help: 'Install skills for ${agent.displayName} (${agent.skillsRelativePath}).',
        );
      }

      for (final alias in agent.aliases) {
        if (alias != agent.cliName && !argParser.options.containsKey(alias)) {
          argParser.addFlag(
            alias,
            negatable: false,
            help: 'Alias for --${agent.cliName}.',
          );
        }
      }
    }

    if (!argParser.options.containsKey('list')) {
      argParser.addFlag(
        'list',
        abbr: 'l',
        negatable: false,
        help: 'List all available Naki UI skills and their descriptions.',
      );
    }

    if (!argParser.options.containsKey('skill')) {
      argParser.addOption(
        'skill',
        abbr: 's',
        help: 'Install or remove only a specific skill by name (e.g. naki-ui-theming).',
      );
    }

    if (!argParser.options.containsKey('target')) {
      argParser.addOption(
        'target',
        abbr: 't',
        help: 'Custom target directory for skills.',
      );
    }

    if (!argParser.options.containsKey('all')) {
      argParser.addFlag(
        'all',
        negatable: false,
        help: 'Install skills for all detected agents in the workspace.',
      );
    }

    if (!argParser.options.containsKey('force')) {
      argParser.addFlag(
        'force',
        abbr: 'f',
        negatable: false,
        help: 'Force overwrite existing skills even if unchanged.',
      );
    }

    if (!argParser.options.containsKey('dry-run')) {
      argParser.addFlag(
        'dry-run',
        negatable: false,
        help: 'Preview changes without modifying the filesystem.',
      );
    }

    if (!argParser.options.containsKey('remove')) {
      argParser.addFlag(
        'remove',
        negatable: false,
        help: 'Remove installed Naki UI skills from the target agent directory.',
      );
    }

    if (!argParser.options.containsKey('clean')) {
      argParser.addFlag(
        'clean',
        negatable: false,
        help: 'Alias for --remove.',
      );
    }

    if (!argParser.options.containsKey('jaspr')) {
      argParser.addFlag(
        'jaspr',
        defaultsTo: true,
        help:
            'Automatically install companion Jaspr skills if not found in the target agent directory.',
      );
    }

    if (!argParser.options.containsKey('source')) {
      argParser.addOption(
        'source',
        help: 'Explicit path to the Naki UI skills source directory.',
        hide: true,
      );
    }

    if (!argParser.options.containsKey('jaspr-source')) {
      argParser.addOption(
        'jaspr-source',
        help: 'Explicit path to the Jaspr skills source directory.',
        hide: true,
      );
    }

    if (!argParser.options.containsKey('project')) {
      argParser.addOption(
        'project',
        help: 'Target project workspace directory.',
        hide: true,
      );
    }
  }

  @override
  Future<int> run() async {
    final isVerbose = (globalResults?['verbose'] as bool?) ?? false;
    final logger = customLogger ?? CliLogger(isVerbose: isVerbose);
    final installer = SkillInstaller(logger: logger);

    final projectRoot = resolver.findProjectRoot(
      argResults?['project'] as String?,
    );

    logger.detail('Project root resolved to: $projectRoot');

    final sourceDir = await resolver.findSkillsSourceDirectory(
      explicitSourcePath: argResults?['source'] as String?,
      workspaceRoot: projectRoot,
    );

    if (sourceDir == null || !sourceDir.existsSync()) {
      logger.error('Could not locate the Naki UI skills source directory.');
      logger.info(
        'Ensure naki_ui is installed as a dependency or run from the naki_ui repository.',
      );

      return 1;
    }

    logger.detail('Skills source directory: ${sourceDir.path}');

    // Handle --list
    if (argResults?['list'] == true) {
      return _handleList(sourceDir, installer, logger);
    }

    final isRemove = (argResults?['remove'] == true) || (argResults?['clean'] == true);
    final isDryRun = (argResults?['dry-run'] == true);
    final isForce = (argResults?['force'] == true);
    final skillFilter = argResults?['skill'] as String?;
    final customTarget = argResults?['target'] as String?;
    final isAll = (argResults?['all'] == true);

    // Resolve target agent(s)
    final agentsToInstall = <TargetAgent>[];

    if (customTarget == null) {
      if (isAll) {
        final detected = TargetAgent.detectAll(projectRoot);
        if (detected.isNotEmpty) {
          agentsToInstall.addAll(detected);
        } else {
          // Default to antigravity/general
          agentsToInstall.add(TargetAgent.antigravity);
        }
      } else {
        // 1. Check direct flags: --antigravity, --cursor, etc.
        for (final agent in TargetAgent.values) {
          if (argResults?[agent.cliName] == true) {
            agentsToInstall.add(agent);
          } else {
            for (final alias in agent.aliases) {
              if (argResults?.wasParsed(alias) == true && argResults?[alias] == true) {
                agentsToInstall.add(agent);
                break;
              }
            }
          }
        }

        // 2. Check --agent <name>
        final requestedAgent = argResults?['agent'] as String?;
        if (requestedAgent != null) {
          final agent = TargetAgent.fromString(requestedAgent);
          if (agent != null && !agentsToInstall.contains(agent)) {
            agentsToInstall.add(agent);
          } else if (agent == null) {
            logger.error('Unknown agent "$requestedAgent".');
            logger.info('Supported agents: ${TargetAgent.allCliNames.join(', ')}');
            return 1;
          }
        }

        // 3. Auto-detect if no agent was specified
        if (agentsToInstall.isEmpty) {
          final detected = TargetAgent.detect(projectRoot);
          if (detected != null) {
            logger.info(
              'Auto-detected agent: ${cyan.wrap(detected.displayName)} (${detected.skillsRelativePath})',
            );
            agentsToInstall.add(detected);
          } else {
            // Default to Antigravity / General Agent Skills standard
            logger.info(
              'No specific agent directory detected. Defaulting to ${cyan.wrap('.agents/skills')} (Agent Skills Standard).',
            );
            agentsToInstall.add(TargetAgent.antigravity);
          }
        }
      }
    }

    final jasprExplicit = argResults?['jaspr-source'] as String?;
    final jasprSourceDir = jasprExplicit != null
        ? Directory(jasprExplicit)
        : await resolver.findJasprSkillsSourceDirectory(workspaceRoot: projectRoot);
    final includeJaspr = (argResults?['jaspr'] as bool?) ?? true;

    if (customTarget != null) {
      if (isRemove) {
        final res = await installer.remove(
          sourceDir: sourceDir,
          projectRoot: projectRoot,
          customTargetDirectory: customTarget,
          skillFilter: skillFilter,
          dryRun: isDryRun,
        );
        if (res.hasErrors) exitCode = 1;
      } else {
        final res = await installer.install(
          sourceDir: sourceDir,
          projectRoot: projectRoot,
          customTargetDirectory: customTarget,
          skillFilter: skillFilter,
          jasprSourceDir: jasprSourceDir,
          includeJaspr: includeJaspr,
          force: isForce,
          dryRun: isDryRun,
        );
        if (res.hasErrors) exitCode = 1;
      }
    } else {
      for (final agent in agentsToInstall) {
        if (isRemove) {
          final res = await installer.remove(
            sourceDir: sourceDir,
            projectRoot: projectRoot,
            agent: agent,
            skillFilter: skillFilter,
            dryRun: isDryRun,
          );
          if (res.hasErrors) exitCode = 1;
        } else {
          final res = await installer.install(
            sourceDir: sourceDir,
            projectRoot: projectRoot,
            agent: agent,
            skillFilter: skillFilter,
            jasprSourceDir: jasprSourceDir,
            includeJaspr: includeJaspr,
            force: isForce,
            dryRun: isDryRun,
          );
          if (res.hasErrors) exitCode = 1;
        }
      }
    }

    if (exitCode == 0 && !isDryRun && !isRemove) {
      logger.info(
        '\n${green.wrap('✓ Done!')} Naki UI skills are ready to assist your AI coding agent.',
      );
    }

    return exitCode;
  }

  int _handleList(
    Directory sourceDir,
    SkillInstaller installer,
    CliLogger logger,
  ) {
    final skills = installer.scanSkills(sourceDir);

    if (skills.isEmpty) {
      logger.info('No skills found in ${sourceDir.path}.');
      return 0;
    }

    logger.section('Available Naki UI Skills (${skills.length}):');

    for (final skill in skills) {
      logger.info('\n  ${styleBold.wrap(cyan.wrap(skill.name)!)}');
      logger.info('  ${skill.description}');
    }

    logger.info('');
    return 0;
  }
}
