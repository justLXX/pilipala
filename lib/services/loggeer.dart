// final _loggerFactory =

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final _loggerFactory = PiliLogger();

PiliLogger getLogger<T>() {
  return _loggerFactory;
}

class PiliLogger extends Logger {
  PiliLogger() : super();

  @override
  void log(Level level, dynamic message,
      {Object? error, StackTrace? stackTrace, DateTime? time}) async {
    if (level == Level.error && !kIsWeb) {
      String dir = (await getApplicationDocumentsDirectory()).path;
      final String filename = p.join(dir, ".pili_logs");
      await File(filename).writeAsString(
        "**${DateTime.now()}** \n $message \n $stackTrace",
        mode: FileMode.writeOnlyAppend,
      );
    }
    super.log(level, "$message", error: error, stackTrace: stackTrace);
  }
}

Future<File> getLogsPath() async {
  String dir = (await getApplicationDocumentsDirectory()).path;
  final String filename = p.join(dir, ".pili_logs");
  final file = File(filename);
  if (!await file.exists()) {
    await file.create();
  }
  return file;
}

Future<bool> clearLogs() async {
  if (kIsWeb) return true;
  String dir = (await getApplicationDocumentsDirectory()).path;
  final String filename = p.join(dir, ".pili_logs");
  final file = File(filename);
  try {
    await file.writeAsString('');
  } catch (e) {
    print('Error clearing file: $e');
    return false;
  }
  return true;
}
