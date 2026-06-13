// QuickChat Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickChatApp', () {
    test('can be constructed with isFirstLaunch: false', () {
      expect(() => const QuickChatApp(isFirstLaunch: false), returnsNormally);
    });

    test('can be constructed with isFirstLaunch: true', () {
      expect(() => const QuickChatApp(isFirstLaunch: true), returnsNormally);
    });

    test('is a StatefulWidget', () {
      const app = QuickChatApp(isFirstLaunch: false);
      expect(app, isA<StatefulWidget>());
    });
  });
}
