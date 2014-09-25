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
  
  void addOptions(String language, List<String> option) {
    // TODO: this
  }
  
  void _addField(Map map, String key, String value) {
    // TODO: this
  }
}
