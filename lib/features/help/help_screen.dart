import 'package:flutter/material.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.helpTitle),
        backgroundColor: AppTheme.darkBackground,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hardware button guide accordion
          Card(
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.touch_app, color: AppTheme.accentCyan),
              title: const Text(
                AppStrings.helpButtonGuideTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      _buttonGuideItem(
                        AppStrings.buttonGuide1ClickTitle,
                        AppStrings.buttonGuide1ClickDesc,
                      ),
                      const SizedBox(height: 10),
                      _buttonGuideItem(
                        AppStrings.buttonGuide2ClicksTitle,
                        AppStrings.buttonGuide2ClicksDesc,
                      ),
                      const SizedBox(height: 10),
                      _buttonGuideItem(
                        AppStrings.buttonGuideHoldTitle,
                        AppStrings.buttonGuideHoldDesc,
                      ),
                      const SizedBox(height: 10),
                      _buttonGuideItem(
                        AppStrings.buttonGuideGuardTitle,
                        AppStrings.buttonGuideGuardDesc,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Tag shows offline
          _helpAccordionCard(
            icon: Icons.cloud_off,
            color: AppTheme.statusWarn,
            title: AppStrings.helpTagOfflineTitle,
            body: AppStrings.helpTagOfflineBody,
          ),
          const SizedBox(height: 10),

          // GPS Fix: No
          _helpAccordionCard(
            icon: Icons.gps_off,
            color: AppTheme.accentPurple,
            title: AppStrings.helpGpsNoFixTitle,
            body: AppStrings.helpGpsNoFixBody,
          ),
          const SizedBox(height: 10),

          // Buzzer command stays pending
          _helpAccordionCard(
            icon: Icons.hourglass_top,
            color: AppTheme.accentBlue,
            title: AppStrings.helpBuzzerPendingTitle,
            body: AppStrings.helpBuzzerPendingBody,
          ),
          const SizedBox(height: 10),

          // Map not loading
          _helpAccordionCard(
            icon: Icons.map_outlined,
            color: AppTheme.statusOk,
            title: AppStrings.helpMapNotLoadingTitle,
            body: AppStrings.helpMapNotLoadingBody,
          ),
          const SizedBox(height: 10),

          // Background alerts
          _helpAccordionCard(
            icon: Icons.battery_saver,
            color: AppTheme.statusBad,
            title: AppStrings.helpBackgroundAlertsTitle,
            body: AppStrings.helpBackgroundAlertsBody,
          ),
          const SizedBox(height: 10),

          // Privacy note
          _helpAccordionCard(
            icon: Icons.shield_outlined,
            color: AppTheme.accentCyan,
            title: AppStrings.helpPrivacyTitle,
            body: AppStrings.helpPrivacyBody,
          ),
        ],
      ),
    );
  }

  static Widget _helpAccordionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: AppTheme.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buttonGuideItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.accentCyan,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.darkMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
