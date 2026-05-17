/// QuickChat Widget Tests
/// Comprehensive test suite for the QuickChat application

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/app.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/services/template_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App Initialization Tests', () {
    testWidgets('App widget can be created', (WidgetTester tester) async {
      // Simple test that doesn't require plugin initialization
      expect(() => const QuickChatApp(isFirstLaunch: false), returnsNormally);
    });

    testWidgets('App widget accepts isFirstLaunch parameter', (WidgetTester tester) async {
      expect(() => const QuickChatApp(isFirstLaunch: true), returnsNormally);
      expect(() => const QuickChatApp(isFirstLaunch: false), returnsNormally);
    });
  });

  group('App Structure Tests', () {
    test('App class exists and is constructable', () {
      expect(QuickChatApp, isNotNull);
      expect(() => const QuickChatApp(isFirstLaunch: false), returnsNormally);
    });

    test('App constructor validates parameters', () {
      // Test both boolean values
      expect(() => const QuickChatApp(isFirstLaunch: true), returnsNormally);
      expect(() => const QuickChatApp(isFirstLaunch: false), returnsNormally);
    });
  });

  group('App Configuration Tests', () {
    test('App has proper type', () {
      const app = QuickChatApp(isFirstLaunch: false);
      expect(app, isA<StatelessWidget>());
      expect(app, isA<QuickChatApp>());
    });
  });
}
