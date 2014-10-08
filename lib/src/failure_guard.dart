part of anbuild;

void runFailureGuard(SendPort errorResponse, Function func) {
  runZoned(func, onError: (e) {
    errorResponse.send('$e');
  });
}
