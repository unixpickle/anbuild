part of anbuild;

/**
 * Escape an argument for a command-line command.
 * 
 * For now, this just escapes spaces.
 */
String escapeShellArgument(String str) {
  return str.replaceAll(' ', '\\ ');
}
