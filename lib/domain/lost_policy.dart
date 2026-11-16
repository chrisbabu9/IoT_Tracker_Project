/// Lost Mode battery-based reporting intervals and policy logic.
class LostPolicyRow {
  final String batteryRange;
  final int minBat;
  final int maxBat;
  final String intervalText;
  final int intervalSeconds;
  final String description;

  const LostPolicyRow({
    required this.batteryRange,
    required this.minBat,
    required this.maxBat,
    required this.intervalText,
    required this.intervalSeconds,
    required this.description,
  });
}

class LostPolicy {
  LostPolicy._();

  static const List<LostPolicyRow> rows = [
    LostPolicyRow(
      batteryRange: '> 60%',
      minBat: 61,
      maxBat: 100,
      intervalText: 'Every 1 min',
      intervalSeconds: 60,
      description: 'High frequency reporting',
    ),
    LostPolicyRow(
      batteryRange: '30% – 60%',
      minBat: 30,
      maxBat: 60,
      intervalText: 'Every 2 min',
      intervalSeconds: 120,
      description: 'Standard lost tracking',
    ),
    LostPolicyRow(
      batteryRange: '15% – 29%',
      minBat: 15,
      maxBat: 29,
      intervalText: 'Every 3 min',
      intervalSeconds: 180,
      description: 'Power conservation mode',
    ),
    LostPolicyRow(
      batteryRange: '5% – 14%',
      minBat: 5,
      maxBat: 14,
      intervalText: 'Every 5 min',
      intervalSeconds: 300,
      description: 'Critical battery saver',
    ),
    LostPolicyRow(
      batteryRange: '< 5%',
      minBat: 0,
      maxBat: 4,
      intervalText: 'Final report',
      intervalSeconds: 0,
      description: 'One final fix then sleeps',
    ),
  ];

  /// Returns reporting interval in seconds for a given battery percentage (0..100).
  ///
  /// Boundaries:
  /// - bat > 60 (e.g. 61+): 60s
  /// - 30 <= bat <= 60 (e.g. 60, 30): 120s
  /// - 15 <= bat <= 29 (e.g. 29, 15): 180s
  /// - 5 <= bat <= 14 (e.g. 14, 5): 300s
  /// - bat < 5 (e.g. 4): 0s (final report)
  static int getReportingIntervalSeconds(int batteryPct) {
    if (batteryPct > 60) return 60;
    if (batteryPct >= 30) return 120;
    if (batteryPct >= 15) return 180;
    if (batteryPct >= 5) return 300;
    return 0; // final report then sleep
  }

  /// Returns the index (0..4) of the matching row for a given battery level.
  static int getMatchingRowIndex(int batteryPct) {
    if (batteryPct > 60) return 0;
    if (batteryPct >= 30) return 1;
    if (batteryPct >= 15) return 2;
    if (batteryPct >= 5) return 3;
    return 4;
  }
}
