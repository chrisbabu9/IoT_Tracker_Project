import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/config.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_command.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import 'package:trackpoint/data/models/tag_report.dart';

void main() {
  group('TagReport (T-M1)', () {
    test('fromJson defaults', () {
      final r = TagReport.fromJson({});
      expect((r.fix, r.bat, r.csq, r.mode, r.why, r.srv), (0, 0, 99, 'unknown', 'unknown', 0));
      expect(r.hasCoordinates, isFalse);
      expect(r.signalDbm, isNull);
    });
    test('toJson/fromJson round trip', () {
      final r = TagReport.fromJson({
        'fix': 1, 'lat': 10.1, 'lon': 76.2, 'acc': 5, 'spd': 3.5, 'sat': 9,
        'bv': 3.9, 'bat': 77, 'csq': 15, 'mode': 'lost', 'why': 'periodic', 'srv': 123,
      }, pushId: 'p1');
      final j = r.toJson();
      expect(j['lat'], 10.1);
      expect(j.containsKey('crs'), isFalse);
      final again = TagReport.fromJson(j);
      expect((again.lat, again.bat, again.mode, again.srv), (10.1, 77, 'lost', 123));
      expect(r.pushId, 'p1');
    });
    test('signalDbm = -113 + 2*csq, 99 unknown', () {
      TagReport w(int csq) => TagReport.fromJson({'csq': csq});
      expect(w(0).signalDbm, -113);
      expect(w(15).signalDbm, -83);
      expect(w(31).signalDbm, -51);
      expect(w(99).signalDbm, isNull);
    });
    test('copyWith keeps other fields', () {
      final r = TagReport.fromJson({'bat': 50, 'srv': 9}).copyWith(bat: 10);
      expect((r.bat, r.srv), (10, 9));
    });
    test('isFreshFix', () => expect(TagReport.fromJson({'fix': 1}).isFreshFix, isTrue));
  });
  group('TagCommand (T-M2)', () {
    test('defaults to pending/active', () {
      final c = TagCommand.fromJson({'type': 'BUZZER_ON'}, id: 'x');
      expect(c.isPending && c.isActive, isTrue);
    });
    test('status helpers', () {
      TagCommand s(String st) => TagCommand.fromJson({'status': st}, id: 'x');
      expect(s('sent').isActive, isTrue);
      expect(s('completed').isActive, isFalse);
      expect(s('expired').isExpired, isTrue);
      expect(s('failed').isFailed, isTrue);
      expect(s('cancelled').isCancelled, isTrue);
    });
    test('toJson omits null optional fields', () {
      final j = TagCommand.fromJson({'type': 'a'}, id: 'x').toJson();
      expect(j.containsKey('ackedAt'), isFalse);
      expect(j.containsKey('error'), isFalse);
    });
  });
  group('TagSettings / TagConfig (T-M3)', () {
    test('defaults from AppConfig', () {
      const s = TagSettings();
      expect((s.uploadIntervalS, s.pollIntervalS), (AppConfig.defaultUploadIntervalS, AppConfig.defaultPollIntervalS));
    });
    test('fromJson accepts snake_case fallback', () {
      final s = TagSettings.fromJson({'upload_interval_s': 120, 'low_battery_v': 3.6});
      expect((s.uploadIntervalS, s.lowBatteryV), (120, 3.6));
    });
    test('fromJson(null) -> defaults; toJson keys', () {
      expect(TagSettings.fromJson(null).buzzerMaxS, AppConfig.defaultBuzzerMaxS);
      expect(const TagSettings().toJson().keys,
          containsAll(['uploadIntervalS', 'pollIntervalS', 'buzzerMaxS', 'offlineTimeoutS', 'lowBatteryV']));
    });
    test('copyWith', () => expect(const TagSettings().copyWith(pollIntervalS: 7).pollIntervalS, 7));
    test('TagConfig.fromJson with geofence', () {
      final c = TagConfig.fromJson({
        'lostMode': true,
        'geofence': {'enabled': true, 'lat': 1.0, 'lon': 2.0, 'radiusM': 250},
      });
      expect(c.lostMode, isTrue);
      expect(c.geofence!.radiusM, 250);
      expect(c.toJson().containsKey('geofence'), isTrue);
    });
    test('TagConfig.fromJson(null)', () {
      final c = TagConfig.fromJson(null);
      expect(c.geofence, isNull);
      expect(c.lostMode, isNull);
    });
    test('KNOWN LIMITATION B-23: copyWith cannot clear geofence', () {
      final c = TagConfig(geofence: const Geofence(enabled: true, lat: 0, lon: 0)).copyWith();
      expect(c.geofence, isNotNull);
    });
  });
  group('Geofence (T-M4)', () {
    test('defaults radius to AppConfig', () {
      expect(Geofence.fromJson({'enabled': true, 'lat': 1, 'lon': 2}).radiusM, AppConfig.defaultGeofenceRadiusM);
    });
    test('enabled only when literally true', () {
      expect(Geofence.fromJson({'enabled': 'yes'}).enabled, isFalse);
    });
    test('toJson/copyWith', () {
      final g = const Geofence(enabled: false, lat: 1, lon: 2).copyWith(enabled: true, radiusM: 80);
      expect(g.toJson(), {'enabled': true, 'lat': 1.0, 'lon': 2.0, 'radiusM': 80.0});
    });
  });
  group('DeviceSummary / LastSeenNear (T-M5)', () {
    test('fromJson defaults', () {
      final d = DeviceSummary.fromJson({}, deviceId: 'tp_1');
      expect((d.name, d.bleId, d.pairedAt, d.fw, d.lastSeenNear), ('TrackPoint Tag', '', 0, null, null));
    });
    test('merges meta and lastSeenNear', () {
      final d = DeviceSummary.fromJson({'name': 'Keys', 'bleId': 'AA', 'pairedAt': 5},
          deviceId: 'tp_1',
          metaJson: {'fw': '1.0', 'owner': 'u', 'createdAt': 9},
          lastSeenNearJson: {'lat': 1.0, 'lon': 2.0, 'ts': 3});
      expect((d.fw, d.owner, d.createdAt, d.lastSeenNear!.ts), ('1.0', 'u', 9, 3));
      expect(d.toUserDeviceJson(), {'name': 'Keys', 'pairedAt': 5, 'bleId': 'AA'});
    });
    test('copyWith + LastSeenNear json', () {
      final d = DeviceSummary.fromJson({}, deviceId: 'a').copyWith(name: 'N');
      expect(d.name, 'N');
      const l = LastSeenNear(lat: 1, lon: 2, ts: 3);
      expect(LastSeenNear.fromJson(l.toJson()).lon, 2);
    });
  });
}
