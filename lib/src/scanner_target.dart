part of anbuild;

class ConcreteTarget extends Target {
  final Map<String, Compiler> compilers = {};
  final Map<String, List<String>> sources = {};
  
  ConcreteTarget(Iterable<Compiler> theCompilers) {
    for (Compiler c in theCompilers) {
      compilers[c.name] = c;
      sources[c.name] = [];
    }
  }
  
  Future scanFiles(List<String> files) {
    return Future.wait(files.map((f) => new File(f).stat())).then((stats) {
      assert(stats.length == files.length);
      for (int i = 0; i < stats.length; ++i) {
        if (stats[i].type != FileSystemEntityType.FILE) {
          continue;
        }
        _scanFile(files[i]);
      }
    });
  }
  
  void addFiles(String compiler, List<String> files) {
    for (String f in files) {
      _addFile(compiler, f);
    }
  }
  
  void addIncludes(String compiler, List<String> directories) {
    Compiler c = compilers[compiler];
    if (c != null) {
      c.addIncludes(directories);
    }
  }
  
  void addOptions(String compiler, List<String> options) {
    Compiler c = compilers[compiler];
    if (c != null) {
      c.addOptions(options);
    }
  }
  
  void addFlags(String compiler, List<String> flags) {
    Compiler c = compilers[compiler];
    if (c != null) {
      c.addFlags(flags);
    }
  }
  
  void _scanFile(String path) {
    for (Compiler c in compilers.values) {
      if (c.fileExtensions.contains(path_lib.extension(path))) {
        _addFile(c.name, path);
        return;
      }
    }
  }
  
  void _addFile(String compiler, String path) {
    var list = sources[compiler];
    if (list != null) {
      list.add(path);
    }
  }
}
