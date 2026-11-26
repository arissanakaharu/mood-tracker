import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_tracker_app/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // folder sementara biar file Hive ga ada yang tertinggal di project
    tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('moods');
  });

  tearDownAll(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('HomePage menampilkan sapaan', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('Halo'), findsOneWidget);
  });
}