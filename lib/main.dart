import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/app.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/onboarding/onboarding_screen.dart';
import 'package:trackpoint/features/settings/app_settings_providers.dart';
import 'package:trackpoint/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var isOnboardingDone = false;
  var isSimulation = !kReleaseMode;
  var units = UnitSystem.metric;
  try {
    final prefs = await SharedPreferences.getInstance();
    isOnboardingDone = prefs.getBool(kPrefOnboardingCompleted) ?? false;
    isSimulation = prefs.getBool(AppConfig.prefSimulationMode) ?? !kReleaseMode;
    units = prefs.getString(AppConfig.prefUnits) == 'imperial'
        ? UnitSystem.imperial
        : UnitSystem.metric;
  } catch (e) {
    debugPrint('[Preferences] Warning reading preferences: $e');
  }

  // 1. Initialize Firebase Core (Android may already have it started natively).
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') debugPrint('[Firebase] init error: $e');
  } catch (e) {
    debugPrint('[Firebase] init error: $e');
  }

  // 2. Database persistence + optional emulator (must run before DB use).
  try {
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
    if (AppConfig.useEmulator) {
      final host = AppConfig.emulatorHost;
      debugPrint('[Firebase] Using emulators at $host');
      await FirebaseAuth.instance.useAuthEmulator(host, AppConfig.authEmulatorPort);
      FirebaseDatabase.instance
          .useDatabaseEmulator(host, AppConfig.rtdbEmulatorPort);
    }
  } catch (e) {
    debugPrint('[Firebase] config warning: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompletedProvider.overrideWith((ref) => isOnboardingDone),
        simulationModeProvider.overrideWith((ref) => isSimulation),
        unitSystemProvider.overrideWith((ref) => units),
      ],
      child: const TrackPointApp(),
    ),
  );
}
