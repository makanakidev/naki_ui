import 'dart:io';

import 'package:path/path.dart' as p;

/// Supported AI agents and their target skill directory conventions.
enum TargetAgent {
  antigravity(
    cliName: 'antigravity',
    displayName: 'Antigravity',
    skillsRelativePath: '.agents/skills',
    aliases: ['antigravity'],
    directoryMarkers: ['.agents'],
  ),
  cursor(
    cliName: 'cursor',
    displayName: 'Cursor',
    skillsRelativePath: '.cursor/skills',
    aliases: ['cursor'],
    directoryMarkers: ['.cursor'],
  ),
  claudeCode(
    cliName: 'claude-code',
    displayName: 'Claude Code',
    skillsRelativePath: '.claude/skills',
    aliases: ['claude-code', 'claude'],
    directoryMarkers: ['.claude'],
  ),
  cline(
    cliName: 'cline',
    displayName: 'Cline',
    skillsRelativePath: '.cline/skills',
    aliases: ['cline'],
    directoryMarkers: ['.cline', '.clinerules'],
  ),
  codex(
    cliName: 'codex',
    displayName: 'Codex',
    skillsRelativePath: '.agents/skills',
    aliases: ['codex'],
    directoryMarkers: ['.agents'],
  ),
  copilot(
    cliName: 'copilot',
    displayName: 'GitHub Copilot',
    skillsRelativePath: '.github/skills',
    aliases: ['copilot', 'github-copilot'],
    directoryMarkers: ['.github'],
  ),
  commandCode(
    cliName: 'command-code',
    displayName: 'Command Code',
    skillsRelativePath: '.commandcode/skills',
    aliases: ['command-code', 'commandcode'],
    directoryMarkers: ['.commandcode'],
  ),
  openCode(
    cliName: 'opencode',
    displayName: 'OpenCode',
    skillsRelativePath: '.opencode/skills',
    aliases: ['opencode', 'open-code'],
    directoryMarkers: ['.opencode'],
  ),
  continueAgent(
    cliName: 'continue',
    displayName: 'Continue',
    skillsRelativePath: '.continue/skills',
    aliases: ['continue'],
    directoryMarkers: ['.continue'],
  ),
  windsurf(
    cliName: 'windsurf',
    displayName: 'Windsurf',
    skillsRelativePath: '.windsurf/skills',
    aliases: ['windsurf'],
    directoryMarkers: ['.windsurf'],
  ),
  general(
    cliName: 'general',
    displayName: 'General / Agent Skills Standard',
    skillsRelativePath: '.agents/skills',
    aliases: ['general', 'generic'],
    directoryMarkers: ['.agents'],
  )
  ;

  final String cliName;
  final String displayName;
  final String skillsRelativePath;
  final List<String> aliases;
  final List<String> directoryMarkers;

  const TargetAgent({
    required this.cliName,
    required this.displayName,
    required this.skillsRelativePath,
    required this.aliases,
    required this.directoryMarkers,
  });

  /// Resolves the absolute path for this agent's skills directory.
  String getSkillsDirectory(String projectRoot) {
    return p.normalize(p.join(projectRoot, skillsRelativePath));
  }

  /// Checks if this agent's configuration or skills directory exists in [projectRoot].
  bool isDetected(String projectRoot) {
    // If skills folder itself exists, it's definitely detected
    if (Directory(getSkillsDirectory(projectRoot)).existsSync()) {
      return true;
    }

    // Check marker directories (e.g. .agents, .cursor, .claude, etc.)
    for (final marker in directoryMarkers) {
      if (marker == '.github') {
        // Only auto-detect copilot if .github/skills exists or .github/copilot-instructions.md exists
        // because .github is used for generic workflows.
        if (Directory(p.join(projectRoot, '.github', 'skills')).existsSync() ||
            File(
              p.join(projectRoot, '.github', 'copilot-instructions.md'),
            ).existsSync()) {
          return true;
        }

        continue;
      }

      final markerPath = p.join(projectRoot, marker);
      if (Directory(markerPath).existsSync() || File(markerPath).existsSync()) {
        return true;
      }
    }

    return false;
  }

  /// Looks up a [TargetAgent] by CLI name or alias (case-insensitive).
  static TargetAgent? fromString(String name) {
    final normalized = name.trim().toLowerCase().replaceAll('_', '-');

    for (final agent in TargetAgent.values) {
      if (agent.cliName == normalized) return agent;

      if (agent.aliases.any((alias) => alias.toLowerCase() == normalized)) {
        return agent;
      }
    }

    return null;
  }

  /// All unique CLI option names across all agents.
  static List<String> get allCliNames =>
      TargetAgent.values.map((e) => e.cliName).toList();

  /// All registered alias names and canonical names.
  static List<String> get allSupportedNames => TargetAgent.values
      .expand((e) => [e.cliName, ...e.aliases])
      .toSet()
      .toList();

  /// Detects all matching agents present in [projectRoot].
  static List<TargetAgent> detectAll(String projectRoot) {
    return TargetAgent.values
        .where((agent) => agent.isDetected(projectRoot))
        .toList();
  }

  /// Auto-detects the most suitable agent for [projectRoot].
  static TargetAgent? detect(String projectRoot) {
    final matches = detectAll(projectRoot);

    if (matches.isEmpty) return null;

    // If only one match, return it
    if (matches.length == 1) return matches.first;

    // Preference hierarchy if multiple directory markers are present:
    // 1. Antigravity / General (.agents)
    // 2. Cursor (.cursor)
    // 3. Claude (.claude)
    // 4. Cline (.cline)
    // 5. OpenCode / Windsurf / Continue / Copilot
    if (matches.contains(TargetAgent.antigravity)) {
      return TargetAgent.antigravity;
    }

    if (matches.contains(TargetAgent.cursor)) {
      return TargetAgent.cursor;
    }

    if (matches.contains(TargetAgent.claudeCode)) {
      return TargetAgent.claudeCode;
    }

    return matches.first;
  }
}
