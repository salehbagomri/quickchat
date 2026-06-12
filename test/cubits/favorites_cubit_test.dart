import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/data/local_storage/hive_service.dart';
import 'package:quickchat/features/favorites/favorites_cubit.dart';

import '../helpers/hive_test_helper.dart';

void main() {
  group('FavoritesCubit', () {
    setUp(setUpHive);
    tearDown(tearDownHive);

    // -------------------------------------------------------------------------
    // Initial state
    // -------------------------------------------------------------------------
    test('initial state has empty contacts list', () {
      final cubit = FavoritesCubit();
      expect(cubit.state.contacts, isEmpty);
      cubit.close();
    });

    // -------------------------------------------------------------------------
    // addFavorite
    // -------------------------------------------------------------------------
    group('addFavorite', () {
      test('persists contact to Hive', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
          phoneNumber: '77100200',
          countryCode: '+967',
          label: 'Ahmad',
        );
        final stored = HiveService().getAllFavorites();
        expect(stored.length, 1);
        expect(stored.first.displayName, 'Ahmad');
        await cubit.close();
      });

      test('uses formattedPhone as displayName when label is null', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
          phoneNumber: '77100200',
          countryCode: '+967',
          label: null,
        );
        final stored = HiveService().getAllFavorites();
        expect(stored.first.displayName, '+96777100200');
        await cubit.close();
      });

      test('multiple contacts are stored independently', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
            phoneNumber: '77100200', countryCode: '+967', label: 'A');
        await cubit.addFavorite(
            phoneNumber: '55200300', countryCode: '+967', label: 'B');
        expect(HiveService().getAllFavorites().length, 2);
        await cubit.close();
      });
    });

    // -------------------------------------------------------------------------
    // isFavorite — reads from state.contacts (reactive via Hive watch)
    // -------------------------------------------------------------------------
    group('isFavorite', () {
      test('returns false when no contacts exist', () {
        final cubit = FavoritesCubit();
        expect(cubit.isFavorite('+96777100200'), isFalse);
        cubit.close();
      });

      test('returns true after adding matching contact', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
          phoneNumber: '77100200',
          countryCode: '+967',
          label: null,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cubit.isFavorite('+96777100200'), isTrue);
        await cubit.close();
      });

      test('returns false for non-matching phone', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
          phoneNumber: '77100200',
          countryCode: '+967',
          label: null,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(cubit.isFavorite('+96699000000'), isFalse);
        await cubit.close();
      });
    });

    // -------------------------------------------------------------------------
    // removeFavorite
    // -------------------------------------------------------------------------
    group('removeFavorite', () {
      test('deletes contact from Hive', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
            phoneNumber: '77100200', countryCode: '+967', label: null);
        final id = HiveService().getAllFavorites().first.id;
        await cubit.removeFavorite(id);
        expect(HiveService().getAllFavorites(), isEmpty);
        await cubit.close();
      });

      test('only removes the targeted contact', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
            phoneNumber: '77100200', countryCode: '+967', label: 'A');
        await cubit.addFavorite(
            phoneNumber: '55200300', countryCode: '+967', label: 'B');
        final favorites = HiveService().getAllFavorites();
        await cubit.removeFavorite(favorites.first.id);
        expect(HiveService().getAllFavorites().length, 1);
        await cubit.close();
      });
    });

    // -------------------------------------------------------------------------
    // rename
    // -------------------------------------------------------------------------
    group('rename', () {
      test('updates label in Hive', () async {
        final cubit = FavoritesCubit();
        await cubit.addFavorite(
            phoneNumber: '77100200', countryCode: '+967', label: 'Old');
        final id = HiveService().getAllFavorites().first.id;
        await cubit.rename(id, 'New Name');
        expect(HiveService().getAllFavorites().first.displayName, 'New Name');
        await cubit.close();
      });

      test('silently ignores unknown id', () async {
        final cubit = FavoritesCubit();
        await cubit.rename('non-existent-id', 'Anything');
        expect(HiveService().getAllFavorites(), isEmpty);
        await cubit.close();
      });
    });
  });
}
