part of anbuild;

abstract class Medium {
  final ConcreteTarget target;
  final String buildPath;
  
  Medium(this.target, String buildPath) : buildPath = absolutePath(buildPath);
  
  String generate();
}
