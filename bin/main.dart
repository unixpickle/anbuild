import 'dart:io';
import 'dart:isolate';

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('Usage: anbuild <build.dart>');
    stderr.flush().then((_) {
      exit(1);
    });
    return;
  }
  
  String buildFile = args[0];
  Isolate.spawnUri(new Uri.file(buildFile), [], null).then((isolate) {
    // TODO: here, start listening to source file requests
  });
}
