part of anbuild;

/**
 * An abstract compiler command like "gcc" or "nasm".
 */
abstract class Compiler {
  /**
   * The name of this compiler. Generally, this should be lowercase for
   * uniformity.
   * 
   * For example: 'gcc', 'g++', 'clang', 'elf-64-pc-none-gcc', 'nasm'
   */
  final String name;
  
  /**
   * The file extensions used by source files that can be build with this
   * compiler.
   */
  final List<String> fileExtensions;
  
  /**
   * Create a new [Compiler] with a [name] and a list of supported
   * [fileExtensions]. The resulting [Compiler] will begin with empty but
   * mutable [flags] and [includes].
   */
  Compiler(this.name, this.fileExtensions);
  
  /**
   * Generate a build command which compiles a given [source] file to a given
   * [output] file.
   */
  String generateCommand(String source, String output);
  
  /**
   * Add a list of options to this compiler.
   * 
   * Options are generally command-line arguments that may be repeated multiple
   * times.
   */
  void addOptions(List<String> options);
  
  /**
   * Add a set of flags to this compiler.
   * 
   * Flags are generally command-line arguments that may not be repeated
   * multiple times.
   */
  void addFlags(List<String> flags);
  
  /**
   * Add a list of include directories to this compiler.
   * 
   * For languages like C and C++, include directories are put into the header
   * search path. In other languages, such a concept may not exist and include
   * directories are useless.
   */
  void addIncludes(List<String> directories);
}
