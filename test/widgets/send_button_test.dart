import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickchat/features/home/widgets/send_button.dart';
import 'package:quickchat/l10n/app_localizations.dart';

/// Builder wrapper that defers rendering until l10n is available.
Widget _localized(Widget Function(AppLocalizations) build) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      if (l10n == null) return const SizedBox.shrink();
      return Scaffold(body: Center(child: build(l10n)));
    }),
  );
}

/// Pumps the widget and waits for localizations without waiting for animations.
/// Use instead of pumpAndSettle when the widget contains infinite animations.
Future<void> pumpWithLocalizations(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump(); // first frame — kicks off async localizations
  await tester.pump(const Duration(milliseconds: 500)); // allow load
}

void main() {
  group('SendButton', () {
    testWidgets('shows send icon when not loading', (tester) async {
      await tester.pumpWidget(_localized(
        (l10n) => SendButton(isLoading: false, l10n: l10n, onPressed: () {}),
      ));
      await tester.pumpAndSettle(); // no infinite animation here
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows spinner and no send icon when loading', (tester) async {
      // pumpAndSettle cannot be used — CircularProgressIndicator never settles
      await pumpWithLocalizations(tester, _localized(
        (l10n) => SendButton(isLoading: true, l10n: l10n, onPressed: null),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);
    });

    testWidgets('button is disabled when onPressed is null', (tester) async {
      // pumpAndSettle cannot be used — CircularProgressIndicator never settles
      await pumpWithLocalizations(tester, _localized(
        (l10n) => SendButton(isLoading: true, l10n: l10n, onPressed: null),
      ));
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('tapping calls onPressed callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_localized(
        (l10n) => SendButton(
          isLoading: false,
          l10n: l10n,
          onPressed: () => tapped = true,
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      expect(tapped, isTrue);
    });
  });
}
