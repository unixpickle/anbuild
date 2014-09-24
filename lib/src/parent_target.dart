part of anbuild;

/**
 * A [Target] which forwards commands to the parent isolate.
 */
class ParentTarget extends Target {
  final Map<String, List<String>> _flags = {};
  final Map<String, List<String>> _options = {};
  final Map<String, List<String>> _sources = {};
  final Map<String, List<String>> _includes = {};
  final List<String> _scanFiles = [];
  
  /**
   * The [SendPort] which allows this instance to communicate with the parent
   * isolate.
   */
  final SendPort sendPort;
  
  /**
   * Create a [ParentTarget] with a given [sendPort].
   */
  ParentTarget(this.sendPort);
  
  /**
   * Tell the parent isolate that this target has finished.
   */
  void done() {
    sendPort.send({'flags': _flags, 'options': _options, 'sources': _sources,
                   'includes': _includes, 'scanFiles': _scanFiles});
  }
  
  Future scanFiles(List<String> files) {
    _scanFiles.addAll(files);
    return new Future.value(null);
  }
  
  void addFiles(String compiler, List<String> files) {
    _addOrSet(_sources, compiler, files);
  }
  
  void addIncludes(String compiler, List<String> directories) {
    _addOrSet(_includes, compiler, directories);
  }
  
  void addOptions(String compiler, List<String> options) {
    _addOrSet(_options, compiler, options);
  }
  
  void addFlags(String compiler, List<String> flags) {
    _addOrSet(_flags, compiler, flags);
  }
  
  Future _addOrSet(Map<String, List<String>> map, String key,
                   List<String> values) {
    var theList = map[key];
    if (theList != null) {
      theList.addAll(values);
    } else {
      map[key] = values;
    }
  }
}
