part of anbuild;

/**
 * The result of a target, including all of the sources it searched and options
 * it added.
 */
class TargetResult {
  Map<String, List<String>> options;
  Map<String, List<String>> flags;
  Map<String, List<String>> includes;
  Map<String, List<String>> sources;
  List<String> scanSources;
  
  TargetResult() : options = {}, flags = {}, includes = {}, sources = {},
      scanSources = [];
  
  TargetResult.unpack(Map map) : options = map['options'],
      flags = map['flags'], includes = map['includes'],
      sources = map['sources'], scanSources = map['scanSources'];
  
  Map<String, dynamic> pack() {
    return {'options': options, 'flags': flags, 'includes': includes,
            'sources': sources, 'scanSources': scanSources};
  }
  
  void addFromTargetResult(TargetResult result) {
    for (var key in result.options) {
      addOptions(key, result.options[key]);
    }
    for (var key in result.flags) {
      addFlags(key, result.flags[key]);
    }
    for (var key in result.includes) {
      addIncludes(key, result.includes[key]);
    }
    for (var key in result.sources) {
      addSources(key, result.sources[key]);
    }
    addScanSources(result.scanSources);
  }
  
  void addOptions(String language, List<String> theOptions) {
    _addFields(options, language, theOptions);
  }
  
  void addFlags(String language, List<String> theFlags) {
    _addFields(flags, language, theFlags);
  }
  
  void addIncludes(String language, List<String> directories) {
    _addFields(includes, language, directories.map(targetAbsolutePath));
  }
  
  void addSources(String language, List<String> files) {
    _addFields(sources, language, files.map(targetAbsolutePath));
  }
  
  void addScanSources(List<String> files) {
    scanSources.addAll(files.map(targetAbsolutePath));
  }
  
  void _addFields(Map map, String key, Iterable<String> values) {
    if (map[key] == null) {
      map[key] = new List.from(values);
    } else {
      map[key].addAll(values);
    }
  }
}
