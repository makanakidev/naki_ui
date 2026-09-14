import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Resolves package location, skills source directory, and target
/// project workspace.
class PackageResolver {
  const PackageResolver();

  /// Extracts the version of the `naki_ui` package from its `pubspec.yaml`.
  Future<String?> resolvePackageVersion({String? workspaceRoot}) async {
    final skillsDir = await findSkillsSourceDirectory(workspaceRoot: workspaceRoot);
    if (skillsDir != null) {
      final packageRoot = skillsDir.parent.path;
      final pubspec = File(p.join(packageRoot, 'pubspec.yaml'));

      if (pubspec.existsSync()) {
        try {
          final content = pubspec.readAsStringSync();
          final doc = loadYaml(content);

          if (doc is Map && doc['version'] != null) {
            return doc['version'].toString().trim();
          }
        } catch (_) {}
      }
    }

    final currentProject = workspaceRoot ?? findProjectRoot();
    final localPubspec = File(p.join(currentProject, 'pubspec.yaml'));

    if (localPubspec.existsSync()) {
      try {
        final content = localPubspec.readAsStringSync();
        final doc = loadYaml(content);

        if (doc is Map && doc['name'] == 'naki_ui' && doc['version'] != null) {
          return doc['version'].toString().trim();
        }
      } catch (_) {}
    }

    return null;
  }

  /// Locates the project root directory from [startPath] by walking up parent directories
  /// until a `pubspec.yaml` or `.git` directory is found. Defaults to [Directory.current.path].
  String findProjectRoot([String? startPath]) {
    String current = p.normalize(p.absolute(startPath ?? Directory.current.path));
    final root = p.rootPrefix(current);

    while (true) {
      if (File(p.join(current, 'pubspec.yaml')).existsSync() ||
          Directory(p.join(current, '.git')).existsSync() ||
          Directory(p.join(current, '.agents')).existsSync() ||
          Directory(p.join(current, '.cursor')).existsSync()) {
        return current;
      }

      final parent = p.dirname(current);

      if (parent == current || parent == root) break;

      current = parent;
    }

    return p.normalize(p.absolute(startPath ?? Directory.current.path));
  }

  /// Locates the `skills` source directory provided by `naki_ui`.
  Future<Directory?> findSkillsSourceDirectory({
    String? explicitSourcePath,
    String? workspaceRoot,
  }) async {
    // 1. Explicit source path if provided
    if (explicitSourcePath != null) {
      final dir = Directory(explicitSourcePath);

      if (dir.existsSync()) return dir;

      final nested = Directory(p.join(explicitSourcePath, 'skills'));

      if (nested.existsSync()) return nested;
    }

    final currentProject = workspaceRoot ?? findProjectRoot();

    // 2. If running directly inside the naki_ui repository
    final localSkills = Directory(p.join(currentProject, 'skills'));
    final localPubspec = File(p.join(currentProject, 'pubspec.yaml'));

    if (localPubspec.existsSync()) {
      try {
        final content = localPubspec.readAsStringSync();

        if (content.contains('name: naki_ui') && localSkills.existsSync()) {
          return localSkills;
        }
      } catch (_) {}
    }

    // 3. Look in .dart_tool/package_config.json
    final packageConfigDir = _findPackageConfigFile(currentProject);

    if (packageConfigDir != null) {
      final dir = _resolveFromPackageConfig(packageConfigDir);

      if (dir != null && dir.existsSync()) {
        return dir;
      }
    }

    // 4. Resolve via Dart VM Isolate
    try {
      final uri = await Isolate.resolvePackageUri(
        Uri.parse('package:naki_ui/naki_ui.dart'),
      );

      if (uri != null && uri.scheme == 'file') {
        final libDir = p.dirname(uri.toFilePath());
        final packageRoot = p.dirname(libDir);

        final skillsDir = Directory(p.join(packageRoot, 'skills'));

        if (skillsDir.existsSync()) return skillsDir;
      }
    } catch (_) {}

    // 5. Check relative to current platform script
    // (for global pub activations / snapshots)
    try {
      final scriptUri = Platform.script;

      if (scriptUri.scheme == 'file') {
        String scriptDir = p.dirname(scriptUri.toFilePath());

        // Check up to 3 levels up
        for (int i = 0; i < 3; i++) {
          final candidate = Directory(p.join(scriptDir, 'skills'));

          if (candidate.existsSync()) return candidate;

          final parent = p.dirname(scriptDir);

          if (parent == scriptDir) break;

          scriptDir = parent;
        }
      }
    } catch (_) {}

    // 6. Last resort fallback: check if local directory has skills/
    if (localSkills.existsSync()) {
      return localSkills;
    }

    return null;
  }

  /// Locates the `skills` source directory provided by the `jaspr` package.
  Future<Directory?> findJasprSkillsSourceDirectory({
    String? workspaceRoot,
  }) async {
    final currentProject = workspaceRoot ?? findProjectRoot();

    // 1. Look in .dart_tool/package_config.json
    final packageConfigDir = _findPackageConfigFile(currentProject);
    if (packageConfigDir != null) {
      final dir = _resolvePackageFromConfig(packageConfigDir, 'jaspr');
      if (dir != null && dir.existsSync()) {
        return dir;
      }
    }

    // 2. Resolve via Dart VM Isolate
    try {
      final uri = await Isolate.resolvePackageUri(
        Uri.parse('package:jaspr/jaspr.dart'),
      );
      if (uri != null && uri.scheme == 'file') {
        final libDir = p.dirname(uri.toFilePath());
        final packageRoot = p.dirname(libDir);
        final skillsDir = Directory(p.join(packageRoot, 'skills'));
        if (skillsDir.existsSync()) {
          return skillsDir;
        }
      }
    } catch (_) {}

    return null;
  }

  File? _findPackageConfigFile(String startDir) {
    String current = p.normalize(p.absolute(startDir));
    final root = p.rootPrefix(current);

    while (true) {
      final configFile = File(p.join(current, '.dart_tool', 'package_config.json'));

      if (configFile.existsSync()) {
        return configFile;
      }

      final parent = p.dirname(current);
      if (parent == current || parent == root) break;

      current = parent;
    }

    return null;
  }

  Directory? _resolveFromPackageConfig(File packageConfigFile) {
    return _resolvePackageFromConfig(packageConfigFile, 'naki_ui');
  }

  Directory? _resolvePackageFromConfig(File packageConfigFile, String packageName) {
    try {
      final content = packageConfigFile.readAsStringSync();
      final config = jsonDecode(content) as Map<String, dynamic>;
      final packages = config['packages'] as List<dynamic>?;
      if (packages == null) return null;

      for (final pkg in packages) {
        if (pkg is Map<String, dynamic> && pkg['name'] == packageName) {
          final rootUri = pkg['rootUri'] as String?;
          if (rootUri == null) continue;

          String packageRootPath;
          if (p.isAbsolute(rootUri) || rootUri.startsWith('file://')) {
            packageRootPath = p.fromUri(rootUri);
          } else {
            packageRootPath = p.normalize(
              p.join(p.dirname(packageConfigFile.path), rootUri),
            );
          }

          final skillsDir = Directory(p.join(packageRootPath, 'skills'));
          if (skillsDir.existsSync()) {
            return skillsDir;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
