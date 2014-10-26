part of anbuild;

/**
 * The directory which contains all dependencies.
 * 
 * This directory is unified throughout every target in a project so that
 * dependencies are not duplicated.
 */
String dependencyDirectory = null;

/**
 * Returns the directory of the current target.
 * 
 * For example, if the current isolate is running "/some/project/build.dart",
 * this will be "/some/project".
 */
String get targetDirectory {
  var segments = Platform.script.pathSegments;
  var relPath = segments.join(path_lib.separator);
  return path_lib.dirname(path_lib.separator + relPath);
}

/**
 * Get an absolute path from a target-relative [path].
 * 
 * For example, if [path] is "src/my_file.c" and [targetDirectory] is
 * "/some/project", the result will be "/some/project/src/my_file.c".
 */
String targetAbsolutePath(String path) {
  if (path_lib.isAbsolute(path)) {
    return path;
  }
  return path_lib.normalize(path_lib.join(targetDirectory, path));
}

/**
 * Get an absolute path for a dependency-relative [path].
 * 
 * For example, if [path] is "ansa/build.dart" and [dependencyDirectory] is
 * "/dependencies", this will result in "/dependencies/ansa/build.dart".
 */
String dependencyAbsolutePath(String path) {
  if (path_lib.isAbsolute(path)) {
    return path;
  }
  return path_lib.normalize(path_lib.join(dependencyDirectory, path));
}
