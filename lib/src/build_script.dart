part of anbuild;

class NoBuildDirectoryError extends Error {
  final String expectedPath;
  
  NoBuildDirectoryError(this.expectedPath);
  
  String toString() => 'NoBuildDirectoryError: $expectedPath';
}

class _TargetResult {
  final message;
  
  Map<String, List<String>> get flags => message['flags'];
  Map<String, List<String>> get options => message['options'];
  Map<String, List<String>> get includes => message['includes'];
  Map<String, List<String>> get sources => message['sources'];
  List<String> get scanFiles => message['scanFiles'];
  
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
    Completer c = new Completer();
    _createPackagesLink().then((_) {
      Uri launchUri = new Uri.file(path_lib.join(path, 'anbuild',
                                                 'main.dart'));
      return Isolate.spawnUri(launchUri, [], _receiver.sendPort);
    }).then((Isolate i) => _createdIsolate(i)).then((_) {
      return _deletePackagesLink().then((_) {
        c.complete();
      }).catchError((e) => c.completeError(e));
    }).catchError((e) {
      return _deletePackagesLink().whenComplete(() {
        c.completeError(e);
      }).catchError((_) {});
    });
    return c.future;
  }
  
  Future<String> _createPackagesLink() {
    String root = path_lib.join(path, 'anbuild');
    String packagesDir = path_lib.join(root, 'packages');
    return new File(root).stat().then((FileStat stat) {
      if (stat.type != FileSystemEntityType.DIRECTORY) {
        throw new NoBuildDirectoryError(root);
      }
    }).then((_) {
      return new File(packagesDir).exists();
    }).then((bool exists) {
      if (exists) return null;
      return new Directory(packagesDir).create();
    }).then((_) {
      String anarchPath;
      if (target is ParentTarget) {
        anarchPath = absolutePath('packages/anarch');
      } else {
        anarchPath = absolutePath('../lib');
      }
      return new Directory(anarchPath).resolveSymbolicLinks();
    }).then((String target) {
      return new Link(path_lib.join(packagesDir, 'anbuild')).create(target);
    }).then((_) {
      String localPackages = absolutePath('packages');
      return new Directory(localPackages).list(followLinks: false).toList();
    }).then((List<FileSystemEntity> entities) {
      return Future.forEach(entities, (FileSystemEntity ent) {
        String baseName = path_lib.basename(ent.path);
        if (baseName == 'anbuild' || baseName.startsWith('.')) {
          return new Future.value(null);
        }
        return new Link(path_lib.join(packagesDir, baseName)).create(ent.path);
      });
    });
  }
  
  Future _deletePackagesLink() {
    String packagesDir = path_lib.join(path, 'anbuild', 'packages');
    return new Directory(packagesDir).delete(recursive: true);
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
