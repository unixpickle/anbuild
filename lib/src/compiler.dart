part of anbuild;

/**
 * An abstract compiler command like "gcc" or "nasm".
 */
abstract class Compiler {
  final List<String> includeDirectories = new List<String>();
  final List<String> flags = new List<String>();
  final String name;
  
  Compiler(this.name);
  
  bool usesExtension(String extension);
  String generateCommand(String source);
}
