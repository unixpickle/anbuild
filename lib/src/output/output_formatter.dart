part of anbuild;

/**
 * An abstract means by which to convert a [TargetResult] to a buildable file.
 * 
 * Subclasses of [OutputFormatter] could generate files like Makefiles, Xcode
 * projects, or Eclipse workspaces.
 */
typedef Future OutputFormatter(String targetRoot, TargetResult target);
