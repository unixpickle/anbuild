part of anbuild;

/**
 * Scans a bunch of source files.
 * 
 * The future will return with a list of absolute file paths to individual
 * files. Paths to directories will not be returned.
 * 
 * This will NOT follow symbolic links.
 */
Future<List<String>> recursivelyScanFiles(Iterable<String> scanFiles) {
  var result = [];
  return Future.forEach(scanFiles, (file) {
    return new File(file).stat().then((stats) {
      if (stats.type == FileSystemEntityType.DIRECTORY) {
        var listing = new Directory(file).list();
        return listing.map((x) => x.absolute.path).toList().then((paths) {
          return recursivelyScanFiles(paths);
        });
      } else if (stats.type == FileSystemEntityType.FILE) {
        return [targetAbsolutePath(file)];
      } else {
        return [];
      }
    }).then((someFiles) => result.addAll(someFiles));
  }).then((_) => result);
}
