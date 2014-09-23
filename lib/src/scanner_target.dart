part of anbuild;

class ScannerTarget implements Target {
  final List<Compiler> compilers;
  final Map<Compiler, List<String>> sources = {};
  final Map<Compiler, List<String>> includes = {};
  
  ScannerTarget(this.compilers);
  
  Future addSourceDirectories(List<String> directories) {
    return Future.wait(directories.map(_addSourceDirectory));
  }
  
  Future addSources(List<String> files) {
    // TODO: this
  }
  
  Future addSourcesToCompilers(List<String> compilers, List<String> files) {
    // TODO: this
  }
  
  Future addIncludes(List<String> compilers, List<String> directories) {
    // TODO: this
  }
  
  Future addFlags(List<String> compilers, List<String> flags) {
    // TODO: this
  }
  
  Future _addSourceDirectory(String directory) {
    var stream = new Directory(directory).list(followLinks: true);
    return stream.toList().then((List<FileSystemEntity> entities) {
      return Future.forEach(entities, (e) {
        return e.stat().then((FileStat stat) {
          if (stat.type == FileSystemEntityType.FILE) {
            _addSource(e.absolute.path);
            return new Future.value(null);
          } else if (stat.type == FileSystemEntityType.DIRECTORY) {
            return _addSourceDirectory(e.absolute.path);
          } else {
            return new Future.value(null);
          }
        });
      });
    });
  }
  
  void _addSource(String file) {
    for (Compiler c in compilers) {
      if (c.usesExtension(path_lib.extension(file))) {
        // TODO: this needs to get done
        return;
      }
    }
  }
}
