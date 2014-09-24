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
  
  final List<List> _commands = [];
  
  /**
   * Create a [ParentTarget] with a given [sendPort].
   */
  ParentTarget(this.sendPort);
  
  /**
   * Tell the parent isolate that this target has finished, sending all pending
   * commands to it.
   */
  void done() {
    sendPort.send(_commands);
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
    List res = [command];
    res.add(args);
    _commands.add(res);
    return new Future.value(null);
  }
}
