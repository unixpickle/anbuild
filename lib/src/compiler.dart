part of anbuild;

abstract class Compiler {
  final List<String> includeDirectories = new List<String>();
  final List<String> flags = new List<String>();
  final String name;
  
  Compiler(this.name);
  
  String generateCommand(String source);
}
