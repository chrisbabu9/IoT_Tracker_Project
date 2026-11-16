import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

const String kPrefOnboardingCompleted = 'trackpoint_onboarding_completed';

final onboardingCompletedProvider = StateProvider<bool>((ref) => false);

/// 3-step Onboarding screen explaining TrackPoint capabilities,
/// required permissions, and the physical tag button guide.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kPrefOnboardingCompleted, true);
    ref.read(onboardingCompletedProvider.notifier).state = true;
    if (!mounted) return;

    final user = ref.read(currentUserProvider);
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/sign-in');
    }
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.brandGradient.createShader(bounds),
                        child: const Icon(Icons.location_on,
                            size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        AppStrings.appTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: const Text(
                        AppStrings.onboardingSkip,
                        style: TextStyle(color: AppTheme.darkMuted),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (idx) {
                  setState(() {
                    _currentPage = idx;
                  });
                },
                children: [
                  _buildPage1Overview(),
                  _buildPage2Permissions(),
                  _buildPage3ButtonGuide(),
                ],
              ),
            ),

            // Bottom Navigation & Indicators
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Row(
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.accentCyan
                              : AppTheme.darkLine,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      _currentPage == 2
                          ? AppStrings.onboardingGetStarted
                          : AppStrings.onboardingNext,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1Overview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentBlue.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.radar_outlined,
                size: 64,
                color: AppTheme.accentCyan,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            AppStrings.onboardingTitle1,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.onboardingDesc1,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.darkMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildFeaturePill(
            icon: Icons.bluetooth,
            title: 'Nearby BLE Tracking',
            subtitle: 'Distance zones & instant buzzer locator when nearby.',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: Icons.satellite_alt_outlined,
            title: 'GPS + 4G LTE Cellular',
            subtitle: 'Wakes up and uploads live fixes when out of Bluetooth range.',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: Icons.vibration,
            title: 'Motion & Accelerometer',
            subtitle: 'Instant movement alerts powered by onboard MPU6050 sensor.',
          ),
        ],
      ),
    );
  }

  Widget _buildPage2Permissions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentPurple.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.security_outlined,
                size: 64,
                color: AppTheme.accentPurple,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            AppStrings.onboardingTitle2,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.onboardingDesc2,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.darkMuted, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildFeaturePill(
            icon: Icons.bluetooth_searching,
            title: 'Bluetooth Scan & Connect',
            subtitle: 'Discover, bond, ring buzzer, and read real-time tag telemetry.',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: Icons.my_location,
            title: 'Phone Location',
            subtitle: 'Estimates phone-to-tag distance and records last-seen location.',
          ),
          const SizedBox(height: 12),
          _buildFeaturePill(
            icon: Icons.notifications_active_outlined,
            title: 'Push & Local Alerts',
            subtitle: 'Left-behind alerts, movement detection, geofence, and SOS triggers.',
          ),
        ],
      ),
    );
  }

  Widget _buildPage3ButtonGuide() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.statusWarn.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.touch_app_outlined,
                size: 48,
                color: AppTheme.statusWarn,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            AppStrings.onboardingTitle3,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.onboardingDesc3,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.darkMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildButtonActionRow(
            badge: '1 Click',
            color: AppTheme.accentCyan,
            title: AppStrings.buttonGuide1ClickTitle,
            desc: AppStrings.buttonGuide1ClickDesc,
          ),
          const SizedBox(height: 10),
          _buildButtonActionRow(
            badge: '2 Clicks',
            color: AppTheme.accentPurple,
            title: AppStrings.buttonGuide2ClicksTitle,
            desc: AppStrings.buttonGuide2ClicksDesc,
          ),
          const SizedBox(height: 10),
          _buildButtonActionRow(
            badge: 'Hold 2s',
            color: AppTheme.statusBad,
            title: AppStrings.buttonGuideHoldTitle,
            desc: AppStrings.buttonGuideHoldDesc,
          ),
          const SizedBox(height: 10),
          _buildButtonActionRow(
            badge: 'Guard',
            color: AppTheme.darkMuted,
            title: AppStrings.buttonGuideGuardTitle,
            desc: AppStrings.buttonGuideGuardDesc,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.darkLine),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.accentCyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.darkMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonActionRow({
    required String badge,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.darkLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(color: AppTheme.darkMuted, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
