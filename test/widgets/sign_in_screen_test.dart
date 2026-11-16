import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/firebase/auth_repository.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/auth/sign_in_screen.dart';

Widget app(FakeAuthRepository repo) {
  Widget page(String t) => Scaffold(body: Text(t));
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/home', builder: (_, __) => page('HOME')),
    GoRoute(path: '/sign-up', builder: (_, __) => page('SIGNUP')),
    GoRoute(path: '/forgot-password', builder: (_, __) => page('FORGOT')),
  ]);
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repo)],
    child: MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
  );
}

void main() {
  late FakeAuthRepository repo;
  setUp(() => repo = FakeAuthRepository());
  tearDown(() => repo.dispose());

  void bigScreen(WidgetTester t) {
    t.view.physicalSize = const Size(800, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
  }

  final signInButton = find.widgetWithText(ElevatedButton, AppStrings.signIn);
  final fields = find.byType(TextFormField);

  testWidgets('empty submit shows validation errors (T-W2)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    await tester.tap(signInButton);
    await tester.pump();
    expect(find.text(AppStrings.invalidEmail), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('short password rejected locally (T-W2b)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    await tester.enterText(fields.at(0), 'a@b.co');
    await tester.enterText(fields.at(1), '123');
    await tester.tap(signInButton);
    await tester.pump();
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('wrong password shows repository error banner (T-W2c)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    await tester.enterText(fields.at(0), 'a@b.co');
    await tester.enterText(fields.at(1), 'wrongpass');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Invalid password.'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('correct password navigates to /home (T-W2d)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    await tester.enterText(fields.at(0), 'a@b.co');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('links navigate to sign-up and forgot-password (T-W2e)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    await tester.tap(find.text(AppStrings.signUp));
    await tester.pumpAndSettle();
    expect(find.text('SIGNUP'), findsOneWidget);

    await tester.pumpWidget(app(repo)); // fresh router
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.forgotPassword));
    await tester.pumpAndSettle();
    expect(find.text('FORGOT'), findsOneWidget);
  });

  testWidgets('password visibility toggle (T-W2f)', (tester) async {
    bigScreen(tester);
    await tester.pumpWidget(app(repo));
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_outlined));
    await tester.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}
