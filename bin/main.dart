import '../lib/anbuild.dart';
import 'package:args/args.dart';
import 'package:path/path.dart' as path_lib;
import 'dart:io';

void main(List<String> args) {
  if (args.length == 0) {
    dieUsage();
  }
  var results = argumentParser.parse(args);
  if (results.rest.length != 1) {
    dieUsage();
  }
  var scriptPath = path_lib.absolute(results.rest.first);
  var outputDir = path_lib.dirname(scriptPath);
  if (results['output'] != null) {
    outputDir = path_lib.absolute(results['output']);
  }
  runBuild(scriptPath, outputDir, exportMakefile);
}

void runBuild(String script, String outputDir, OutputFormatter formatter) {
  runDependency(path_lib.absolute(script)).then((result) {
    return formatter(outputDir, result);
  }).catchError((e) {
    stderr.writeln('Error: $e');
    exit(1);
  });
}

ArgParser get argumentParser {
  ArgParser parser = new ArgParser(allowTrailingOptions: true);
  parser.addOption('formatter', help: 'The target build system',
      defaultsTo: 'makefile', allowed: ['makefile']);
  parser.addOption('output', help: 'The output directory');
  return parser;
}

void dieUsage() {
  stderr.writeln('Usage: anbuild [options] buildscript.dart');
  stderr.writeln(argumentParser.getUsage());
  exit(1);
}
