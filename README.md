# anbuild

This will be a replacement for [makemaker](https://github.com/unixpickle/makemaker).  The main purpose of this tool is too generate makefiles (or, in the future, other types of build scripts).

# General system

Here's how it will work:

 * I create library X
 * In the root directory for library X, I create a new directory called **anbuild/**
 * In my new *anbuild/* directory, I create a file called **main.dart** which operates on the "target". These operations include:
   * Add include directories
   * Add sources
   * Add compiler flags
 * To generate a Makefile, I run a command such as: `anbuild --medium makefile ./`
 * To run the new Makefile, I run `make -C anbuild/`

# Theoretical example

I'd like my **main.dart** build scripts to look something like this:

    import 'package:anbuild/anbuild.dart';
    void main(_, port) {
      var target = new ParentTarget(port);
      target.addIncludes('c', 'include');
      target.addIncludes('cxx', 'include');
      target.scanDirectory('src/');
      target.done();
    }

In such build scripts, you would be able to add dependencies to the target like such:

	new BuildScript('dependencies/my_lib', target).run().then((_) {
	    // ...
	});

This would run *dependencies/my_lib/anbuild/main.dart* as its own script in a separate isolate.

# TODO

 * Implement the concept of a "medium". In this case, "makefile" will be the only medium for now.
 * Implement the concept of a toolchain. Some ideas: "native" (default), "x86-64-gcc-elf", "x86-64-clang-elf", "none".
 * Command-line arguments to generate "custom" medium with C-style compilers.