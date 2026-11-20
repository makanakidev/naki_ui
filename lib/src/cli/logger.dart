import 'dart:io';

import 'package:io/ansi.dart';

/// Console logger for Naki CLI with formatting, colors, and verbosity control.
class CliLogger {
  final bool isVerbose;
  final Stdout out;
  final Stdout err;

  CliLogger({
    this.isVerbose = false,
    Stdout? out,
    Stdout? err,
  }) : out = out ?? stdout,
       err = err ?? stderr;

  /// Logs a standard informational message.
  void info(String message) {
    out.writeln(message);
  }

  /// Logs a success message with green checkmark.
  void success(String message) {
    out.writeln('${green.wrap('✓')} $message');
  }

  /// Logs a warning message with yellow exclamation.
  void warn(String message) {
    out.writeln('${yellow.wrap('!')} $message');
  }

  /// Logs an error message with red cross.
  void error(String message) {
    err.writeln('${red.wrap('✖')} $message');
  }

  /// Logs detailed debug information when verbose mode is enabled.
  void detail(String message) {
    if (isVerbose) {
      out.writeln('${darkGray.wrap('›')} ${styleDim.wrap(message)}');
    }
  }

  /// Logs an emphasized section title.
  void section(String title) {
    out.writeln('\n${styleBold.wrap(title)}');
  }
}
