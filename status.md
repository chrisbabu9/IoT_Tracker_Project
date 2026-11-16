# status.md — architecture, bug register, plan (update rows only)
Last analysis: 2026-11-11 (static read; Flutter SDK unavailable in sandbox, nothing executed).

## 1. Architecture (81 files, ~10k lines, Flutter + Riverpod + go_router + Firebase RTDB + flutter_blue_plus)
```
main.dart ─ Firebase init, RTDB persistence, SharedPreferences(onboarding) ─> ProviderScope
app.dart  ─ GoRouter (auth redirect) + MaterialApp.router builder:
            SosBannerHost > AlertToastHost > Navigator;  keeps alive while signed in:
            lastSeenNearService, tagConnectionManager, geofenceMonitor, alertMonitor, push service
core/     config, geo(haversine), result(Result<T>/AppException), strings, theme, time_utils
domain/   tag_presence, tag_mode, lost_policy, distance_zone(median7+EMA), geofence_tracker,
          alert_rules(AlertType/AlertEvent), trip_stats, history_utils(day bounds, path, CSV)
data/ble  TagBleService (iface) <- FlutterBluePlusTagBleService | FakeTagBleService; tp_ble_protocol
data/fb   Auth/Device/Report/Command/Config repositories (iface + Firebase + Fake each)
data/models DeviceSummary/LastSeenNear, TagReport, TagCommand, TagConfig/TagSettings, Geofence
features  auth, home(tag_card), dashboard, map, find(buzzer), lost(+sos banner), geofence,
          history, alerts(bus/monitor/store), pair, settings(device/app/developer), help, onboarding
```
Mode switch: `simulationModeProvider` (auth_state.dart) -> `bleServiceProvider` returns Fake or real.
Firebase is ALWAYS production unless `--dart-define=USE_EMULATOR=true`; only BLE is simulated.
Data flow: tag --LTE--> RTDB devices/{id}/history (srv ts) -> `latestReportProvider` -> presence/alerts/map.
App --cloud command--> devices/{id}/commands (2-min expiry) when BLE not connected, else BLE write.

