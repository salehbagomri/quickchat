import 'dart:io';
import 'package:quickchat/data/local_storage/hive_service.dart';

Directory? _tempDir;

Future<void> setUpHive() async {
  _tempDir = await Directory.systemTemp.createTemp('quickchat_hive_test_');
  await HiveService.initForTest(_tempDir!.path);
}

Future<void> tearDownHive() async {
  await HiveService.closeForTest();
  await _tempDir?.delete(recursive: true);
  _tempDir = null;
}
