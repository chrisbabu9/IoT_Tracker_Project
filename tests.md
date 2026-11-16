# tests.md — test registry (every public function -> test ID -> file)
Run: `flutter analyze && flutter test --coverage`. State: 206 tests pass locally (`flutter test`); 188 also run on the Dart VM shim via `tools_run.sh` (stub shim: core, domain, protocol, models, fake BLE, fake repos, evaluator). Widget tests + alert_store_test are WRITTEN, NOT EXECUTED (need Flutter/Riverpod).
B-17 tests now pass (bugs fixed).

## Unit
| ID | Functions covered | File |
|----|-------------------|------|
| T-C1 | GeoUtils.haversineDistance | test/core/geo_test.dart |
| T-C2 | GeoUtils.isValidCoordinate | geo_test |
| T-C3 | GeoUtils.calculateSpeedKmh | geo_test |
| T-C4 | TimeUtils.formatTimeAgo | test/core/time_utils_test.dart |
| T-C5 | TimeUtils.formatDateTime / formatDateOnly / formatTimeOnly | time_utils_test |
| T-C6 | TimeUtils.formatDuration | time_utils_test |
| T-C7 | Result.success/failure/fold/dataOrNull/exceptionOrNull, AppException(+subclasses) | test/core/result_test.dart |
| T-C8/9 | Units.distance / Units.speed | test/core/units_test.dart |
| T-E4 | AlertEvaluator.onBleDrop, DeviceAlertState.setBle | test/domain/alert_evaluator_test.dart |
| T-D1 | LostPolicy.getReportingIntervalSeconds | test/domain/lost_policy_test.dart |
| T-D2 | LostPolicy.getMatchingRowIndex + rows consistency (0..100) | lost_policy_test |
| T-D3 | DistanceZoneCalculator.getZoneFromRssi | test/domain/distance_zone_test.dart |
| T-D4 | DistanceZoneCalculator.getZoneLabel | distance_zone_test |
| T-D5 | DistanceZoneCalculator.addSample / reset (median, EMA, trend) | distance_zone_test |
| T-D6 | TagPresence.compute (+TagPresenceInfo getters) | test/domain/tag_presence_test.dart |
| T-D7 | TagModeResolver.resolve | test/domain/tag_mode_test.dart |
| T-D8 | GeofenceTracker.update / reset | test/domain/geofence_tracker_test.dart |
| T-D9 | formatDistance | geofence_tracker_test |
| T-D10 | GeofenceStatus.compute, AlertRules.evaluateGeofence | geofence_tracker_test |
| T-D11 | TripStats.calculate / distanceKm | test/domain/trip_stats_test.dart |
| T-D12 | HistoryDay.dateOnly / bounds | test/domain/history_utils_test.dart |
| T-D13 | HistoryPath.withCoordinates | history_utils_test |
| T-D14 | HistoryCsv.build / fileName (+_cell quoting) | history_utils_test |
| T-B1 | TpBleProtocol encode/decode Buzzer, Status, DeviceInfo, Command; TagStatus.toString | test/data/tp_ble_protocol_test.dart |
| T-B2 | FakeTagBleService: linkState, status, simulate*, setBuzzer, sendCommand, scan, pairAndBond (B-02 doc test) | test/data/fake_ble_test.dart |
| T-M1 | TagReport fromJson/toJson/copyWith/signalDbm | test/data/models_test.dart |
| T-M2 | TagCommand fromJson/toJson/status getters | models_test |
| T-M3 | TagSettings/TagConfig fromJson/toJson/copyWith (B-23 doc test) | models_test |
| T-M4 | Geofence fromJson/toJson/copyWith | models_test |
| T-M5 | DeviceSummary/LastSeenNear fromJson/toUserDeviceJson/copyWith | models_test |
| T-R1 | FakeCommandRepository (send, dedupe, cancel-opposite, expire, watch*), oppositeCommandType | test/data/fake_repos_test.dart |
| T-R2 | FakeConfigRepository | fake_repos_test |
| T-R3 | FakeDeviceRepository (+ B-17 EXPECTED FAIL: watchUserDevices initial value) | fake_repos_test |
| T-R4 | FakeReportRepository (+ B-17 EXPECTED FAIL: paging mutates list) | fake_repos_test |
| T-R5 | FakeAuthRepository | fake_repos_test |
| T-E1 | AlertEvaluator.onReport (baseline, edge SOS/lost, battery, rebuild-safety) | test/domain/alert_evaluator_test.dart |
| T-E2 | AlertEvaluator.onTick (offline by time, BLE, grace) | alert_evaluator_test |
| T-E3 | alertCategory | alert_evaluator_test |
| T-A1 | AlertStoreNotifier add/setEnabled/clearAll/persist/cap, PersistedAlert json | test/data/alert_store_test.dart |

## Widget
| ID | Widget | File |
|----|--------|------|
| T-W1/1b | HelpScreen (expand, 7 sections) | test/widgets/help_screen_test.dart |
| T-W2..2f | SignInScreen (validation, wrong/right password, nav, obscure toggle) | sign_in_screen_test.dart |
| T-W3..3c | AlertsScreen (empty, list+clear, settings toggle persists) | alerts_screen_test.dart |
| T-W4..4d | GeofenceCard (not set, off, waiting, inside/outside) | geofence_card_test.dart |
| T-W5 | CommandStatusCard (pending -> completed, countdown) | command_status_card_test.dart |

## TODO (not covered; needs plugin mocks or integration env)
| ID | Target | Needs |
|----|--------|-------|
| T-X1 | TagCard, HomeScreen (rename/remove dialogs) | override repos with Fakes; fix B-12/B-17 first |
| T-X2 | PairTagScreen full flow in sim mode | Fake BLE + FakeDeviceRepository; fix B-18 |
| T-X3 | GeofenceScreen load/save | fix B-04, B-24 |
| T-X4 | HistoryScreen paging/day filter | fix B-24, B-16 |
| T-X5 | LostModeScreen toggle (BLE + cloud routes), FindScreen buzzer | Fake BLE/command repos |
| T-X6 | DeviceSettingsScreen validators | Fake config repo |
| T-X7 | AlertMonitor (offline timer, baseline, edge-triggered SOS) | after B-05/06 refactor into AlertService |
| T-X8 | Firebase*Repository, PushNotificationService, FlutterBluePlusTagBleService, LastSeenNearService | Firebase emulator / hardware, integration_test |
| T-X9 | Router redirect (RouterNotifier.redirect) | ProviderScope with Fake auth |

## Rule
New/changed public function => add a row here + test in the same change. Update the "State" line after each local run.

| T-X10 | HistoryScreen export/delete/replay widgets | Fake report repo + fake CsvExporter override |