## 2. Bug register  (H=breaks feature/data, M=wrong behaviour, L=polish)  state: open|fixed|wontfix
| ID | Sev | Where (file:symbol) | Problem -> fix | State |
|----|-----|---------------------|----------------|-------|
| B-01 | H | auth_state:simulationModeProvider/bleServiceProvider | Defaults to simulation (true), not persisted; Fake created per rebuild, never disposed. -> default `!kReleaseMode`, persist in prefs, `ref.onDispose(service.dispose)` | fixed |
| B-02 | H | FakeTagBleService + pair flow | Sim pairing claims fixed id `tp_9f3a7c21b4d85e60` in PRODUCTION RTDB; one shared state for all bleIds; switching to real leaves ghost tag (autoConnect to fake MAC forever). -> per-bleId state, sim ids prefixed `sim_`, hide/clean sim tags when mode flips | fixed |
| B-03 | H | app.dart:TrackPointApp.build | `pushNotificationService.initialize()` runs on EVERY rebuild -> duplicate FCM listeners/subscriptions, repeated token writes. -> init once via provider/`ref.listen`; cancel old subs | fixed |
| B-04 | H | geofence_screen:_loadFromConfig | `setState` during `build`; `_loaded=true` while config still loading so saved fence is never shown. -> load only when `AsyncData`, in listener/post-frame | fixed |
| B-05 | H | alert_monitor:_onReport | Offline alert evaluated only when a NEW report arrives -> never fires when tag goes silent; timeout hardcoded 900 s. -> periodic timer + per-tag `offlineTimeoutS` | fixed |
| B-06 | H | alert_monitor:build/_onReport | No baseline: first stream value (app start, rename => rebuild clears `_watchers`) re-fires final/SOS/movement; SOS & lost alert on every report (spam + notification each). -> persist last handled `srv` per device, edge-trigger SOS/lost | fixed |
| B-07 | M | alert_monitor:_emit, alerts_screen:_categories | Local notification posted even if category disabled; geofenceReEntered/tagBackOnline/batteryCriticalFinal not toggleable; geofence+push events get no system notification; FCM + local duplicates. -> single `AlertService` (filter -> store -> notify, dedupe by type+device+srv) | fixed |
| B-08 | H | features/alerts, history, dashboard | Missing: `leftBehind` alert (never emitted; onboarding promises it); no background execution so BLE-disconnect/lastSeenNear only while app alive; History has no CSV export/delete/replay though strings/providers/repo exist. -> implement or remove copy | fixed (CSV export, delete day, route replay, foreground left-behind alert; no background service) |
| B-09 | M | auth_repository:deleteAccount, signOut | Tags stay owned by deleted uid; users/{uid} not deleted; alerts in prefs not per-user; selected tag/FCM token survive sign-out. -> cleanup pipeline | fixed |
| B-10 | M | map_screen, geofence_map, history_path_map | `activeTileUrlProvider` (Developer override) never used; hardcoded OSM/Esri. | fixed |
| B-11 | M | last_seen_near_service, map_screen | Location permission only *checked*, requested only in real pairing; sim skips -> phone marker/lastSeenNear silently off. `Geolocator.getCurrentPosition(desiredAccuracy,timeLimit)` deprecated in v13 -> `locationSettings` | fixed |
| B-12 | M | tag_card, tag_providers (empty bleId) | `BluetoothDevice.fromId('')` throws in real mode for devices with `bleId==''`. -> guard before provider call | fixed |
| B-13 | M | device_repository | `watchUserDevices` N+1 sequential `get`s per event; meta/lastSeenNear not live; `renameDevice` 2 non-atomic writes (use `update`); `claimDevice` read-then-write race (transaction + rules) | fixed |
| B-14 | M | command_repository:sendCommand | Pending BUZZER_ON not cancelled by BUZZER_OFF; expiry only set by an open UI; needs `.indexOn:["status"]` | fixed |
| B-15 | M | stats_provider, map_screen:_path24hProvider | limit 500 < 1440 pts/day in Lost mode (oldest cut); duplicate 24 h queries; never refresh on new report | fixed |
| B-16 | M | history_path_map, history_screen | Map keeps initialCenter (no re-center/fit on data change); `bat != null` always true (int); RTDB needs `.indexOn:["srv"]` (rules file not in repo) | fixed |
| B-17 | M | Fake repos | `FakeDeviceRepository.watchUserDevices`/`FakeReportRepository.watchLatestReport` emit no initial value (tests load forever); `FakeReportRepository.getPagedHistory` sorts stored list in place (breaks `getLatestReport`) | fixed |
| B-18 | L | pair_tag_screen | `setState` via `_log` from initState path; BLE link left connected if claim fails; scan sub not cancelled on window expiry | fixed |
| B-19 | L | settings | Units, timezone, theme(System) options not wired/persisted; `lowBatteryV` unused (alerts use 20 %) | fixed (units wired+persisted; timezone card removed; theme option removed) |
| B-20 | M | all screens, theme.dart | Light theme broken: hardcoded `AppTheme.dark*` colours; sign-in title `Colors.white` invisible | fixed by decision: app is dark-only (light theme not supported) |
| B-21 | L | tag_mode, device_settings_screen | stale 'lost' report has no age limit; `_DeviceInfoCard.presence` is `dynamic` | fixed |
| B-22 | L | tag_card, dashboard | battery colour thresholds differ (40 vs 60); `csq 99` (unknown) counted as good signal in TagCard | fixed |
| B-23 | L | strings, config, geofence | ~60 unused strings; unused consts (min/maxGeofenceRadiusM, geofenceStepM); geofence default 100 (screen) vs 500 (config); slider 20–2000 vs 50–5000; `TagConfig.copyWith` cannot clear geofence | partial (geofence defaults fixed; dead strings remain) |
| B-24 | M | geofence_providers, history_providers | Test hooks `geofenceMapEnabledProvider`/`historyMapEnabledProvider` never read -> widget tests hit network tiles | fixed |
| B-25 | M | pubspec.yaml | `sdk >=3.0.0` but code needs Flutter ≥3.35 (`DropdownButtonFormField.initialValue`, `CardThemeData`, `withValues`) | fixed |
| B-26 | L | firebase_options, developer_screen | Keys committed (restrict + App Check); `database.rules.json` not in repo so ownership rules unverified; diagnostics write `users/{uid}/_diagnostic_ping` | fixed: database.rules.suggested.json (review + emulator-test before deploying) |
| B-27 | L | flutter_blue_plus_service | `dispose()` never called; subs for removed tags leak; failed RSSI read reported as connected @ -100 ("Edge of range") | fixed (RSSI fallback; dispose wired via B-01) |
| B-28 | L | alert_bus:alertRoute | Most alerts `push('/home')` (stacks Home); route to `/dashboard` with `deviceId` | fixed |

