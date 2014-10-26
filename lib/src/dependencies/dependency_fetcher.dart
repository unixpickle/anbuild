part of anbuild;

/**
 * A means of fetching an abstract dependency.
 */
abstract class DependencyFetcher {
  /**
   * The name of the dependency. This is the filename that the dependency will
   * use within the dependencies [directory].
   */
  final String name;
  
  /**
   * A path equivalent to [dependencyDirectory] joined with [name].
   */
  String get dependencyPath => path_lib.join(dependencyDirectory, name);
  
  /**
   * Create a new [DependencyFetcher] with a given dependency [name].
   */
  DependencyFetcher(this.name);
  
  /**
   * If the dependency does not already exist, download it via
   * [downloadDepedency].
   * 
   * This will create the dependencies [directory] if it does not already
   * exist.
   */
  Future fetch() {
    return new Directory(dependencyDirectory).stat().then((info) {
      if (info.type != FileSystemEntityType.DIRECTORY) {
        return new Directory(dependencyDirectory).create();
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
