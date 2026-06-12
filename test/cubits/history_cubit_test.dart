import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:quickchat/core/constants/app_constants.dart';
import 'package:quickchat/data/models/chat_history.dart';
import 'package:quickchat/features/history/history_cubit.dart';

import '../helpers/hive_test_helper.dart';

ChatHistory _makeHistory({
  String phone = '77100200',
  String countryCode = '+967',
  String? message,
}) =>
    ChatHistory(
      phoneNumber: phone,
      countryCode: countryCode,
      message: message,
      timestamp: DateTime.now(),
    );

void main() {
  group('HistoryCubit', () {
    setUp(setUpHive);
    tearDown(tearDownHive);

    // -------------------------------------------------------------------------
    // Initial state
    // -------------------------------------------------------------------------
    test('initial state has empty items list', () {
      final cubit = HistoryCubit();
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.query, '');
      cubit.close();
    });

    test('loads existing items on construction', () async {
      final box = Hive.box<ChatHistory>(AppConstants.historyBox);
      await box.add(_makeHistory(phone: '77100200'));

      final cubit = HistoryCubit();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.items.length, 1);
      await cubit.close();
    });

    // -------------------------------------------------------------------------
    // search
    // -------------------------------------------------------------------------
    group('search', () {
      test('filters items by phone fragment', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200'));
        await box.add(_makeHistory(phone: '55200300'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        cubit.search('771');
        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.phoneNumber, '77100200');
        await cubit.close();
      });

      test('empty query returns all items', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200'));
        await box.add(_makeHistory(phone: '55200300'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        cubit.search('');
        expect(cubit.state.items.length, 2);
        await cubit.close();
      });

      test('filters by message content', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200', message: 'Hello'));
        await box.add(_makeHistory(phone: '55200300', message: 'Goodbye'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        cubit.search('hello');
        expect(cubit.state.items.length, 1);
        expect(cubit.state.items.first.message, 'Hello');
        await cubit.close();
      });

      test('stores query in state', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory());

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cubit.search('test');
        expect(cubit.state.query, 'test');
        await cubit.close();
      });

      test('no match returns empty items', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        cubit.search('99999');
        expect(cubit.state.items, isEmpty);
        await cubit.close();
      });
    });

    // -------------------------------------------------------------------------
    // deleteItemForUndo
    // -------------------------------------------------------------------------
    group('deleteItemForUndo', () {
      test('removes item from Hive', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cubit.state.items.length, 1);

        await cubit.deleteItemForUndo(cubit.state.items.first);
        expect(box.isEmpty, isTrue);
        await cubit.close();
      });

      test('returns a detached copy with same data', () async {
        final box = Hive.box<ChatHistory>(AppConstants.historyBox);
        await box.add(_makeHistory(phone: '77100200', message: 'Test msg'));

        final cubit = HistoryCubit();
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final copy = await cubit.deleteItemForUndo(cubit.state.items.first);
        expect(copy.phoneNumber, '77100200');
        expect(copy.message, 'Test msg');
        await cubit.close();
      });
    });

    // -------------------------------------------------------------------------
    // restoreItem
    // -------------------------------------------------------------------------
    test('restoreItem re-adds item to Hive', () async {
      final box = Hive.box<ChatHistory>(AppConstants.historyBox);
      await box.add(_makeHistory(phone: '77100200'));

      final cubit = HistoryCubit();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final copy = await cubit.deleteItemForUndo(cubit.state.items.first);
      expect(box.isEmpty, isTrue);

      await cubit.restoreItem(copy);
      expect(box.length, 1);
      await cubit.close();
    });

    // -------------------------------------------------------------------------
    // clearAll
    // -------------------------------------------------------------------------
    test('clearAll empties the Hive box', () async {
      final box = Hive.box<ChatHistory>(AppConstants.historyBox);
      await box.add(_makeHistory());
      await box.add(_makeHistory(phone: '55200300'));

      final cubit = HistoryCubit();
      await cubit.clearAll();
      expect(box.isEmpty, isTrue);
      await cubit.close();
    });
  });
}
