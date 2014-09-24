part of anbuild;

/**
 * An abstract class which represents the compiler flags, sources, options, and
 * include directories that will be used to create an executable.
 */
abstract class Target {
  /**
   * Add a directory by reading its contents and scanning each contained file
   * with [scanFiles].
   * 
   * If [recursively] is specified as `false`, sub-directories of the given
   * [directory] will not be scanned. The default value of this argument is
   * `true`.
   */
  Future scanDirectory(String directory, {bool recursive: true}) {
    Directory dir = new Directory(directory);
    var listJob = new Directory(directory).list(recursive: recursive,
        followLinks: true).toList();
    return listJob.then((List<FileSystemEntity> entities) {
      return scanFiles(entities.map((e) => e.absolute.path));
    });
  }
  
  /**
   * Add a list of files by "scanning" them (usually just file-extension
   * checking) to figure out which compiler they belong to.
   * 
   * If a compiler cannot be found for a given file, that file will be ignored.
   */
  Future scanFiles(List<String> files);
  
  /**
   * Add a list of [files] to a specified [compiler].
   * 
   * If there is no such [compiler], the files will be ignored.
   */
  void addFiles(String compiler, List<String> files);
  
  /**
   * Add a list of [directories] to the includes list of a given [compiler].
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
