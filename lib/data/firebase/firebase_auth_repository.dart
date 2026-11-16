import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trackpoint/core/result.dart';
import 'package:trackpoint/data/firebase/auth_repository_base.dart';

/// Firebase Auth implementation
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseDatabase _db;

  FirebaseAuthRepository({FirebaseAuth? auth, FirebaseDatabase? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _db = db ?? FirebaseDatabase.instance;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  AppUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  @override
  Future<Result<AppUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        return Result.failure(const AuthException('Failed to get user details.'));
      }
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthException(e.message ?? 'Authentication failed.', code: e.code));
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }

  @override
  Future<Result<AppUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        return Result.failure(const AuthException('Failed to register user.'));
      }
      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthException(e.message ?? 'Registration failed.', code: e.code));
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthException(e.message ?? 'Password reset failed.', code: e.code));
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Result.failure(const AuthException('No user is currently signed in.'));
    }
    if (newPassword.length < 10) {
      return Result.failure(const AuthException('New password must be at least 10 characters.'));
    }

    try {
      // Re-authenticate user before changing sensitive credential
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthException(e.message ?? 'Failed to update password.', code: e.code));
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount(String currentPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Result.failure(const AuthException('No user is currently signed in.'));
    }

    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      // Release every owned tag and remove user data BEFORE deleting the login
      // (needs auth). Tags stay re-claimable instead of orphaned.
      final uid = user.uid;
      final snap = await _db.ref('users/$uid/devices').get();
      final updates = <String, Object?>{'users/$uid': null};
      if (snap.exists && snap.value is Map) {
        for (final id in (snap.value as Map).keys) {
          updates['devices/$id/meta/owner'] = null;
        }
      }
      await _db.ref().update(updates);
      await user.delete();
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(AuthException(e.message ?? 'Account deletion failed.', code: e.code));
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(AuthException(e.toString()));
    }
  }
}
