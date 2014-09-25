part of anbuild;

/**
 * The result of a target, including all of the sources it searched and options
 * it added.
 */
class TargetResult {
  /**
   * Compiler options for each language.
   * 
   * Generally, these will be directly translated to command-line arguments.
   */
  Map<String, List<String>> options;
  
  /**
   * Compiler flags for each language.
   * 
   * Flags differ from options in that they should only be specified once;
   * duplicate flags may be ignored.
   */
  Map<String, List<String>> flags;
  
  /**
   * Include directories for each language.
   * 
   * Generally, these will be used to create a header search path for C or C++.
   */
  Map<String, List<String>> includes;
  
  /**
   * Source files to compile for each language.
   */
  Map<String, List<String>> sources;
  
  /**
   * Source files and directories whose languages were not specified.
   * 
   * When *anbuild* runs, it will scan these sources and determine the language
   * they contain. Usually, this matching processes is based on file
   * extensions.
   */
  List<String> scanSources;
  
  /**
   * Create an empty [TargetResult].
   */
  TargetResult() : options = {}, flags = {}, includes = {}, sources = {},
      scanSources = [];
  
  /**
   * Create a [TargetResult] from an object received from an isolate.
   */
  TargetResult.unpack(Map map) : options = map['options'],
      flags = map['flags'], includes = map['includes'],
      sources = map['sources'], scanSources = map['scanSources'];
  
  /**
   * Pack a [TargetResult] to be sent between isolates.
   */
  Map<String, dynamic> pack() {
    return {'options': options, 'flags': flags, 'includes': includes,
            'sources': sources, 'scanSources': scanSources};
  }
  
  /**
   * Add the contents of [result] to this object.
   */
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
  
  /**
   * Add a list of options to this target's [options].
   */
  void addOptions(String language, List<String> theOptions) {
    _addFields(options, language, theOptions);
  }
  
  /**
   * Add a list of flags to this target's [flags].
   */
  void addFlags(String language, List<String> theFlags) {
    _addFields(flags, language, theFlags);
  }
  
  /**
   * Add a list of includes to this target's [includes].
   */
  void addIncludes(String language, List<String> directories) {
    _addFields(includes, language, directories.map(targetAbsolutePath));
  }
  
  /**
   * Add a list of sources to this target's [sources].
   */
  void addSources(String language, List<String> files) {
    _addFields(sources, language, files.map(targetAbsolutePath));
  }
  
  /**
   * Add a list of [scanSources].
   */
  void addScanSources(List<String> paths) {
    scanSources.addAll(paths.map(targetAbsolutePath));
  }
  
  /**
   * Add fields to a list in [map]. Create the list if it does not exist.
   */
  void _addFields(Map map, String key, Iterable<String> values) {
    if (map[key] == null) {
      map[key] = new List.from(values);
    } else {
      map[key].addAll(values);
    }
  }
}
