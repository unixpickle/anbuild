part of anbuild;

abstract class Target {
  Future addSourceDirectories(List<String> directories);
  Future addSources(List<String> files);
  Future addSourcesToCompilers(List<String> compilers, List<String> files);
  Future addIncludes(List<String> compilers, List<String> directories);
  Future addFlags(List<String> compilers, List<String> flags);
}
