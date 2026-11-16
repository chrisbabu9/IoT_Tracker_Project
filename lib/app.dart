import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/firebase/auth_repository.dart';
import 'package:trackpoint/features/auth/account_screen.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/auth/forgot_password_screen.dart';
import 'package:trackpoint/features/auth/sign_in_screen.dart';
import 'package:trackpoint/features/auth/sign_up_screen.dart';
import 'package:trackpoint/features/dashboard/dashboard_screen.dart';
import 'package:trackpoint/features/alerts/alert_bus.dart';
import 'package:trackpoint/features/alerts/alert_monitor.dart';
import 'package:trackpoint/features/alerts/alerts_screen.dart';
import 'package:trackpoint/features/connection/tag_connection_manager.dart';
import 'package:trackpoint/features/dashboard/last_seen_near_service.dart';
import 'package:trackpoint/features/find/find_screen.dart';
import 'package:trackpoint/features/geofence/geofence_providers.dart';
import 'package:trackpoint/features/geofence/geofence_screen.dart';
import 'package:trackpoint/features/history/history_screen.dart';
import 'package:trackpoint/features/home/home_screen.dart';
import 'package:trackpoint/features/lost/lost_mode_screen.dart';
import 'package:trackpoint/features/lost/sos_banner.dart';
import 'package:trackpoint/features/map/map_screen.dart';
import 'package:trackpoint/features/onboarding/onboarding_screen.dart';
import 'package:trackpoint/features/pair/pair_tag_screen.dart';
import 'package:trackpoint/features/help/help_screen.dart';
import 'package:trackpoint/features/notifications/push_notification_service.dart';
import 'package:trackpoint/features/settings/app_settings_screen.dart';
import 'package:trackpoint/features/settings/developer_screen.dart';
import 'package:trackpoint/features/settings/device_settings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
    _ref.listen<bool>(
      onboardingCompletedProvider,
      (_, __) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    if (authState.isLoading) return null;

    final user = authState.value;
    final currentLoc = state.matchedLocation;
    final isOnboarding = currentLoc == '/onboarding';
    final isAuthRoute = currentLoc == '/sign-in' ||
        currentLoc == '/sign-up' ||
        currentLoc == '/forgot-password';

    // If user hasn't seen onboarding and is on onboarding, allow it
    if (isOnboarding) return null;

    // Not logged in -> redirect to /sign-in
    if (user == null) {
      return isAuthRoute ? null : '/sign-in';
    }

    // Logged in and on auth route -> redirect to /home
    if (isAuthRoute) {
      return '/home';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation:
        ref.read(onboardingCompletedProvider) ? '/home' : '/onboarding',
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/pair',
        builder: (context, state) => const PairTagScreen(),
      ),
      GoRoute(
        path: '/geofence',
        builder: (context, state) => const GeofenceScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/lost',
        builder: (context, state) => const LostModeScreen(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),
      GoRoute(
        path: '/find',
        builder: (context, state) => const FindScreen(),
      ),
      GoRoute(
        path: '/alerts',
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: '/device-settings',
        builder: (context, state) => const DeviceSettingsScreen(),
      ),
      GoRoute(
        path: '/developer',
        builder: (context, state) => const DeveloperScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpScreen(),
      ),
    ],
  );
});

class TrackPointApp extends ConsumerWidget {
  const TrackPointApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // FCM registration: once per signed-in user (service is idempotent by uid).
    final signedIn = ref.watch(currentUserProvider) != null;
    if (signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(pushNotificationServiceProvider)
            .initialize(onNavigate: (route) => router.push(route));
      });
    }

    // Keep the last-seen-near recorder alive on every screen while signed in.
    if (ref.watch(currentUserProvider) != null) {
      ref.watch(lastSeenNearServiceProvider);
      ref.watch(tagConnectionManagerProvider);
      ref.watch(geofenceMonitorProvider);
      ref.watch(alertMonitorProvider);
    }

    return MaterialApp.router(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // dark-only: widgets use the dark palette (B-20)
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      builder: (context, child) => SosBannerHost(
        onOpenMap: (deviceId) {
          ref.read(selectedDeviceOverrideProvider.notifier).state = deviceId;
          router.push('/map');
        },
        child: AlertToastHost(
          messengerKey: rootScaffoldMessengerKey,
          onOpen: (event) {
            if (event.deviceId.isNotEmpty) {
              ref.read(selectedDeviceOverrideProvider.notifier).state =
                  event.deviceId;
            }
            router.push(alertRoute(event));
          },
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
