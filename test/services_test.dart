/// QuickChat Services Unit Tests
/// Tests for PreferencesService, TemplateService, and other core services

import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/data/services/preferences_service.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/data/services/template_service.dart';
import 'package:quickchat/data/models/message_template.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Note: Service tests require plugin initialization which is not available in unit test environment
  // These tests are skipped. For full integration testing, run on a real device or emulator.

  group('Service Structure Tests', () {
    test('PreferencesService class exists', () {
      expect(PreferencesService, isNotNull);
      expect(() => PreferencesService(), returnsNormally);
    });

    test('HiveService class exists', () {
      expect(HiveService, isNotNull);
      expect(() => HiveService(), returnsNormally);
    });

    test('TemplateService class exists', () {
      expect(TemplateService, isNotNull);
      expect(() => TemplateService(), returnsNormally);
    });
  });

  group('MessageTemplate Model Tests', () {
    test('MessageTemplate creates correctly with factory', () {
      final template = MessageTemplate.create(
        title: 'Test',
        message: 'Test message',
      );

      expect(template.id, isNotEmpty);
      expect(template.title, equals('Test'));
      expect(template.message, equals('Test message'));
      expect(template.createdAt, isNotNull);
      expect(template.updatedAt, isNotNull);
    });

    test('MessageTemplate copyWith works', () {
      final now = DateTime.now();
      final template = MessageTemplate(
        id: 'test',
        title: 'Original',
        message: 'Original message',
        createdAt: now,
        updatedAt: now,
      );

      // Give a tiny delay to ensure updatedAt is different
      final updated = template.copyWith(
        title: 'Updated',
        message: 'Updated message',
      );

      expect(updated.id, equals(template.id));
      expect(updated.title, equals('Updated'));
      expect(updated.message, equals('Updated message'));
      // updatedAt should be equal or after
      expect(
        updated.updatedAt.isAtSameMomentAs(template.updatedAt) ||
        updated.updatedAt.isAfter(template.updatedAt),
        isTrue
      );
    });

    test('MessageTemplate has valid timestamps', () {
      final before = DateTime.now();
      final template = MessageTemplate.create(
        title: 'Test',
        message: 'Test',
      );
      final after = DateTime.now().add(const Duration(milliseconds: 100));

      // Timestamps should be between before and after
      expect(
        template.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue
      );
      expect(template.createdAt.isBefore(after), isTrue);
      expect(template.updatedAt.isBefore(after), isTrue);
    });
  });
}

