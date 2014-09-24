part of anbuild;

/**
 * Escape an argument for a command-line command.
 * 
 * For now, this simply surrounds an argument in quotations if it contains a
 * space.
 */
String escapeShellArgument(String str) {
  if (str.contains(' ')) {
    return '"$str"';
  } else {
    return str;
  }
}
