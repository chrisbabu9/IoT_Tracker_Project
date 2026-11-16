import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/domain/alert_rules.dart';
import 'package:trackpoint/features/alerts/alert_bus.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

/// Service responsible for FCM Push Notification registration and routing.
class PushNotificationService {
  final Ref _ref;
  final FirebaseDatabase _db;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  String? _initUid; // uid we registered for; prevents duplicate listeners

  PushNotificationService(this._ref, {FirebaseDatabase? db})
      : _db = db ?? FirebaseDatabase.instance;

  Future<void> initialize({void Function(String route)? onNavigate}) async {
    // Only attempt on platforms where Firebase Messaging is supported
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    final uid = _ref.read(currentUserProvider)?.uid;
    if (uid == null || uid == _initUid) return;
    _initUid = uid;
    dispose(); // drop listeners of a previous registration

    try {
      if (Firebase.apps.isEmpty) return;

      final messaging = FirebaseMessaging.instance;

      // 1. Request notification permissions
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2. Register current token
      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // 3. Listen for token refreshes
      _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) {
        _saveToken(newToken);
      });

      // 4. Handle foreground notifications -> emit to AlertBus
      _messageSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // 5. Handle background tap
      _messageOpenedSub =
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final route = _extractRoute(message);
        if (route != null && onNavigate != null) {
          onNavigate(route);
        }
      });

      // 6. Handle cold-start from terminated state
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        final route = _extractRoute(initialMessage);
        if (route != null && onNavigate != null) {
          onNavigate(route);
        }
      }
    } catch (e) {
      debugPrint('[PushNotificationService] Failed to initialize FCM: $e');
    }
  }

  static String _key(String token) => token.replaceAll(RegExp(r'[.#$\[\]]'), '_');

  /// Call BEFORE signing out: removes this device's token so pushes for the
  /// old account stop, and allows re-registration for the next user.
  Future<void> onSignOut() async {
    final uid = _ref.read(currentUserProvider)?.uid;
    _initUid = null;
    dispose();
    try {
      final messaging = FirebaseMessaging.instance;
      final token = await messaging.getToken();
      if (uid != null && token != null) {
        await _db.ref('users/$uid/fcmTokens/${_key(token)}').remove();
      }
      await messaging.deleteToken();
    } catch (e) {
      debugPrint('[PushNotificationService] sign-out cleanup failed: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;
    try {
      // Register token at /users/{uid}/fcmTokens/{token}: true
      final sanitizedToken = _key(token);
      await _db.ref('users/${user.uid}/fcmTokens/$sanitizedToken').set(true);
    } catch (e) {
      debugPrint('[PushNotificationService] Error saving FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    if (notification != null) {
      final bus = _ref.read(alertBusProvider);
      final typeStr = data['type']?.toString();
      final deviceId = data['deviceId']?.toString() ?? '';

      final alertType = AlertType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => AlertType.tagOffline,
      );

      bus.emit(
        AlertEvent(
          type: alertType,
          title: notification.title ?? 'TrackPoint Alert',
          message: notification.body ?? '',
          timestampMs: DateTime.now().millisecondsSinceEpoch,
          deviceId: deviceId,
        ),
      );
    }
  }

  String? _extractRoute(RemoteMessage message) {
    final data = message.data;
    if (data.containsKey('route')) {
      return data['route'] as String;
    }
    final type = data['type']?.toString();
    if (type == 'geofenceLeft' || type == 'geofenceReEntered') {
      return '/geofence';
    }
    if (type == 'sosAlert' || type == 'lostModeUpdate') {
      return '/map';
    }
    return '/alerts';
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _messageSub?.cancel();
    _messageOpenedSub?.cancel();
  }
}

final pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) {
  final service = PushNotificationService(ref);
  ref.onDispose(service.dispose);
  return service;
});
