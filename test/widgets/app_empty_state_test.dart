import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/core/widgets/app_empty_state.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppEmptyState', () {
    testWidgets('renders icon and message', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(
        icon: Icons.history,
        message: 'No history yet',
      )));
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('renders subMessage when provided', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(
        icon: Icons.search,
        message: 'No results',
        subMessage: 'Try a different search',
      )));
      expect(find.text('No results'), findsOneWidget);
      expect(find.text('Try a different search'), findsOneWidget);
    });

    testWidgets('does not render subMessage when omitted', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(
        icon: Icons.search,
        message: 'Empty',
      )));
      expect(find.byType(Text), findsOneWidget); // only the main message
    });

    testWidgets('renders action button when actionLabel and onAction provided', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(AppEmptyState(
        icon: Icons.add,
        message: 'Nothing here',
        actionLabel: 'Add One',
        onAction: () => tapped = true,
      )));
      expect(find.text('Add One'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });

    testWidgets('does not render action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(
        icon: Icons.inbox,
        message: 'Empty',
        onAction: null,
      )));
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('content column is centered via a Center widget', (tester) async {
      await tester.pumpWidget(_wrap(const AppEmptyState(
        icon: Icons.info,
        message: 'Centered',
      )));
      // The widget uses Center as its root; other Centers may exist in the tree
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });
  });
}
