part of anbuild;

/**
 * Returns the directory of the current target.
 * 
 * For example, if the current isolate is running
 * "/home/user/project/anbuild/main.dart", this will be
 * "/home/user/project".
 */
String get targetDirectory {
  return path_lib.dirname(path_lib.dirname(Platform.script.path));
}

/**
 * Get an absolute path for a target-relative [path].
 * 
 * For example, if [path] is "src/my_file.c" and [targetDirectory] is
 * "/home/user/project", the result will be "/home/user/project/src/my_file.c".
 */
String targetAbsolutePath(String path) {
  if (path_lib.isAbsolute(path)) {
    return path;
  }
  return path_lib.normalize(path_lib.relative(path, from: targetDirectory));
}

/**
 * Get a target-relative path for an absolute [path].
 * 
 * This will throw an [ArgumentError] if [path] is not an absolute path.
 * 
 * For example, if [path] is "/home/user/project/src/my_file.c" and
 * [targetDirectory] is "/home/user/project", the result will be
 * "src/my_file.c".
 */
String targetRelativePath(String path) {
  if (!path_lib.isAbsolute(path)) {
    throw new ArgumentError('path is not absolute: $path');
  }
  return path_lib.relative(path, from: targetDirectory);
}
