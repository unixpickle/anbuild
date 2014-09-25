part of anbuild;

String get scriptDirectory => path_lib.dirname(Platform.script.path);

/**
 * Compute the absolute value of a [path] relative to the current script's
 * directory.
 * 
 * This is different than using the current working directory to compute an
 * absolute path, because this allows paths to be computed on a per-isolate
 * basis.
 */
String absolutePath(String path) {
  if (path_lib.isAbsolute(path)) {
    return path;
  }
  var rawAbsolutePath = path_lib.join(scriptDirectory, path);
  return path_lib.normalize(rawAbsolutePath);
}

/**
 * Compute the relative path to [path] from the current script's directory.
 * 
 * This is different than using the current working directory to compute a
 * relative path, because this allows paths to be computed on a per-isolate
 * basis.
 */
String relativePath(String path) {
  return path_lib.relative(path, from: scriptDirectory);
}
