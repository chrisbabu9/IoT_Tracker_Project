import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/firebase/auth_repository.dart';
import 'package:trackpoint/features/alerts/alerts_screen.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

Widget app() => ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
    child: MaterialApp(theme: AppTheme.darkTheme, home: const AlertsScreen()));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('empty state (T-W3)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.alertsEmpty), findsOneWidget);
    expect(find.byIcon(Icons.clear_all), findsNothing);
  });

  testWidgets('lists stored alerts and clears them (T-W3b)', (tester) async {
    SharedPreferences.setMockInitialValues({
      'alert_store_v1_list': jsonEncode([
        {
          'type': 'lowBattery',
          'title': 'Low battery',
          'message': 'Keys battery at 15%.',
          'ts': DateTime.now().millisecondsSinceEpoch,
          'deviceId': 'd1',
        }
      ]),
    });
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Keys battery at 15%.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.clear_all));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.alertsEmpty), findsOneWidget);
  });

  testWidgets('settings panel toggles a category and persists (T-W3c)', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.alertsCategoryHeader), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNWidgets(8));

    await tester.tap(find.byType(SwitchListTile).first); // tagOffline
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('alert_store_v1_cats'), contains('"tagOffline":false'));
  });
}
