part of anbuild;

/**
 * Typical C/C++ command line compiler.
 */
class CStyleCompiler extends Compiler {
  final String compilerCommand;
  final List<String> arguments = [];
  
  CStyleCompiler(String name, List<String> fileExtensions,
                 this.compilerCommand) : super(name, fileExtensions);
  
  String generateCommand(String source, String output) {
    StringBuffer buffer = new StringBuffer();
    buffer.write(compilerCommand);
    for (String arg in arguments) {
      buffer.write(' ');
      buffer.write(escapeShellArgument(arg));
    }
    buffer.write(' ');
    buffer.write(escapeShellArgument(source));
    buffer.write(' -o ');
    buffer.write(escapeShellArgument(output));
    return buffer.toString();
  }
  
  void addOptions(List<String> options) {
    arguments.addAll(options);
  }
  
  void addFlags(List<String> flags) {
    for (String flag in flags) {
      if (!arguments.contains(flag)) {
        arguments.add(flag);
      }
    }
  }
  
  void addIncludes(List<String> directories) {
    addFlags(directories.map((String dir) => '-I$dir'));
  }
  
  String toString() {
    return 'CStyleCompiler (name=$name, command=$compilerCommand, ' +
        'extensions=$fileExtensions)';
  }
}
