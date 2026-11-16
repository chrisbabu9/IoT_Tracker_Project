import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/data/firebase/auth_repository_base.dart';
import 'package:trackpoint/data/firebase/fake_auth_repository.dart';
import 'package:trackpoint/data/firebase/command_repository_base.dart';
import 'package:trackpoint/data/firebase/fake_command_repository.dart';
import 'package:trackpoint/data/firebase/fake_config_repository.dart';
import 'package:trackpoint/data/firebase/fake_device_repository.dart';
import 'package:trackpoint/data/firebase/fake_report_repository.dart';
import 'package:trackpoint/data/models/geofence.dart';
import 'package:trackpoint/data/models/tag_config.dart';
import '../helpers.dart';

void main() {
  group('FakeCommandRepository (T-R1)', () {
    late FakeCommandRepository repo;
    setUp(() => repo = FakeCommandRepository());
    tearDown(() => repo.dispose());

    test('creates pending command, de-duplicates same type', () async {
      final a = (await repo.sendCommand(deviceId: 'd', type: 'BUZZER_ON')).dataOrNull!;
      final b = (await repo.sendCommand(deviceId: 'd', type: 'BUZZER_ON')).dataOrNull!;
      expect(a.isPending, isTrue);
      expect(b.id, a.id);
      expect(a.expiresAt - a.createdAt, 120000);
    });
    test('opposite command cancels the pending one (B-14)', () async {
      final a = (await repo.sendCommand(deviceId: 'd', type: 'BUZZER_ON')).dataOrNull!;
      final b = (await repo.sendCommand(deviceId: 'd', type: 'BUZZER_OFF')).dataOrNull!;
      expect(b.id, isNot(a.id));
      expect((await repo.watchCommand('d', a.id).first)!.isCancelled, isTrue);
      expect((await repo.getActiveCommand('d', 'BUZZER_ON')).dataOrNull, isNull);
    });
    test('oppositeCommandType pairs', () {
      expect(oppositeCommandType('LOST_ON'), 'LOST_OFF');
      expect(oppositeCommandType('BUZZER_OFF'), 'BUZZER_ON');
      expect(oppositeCommandType('REPORT_NOW'), isNull);
    });
    test('completed command allows a new one', () async {
      final a = (await repo.sendCommand(deviceId: 'd', type: 'LOST_ON')).dataOrNull!;
      repo.updateCommandStatus('d', a.id, 'completed');
      final b = (await repo.sendCommand(deviceId: 'd', type: 'LOST_ON')).dataOrNull!;
      expect(b.id, isNot(a.id));
    });
    test('watchCommand emits current value first', () async {
      final a = (await repo.sendCommand(deviceId: 'd', type: 'REPORT_NOW')).dataOrNull!;
      expect((await repo.watchCommand('d', a.id).first)!.id, a.id);
    });
    test('markExpired', () async {
      final a = (await repo.sendCommand(deviceId: 'd', type: 'X')).dataOrNull!;
      await repo.markExpired('d', a.id);
      expect((await repo.getActiveCommand('d', 'X')).dataOrNull, isNull);
    });
    test('watchRecentCommands newest first, limited', () async {
      for (final t in ['A', 'B', 'C']) {
        await repo.sendCommand(deviceId: 'd', type: t);
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      final list = await repo.watchRecentCommands('d', limit: 2).first;
      expect(list.map((c) => c.type), ['C', 'B']);
    });
  });

  group('FakeConfigRepository (T-R2)', () {
    test('settings + geofence update, clear keeps settings', () async {
      final repo = FakeConfigRepository();
      addTearDown(repo.dispose);
      await repo.updateSettings('d', const TagSettings(pollIntervalS: 9));
      await repo.updateGeofence('d', const Geofence(enabled: true, lat: 1, lon: 2));
      var c = (await repo.getConfig('d')).dataOrNull!;
      expect((c.settings.pollIntervalS, c.geofence!.lat), (9, 1.0));
      await repo.clearGeofence('d');
      c = (await repo.getConfig('d')).dataOrNull!;
      expect(c.geofence, isNull);
      expect(c.settings.pollIntervalS, 9);
    });
    test('watchConfig yields default first', () async {
      final repo = FakeConfigRepository();
      addTearDown(repo.dispose);
      expect((await repo.watchConfig('x').first).geofence, isNull);
    });
  });

  group('FakeDeviceRepository (T-R3)', () {
    late FakeDeviceRepository repo;
    setUp(() => repo = FakeDeviceRepository());
    tearDown(() => repo.dispose());
    Future<void> claim(String uid) => repo.claimDevice(uid: uid, deviceId: 'tp_1', name: 'Keys', bleId: 'AA', fw: '1');

    test('claim, list, rename, remove', () async {
      await claim('u1');
      expect((await repo.getUserDevices('u1')).dataOrNull!.single.name, 'Keys');
      await repo.renameDevice(uid: 'u1', deviceId: 'tp_1', newName: 'Wallet');
      expect((await repo.getUserDevices('u1')).dataOrNull!.single.name, 'Wallet');
      await repo.removeDevice(uid: 'u1', deviceId: 'tp_1');
      expect((await repo.getUserDevices('u1')).dataOrNull, isEmpty);
    });
    test('second user cannot claim -> already-owned', () async {
      await claim('u1');
      final r = await repo.claimDevice(uid: 'u2', deviceId: 'tp_1', name: 'x', bleId: 'b', fw: '1');
      expect(r.isFailure, isTrue);
      expect(r.exceptionOrNull!.code, 'already-owned');
    });
    test('rename unknown device fails', () async {
      expect((await repo.renameDevice(uid: 'u', deviceId: 'nope', newName: 'n')).isFailure, isTrue);
    });
    test('lastSeenNear round trip', () async {
      await repo.recordLastSeenNear(deviceId: 'd', lat: 1, lon: 2, timestampMs: 3);
      expect((await repo.watchLastSeenNear('d').first)!.ts, 3);
    });
    test('B-17: watchUserDevices must emit current list on subscribe', () async {
      await claim('u1');
      final list = await repo.watchUserDevices('u1').first.timeout(const Duration(milliseconds: 300));
      expect(list.length, 1);
    });
  });

  group('FakeReportRepository (T-R4)', () {
    late FakeReportRepository repo;
    setUp(() => repo = FakeReportRepository());
    tearDown(() => repo.dispose());

    test('latest + range filter + sorted ascending', () async {
      repo.addReport('d', rep(srv: 300));
      repo.addReport('d', rep(srv: 100));
      repo.addReport('d', rep(srv: 200));
      final r = (await repo.getReportsRange(deviceId: 'd', startSrv: 100, endSrv: 250)).dataOrNull!;
      expect(r.map((e) => e.srv), [100, 200]);
    });
    test('getLatestReport empty -> null', () async {
      expect((await repo.getLatestReport('d')).dataOrNull, isNull);
    });
    test('paged history newest first with endBefore cursor', () async {
      for (final s in [1, 2, 3, 4]) {
        repo.addReport('d', rep(srv: s));
      }
      final p = (await repo.getPagedHistory(deviceId: 'd', endBeforeSrv: 4, limit: 2)).dataOrNull!;
      expect(p.map((e) => e.srv), [3, 2]);
    });
    test('B-17: paging must not mutate stored order', () async {
      for (final s in [1, 2, 3]) {
        repo.addReport('d', rep(srv: s));
      }
      await repo.getPagedHistory(deviceId: 'd');
      expect((await repo.getLatestReport('d')).dataOrNull!.srv, 3);
    });
    test('deleteDayReports removes only that local day', () async {
      repo.addReport('d', rep(srv: DateTime(2026, 10, 24, 12).millisecondsSinceEpoch));
      repo.addReport('d', rep(srv: DateTime(2026, 10, 25, 1).millisecondsSinceEpoch));
      final n = (await repo.deleteDayReports(deviceId: 'd', day: DateTime(2026, 10, 24))).dataOrNull;
      expect(n, 1);
      expect((await repo.getPagedHistory(deviceId: 'd')).dataOrNull!.length, 1);
    });
  });

  group('FakeAuthRepository (T-R5)', () {
    test('sign in fails with wrong password, succeeds with default', () async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      expect((await repo.signInWithEmailAndPassword(email: 'a@b.c', password: 'bad')).isFailure, isTrue);
      final ok = await repo.signInWithEmailAndPassword(email: 'a@b.c', password: 'password123');
      expect(ok.dataOrNull!.email, 'a@b.c');
      expect(repo.currentUser, isNotNull);
    });
    test('changePassword then sign-in with new one', () async {
      final repo = FakeAuthRepository();
      addTearDown(repo.dispose);
      expect((await repo.changePassword(currentPassword: 'x', newPassword: 'newpassword1')).isFailure, isTrue);
      await repo.changePassword(currentPassword: 'password123', newPassword: 'newpassword1');
      expect((await repo.signInWithEmailAndPassword(email: 'a@b.c', password: 'newpassword1')).isSuccess, isTrue);
    });
    test('signOut emits null', () async {
      final repo = FakeAuthRepository(initialUser: const AppUser(uid: 'u'));
      addTearDown(repo.dispose);
      final f = repo.authStateChanges().first;
      await repo.signOut();
      expect(await f, isNull);
      expect(repo.currentUser, isNull);
    });
  });
}
