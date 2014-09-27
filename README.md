# anbuild

This will be a replacement for [makemaker](https://github.com/unixpickle/makemaker).  The main purpose of this tool is to generate Makefiles (or, in the future, other types of build scripts).

# Installation

The file [bin/main.dart](bin/main.dart) is the main anbuild executable. Run it with:

    dart bin/main.dart <path to build.dart>

You may want to setup a Bash alias to turn this into a simple `anbuild` command.

# General usage

Here's how it works:

 * In the root directory of a library, I create a file called **build.dart**.
 * In my new *build.dart* file, I can add
   * include directories
   * sources files and directories
   * compiler flags
   * dependency build scripts
 * In the *build.dart* script, I may download dependencies from online sources
 * To generate a Makefile, I run a command such as: `anbuild build.dart`
 * To run the new Makefile, I run `make`

# Example

**build.dart** scripts to look something like this:

```dart
import 'package:anbuild/anbuild.dart';
void main(_, port) {
  var result = new TargetResult();
  result.addIncludes('c', ['include']);
  result.addFlags('c', ['-c']);
  result.addScanSources('src');
  port.send(result.pack());
}
```

In such build scripts, you can add dependencies to the target like such:

```dart
var result = ...;
...
runDependency('dependencies/my_lib/build.dart').then((aResult) {
  result.addFromTargetResult(aResult);
});
```

The code above will asynchronously run *dependencies/my_lib/build.dart* in a separate isolate and add its result to the `result` object.
