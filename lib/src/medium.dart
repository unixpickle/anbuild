part of anbuild;

abstract class Medium {
  final ConcreteTarget target;
  final String buildPath;
  
  Medium(this.target, String buildPath) : buildPath = absolutePath(buildPath);
  
  factory Medium.named(String name, ConcreteTarget target, String buildPath) {
    if (name != 'makefile') {
      throw new ArgumentError('unknown medium: $name');
    }
    return new Makefile(target, buildPath);
  }
  
  Future write();
}
