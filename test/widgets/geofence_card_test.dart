import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/domain/geofence_tracker.dart';
import 'package:trackpoint/features/geofence/geofence_card.dart';
import 'package:trackpoint/features/geofence/geofence_providers.dart';

Widget host(GeofenceStatus? s) => ProviderScope(
      overrides: [geofenceStatusProvider.overrideWithValue(s)],
      child: MaterialApp(theme: AppTheme.darkTheme, home: const Scaffold(body: GeofenceCard())),
    );

const fence = Geofence(enabled: true, lat: 0, lon: 0, radiusM: 100);

void main() {
  testWidgets('not set (T-W4)', (tester) async {
    await tester.pumpWidget(host(null));
    expect(find.text(AppStrings.geofenceNotSet), findsOneWidget);
  });
  testWidgets('disabled shows Off + radius (T-W4b)', (tester) async {
    await tester.pumpWidget(host(GeofenceStatus(fence: fence.copyWith(enabled: false))));
    expect(find.text('${AppStrings.geofenceOff} · 100 m'), findsOneWidget);
  });
  testWidgets('waiting for fix (T-W4c)', (tester) async {
    await tester.pumpWidget(host(const GeofenceStatus(fence: fence)));
    expect(find.text(AppStrings.geofenceWaitingFix), findsOneWidget);
  });
  testWidgets('inside / outside text (T-W4d)', (tester) async {
    await tester.pumpWidget(host(const GeofenceStatus(
        fence: fence,
        evaluation: GeofenceEvaluation(isInside: true, distanceToCenterMeters: 20, radiusMeters: 100))));
    expect(find.text('${AppStrings.geofenceInside} · 20 m ${AppStrings.geofenceFromCentre}'), findsOneWidget);

    await tester.pumpWidget(host(const GeofenceStatus(
        fence: fence,
        evaluation: GeofenceEvaluation(isInside: false, distanceToCenterMeters: 1500, radiusMeters: 100))));
    await tester.pump();
    expect(find.text('${AppStrings.geofenceOutside} · 1.5 km ${AppStrings.geofenceFromCentre}'), findsOneWidget);
  });
}
