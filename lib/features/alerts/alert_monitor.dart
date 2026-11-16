import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/data/models/tag_report.dart';
import 'package:trackpoint/domain/alert_evaluator.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/features/alerts/alert_bus.dart';
import 'package:trackpoint/features/alerts/alert_store.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

// ---------------------------------------------------------------------------
// Local notifications helper (singleton)
// ---------------------------------------------------------------------------

final _notif = FlutterLocalNotificationsPlugin();
bool _notifInitialised = false;
int _notifId = 0;

Future<void> _ensureNotifInit() async {
  if (_notifInitialised) return;
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();
  await _notif.initialize(
    const InitializationSettings(android: android, iOS: ios),
  );
  _notifInitialised = true;
}

Future<void> _postNotification({
  required String title,
  required String body,
}) async {
  await _ensureNotifInit();
  const android = AndroidNotificationDetails(
    AppStrings.alertNotifChannelId,
    AppStrings.alertNotifChannelName,
    importance: Importance.high,
    priority: Priority.high,
  );
  const ios = DarwinNotificationDetails();
  await _notif.show(
    _notifId++,
    title,
    body,
    const NotificationDetails(android: android, iOS: ios),
  );
}

// ---------------------------------------------------------------------------
// AlertMonitor: feeds reports + BLE link + a 30 s clock into AlertEvaluator and
// is the single sink for every alert (monitor, geofence, push): store ->
// (accepted only) toast + system notification.
// ---------------------------------------------------------------------------

class _DeviceWatch {
  StreamSubscription<TagReport?>? reportSub;
  StreamSubscription<BleLink>? linkSub;
  void cancel() {
    reportSub?.cancel();
    linkSub?.cancel();
  }
}

class AlertMonitor extends AsyncNotifier<void> {
  final Map<String, _DeviceWatch> _watchers = {};
  // Survive provider rebuilds (device list changes) so nothing is re-fired.
  final Map<String, DeviceAlertState> _states = {};
  final Map<String, String> _names = {};
  final Map<String, int> _timeouts = {};

  int _timeoutOf(String id) => _timeouts[id] ?? 900;

  @override
  Future<void> build() async {
    final devices = ref.watch(userDevicesProvider).value ?? [];
    final ble = ref.watch(bleServiceProvider);
    final bus = ref.read(alertBusProvider);
    final reportRepo = ref.read(reportRepositoryProvider);

    for (final w in _watchers.values) {
      w.cancel();
    }
    _watchers.clear();
    final ids = devices.map((d) => d.deviceId).toSet();
    _states.removeWhere((id, _) => !ids.contains(id));

    for (final d in devices) {
      final id = d.deviceId;
      _names[id] = d.name;
      final st = _states.putIfAbsent(id, DeviceAlertState.new);
      final w = _DeviceWatch();
      _watchers[id] = w;

      w.reportSub = reportRepo.watchLatestReport(id).listen((report) {
        for (final e in AlertEvaluator.onReport(
          st: st,
          deviceId: id,
          tagName: _names[id] ?? d.name,
          report: report,
          nowMs: DateTime.now().millisecondsSinceEpoch,
          offlineTimeoutS: _timeoutOf(id),
        )) {
          bus.emit(e);
        }
      });
      if (d.bleId.isNotEmpty) {
        w.linkSub = ble.linkState(d.bleId).listen((l) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (st.setBle(l.isConnected, now)) {
            for (final e in AlertEvaluator.onBleDrop(
                st: st, deviceId: id, tagName: _names[id] ?? d.name, nowMs: now)) {
              bus.emit(e);
            }
          }
        });
      }
      ref.listen(tagConfigProvider(id), (_, next) {
        final cfg = next.valueOrNull;
        if (cfg != null) _timeouts[id] = cfg.settings.offlineTimeoutS;
      }, fireImmediately: true);
    }

    final busSub = bus.stream.listen(_persist);
    final timer = Timer.periodic(const Duration(seconds: 30), (_) {
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final entry in _states.entries) {
        for (final e in AlertEvaluator.onTick(
          st: entry.value,
          deviceId: entry.key,
          tagName: _names[entry.key] ?? entry.key,
          nowMs: now,
          offlineTimeoutS: _timeoutOf(entry.key),
        )) {
          bus.emit(e);
        }
      }
    });

    ref.onDispose(() {
      busSub.cancel();
      timer.cancel();
      for (final w in _watchers.values) {
        w.cancel();
      }
      _watchers.clear();
    });
  }

  Future<void> _persist(AlertEvent event) async {
    await ref.read(alertStoreProvider.future); // prefs must be loaded
    final ok = await ref.read(alertStoreProvider.notifier).add(event);
    if (!ok) return; // disabled category or duplicate
    ref.read(alertBusProvider).accept(event);
    unawaited(_postNotification(title: event.title, body: event.message));
  }
}

final alertMonitorProvider =
    AsyncNotifierProvider<AlertMonitor, void>(AlertMonitor.new);
