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
  if (results['formatter'] != 'makefile') {
    stderr.writeln('invalid formatter: ${results['formatter']}');
    dieUsage();
  }
  runBuild(results.rest.first, exportMakefile);
}

void runBuild(String script, OutputFormatter formatter) {
  runDependency(path_lib.absolute(script)).then((result) {
    return formatter(path_lib.dirname(script), result);
  }).catchError((e) {
    stderr.writeln('Error: $e');
    exit(1);
  });
}

ArgParser get argumentParser {
  ArgParser parser = new ArgParser(allowTrailingOptions: true);
  parser.addOption('formatter', help: 'The target build system',
      defaultsTo: 'makefile');
  return parser;
}

void dieUsage() {
  stderr.writeln('Usage: anbuild [options] buildscript.dart');
  stderr.writeln(argumentParser.getUsage());
  exit(1);
}
