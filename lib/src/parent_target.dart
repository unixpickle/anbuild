part of anbuild;

/**
 * The signature of the function which will perform most of the compilation
 * process. Exceptions from this function will be caught using the zoning
 * mechanism and passed down to the parent target.
 */
typedef BuildScriptMain(ParentTarget target);

/**
 * A [Target] which forwards commands to the parent isolate.
 */
class ParentTarget implements Target {
  /**
   * The [SendPort] which allows this instance to communicate with the parent
   * isolate.
   */
  final SendPort sendPort;
  
  /**
   * Call this from your build script's main(). It calls [theMain] inside of a
   * zone, so that any exceptions will be caught and forwarded to the parent
   * isolate.
   */
  static void run(var message, BuildScriptMain theMain) {
    if (!(message is SendPort)) {
      throw new ArgumentError('expected SendPort as initial message');
    }
    ParentTarget t = new ParentTarget(message);
    runZoned(() => theMain(t), onError: t._fail);
  }
  
  /**
   * Create a [ParentTarget] with a given [sendPort].
   */
  ParentTarget(this.sendPort);
  
  /**
   * Tell the parent isolate that this target has finished.
   */
  void done() {
    sendPort.send(['done']);
  }
  
  Future addSourceDirectories(List<String> directories) {
    return _runCommand('sourceDirs', directories);
  }
  
  Future addSources(List<String> files) {
    return _runCommand('sources', files);
  }
  
  Future addSourcesToCompilers(List<String> compilers, List<String> files) {
    return _runCommand('sourcesTo', [compilers, files]);
  }
  
  Future addIncludes(List<String> compilers, List<String> directories) {
    return _runCommand('includes', [compilers, directories]);
  }
  
  Future addFlags(List<String> compilers, List<String> flags) {
    return _runCommand('flags', [compilers, flags]);
  }
  
  Future _runCommand(String command, List args) {
    ReceivePort recv = new ReceivePort();
    List newArgs = [command, recv.sendPort];
    newArgs.add(args);
    sendPort.send(newArgs);
    return recv.first.then((var obj) {
      if (obj == true) {
        return null;
      } else {
        return new Future.error(new Error());
      }
      recv.close();
    });
  }
  
  void _fail(e) {
    sendPort.send(['error', e.toString()]);
  }
}
