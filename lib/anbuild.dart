/**
 * This library will be provided to all build scripts that are run by anbuild.
 */
library anbuild;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:path/path.dart' as path_lib;

part 'src/compiler.dart';
part 'src/build_script.dart';
part 'src/target.dart';
part 'src/parent_target.dart';
part 'src/scanner_target.dart';
