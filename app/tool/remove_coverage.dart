import 'dart:io';
import 'package:args/args.dart' as a;

/// Manipulate an `lcov.info` file to ignore files matching given patterns.
///
/// If not given a file, `stdin` will be filtered and sent to `stdout`.
///
/// Usage:
/// ```text
/// Remove files with paths matching given PATTERNs from the lcov.info FILE
/// -f, --file=<FILE>         the target lcov.info file to manipulate
/// -r, --remove=<PATTERN>    a pattern of paths to exclude from coverage
/// -h, --help                show this help
/// ```
///
/// This file is necessary because the UI pages should not be included in the coverage because they cannot be tested using traditional methods.
main(List<String> arguments) {
  final parser = a.ArgParser()
    ..addSeparator(
        'Remove files with paths matching given PATTERNs from the lcov.info FILE')
    ..addOption('file',
        abbr: 'f',
        help: 'the target lcov.info file to manipulate',
        valueHelp: 'FILE')
    ..addMultiOption('remove',
        abbr: 'r',
        splitCommas: true,
        help:
            'a pattern of paths to exclude from coverage comma seperated No spaces',
        valueHelp: 'PATTERN')
    ..addFlag('help',
        abbr: 'h', negatable: false, defaultsTo: false, help: 'show this help');

  final args = parser.parse(arguments);

  if (args['help']) {
    print(parser.usage);
    exit(0);
  }

  final List<String> patterns = (args['remove'] as List<String>)
      .map((String s) => s)
      .toList(growable: false);

  print(patterns);
  bool keep = true;
  final keeper = (String s) {
    if (s.startsWith('SF:') &&
        patterns.any((String pattern) => s.substring(3).contains(pattern))) {
      print("Removing ${s.substring(3)}");
      keep = false;
    } else if (!keep && s == 'end_of_record') {
      keep = true;
      return false;
    }
    return keep;
  };
  String path = args['file'];

  if (path == null) {
    path = 'coverage/lcov.info';
  }
  final File f = File(args['file']);
  f.readAsLines().then(
      (List<String> los) => f.writeAsString(los.where(keeper).join('\n')));
}
