import 'dart:convert';
import 'dart:io';

///Reads the environment variable from your path.
Future<void> main() async {
  final config = {
    'FINESSE_API_TOKEN': Platform.environment['FINESSE_API_TOKEN'],
    'FINESSE_SERVER_KEY': Platform.environment['FINESSE_SERVER_KEY']
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
  print('generated .env.dart');
}
