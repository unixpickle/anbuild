part of anbuild;

/**
 * Returns the directory of the current target.
 * 
 * For example, if the current isolate is running "/some/project/build.dart",
 * this will be "/some/project".
 */
String get targetDirectory {
  return path_lib.dirname(Platform.script.path);
}

/**
 * Get an absolute path for a target-relative [path].
 * 
 * For example, if [path] is "src/my_file.c" and [targetDirectory] is
 * "/some/project", the result will be "/some/project/src/my_file.c".
 */
String targetAbsolutePath(String path) {
  if (path_lib.isAbsolute(path)) {
    return path;
  }
  return path_lib.normalize(path_lib.relative(path, from: targetDirectory));
}
