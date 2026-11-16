import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/notifications/push_notification_service.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isChangingPassword = false;
  String? _passwordError;
  String? _passwordSuccess;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() {
      _isChangingPassword = true;
      _passwordError = null;
      _passwordSuccess = null;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isChangingPassword = false;
    });

    result.fold(
      onSuccess: (_) {
        setState(() {
          _passwordSuccess = AppStrings.passwordChanged;
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        });
      },
      onFailure: (e) {
        setState(() {
          _passwordError = e.message;
        });
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    final passwordTextController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.deleteAccountConfirmation,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordTextController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: AppStrings.currentPassword,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusBad),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.deleteAccount(passwordTextController.text);
      if (!mounted) return;

      result.fold(
        onSuccess: (_) {
          ref.read(selectedDeviceOverrideProvider.notifier).state = null;
          context.go('/sign-in');
        },
        onFailure: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: AppTheme.statusBad),
          );
        },
      );
    }
  }

  Future<void> _handleSignOut() async {
    await ref.read(pushNotificationServiceProvider).onSignOut();
    ref.read(selectedDeviceOverrideProvider.notifier).state = null;
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    if (mounted) {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.account),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Signed in as',
                          style: TextStyle(color: AppTheme.darkMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Unknown User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'UID: ${user?.uid ?? "—"}',
                          style: const TextStyle(
                            color: AppTheme.darkMuted,
                            fontSize: 12,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Change Password Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.changePassword,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          if (_passwordSuccess != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.statusOk.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.statusOk.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _passwordSuccess!,
                                style: const TextStyle(color: Color(0xFFBBF7D0), fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (_passwordError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.statusBad.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.statusBad.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                _passwordError!,
                                style: const TextStyle(color: Color(0xFFFECACA), fontSize: 13),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextFormField(
                            controller: _currentPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: AppStrings.currentPassword,
                              prefixIcon: Icon(Icons.lock_outline, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return AppStrings.enterCurrentPassword;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _newPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: AppStrings.newPassword,
                              prefixIcon: Icon(Icons.lock_reset, size: 20),
                            ),
                            validator: (v) {
                              if (v == null || v.length < 10) {
                                return AppStrings.passwordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _confirmNewPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: AppStrings.confirmPassword,
                              prefixIcon: Icon(Icons.lock_reset, size: 20),
                            ),
                            validator: (v) {
                              if (v != _newPasswordController.text) {
                                return AppStrings.passwordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          OutlinedButton(
                            onPressed: _isChangingPassword ? null : _handleChangePassword,
                            child: _isChangingPassword
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text(AppStrings.changePassword),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Out & Delete Account Actions
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.signOut),
                  onPressed: _handleSignOut,
                ),
                const SizedBox(height: 12),

                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppTheme.statusBad),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text(AppStrings.deleteAccount),
                  onPressed: _handleDeleteAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
