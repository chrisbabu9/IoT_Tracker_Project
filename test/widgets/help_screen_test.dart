import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/features/help/help_screen.dart';

void main() {
  testWidgets('HelpScreen shows guide expanded and expands FAQ items (T-W1)', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: const HelpScreen()));

    expect(find.text(AppStrings.helpTitle), findsOneWidget);
    expect(find.text(AppStrings.buttonGuide1ClickTitle), findsOneWidget); // initiallyExpanded
    expect(find.text(AppStrings.helpTagOfflineBody), findsNothing);

    await tester.tap(find.text(AppStrings.helpTagOfflineTitle));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.helpTagOfflineBody), findsOneWidget);
  });

  testWidgets('HelpScreen lists all 7 sections (T-W1b)', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.darkTheme, home: const HelpScreen()));
    expect(find.byType(ExpansionTile), findsNWidgets(7));
  });
}
