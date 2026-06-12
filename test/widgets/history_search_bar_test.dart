import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/features/history/widgets/history_search_bar.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Wraps [child] in a localized MaterialApp.
Widget _wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

/// Wraps HistorySearchBar in a ListenableBuilder so the StatelessWidget
/// rebuilds when the controller notifies (i.e., when text changes).
Widget _searchBar({
  required TextEditingController controller,
  ValueChanged<String>? onChanged,
  VoidCallback? onClear,
}) {
  return ListenableBuilder(
    listenable: controller,
    builder: (_, __) => HistorySearchBar(
      controller: controller,
      onChanged: onChanged ?? (_) {},
      onClear: onClear ?? () {},
    ),
  );
}

void main() {
  group('HistorySearchBar', () {
    testWidgets('renders a TextField with search icon', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(_searchBar(controller: controller)));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('does not show clear button when empty', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(_searchBar(controller: controller)));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('shows clear button when text is entered', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_wrap(_searchBar(controller: controller)));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('onChanged is called when typing', (tester) async {
      final controller = TextEditingController();
      final typed = <String>[];
      await tester.pumpWidget(_wrap(_searchBar(
        controller: controller,
        onChanged: typed.add,
      )));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'test');
      expect(typed, isNotEmpty);
      expect(typed.last, 'test');
    });

    testWidgets('tapping clear button calls onClear', (tester) async {
      final controller = TextEditingController(text: 'something');
      var cleared = false;
      await tester.pumpWidget(_wrap(_searchBar(
        controller: controller,
        onClear: () => cleared = true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.clear));
      expect(cleared, isTrue);
    });
  });
}
