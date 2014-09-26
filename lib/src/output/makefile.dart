part of anbuild;

/**
 * Export a Makefile that builds a [target] in a [targetRoot] directory.
 */
Future exportMakefile(String targetRoot, TargetResult target) {
  return new _Makefile(targetRoot, target).export();
}

class _Makefile {
  final String targetRoot;
  final TargetResult scanned;
  final StringBuffer buffer = new StringBuffer();
  
  List<String> get cSources => scanned.getSources('c');
  List<String> get cppSources => scanned.getSources('c++');
  List<String> get asmSources => scanned.getSources('asm');
  
  _Makefile(this.targetRoot, TargetResult res)
      : scanned = new TargetResult.from(res);
  
  Future export() {
    return scan().then((_) {
      encodeHeader();
      encodeBody();
      encodeFooter();
      return writeMakefile();
    });
  }
  
  Future scan() {
    return recursivelyScanFiles(scanned.scanSources).then((files) {
      for (String path in files) {
        var extension = path_lib.extension(path);
        if (extension == '.c') {
          scanned.addSources('c', [path]);
        } else if (['.cc', '.C', '.cpp'].contains(extension)) {
          scanned.addSources('c++', [path]);
        } else if (['.s', '.S', '.asm'].contains(extension)) {
          scanned.addSources('asm', [path]);
        }
      }
      scanned.scanSources = [];
    });
  }
  
  void encodeHeader() {
    buffer.write('all: objects/');
    List<String> allSources = [];
    allSources..addAll(cSources)..addAll(cppSources)..addAll(asmSources);
    for (String path in allSources) {
      buffer.write(' ');
      buffer.write(shellEscape(path));
    }
    buffer.write('\n\n' 'objects/: \n\t' 'mkdir objects/\n\n');
  }
  
  void encodeBody() {
    for (var path in cSources) {
      encodeSource(path, 'CC', 'c');
    }
    for (var path in cppSources) {
      encodeSource(path, 'CXX', 'c++');
    }
    for (var path in asmSources) {
      encodeSource(path, 'AS', 'asm');
    }
  }
  
  void encodeSource(String path, String compiler, String language) {
    assert(path_lib.isAbsolute(path));
    var objectName = path_lib.relative(path, from: targetRoot)
        .replaceAll(new RegExp(r'(/|\\|\.)'), '_');
    objectName = 'objects/$objectName.o';
    buffer.write(shellEscape(objectName));
    buffer.write(': ');
    buffer.write(shellEscape(path));
    buffer.write('\n\t\$($compiler) \$(${compiler}FLAGS)');
    
    for (var opt in scanned.getOptions(language)) {
      buffer.write(' ');
      buffer.write(shellEscape(path));
    }
    var addedFlags = new Set<String>();
    for (var flag in scanned.getFlags(language)) {
      if (addedFlags.contains(flag)) {
        continue;
      }
      addedFlags.add(flag);
      buffer.write(' ');
      buffer.write(shellEscape(flag));
    }
    for (var include in scanned.getIncludes(language)) {
      buffer.write(' ');
      buffer.write(shellEscape('-I$include'));
    }
    
    buffer.write(' ');
    buffer.write(shellEscape(path));
    buffer.write(' -o ');
    buffer.write(shellEscape(objectName));
    buffer.write('\n\n');
  }
  
  void encodeFooter() {
    buffer.write('clean:\n\t' 'rm -rf objects/\n\n');
  }
  
  Future writeMakefile() {
    var data = buffer.toString();
    var makefilePath = path_lib.join(targetRoot, 'Makefile');
    return new File(makefilePath).writeAsString(data);
  }
}
