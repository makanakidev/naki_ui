import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../cli/naki_command_runner.dart';

void main() {
  group('SkillsCommand integration', () {
    late Directory tempWorkspace;
    late NakiCommandRunner runner;

    setUp(() {
      tempWorkspace = Directory.systemTemp.createTempSync('naki_cli_test_');
      File(p.join(tempWorkspace.path, 'pubspec.yaml')).writeAsStringSync('''
name: test_app
dependencies:
  jaspr: ^0.23.4
''');
      runner = NakiCommandRunner();
    });

    tearDown(() {
      if (tempWorkspace.existsSync()) {
        tempWorkspace.deleteSync(recursive: true);
      }
    });

    test(
      'installs skills to Antigravity (.agents/skills) via --antigravity',
      () async {
        final code = await runner.run([
          'skills',
          '--antigravity',
          '--project',
          tempWorkspace.path,
        ]);

        expect(code, 0);
        final frameworkSkill = File(
          p.join(
            tempWorkspace.path,
            '.agents',
            'skills',
            'naki-ui-framework',
            'SKILL.md',
          ),
        );
        final themingSkill = File(
          p.join(
            tempWorkspace.path,
            '.agents',
            'skills',
            'naki-ui-theming',
            'SKILL.md',
          ),
        );
        final fundamentalsSkill = File(
          p.join(
            tempWorkspace.path,
            '.agents',
            'skills',
            'naki-ui-fundamentals',
            'SKILL.md',
          ),
        );

        expect(frameworkSkill.existsSync(), isTrue);
        expect(themingSkill.existsSync(), isTrue);
        expect(fundamentalsSkill.existsSync(), isTrue);
      },
    );

    test('installs skills to Cursor (.cursor/skills) via --cursor', () async {
      final code = await runner.run([
        'skills',
        '--cursor',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(
          p.join(
            tempWorkspace.path,
            '.cursor',
            'skills',
            'naki-ui-fundamentals',
          ),
        ).existsSync(),
        isTrue,
      );
    });

    test(
      'installs skills to Claude Code (.claude/skills) via --claude-code and --claude',
      () async {
        final code = await runner.run([
          'skills',
          '--claude-code',
          '--project',
          tempWorkspace.path,
        ]);

        expect(code, 0);
        expect(
          Directory(
            p.join(tempWorkspace.path, '.claude', 'skills', 'naki-ui-theming'),
          ).existsSync(),
          isTrue,
        );
      },
    );

    test('installs skills via --agent copilot (.github/skills)', () async {
      final code = await runner.run([
        'skills',
        '--agent',
        'copilot',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(
          p.join(tempWorkspace.path, '.github', 'skills', 'naki-ui-framework'),
        ).existsSync(),
        isTrue,
      );
    });

    test('installs only a specific skill with --skill', () async {
      final code = await runner.run([
        'skills',
        '--antigravity',
        '--skill',
        'naki-ui-theming',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(
          p.join(tempWorkspace.path, '.agents', 'skills', 'naki-ui-theming'),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          p.join(tempWorkspace.path, '.agents', 'skills', 'naki-ui-framework'),
        ).existsSync(),
        isFalse,
      );
    });

    test('dry run does not write to disk', () async {
      final code = await runner.run([
        'skills',
        '--cursor',
        '--dry-run',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(p.join(tempWorkspace.path, '.cursor', 'skills')).existsSync(),
        isFalse,
      );
    });

    test('removes skills with --clean / --remove', () async {
      // First install
      await runner.run([
        'skills',
        '--antigravity',
        '--project',
        tempWorkspace.path,
      ]);
      expect(
        Directory(
          p.join(tempWorkspace.path, '.agents', 'skills', 'naki-ui-theming'),
        ).existsSync(),
        isTrue,
      );

      // Now remove
      final code = await runner.run([
        'skills',
        '--antigravity',
        '--remove',
        '--project',
        tempWorkspace.path,
      ]);
      expect(code, 0);
      expect(
        Directory(
          p.join(tempWorkspace.path, '.agents', 'skills', 'naki-ui-theming'),
        ).existsSync(),
        isFalse,
      );
    });

    test('auto-detects agent when marker exists in workspace', () async {
      Directory(p.join(tempWorkspace.path, '.cursor')).createSync();

      final code = await runner.run([
        'skills',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(
          p.join(
            tempWorkspace.path,
            '.cursor',
            'skills',
            'naki-ui-fundamentals',
          ),
        ).existsSync(),
        isTrue,
      );
    });

    test('supports naki_ui --version and naki_ui skills --list', () async {
      final versionCode = await runner.run(['--version']);
      expect(versionCode, 0);

      final listCode = await runner.run([
        'skills',
        '--list',
        '--project',
        tempWorkspace.path,
      ]);
      expect(listCode, 0);
    });

    test(
      'installs missing Jaspr companion skills alongside Naki skills',
      () async {
        final code = await runner.run([
          'skills',
          '--cursor',
          '--project',
          tempWorkspace.path,
        ]);

        expect(code, 0);
        // Naki UI skills
        expect(
          Directory(
            p.join(
              tempWorkspace.path,
              '.cursor',
              'skills',
              'naki-ui-fundamentals',
            ),
          ).existsSync(),
          isTrue,
        );
        // Companion Jaspr skills
        expect(
          Directory(
            p.join(
              tempWorkspace.path,
              '.cursor',
              'skills',
              'jaspr-fundamentals',
            ),
          ).existsSync(),
          isTrue,
        );
        expect(
          Directory(
            p.join(tempWorkspace.path, '.cursor', 'skills', 'jaspr-styling'),
          ).existsSync(),
          isTrue,
        );
      },
    );

    test('respects --no-jaspr flag to skip companion skills', () async {
      final code = await runner.run([
        'skills',
        '--cursor',
        '--no-jaspr',
        '--project',
        tempWorkspace.path,
      ]);

      expect(code, 0);
      expect(
        Directory(
          p.join(
            tempWorkspace.path,
            '.cursor',
            'skills',
            'naki-ui-fundamentals',
          ),
        ).existsSync(),
        isTrue,
      );
      expect(
        Directory(
          p.join(tempWorkspace.path, '.cursor', 'skills', 'jaspr-fundamentals'),
        ).existsSync(),
        isFalse,
      );
    });

    test('supports naki_ui --help and naki_ui -h', () async {
      expect(await runner.run(['--help']), 0);
      expect(await runner.run(['-h']), 0);
      expect(await runner.run(['skills', '--help']), 0);
      expect(await runner.run(['skills', '-h']), 0);
    });
  });
}
