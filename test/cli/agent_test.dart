import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../../cli/agent.dart';

void main() {
  group('TargetAgent', () {
    test('resolves agents by canonical name', () {
      expect(TargetAgent.fromString('antigravity'), TargetAgent.antigravity);
      expect(TargetAgent.fromString('cursor'), TargetAgent.cursor);
      expect(TargetAgent.fromString('claude-code'), TargetAgent.claudeCode);
      expect(TargetAgent.fromString('cline'), TargetAgent.cline);
      expect(TargetAgent.fromString('codex'), TargetAgent.codex);
      expect(TargetAgent.fromString('copilot'), TargetAgent.copilot);
      expect(TargetAgent.fromString('command-code'), TargetAgent.commandCode);
      expect(TargetAgent.fromString('opencode'), TargetAgent.openCode);
      expect(TargetAgent.fromString('continue'), TargetAgent.continueAgent);
      expect(TargetAgent.fromString('windsurf'), TargetAgent.windsurf);
      expect(TargetAgent.fromString('general'), TargetAgent.general);
    });

    test('resolves agents by aliases and normalized cases', () {
      expect(TargetAgent.fromString('claude'), TargetAgent.claudeCode);
      expect(TargetAgent.fromString('CLAUDE_CODE'), TargetAgent.claudeCode);
      expect(TargetAgent.fromString('generic'), TargetAgent.general);
      expect(TargetAgent.fromString('commandcode'), TargetAgent.commandCode);
      expect(TargetAgent.fromString('open-code'), TargetAgent.openCode);
      expect(TargetAgent.fromString('github-copilot'), TargetAgent.copilot);
      expect(TargetAgent.fromString('nonexistent'), isNull);
    });

    test('returns correct skills relative path', () {
      expect(TargetAgent.antigravity.skillsRelativePath, '.agents/skills');
      expect(TargetAgent.cursor.skillsRelativePath, '.cursor/skills');
      expect(TargetAgent.claudeCode.skillsRelativePath, '.claude/skills');
      expect(TargetAgent.cline.skillsRelativePath, '.cline/skills');
      expect(TargetAgent.copilot.skillsRelativePath, '.github/skills');
      expect(TargetAgent.commandCode.skillsRelativePath, '.commandcode/skills');
      expect(TargetAgent.openCode.skillsRelativePath, '.opencode/skills');
      expect(TargetAgent.continueAgent.skillsRelativePath, '.continue/skills');
      expect(TargetAgent.windsurf.skillsRelativePath, '.windsurf/skills');
    });

    test('detects agent directory markers in project root', () {
      final tempDir = Directory.systemTemp.createTempSync('naki_agent_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      expect(TargetAgent.cursor.isDetected(tempDir.path), isFalse);

      Directory(p.join(tempDir.path, '.cursor')).createSync();
      expect(TargetAgent.cursor.isDetected(tempDir.path), isTrue);

      Directory(p.join(tempDir.path, '.claude')).createSync();
      expect(TargetAgent.claudeCode.isDetected(tempDir.path), isTrue);

      final detected = TargetAgent.detectAll(tempDir.path);
      expect(detected, containsAll([TargetAgent.cursor, TargetAgent.claudeCode]));
    });
  });
}