## 3. Plan (token-minimal, fix in this order; each step = read 1 symbol, edit, test)
1. P0 data/safety: B-01, B-02, B-03, B-04  (+ tests in tests.md T-W*, T-S*)
2. P1 alerts correctness: B-05, B-06, B-07, B-28 (introduce AlertService; unit-test with FakeReportRepository)
3. P1 platform: B-11, B-12, B-25, B-24, B-17 (unblocks tests)
4. P2 data: B-13, B-14, B-15, B-16, B-09
5. P2 UX: B-20, B-10, B-19, B-18, B-08 (decide: implement vs drop left-behind/CSV/replay)
6. P3 cleanup: B-21, B-22, B-23, B-26, B-27

## 4. Test status
Written (not executed): see tests.md. Files in `test/`. Run `flutter test` locally; paste failures only.

## 5. Manual QA (production mode, real tag)
Dev screen -> Simulation OFF -> restart app -> pair (60 s window) -> verify: bond, DEVICE_INFO id,
claim in RTDB, link RSSI zones, buzzer via BLE, buzzer via cloud (BLE off, expect <= poll interval),
Lost on/off confirm, SOS banner, geofence leave/re-enter (app open), history paging, FCM background.

## 6. Fix log (this session) — verification level
Verified on Dart VM (181 tests, `tools_run.sh` shim; pure logic + fakes + alert evaluator):
B-02 (per-tag fake, SIM:/sim_ namespace), B-05/06/07 (AlertEvaluator, category map, store dedupe), B-14 (fake + `oppositeCommandType`), B-17.
Compile-checked only (no Flutter SDK here; syntax-level analyze clean) — RUN LOCALLY (`flutter analyze`, `flutter test`):
B-01, B-03, B-04, B-09, B-10, B-11, B-12, B-13, B-15, B-16, B-18, B-21, B-22, B-23, B-24, B-25, B-28.
Needs Firebase emulator / device to verify: B-09 (delete-account cleanup), B-13 (claim transaction), B-14 (Firebase cancel), B-03 (FCM).
Architecture change: each `*_repository.dart` is now a barrel -> `*_repository_base.dart` (interface), `firebase_*`, `fake_*`.
New files: core/phone_location.dart, domain/alert_evaluator.dart.
Required RTDB indexes (add to database.rules.json): devices/$id/history `.indexOn: ["srv"]`; devices/$id/commands `.indexOn: ["status"]`.
Behaviour notes: simulation shows only `sim_*` tags, real mode only real tags; sim mode now persisted (default OFF in release).
Still open: B-23 (unused strings only).
Phase 3 (this round): fixed `fireImmediately` compile error in app.dart (WidgetRef.listen has none; push init now post-frame + idempotent by uid).
New: core/units.dart (Units.distance/speed), AlertEvaluator.onBleDrop (left-behind, 10 min cooldown, skipped in Lost/SOS), history export/delete/replay in history_screen.dart,
database.rules.suggested.json (ownership + indexes; claim needs `meta/owner` readable by any signed-in user).
Limits: left-behind works only while the app process is alive; geofence radius label on the editor screen stays metric.
