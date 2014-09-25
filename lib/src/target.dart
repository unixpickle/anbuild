part of anbuild;

/**
 * An abstract class which represents the compiler flags, sources, options, and
 * include directories that will be used to create an executable.
 */
abstract class Target {
  /**
   * A future which will complete when asynchronous operations on this target
   * complete.
   */
  Future nextTask = new Future.value(null);
  
  /**
   * Indicate that the caller is done operating on this target.
   */
  Future done();
  
  /**
   * Add a dependency asynchronously by running its build script on this
   * target.
   * 
   * The path to the dependency will be resolved using [absolutePath].
   */
  void addDependency(String path) {
    nextTask = nextTask.then((_) {
      return new BuildScript(absolutePath(path), this).run();
    });
  }
  
  /**
   * Add a directory by reading its contents and scanning each contained file
   * with [scanFiles].
   * 
   * The [directory] path will be resolved with [absolutePath].
   * 
   * If [recursively] is specified as `false`, sub-directories of the given
   * [directory] will not be scanned. The default value of this argument is
   * `true`.
   */
  void scanDirectory(String directory, {bool recursive: true}) {
    nextTask = nextTask.then((_) {
      Directory dir = new Directory(absolutePath(directory));
      return dir.list(recursive: recursive, followLinks: true).toList();
    }).then((List<FileSystemEntity> entities) {
      scanFiles(entities.map((e) => e.path));
    });
  }
  
  /**
   * Add a list of files by "scanning" them (usually just file-extension
   * checking) to figure out which compiler they belong to.
   * 
   * The [files] will be resolved with [absolutePath].
   * 
   * If a compiler cannot be found for a given file, that file will be ignored.
   */
  void scanFiles(List<String> files);
  
  /**
   * Add a list of [files] to a specified [compiler].
   * 
   * The [files] will be resolved with [absolutePath].
   * 
   * If there is no such [compiler], the files will be ignored.
   */
  void addFiles(String compiler, List<String> files);
  
  /**
   * Add a list of [directories] to the includes list of a given [compiler].
   * 
   * The [directories] will be resolved with [absolutePath].
   * 
   * If there is no such [compiler], the files will be ignored.
   */
  void addIncludes(String compiler, List<String> directories);
  
  /**
   * Add a list of [options] to a specified [compiler].
   * 
   * If there is no such [compiler], the options will be ignored.
   */
  void addOptions(String compiler, List<String> options);
  
  /**
   * Add a set of [flags] to a specified [compiler].
   * 
   * If there is no such [compiler], the options will be ignored.
   */
  void addFlags(String compiler, List<String> flags);
}
