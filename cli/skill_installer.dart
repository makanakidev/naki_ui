import 'dart:io';

import 'package:io/ansi.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'agent.dart';
import 'logger.dart';

/// Metadata representation of an agent skill found in the Naki UI package.
class SkillInfo {
  final String name;
  final String description;
  final Directory sourceDir;
  final File skillFile;
  final String? version;

  const SkillInfo({
    required this.name,
    required this.description,
    required this.sourceDir,
    required this.skillFile,
    this.version,
  });

  /// Reads skill metadata from a skill directory.
  static SkillInfo? fromDirectory(Directory dir) {
    final skillFile = File(p.join(dir.path, 'SKILL.md'));
    if (!skillFile.existsSync()) return null;

    final name = p.basename(dir.path);
    String description = 'Naki UI skill';
    String? version;

    try {
      final content = skillFile.readAsStringSync();
      final match = RegExp(
        r'^---\s*\n(.*?)\n---',
        dotAll: true,
      ).firstMatch(content);

      if (match != null) {
        final yamlContent = match.group(1)!;
        final doc = loadYaml(yamlContent);

        if (doc is Map) {
          if (doc['description'] != null) {
            description = doc['description'].toString().trim();
          }

          if (doc['name'] != null) {
            // Can override or match directory name
          }

          if (doc['metadata'] is Map &&
              (doc['metadata'] as Map)['version'] != null) {
            version = (doc['metadata'] as Map)['version'].toString();
          }
        }
      }
    } catch (_) {}

    return SkillInfo(
      name: name,
      description: description,
      sourceDir: dir,
      skillFile: skillFile,
      version: version,
    );
  }
}

/// Result summary of a skill installation or removal operation.
class SkillOperationResult {
  final List<String> added;
  final List<String> updated;
  final List<String> skipped;
  final List<String> removed;
  final List<String> errors;

  const SkillOperationResult({
    this.added = const [],
    this.updated = const [],
    this.skipped = const [],
    this.removed = const [],
    this.errors = const [],
  });

  bool get hasChanges =>
      added.isNotEmpty || updated.isNotEmpty || removed.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;
}

/// Manages scanning, installation, updating, and removal of Naki UI skills.
class SkillInstaller {
  final CliLogger logger;

  const SkillInstaller({required this.logger});

  /// Scans the given source directory for valid skill subdirectories.
  List<SkillInfo> scanSkills(Directory sourceDir) {
    if (!sourceDir.existsSync()) return [];

    final skills = <SkillInfo>[];
    final entities = sourceDir.listSync().whereType<Directory>().toList();
    entities.sort((a, b) => a.path.compareTo(b.path));

    for (final dir in entities) {
      final info = SkillInfo.fromDirectory(dir);
      if (info != null) skills.add(info);
    }

    return skills;
  }

