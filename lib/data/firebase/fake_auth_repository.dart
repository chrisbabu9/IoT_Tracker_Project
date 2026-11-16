import 'dart:async';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/firebase/auth_repository_base.dart';

/// In-memory fake authentication repository for unit and widget tests
class FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();
  AppUser? _user;
  String _password = 'password123';

  FakeAuthRepository({AppUser? initialUser}) : _user = initialUser;

  @override
  Stream<AppUser?> authStateChanges() {
    return _controller.stream;
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Future<Result<AppUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (password != _password) {
      return Result.failure(const AuthException('Invalid password.', code: 'wrong-password'));
    }
    _user = AppUser(uid: 'mock_uid_${email.hashCode}', email: email);
    _controller.add(_user);
    return Result.success(_user!);
  }

  @override
  Future<Result<AppUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _password = password;
    _user = AppUser(uid: 'mock_uid_${email.hashCode}', email: email);
    _controller.add(_user);
    return Result.success(_user!);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return Result.success(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword != _password) {
      return Result.failure(const AuthException('Current password does not match.', code: 'wrong-password'));
    }
    _password = newPassword;
    return Result.success(null);
  }

  @override
  Future<Result<void>> deleteAccount(String currentPassword) async {
    _user = null;
    _controller.add(null);
    return Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    _user = null;
    _controller.add(null);
    return Result.success(null);
  }

  void dispose() {
    _controller.close();
  }
}
