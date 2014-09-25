part of anbuild;

/**
 * Manage a target's *packages* directory.
 */
class _PackagesDirectory {
  /**
   * The path to the packages directory to manage.
   */
  final String path;
  
  /**
   * Will be `true` after [create] has succeeded at least once on this
   * instance.
   */
  bool created = false;
  
  /**
   * The path to the current script's packages directory.
   */
  String get localPath => targetAbsolutePath('packages');
  
  /**
   * Create a new [_PackagesDirectory] which will create a new directory at a
   * specified [path].
   */
  _PackagesDirectory(this.path);
  
  /**
   * Create the new package directory and give it all the packages it needs to
   * run anbuild.
   */
  Future create() {
    return new File(path).exists().then((exists) {
      if (exists) {
        throw new FileSystemException('packages/ already exists', path);
      }
    }).then((_) {
      return new Directory(path).create();
    }).then((_) {
      return hasReflectivePackage();
    }).then((reflective) {
      if (!reflective) {
        return createReflectivePackage();
      } else {
        return null;
      }
    }).then((_) {
      return linkLocalPackages();
    }).then((_) {
      created = true;
    });
  }
  
  /**
   * Delete the directory at [path].
   */
  Future delete() {
    return new Directory(path).delete(recursive: true);
  }
  
  /**
   * "Reflective" in this case means that the packages directory includes a
   * link to anbuild itself.
   */
  Future<bool> hasReflectivePackage() {
    return new Link(path_lib.join(localPath, 'anbuild')).stat().then((info) {
      return info.type != FileSystemEntityType.NOT_FOUND;
    });
  }
  
  /**
   * Create a "reflective" link in the case that the packages directory does
   * not include one.
   */
  Future createReflectivePackage() {
    var anbuildPath = targetAbsolutePath('../lib');
    // Make sure the anbuild path exists before we link to it.
    return new Directory(anbuildPath).exists().then((exists) {
      if (!exists) {
        throw new StateError('missing ../lib directory!');
      }
    }).then((_) {
      return new Link(path_lib.join(path, 'anbuild')).create(anbuildPath);
    });
  }
  
  /**
   * Iterates through this target's packages and links each one to the
   * new packages directory.
   */
  Future linkLocalPackages() {
    // List every package in our packages directory.
    var listStream = new Directory(localPath).list();
    var entities = null;
    return listStream.toList().then((res) {
      // Resolve every symbolic link in the packages directory so that we don't
      // have deepening levels of symbolic links.
      entities = res;
      return Future.wait(res.map((e) => e.resolveSymbolicLinks()));
    }).then((resolved) {
      assert(resolved.length == entities.length);
      var waiting = [];
      for (int i = 0; i < resolved.length; ++i) {
        // Use the name from the packages directory as the name for the newly
        // created link, since Pub might give the actual package directory a
        // weird name.
        var packageName = path_lib.basename(entities[i].path);
        var sourcePath = resolved[i].absolute.path;
        var link = new Link(path_lib.join(path, packageName));
        waiting.add(link.create(sourcePath));
      }
      return Future.wait(waiting);
    });
  }
}
