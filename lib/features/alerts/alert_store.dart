import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

// ---------------------------------------------------------------------------
// Keys
// ---------------------------------------------------------------------------
const _kAlertList = 'alert_store_v1_list';
const _kAlertCats = 'alert_store_v1_cats';

// ---------------------------------------------------------------------------
// Persisted alert item
// ---------------------------------------------------------------------------

class PersistedAlert {
  final AlertType type;
  final String title;
  final String message;
  final int timestampMs;
  final String deviceId;

  const PersistedAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.timestampMs,
    required this.deviceId,
  });

  factory PersistedAlert.fromEvent(AlertEvent e) => PersistedAlert(
        type: e.type,
        title: e.title,
        message: e.message,
        timestampMs: e.timestampMs,
        deviceId: e.deviceId,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'message': message,
        'ts': timestampMs,
        'deviceId': deviceId,
      };

  factory PersistedAlert.fromJson(Map<String, dynamic> j) => PersistedAlert(
        type: AlertType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => AlertType.tagOffline,
        ),
        title: j['title'] as String? ?? '',
        message: j['message'] as String? ?? '',
        timestampMs: j['ts'] as int? ?? 0,
        deviceId: j['deviceId'] as String? ?? '',
      );
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class AlertStoreState {
  final List<PersistedAlert> alerts; // newest-first
  final Map<AlertType, bool> enabled; // per-category on/off

  const AlertStoreState({required this.alerts, required this.enabled});

  AlertStoreState copyWith({
    List<PersistedAlert>? alerts,
    Map<AlertType, bool>? enabled,
  }) =>
      AlertStoreState(
        alerts: alerts ?? this.alerts,
        enabled: enabled ?? this.enabled,
      );

  static AlertStoreState get initial => AlertStoreState(
        alerts: const [],
        enabled: {for (final t in AlertType.values) t: true},
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class AlertStoreNotifier extends AsyncNotifier<AlertStoreState> {
  late SharedPreferences _prefs;
  String _suffix = ''; // per-user storage so accounts never see each other's alerts
  String get _listKey => '$_kAlertList$_suffix';
  String get _catsKey => '$_kAlertCats$_suffix';

  @override
  Future<AlertStoreState> build() async {
    final uid = ref.watch(currentUserProvider)?.uid;
    _suffix = uid == null ? '' : '_$uid';
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  AlertStoreState _load() {
    // Load alerts list
    final raw = _prefs.getString(_listKey);
    List<PersistedAlert> alerts = [];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        alerts = decoded
            .map((e) => PersistedAlert.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        alerts = [];
      }
    }

    // Load per-category enabled map
    final catRaw = _prefs.getString(_catsKey);
    Map<AlertType, bool> enabled = {for (final t in AlertType.values) t: true};
    if (catRaw != null) {
      try {
        final decoded = jsonDecode(catRaw) as Map<String, dynamic>;
        for (final t in AlertType.values) {
          if (decoded.containsKey(t.name)) {
            enabled[t] = decoded[t.name] as bool? ?? true;
          }
        }
      } catch (_) {}
    }

    return AlertStoreState(alerts: alerts, enabled: enabled);
  }

  /// Appends an alert if its category is enabled and it is not a duplicate
  /// (same type+tag within 60 s, e.g. local detection + FCM). Keeps at most 200
  /// items. Returns true when the alert was accepted.
  Future<bool> add(AlertEvent event) async {
    final current = state.value ?? AlertStoreState.initial;
    if (!(current.enabled[alertCategory(event.type)] ?? true)) return false;
    final dup = current.alerts.any((a) =>
        a.type == event.type &&
        a.deviceId == event.deviceId &&
        (a.timestampMs - event.timestampMs).abs() < 60000);
    if (dup) return false;

    final item = PersistedAlert.fromEvent(event);
    final next = [item, ...current.alerts].take(200).toList();
    state = AsyncData(current.copyWith(alerts: next));
    await _prefs.setString(
      _listKey,
      jsonEncode(next.map((a) => a.toJson()).toList()),
    );
    return true;
  }

  /// Clears the entire list.
  Future<void> clearAll() async {
    final current = state.value ?? AlertStoreState.initial;
    state = AsyncData(current.copyWith(alerts: []));
    await _prefs.remove(_listKey);
  }

  /// Toggles a category on/off.
  Future<void> setEnabled(AlertType type, bool value) async {
    final current = state.value ?? AlertStoreState.initial;
    final next = Map<AlertType, bool>.from(current.enabled)..[type] = value;
    state = AsyncData(current.copyWith(enabled: next));
    await _prefs.setString(
      _catsKey,
      jsonEncode({for (final t in AlertType.values) t.name: next[t]}),
    );
  }
}

final alertStoreProvider =
    AsyncNotifierProvider<AlertStoreNotifier, AlertStoreState>(
  AlertStoreNotifier.new,
);
