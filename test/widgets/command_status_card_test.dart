import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/firebase/command_repository.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/common/command_status_card.dart';

void main() {
  testWidgets('shows pending then completed with countdown (T-W5)', (tester) async {
    final repo = FakeCommandRepository();
    addTearDown(repo.dispose);
    final cmd = (await repo.sendCommand(deviceId: 'd', type: 'BUZZER_ON')).dataOrNull!;

    await tester.pumpWidget(ProviderScope(
      overrides: [commandRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: CommandStatusCard(deviceId: 'd', commandId: cmd.id)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.text(AppStrings.commandPending), findsOneWidget);
    expect(find.textContaining(AppStrings.findExpiresIn), findsOneWidget);
    expect(find.text(AppStrings.pollDelayNotice), findsOneWidget);

    repo.updateCommandStatus('d', cmd.id, 'completed');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text(AppStrings.commandCompleted), findsOneWidget);
    expect(find.textContaining(AppStrings.findExpiresIn), findsNothing);

    await tester.pumpWidget(const SizedBox()); // dispose card -> cancels periodic timer
  });
}
