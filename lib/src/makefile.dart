part of anbuild;

class Makefile extends Medium {
  String get objectsPath => path_lib.join(buildPath, 'objects');
  
  Makefile(ConcreteTarget target, String buildPath) : super(target, buildPath);
  
  String generate() {
    StringBuffer buffer = new StringBuffer();
    buffer.write(_generateFirstRule());
    buffer.write(_generateObjectsRule());
    for (String compName in target.sources.keys) {
      Compiler compiler = target.compilers[compName];
      for (String path in target.sources[compName]) {
        buffer.write(_generateRule(compiler, path));
      }
    }
    buffer.write(_generateCleanRule());
    return buffer.toString();
  }
  
  String _objectFilePath(String sourcePath) {
    String rel = relativePath(sourcePath);
    rel = rel.replaceAll(new RegExp(r's/(\.|\/)/g'), '_');
    return path_lib.join(objectsPath, '$rel.o');
  }
  
  String _generateRule(Compiler c, String source) {
    String objectPath = _objectFilePath(source);
    StringBuffer buffer = new StringBuffer();
    buffer.write(escapeShellArgument(objectPath));
    buffer.write(': ');
    buffer.write(escapeShellArgument(source));
    buffer.write('\n\t');
    buffer.write(c.generateCommand(source, objectPath));
    buffer.write('\n\n');
    return buffer.toString();
  }
  
  String _generateFirstRule() {
    StringBuffer buffer = new StringBuffer();
    buffer.write('all: ');
    buffer.write(escapeShellArgument(objectsPath));
    for (List<String> paths in target.sources.values) {
      for (String path in paths) {
        buffer.write(' ');
        buffer.write(escapeShellArgument(_objectFilePath(path)));
      }
    }
    buffer.write('\n\n');
    return buffer.toString();
  }
  
  String _generateObjectsRule() {
    String escapedObjects = escapeShellArgument(objectsPath);
    StringBuffer buffer = new StringBuffer();
    buffer.write(escapedObjects);
    buffer.write(': \n\t');
    buffer.write('mkdir ');
    buffer.write(escapedObjects);
    buffer.write('\n\n');
    return buffer.toString();
  }
  
  String _generateCleanRule() {
    StringBuffer buffer = new StringBuffer();
    buffer.write('clean: \n\t' 'rm -rf ');
    buffer.write(escapeShellArgument(objectsPath));
    buffer.write('\n\n');
    return buffer.toString();
  }
}
