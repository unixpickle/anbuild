part of anbuild;

class NoBuildDirectoryError extends Error {
  final String expectedPath;
  
  NoBuildDirectoryError(this.expectedPath);
}

class _TargetResult {
  final message;
  
  Map<String, List<String>> get flags => message.flags;
  Map<String, List<String>> get options => message.options;
  Map<String, List<String>> get includes => message.includes;
  Map<String, List<String>> get sources => message.sources;
  List<String> get scanFiles => message.scanFiles;
  
  _TargetResult(this.message) {
    if (!(message is Map)) {
      throw new ArgumentError('invalid message: $message');
    }
    validatePathListMaps();
    validateScanFiles();
  }
  
  void validatePathListMaps() {
    for (String key in ['flags', 'options', 'sources', 'includes']) {
      // message[key] must be a Map<String, List<String>>
      if (!(message[key] is Map)) {
        throw new ArgumentError('invalid $key: ${message[key]}');
      }
      for (var obj in message[key].keys) {
        if (!(obj is String)) {
          throw new ArgumentError('invalid key in $key: $obj');
        }
      }
      for (var value in message[key].values) {
        if (!(value is List)) {
          throw new ArgumentError('invalid value in $key: $value');
        }
        for (var obj in value) {
          if (!(obj is String)) {
            throw new ArgumentError('invalid value in $key: $value');
          }
        }
      }
    }
  }
  
  void validateScanFiles() {
    if (!(message['scanFiles'] is List)) {
      throw new ArgumentError('invalid scanFiles: ${message['scanFiles']}');
    }
    for (var obj in message['scanFiles']) {
      if (!(obj is String)) {
        throw new ArgumentError('invalid scanFile: $obj');
      }
    }
  }
}

class BuildScript {
  final String path;
  final Target target;
  
  ReceivePort _receiver = null;
  
  BuildScript(this.path, this.target);
  
  Future run() {
    if (_receiver != null) {
      throw new StateError('cannot call run() more than once');
    }
    _receiver = new ReceivePort();
    return _createPackagesLink().then((_) {
      Uri launchUri = new Uri.file(path_lib.join(path, 'anbuild',
                                                 'main.dart'));
      return Isolate.spawnUri(launchUri, [], _receiver.sendPort);
    }).then((Isolate i) => _createdIsolate(i));
  }
  
  Future<String> _createPackagesLink() {
    String root = path_lib.join(path, 'anbuild');
    String packagesLink = path_lib.join(root, 'packages');
    return new File(root).stat().then((FileStat stat) {
      if (stat.type != FileSystemEntityType.DIRECTORY) {
        throw new NoBuildDirectoryError(root);
      }
    }).then((_) {
      return new File(packagesLink).exists();
    }).then((bool exists) {
      if (exists) return null;
      String localDir = path_lib.dirname(Platform.script.path);
      String localPackages = path_lib.join(localDir, 'packages');
      return new File(localPackages).resolveSymbolicLinks();
    }).then((String packages) {
      return new Link(packagesLink).create(packages);
    });
  }
  
  Future _createdIsolate(Isolate isolate) {
    return _receiver.first.then((message) {
      _receiver.close();
      _TargetResult result = new _TargetResult(message);
      for (String compiler in result.flags.keys) {
        target.addFlags(compiler, result.flags[compiler]);
      }
      for (String compiler in result.options.keys) {
        target.addOptions(compiler, result.options[compiler]);
      }
      for (String compiler in result.includes.keys) {
        target.addIncludes(compiler, result.includes[compiler]);
      }
      for (String compiler in result.sources.keys) {
        target.addFiles(compiler, result.sources[compiler]);
      }
      return target.scanFiles(result.scanFiles);
    });
  }
}
