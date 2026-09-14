import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../cli/package_resolver.dart';

void main() {
  group('PackageResolver', () {
    const resolver = PackageResolver();

    test('finds project root from nested subdirectory', () {
      final root = resolver.findProjectRoot();
      expect(File(p.join(root, 'pubspec.yaml')).existsSync(), isTrue);
    });

    test('finds skills source directory in repository', () async {
      final skillsDir = await resolver.findSkillsSourceDirectory();
      expect(skillsDir, isNotNull);
      expect(skillsDir!.existsSync(), isTrue);
      expect(Directory(p.join(skillsDir.path, 'naki-ui-framework')).existsSync(), isTrue);
      expect(Directory(p.join(skillsDir.path, 'naki-ui-fundamentals')).existsSync(), isTrue);
      expect(Directory(p.join(skillsDir.path, 'naki-ui-theming')).existsSync(), isTrue);
    });

    test('extracts version dynamically from pubspec.yaml', () async {
      final version = await resolver.resolvePackageVersion();
      expect(version, isNotNull);
      expect(version, '1.0.0');
    });
  });
}
