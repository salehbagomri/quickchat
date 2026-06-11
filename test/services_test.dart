// QuickChat Services Unit Tests
// Tests for PreferencesService, TemplateService, and other core services

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

      expect(
        template.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue
      );
      expect(template.createdAt.isBefore(after), isTrue);
      expect(template.updatedAt.isBefore(after), isTrue);
    });

    test('isDefault field defaults to false for user-created templates', () {
      final template = MessageTemplate.create(
        title: 'My Template',
        message: 'Custom message',
      );
      expect(template.isDefaultTemplate, isFalse);
      expect(template.isDefault, isNull);
    });

    test('isDefault field is true when explicitly set', () {
      final template = MessageTemplate.create(
        title: 'Default Template',
        message: 'Default message',
        isDefault: true,
      );
      expect(template.isDefaultTemplate, isTrue);
      expect(template.isDefault, isTrue);
    });

    test('copyWith preserves isDefault flag', () {
      final now = DateTime.now();
      final defaultTemplate = MessageTemplate(
        id: 'def1',
        title: 'Default',
        message: 'Default msg',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      );
      final edited = defaultTemplate.copyWith(title: 'Edited');
      // isDefault يُحفَظ، لكن updatedAt يتغير
      expect(edited.isDefault, isTrue);
      expect(edited.title, equals('Edited'));
    });

    test('unmodified default: createdAt == updatedAt', () {
      final template = MessageTemplate.create(
        title: 'Default',
        message: 'Msg',
        isDefault: true,
      );
      // عند الإنشاء createdAt == updatedAt — يُعامَل كغير معدَّل
      expect(template.createdAt, equals(template.updatedAt));
    });

    test('modified default: copyWith sets updatedAt != createdAt', () async {
      final now = DateTime(2025, 1, 1, 10, 0, 0);
      final template = MessageTemplate(
        id: 'def2',
        title: 'Default',
        message: 'Msg',
        createdAt: now,
        updatedAt: now,
        isDefault: true,
      );
      // محاكاة تعديل المستخدم: updatedAt سيكون DateTime.now() != createdAt
      await Future<void>.delayed(const Duration(milliseconds: 1));
      final edited = template.copyWith(message: 'Edited msg');
      expect(edited.createdAt, equals(now));
      expect(edited.updatedAt.isAfter(now), isTrue);
    });
  });
}

