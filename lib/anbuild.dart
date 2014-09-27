/**
 * This library will be provided to all build scripts that are run by anbuild.
 */
library anbuild;

import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'package:path/path.dart' as path_lib;

part 'src/target_result.dart';
part 'src/path.dart';
part 'src/file_scanner.dart';

part 'src/dependencies/dependency.dart';
part 'src/dependencies/dependency_fetcher.dart';
part 'src/dependencies/git_dependency_fetcher.dart';

part 'src/output/output_formatter.dart';
part 'src/output/makefile.dart';
part 'src/output/shell_escape.dart';

part 'src/internal/target_task.dart';
part 'src/internal/package_directory.dart';
