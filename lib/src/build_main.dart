part of anbuild;

void runBuildMain(List<String> args, SendPort errorResponse, Function func) {
  if (args.length != 1) {
    errorResponse.send('Invalid arguments.');
    return;
  }
  dependencyDirectory = args[0];
  runZoned(func, onError: (e) {
    errorResponse.send('$e');
  });
}
