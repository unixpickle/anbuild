part of anbuild;

/**
 * Run a dependency given its main build script.
 */
Future<TargetResult> runDependency(String scriptPath) {
  return new _TargetTask(targetAbsolutePath(scriptPath)).run();
}
