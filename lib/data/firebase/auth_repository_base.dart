import 'dart:async';
import 'package:trackpoint/core/result.dart';

/// User entity abstraction
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? get currentUser;

  Future<Result<AppUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> deleteAccount(String currentPassword);

  Future<Result<void>> signOut();
}
