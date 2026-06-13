import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/data/services/template_service.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  group('TemplateService', () {
    setUp(() async {
      await setUpHive();
      await TemplateService().init();
    });
    tearDown(tearDownHive);

    // -------------------------------------------------------------------------
    // addDefaultTemplates
    // -------------------------------------------------------------------------
    group('addDefaultTemplates', () {
      test('adds 10 English templates on first call', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        expect(svc.getAllTemplates().length, 10);
      });

      test('adds 10 Arabic templates when language is ar', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('ar');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles, contains('تحية عامة'));
      });

      test('is no-op when box already has templates', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        await svc.addDefaultTemplates('ar'); // box non-empty, skipped
        expect(svc.getAllTemplates().length, 10); // still 10, not 20
      });

      test('default templates are marked as default', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        final templates = svc.getAllTemplates();
        expect(templates.every((t) => t.isDefaultTemplate), isTrue);
      });
    });

    // -------------------------------------------------------------------------
    // getAllTemplates / addTemplate
    // -------------------------------------------------------------------------
    group('addTemplate', () {
      test('adds a user template', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'My Title', message: 'My message');
        expect(svc.getAllTemplates().length, 1);
        expect(svc.getAllTemplates().first.title, 'My Title');
      });

      test('user template is not marked as default', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'Custom', message: 'Hello');
        expect(svc.getAllTemplates().first.isDefaultTemplate, isFalse);
      });

      test('multiple templates are sorted newest first', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'First', message: 'A');
        await Future<void>.delayed(const Duration(milliseconds: 2));
        await svc.addTemplate(title: 'Second', message: 'B');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles.first, 'Second');
      });
    });

    // -------------------------------------------------------------------------
    // updateTemplate
    // -------------------------------------------------------------------------
    group('updateTemplate', () {
      test('changes title and message', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'Old', message: 'Old msg');
        final id = svc.getAllTemplates().first.id;
        await svc.updateTemplate(id: id, title: 'New', message: 'New msg');
        final updated = svc.getTemplate(id);
        expect(updated?.title, 'New');
        expect(updated?.message, 'New msg');
      });

      test('clears isDefault flag (makes template user-owned)', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        final template = svc.getAllTemplates().first;
        await svc.updateTemplate(
            id: template.id, title: 'Edited', message: 'New');
        expect(svc.getTemplate(template.id)?.isDefaultTemplate, isFalse);
      });

      test('silently ignores unknown id', () async {
        final svc = TemplateService();
        await svc.updateTemplate(
            id: 'unknown', title: 'X', message: 'Y'); // no throw
        expect(svc.getAllTemplates(), isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // deleteTemplate
    // -------------------------------------------------------------------------
    group('deleteTemplate', () {
      test('removes the template', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'Test', message: 'Hello');
        final id = svc.getAllTemplates().first.id;
        await svc.deleteTemplate(id);
        expect(svc.getAllTemplates(), isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // searchTemplates
    // -------------------------------------------------------------------------
    group('searchTemplates', () {
      test('returns all templates for empty query', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        expect(svc.searchTemplates('').length, 10);
      });

      test('filters by title (case-insensitive)', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        final results = svc.searchTemplates('greeting');
        expect(results, isNotEmpty);
        expect(results.first.title.toLowerCase(), contains('greeting'));
      });

      test('filters by message content', () async {
        final svc = TemplateService();
        await svc.addTemplate(title: 'T1', message: 'Hello world');
        await svc.addTemplate(title: 'T2', message: 'Goodbye');
        final results = svc.searchTemplates('hello');
        expect(results.length, 1);
        expect(results.first.title, 'T1');
      });

      test('returns empty list when no match', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        expect(svc.searchTemplates('zzzznonexistent'), isEmpty);
      });
    });

    // -------------------------------------------------------------------------
    // regenerateDefaultTemplates
    // -------------------------------------------------------------------------
    group('regenerateDefaultTemplates', () {
      test('replaces English defaults with Arabic defaults', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');

        await svc.regenerateDefaultTemplates('ar');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles, contains('تحية عامة'));
        expect(titles, isNot(contains('General Greeting')));
        expect(svc.getAllTemplates().length, 10);
      });

      test('preserves user-added custom templates', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');
        await svc.addTemplate(title: 'My Custom', message: 'Custom msg');

        await svc.regenerateDefaultTemplates('ar');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles, contains('My Custom'));
        expect(svc.getAllTemplates().length, 11); // 10 Arabic + 1 custom
      });

      test('preserves v1.0.0-style template with default title but different message', () async {
        // v1.0.0 templates have isDefault == null (field didn't exist yet).
        // Migration must not delete them if the message differs from the known
        // default — only an exact title+message pair identifies a real default.
        final svc = TemplateService();
        // Simulate a v1.0.0 template: same title as a default, custom message
        await svc.addTemplate(
          title: 'General Greeting',
          message: 'Hey, I want to order pizza 🍕',
        );

        await svc.regenerateDefaultTemplates('ar');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles, contains('General Greeting')); // must survive
      });

      test('preserves user-edited default templates (copyWith clears isDefault)', () async {
        final svc = TemplateService();
        await svc.addDefaultTemplates('en');

        // Edit a default template — copyWith sets isDefault = null
        final template = svc.getAllTemplates().first;
        await svc.updateTemplate(
            id: template.id, title: 'My Edit', message: 'Changed');

        await svc.regenerateDefaultTemplates('ar');
        final titles = svc.getAllTemplates().map((t) => t.title).toList();
        expect(titles, contains('My Edit')); // user-edited, not deleted
      });
    });
  });
}
