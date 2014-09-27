part of anbuild;

/**
 * A means of fetching an abstract dependency.
 */
abstract class DependencyFetcher {
  /**
   * The *dependencies* directory. Usually, this will be something like
   * "/path/to/target/dependencies".
   */
  final String directory;
  
  /**
   * The name of the dependency. This is the filename that the dependency will
   * use within the dependencies [directory].
   */
  final String name;
  
  /**
   * A path equivalent to [directory] joined with [name].
   */
  String get dependencyPath => path_lib.join(directory, name);
  
  /**
   * Create a new [DependencyFetcher] with a given dependency [name].
   * 
   * If you specify the [directory], it will be treated as a target-relative
   * path if it is not absolute. If [directory] is not specified, the
   * target-relative "dependencies" directory will be used.
   */
  DependencyFetcher(this.name, {String directory: null})
      : directory = (directory == null ? targetAbsolutePath('dependencies') :
                     directory);
  
  /**
   * If the dependency does not already exist, download it via
   * [downloadDepedency].
   * 
   * This will create the dependencies [directory] if it does not already
   * exist.
   */
  Future fetch() {
    return new Directory(directory).stat().then((info) {
      if (info.type != FileSystemEntityType.DIRECTORY) {
        return new Directory(directory).create();
      }
    }).then((_) {
      return new File(dependencyPath).stat();
    }).then((info) {
      if (info.type == FileSystemEntityType.NOT_FOUND) {
        return downloadDependency();
      }
    });
  }
  
  /**
   * Download the dependency to [dependencyPath].
   */
  Future downloadDependency();
}
