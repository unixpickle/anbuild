import 'dart:io';
import 'package:args/args.dart';
import '../lib/anbuild.dart';

ArgParser get argumentParser {
  ArgParser parser = new ArgParser(allowTrailingOptions: true);
  parser.addOption('ccompiler', help: 'Add a C-style compiler to the target',
                   valueHelp: 'name:command:ext1,ext2,...',
                   allowMultiple: true);
  parser.addOption('medium', defaultsTo: 'makefile');
  return parser;
}

void printUsage() {
  stderr.writeln('Usage: anbuild [options] <build.dart>');
  stderr.writeln(argumentParser.getUsage());
  stderr.flush().then((_) {
    exit(1);
  });
  return;
}

void main(List<String> args) {
  ArgResults results;
  try {
    results = argumentParser.parse(args);
    if (results.rest.length != 1) {
      throw '';
    }
  } catch (_) {
    printUsage();
    return;
  }
  
  List<Compiler> compilers = parseCompilers(results['ccompiler']);
  if (compilers == null) return;
  
  ConcreteTarget target = new ConcreteTarget(compilers);
  target.addDependency(results.rest.first);
  target.done().then((_) {
    exit(0);
  }).catchError((e) {
    print('error: $e');
    exit(1);
  });
}

List<Compiler> parseCompilers(String descs) {
  List<Compiler> result = [];
  for (String compilerDesc in descs) {
    List<String> comps = compilerDesc.split(':');
    if (comps.length != 3) {
      stderr.writeln('invalid C-style compiler: $compilerDesc');
      stderr.flush().then((_) {
        exit(1);
      });
      return null;
    }
    List<String> extensions = comps[2].split(',');
    result.add(new CStyleCompiler(comps[0], extensions, comps[1]));
  }
  return result;
}