  /// Installs Naki UI skills into the target directory for [agent]
  /// or [customTargetDirectory].
  /// Also checks for and installs companion Jaspr skills if missing.
  Future<SkillOperationResult> install({
    required Directory sourceDir,
    required String projectRoot,
    TargetAgent? agent,
    String? customTargetDirectory,
    String? skillFilter,
    Directory? jasprSourceDir,
    bool includeJaspr = true,
    bool force = false,
    bool dryRun = false,
  }) async {
    final targetDirPath = customTargetDirectory != null
        ? p.normalize(p.absolute(customTargetDirectory))
        : (agent != null
              ? agent.getSkillsDirectory(projectRoot)
              : p.join(projectRoot, '.agents', 'skills'));

    final targetDir = Directory(targetDirPath);
    final availableSkills = scanSkills(sourceDir);

    if (availableSkills.isEmpty) {
      logger.error(
        'No Naki UI skills found in source directory: ${sourceDir.path}',
      );
      return const SkillOperationResult(errors: ['No skills found in source.']);
    }

    final skillsToInstall = skillFilter != null
        ? availableSkills
              .where((s) => s.name.toLowerCase() == skillFilter.toLowerCase())
              .toList()
        : availableSkills;

    if (skillsToInstall.isEmpty && skillFilter != null) {
      logger.error(
        'Skill "$skillFilter" not found. Available skills: ${availableSkills.map((s) => s.name).join(', ')}',
      );
      return SkillOperationResult(errors: ['Skill "$skillFilter" not found.']);
    }

    final added = <String>[];
    final updated = <String>[];
    final skipped = <String>[];
    final errors = <String>[];

    final relativeTarget = p.relative(targetDirPath, from: projectRoot);
    logger.info(
      '${styleBold.wrap('Installing Naki UI skills into')} ${cyan.wrap(relativeTarget)}...',
    );

    if (dryRun) {
      logger.warn('[DRY RUN] No files will be written.');
    }

    if (!dryRun && !targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    for (final skill in skillsToInstall) {
      final skillTargetDir = Directory(p.join(targetDir.path, skill.name));
      final skillTargetFile = File(p.join(skillTargetDir.path, 'SKILL.md'));

      final isExisting =
          skillTargetDir.existsSync() && skillTargetFile.existsSync();

      if (isExisting && !force) {
        // Compare content if not forced
        final sourceContent = skill.skillFile.readAsStringSync();
        final targetContent = skillTargetFile.readAsStringSync();

        if (sourceContent == targetContent) {
          logger.detail('Skill ${skill.name} is already up to date.');
          skipped.add(skill.name);
          continue;
        }
      }

      if (dryRun) {
        if (isExisting) {
          logger.info(
            '  ${yellow.wrap('~')} Would update ${styleBold.wrap(skill.name)}',
          );
          updated.add(skill.name);
        } else {
          logger.info(
            '  ${green.wrap('+')} Would add ${styleBold.wrap(skill.name)}',
          );
          added.add(skill.name);
        }
        continue;
      }

      try {
        if (skillTargetDir.existsSync()) {
          skillTargetDir.deleteSync(recursive: true);
        }
        skillTargetDir.createSync(recursive: true);
        _copyDirectorySync(skill.sourceDir, skillTargetDir);

        if (isExisting) {
          logger.success('Updated ${styleBold.wrap(skill.name)}');
          updated.add(skill.name);
        } else {
          logger.success('Installed ${styleBold.wrap(skill.name)}');
          added.add(skill.name);
        }
      } catch (e) {
        logger.error('Failed to install ${skill.name}: $e');
        errors.add('${skill.name}: $e');
      }
    }

    // Check and install companion Jaspr skills if missing
    if (includeJaspr &&
        jasprSourceDir != null &&
        jasprSourceDir.existsSync() &&
        skillFilter == null) {
      final jasprSkills = scanSkills(jasprSourceDir);
      final missingJasprSkills = <SkillInfo>[];

      for (final js in jasprSkills) {
        final jsTargetFile = File(p.join(targetDir.path, js.name, 'SKILL.md'));
        if (!jsTargetFile.existsSync() || force) {
          missingJasprSkills.add(js);
        }
      }

      if (missingJasprSkills.isNotEmpty) {
        logger.info(
          '\n${styleBold.wrap('Installing missing Jaspr companion skills')} into ${cyan.wrap(relativeTarget)}...',
        );

        for (final skill in missingJasprSkills) {
          final skillTargetDir = Directory(p.join(targetDir.path, skill.name));
          final skillTargetFile = File(p.join(skillTargetDir.path, 'SKILL.md'));
          final isExisting =
              skillTargetDir.existsSync() && skillTargetFile.existsSync();

          if (dryRun) {
            if (isExisting) {
              logger.info(
                '  ${yellow.wrap('~')} Would update companion ${styleBold.wrap(skill.name)}',
              );
              updated.add(skill.name);
            } else {
              logger.info(
                '  ${green.wrap('+')} Would add companion ${styleBold.wrap(skill.name)}',
              );
              added.add(skill.name);
            }
            continue;
          }

          try {
            if (skillTargetDir.existsSync()) {
              skillTargetDir.deleteSync(recursive: true);
            }

            skillTargetDir.createSync(recursive: true);
            _copyDirectorySync(skill.sourceDir, skillTargetDir);

            if (isExisting) {
              logger.success('Updated companion ${styleBold.wrap(skill.name)}');
              updated.add(skill.name);
            } else {
              logger.success(
                'Installed companion ${styleBold.wrap(skill.name)}',
              );
              added.add(skill.name);
            }
          } catch (e) {
            logger.error('Failed to install companion ${skill.name}: $e');
            errors.add('${skill.name}: $e');
          }
        }
      } else {
        logger.detail(
          'All Jaspr companion skills are already installed in $relativeTarget.',
        );
      }
    }

    return SkillOperationResult(
      added: added,
      updated: updated,
      skipped: skipped,
      errors: errors,
    );
  }

  /// Removes Naki UI skills from the target skills directory.
  Future<SkillOperationResult> remove({
    required Directory sourceDir,
    required String projectRoot,
    TargetAgent? agent,
    String? customTargetDirectory,
    String? skillFilter,
    bool dryRun = false,
  }) async {
    final targetDirPath = customTargetDirectory != null
        ? p.normalize(p.absolute(customTargetDirectory))
        : (agent != null
              ? agent.getSkillsDirectory(projectRoot)
              : p.join(projectRoot, '.agents', 'skills'));

    final targetDir = Directory(targetDirPath);
    if (!targetDir.existsSync()) {
      logger.info('Skills directory does not exist: $targetDirPath');
      return const SkillOperationResult();
    }

    final availableSkills = scanSkills(sourceDir);
    final skillsToRemove = skillFilter != null
        ? availableSkills
              .where((s) => s.name.toLowerCase() == skillFilter.toLowerCase())
              .toList()
        : availableSkills;

    final removed = <String>[];
    final errors = <String>[];

    for (final skill in skillsToRemove) {
      final skillTargetDir = Directory(p.join(targetDir.path, skill.name));
      if (!skillTargetDir.existsSync()) continue;

      if (dryRun) {
        logger.info(
          '  ${red.wrap('-')} Would remove ${styleBold.wrap(skill.name)}',
        );
        removed.add(skill.name);
        continue;
      }

      try {
        skillTargetDir.deleteSync(recursive: true);
        logger.success('Removed ${styleBold.wrap(skill.name)}');
        removed.add(skill.name);
      } catch (e) {
        logger.error('Failed to remove ${skill.name}: $e');
        errors.add('${skill.name}: $e');
      }
    }

    return SkillOperationResult(removed: removed, errors: errors);
  }

  void _copyDirectorySync(Directory source, Directory destination) {
    for (final entity in source.listSync(recursive: false)) {
      final destPath = p.join(destination.path, p.basename(entity.path));
      if (entity is File) {
        entity.copySync(destPath);
      } else if (entity is Directory) {
        final subDir = Directory(destPath)..createSync(recursive: true);
        _copyDirectorySync(entity, subDir);
      }
    }
  }
}
