part of anbuild;

class NoBuildDirectoryError extends Error {
  final String expectedPath;
  
  NoBuildDirectoryError(this.expectedPath);
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
      Uri launchUri = new Uri.file(path_lib.join(path, 'main.dart'));
      return Isolate.spawnUri(launchUri, [], _receiver.sendPort);
    }).then((Isolate i) => _createdIsolate(i));
  }
  
  Future<String> _createPackagesLink() {
    String root = path_lib.join(path_lib.dirname(path), 'anbuild');
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
    return _receiver.first.then((object) {
      _receiver.close();
      if (!(object is List)) {
        var err = new ArgumentError('invalid object from isolate: $object');
        return new Future.error(err);
      }
      return Future.forEach(object, (args) {
        if (!(args is List) || args.length == 0 || !(args[0] is String)) {
          var err = new ArgumentError('invalid command: $args');
          return new Future.error(err);
        }
        return _handleCommand(args);
      });
    });
  }
  
  Future _handleCommand(List args) {
    var commandHandlers = {'includes': _addIncludes,
                           'sources': _addSources,
                           'sourcesTo': _addSourcesToCompilers,
                           'sourceDirs': _addSourceDirectories,
                           'flags': _addFlags};
    Function handler = commandHandlers[args[0]];
    if (handler != null) {
      return handler(args.sublist(1));
    } else {
      var err = new ArgumentError('unknown command: ${args[0]}');
      return new Future.error(err);
    }
  }
  
  Future _addIncludes(List args) {
    return _validateDoubleStrings(args).then((_) {
      return target.addIncludes(args[0], args[1]);
    });
  }
  
  Future _addSources(List args) {
    return _validateStrings(args).then((_) {
      return target.addSources(args);
    });
  }
  
  Future _addSourcesToCompilers(List args) {
    return _validateDoubleStrings(args).then((_) {
      return target.addSourcesToCompilers(args[0], args[1]);
    });
  }
  
  Future _addSourceDirectories(List args) {
    return _validateStrings(args).then((_) {
      return target.addSourceDirectories(args);
    });
  }
  
  Future _addFlags(List args) {
    return _validateDoubleStrings(args).then((_) {
      return target.addFlags(args[0], args[1]);
    });
  }
  
  Future _validateStrings(List args) {
    for (var arg in args) {
      if (!(arg is String)) {
        return new Future.error(new ArgumentError('invalid argument: $arg'));
      }
    }
    return new Future.value(null);
  }
  
  Future _validateDoubleStrings(List args) {
    if (args.length != 2) {
      return new Future.error(new ArgumentError('invalid argument count: ' +
          args.length.toString()));
    }
    if (!(args[0] is List) || !(args[1] is List)) {
      return new Future.error(new ArgumentError('invalid arguments: $args'));
    }
    return Future.wait([_validateStrings(args[0]), _validateStrings(args[1])]);
  }
}
