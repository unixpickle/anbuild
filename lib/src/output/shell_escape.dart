part of anbuild;

/**
 * Escape [argument] for a shell such as Bash.
 * 
 * Currently, this method escapes spaces with backslashes. It does not attempt
 * to escape more complex sequences of characters.
 */
String shellEscape(String argument) {
  return argument.replaceAll(' ', r'\ ');
}
