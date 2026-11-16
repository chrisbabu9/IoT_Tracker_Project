import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/data/firebase/auth_repository.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/alerts/alert_store.dart';

AlertEvent ev(AlertType t, [int ts = 1]) => AlertEvent(
    type: t, title: 't', message: 'm', timestampMs: ts, deviceId: 'd');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<(ProviderContainer, AlertStoreNotifier)> boot() async {
    final c = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())]);
    addTearDown(c.dispose);
    await c.read(alertStoreProvider.future);
    return (c, c.read(alertStoreProvider.notifier));
  }

  group('AlertStoreNotifier (T-A1)', () {
    test('add keeps newest first', () async {
      final (c, n) = await boot();
      await n.add(ev(AlertType.lowBattery, 1));
      await n.add(ev(AlertType.sosAlert, 2));
      expect(c.read(alertStoreProvider).value!.alerts.map((a) => a.timestampMs), [2, 1]);
    });
    test('disabled category is dropped', () async {
      final (c, n) = await boot();
      await n.setEnabled(AlertType.lowBattery, false);
      await n.add(ev(AlertType.lowBattery));
      expect(c.read(alertStoreProvider).value!.alerts, isEmpty);
    });
    test('caps at 200', () async {
      final (c, n) = await boot();
      for (var i = 0; i < 205; i++) {
        await n.add(ev(AlertType.tagOffline, i * 100000));
      }
      expect(c.read(alertStoreProvider).value!.alerts.length, 200);
    });
    test('duplicates within 60 s are rejected, later ones accepted (B-07)', () async {
      final (c, n) = await boot();
      expect(await n.add(ev(AlertType.sosAlert, 1000)), isTrue);
      expect(await n.add(ev(AlertType.sosAlert, 30000)), isFalse);
      expect(await n.add(ev(AlertType.sosAlert, 90000)), isTrue);
      expect(c.read(alertStoreProvider).value!.alerts.length, 2);
    });
    test('related types share a category toggle (B-07)', () async {
      final (c, n) = await boot();
      await n.setEnabled(AlertType.tagOffline, false);
      expect(await n.add(ev(AlertType.tagBackOnline)), isFalse);
      expect(c.read(alertStoreProvider).value!.alerts, isEmpty);
    });
    test('clearAll', () async {
      final (c, n) = await boot();
      await n.add(ev(AlertType.tagOffline));
      await n.clearAll();
      expect(c.read(alertStoreProvider).value!.alerts, isEmpty);
    });
    test('persists across containers', () async {
      final (_, n) = await boot();
      await n.add(ev(AlertType.gpsFixLost, 7));
      await n.setEnabled(AlertType.movementDetected, false);
      final (c2, _) = await boot();
      final s = c2.read(alertStoreProvider).value!;
      expect(s.alerts.single.timestampMs, 7);
      expect(s.enabled[AlertType.movementDetected], isFalse);
      expect(s.enabled[AlertType.sosAlert], isTrue);
    });
    test('corrupt prefs fall back to empty', () async {
      SharedPreferences.setMockInitialValues({'alert_store_v1_list': '{bad'});
      final (c, _) = await boot();
      expect(c.read(alertStoreProvider).value!.alerts, isEmpty);
    });
    test('PersistedAlert json round trip, unknown type -> tagOffline', () {
      final a = PersistedAlert.fromJson({'type': 'zzz', 'ts': 5});
      expect((a.type, a.timestampMs, a.title), (AlertType.tagOffline, 5, ''));
      expect(PersistedAlert.fromEvent(ev(AlertType.sosAlert)).toJson()['type'], 'sosAlert');
    });
  });
}
