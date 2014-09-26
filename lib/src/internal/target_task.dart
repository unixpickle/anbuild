part of anbuild;

/**
 * A target which runs in a separate isolate.
 */
class _TargetTask {
  /**
   * The path to the target's root directory.
   */
  final String targetDirectory;
  
  /**
   * The path to the target's main build script.
   */
  final String scriptMain;
  
  /**
   * The target's packages directory.
   */
  _PackagesDirectory packages;
  
  /**
   * The port on which the target result will be received.
   */
  final ReceivePort incoming = new ReceivePort();
  
  /**
   * Create a new task with a [scriptMain] path.
   * 
   * The [targetDirectory] and [packages] will be computed using the script's
   * path.
   */
  _TargetTask(String scriptMain)
      : scriptMain = scriptMain,
        targetDirectory = path_lib.dirname(scriptMain) {
    assert(path_lib.isAbsolute(scriptMain));
    packages = new _PackagesDirectory(path_lib.join(targetDirectory,
                                                    'packages'));
  }
  
  /**
   * Run the build script in an isolate.
   * 
   * You should only call [run] once per instance of [_TargetTask].
   */
  Future<TargetResult> run() {
    return packages.create().then((_) {
      return Isolate.spawnUri(new Uri.file(scriptMain), [], incoming.sendPort);
    }).then((_) {
      return incoming.first;
    }).then((message) {
      incoming.close();
      return new TargetResult.unpack(message);
    }).whenComplete(() {
      if (packages.created) {
        packages.delete();
      }
    });
  }
}
