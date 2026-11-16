import 'package:flutter_test/flutter_test.dart';
import 'package:trackpoint/core/result.dart';

void main() {
  group('Result (T-C7)', () {
    test('success', () {
      final r = Result<int>.success(5);
      expect(r.isSuccess, isTrue);
      expect(r.isFailure, isFalse);
      expect(r.dataOrNull, 5);
      expect(r.exceptionOrNull, isNull);
      expect(r.fold(onSuccess: (d) => d * 2, onFailure: (_) => -1), 10);
    });
    test('failure', () {
      final r = Result<int>.failure(const DeviceException('boom', code: 'x'));
      expect(r.isFailure, isTrue);
      expect(r.dataOrNull, isNull);
      expect(r.exceptionOrNull, isA<DeviceException>());
      expect(r.fold(onSuccess: (_) => 'ok', onFailure: (e) => e.message), 'boom');
    });
    test('AppException.toString includes code', () {
      expect(const AppException('m', code: 'c').toString(), contains('(c)'));
      expect(const AppException('m').toString(), isNot(contains('(')));
    });
    test('subclasses carry message/code', () {
      expect(const AuthException('a', code: 'b').code, 'b');
      expect(const CommandException('c').message, 'c');
      expect(const NetworkException('n'), isA<AppException>());
    });
  });
}
