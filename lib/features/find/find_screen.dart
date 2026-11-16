import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/ble/fake_tag_ble_service.dart';
import 'package:trackpoint/data/models/device_summary.dart';
import 'package:trackpoint/domain/distance_zone.dart';
import 'package:trackpoint/features/auth/auth_state.dart';
import 'package:trackpoint/features/common/command_status_card.dart';
import 'package:trackpoint/features/find/buzzer_controller.dart';
import 'package:trackpoint/features/find/find_providers.dart';
import 'package:trackpoint/features/home/tag_providers.dart';

/// "Find my tag": live distance zone over BLE plus a buzzer that works over
/// BLE when connected and over the internet otherwise.
class FindScreen extends ConsumerStatefulWidget {
  const FindScreen({super.key});

  @override
  ConsumerState<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends ConsumerState<FindScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  String? _commandId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _setBuzzer(
    DeviceSummary tag, {
    required bool on,
    required bool connected,
  }) async {
    if (on) setState(() => _busy = true);
    final outcome = await ref.read(buzzerControllerProvider).set(
          deviceId: tag.deviceId,
          bleId: tag.bleId,
          on: on,
          bleConnected: connected,
        );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _commandId =
          outcome.route == BuzzerRoute.cloud ? outcome.commandId : null;
    });
    if (!outcome.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(outcome.error ?? AppStrings.findBuzzerFailed)),
      );
    }
  }

  Color _zoneColor(DistanceZoneType zone) {
    switch (zone) {
      case DistanceZoneType.rightHere:
      case DistanceZoneType.veryNear:
        return AppTheme.statusOk;
      case DistanceZoneType.near:
        return AppTheme.accentCyan;
      case DistanceZoneType.far:
        return AppTheme.statusWarn;
      case DistanceZoneType.edgeOfRange:
        return AppTheme.statusBad;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag = ref.watch(selectedTagProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.findTitle)),
      body: SafeArea(
        child: tag == null ? _buildNoTag(context) : _buildBody(context, tag),
      ),
    );
  }

  Widget _buildNoTag(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.radar, size: 56, color: AppTheme.darkMuted),
            const SizedBox(height: 16),
            const Text(
              AppStrings.findNoTag,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.darkMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/pair'),
              child: const Text(AppStrings.addYourFirstTag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DeviceSummary tag) {
    final hasBle = tag.bleId.isNotEmpty;
    final link = hasBle ? ref.watch(tagLinkProvider(tag.bleId)).valueOrNull : null;
    final connected = link?.isConnected ?? false;
    final zone = ref.watch(findZoneProvider).valueOrNull;
    final bleStatus =
        hasBle ? ref.watch(tagBleStatusProvider(tag.bleId)).valueOrNull : null;
    final buzzerOn = connected && (bleStatus?.buzzerOn ?? false);
    final ble = ref.watch(bleServiceProvider);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Text(
                tag.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            if (connected)
              _buildIndicator(zone)
            else
              _buildOutOfRange(context),
            if (buzzerOn) ...[
              const SizedBox(height: 12),
              const Center(
                child: Chip(
                  avatar: Icon(Icons.volume_up, size: 18),
                  label: Text(AppStrings.findBuzzerRinging),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              AppStrings.zoneDisclaimer,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.darkMuted, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BigButton(
                    label: AppStrings.buzzerOn,
                    icon: Icons.volume_up,
                    gradient: AppTheme.buzzerOnGradient,
                    onPressed: _busy
                        ? null
                        : () => _setBuzzer(tag, on: true, connected: connected),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BigButton(
                    label: AppStrings.buzzerOff,
                    icon: Icons.volume_off,
                    gradient: AppTheme.buzzerOffGradient,
                    // STOP is never disabled: it must always be reachable.
                    onPressed: () =>
                        _setBuzzer(tag, on: false, connected: connected),
                  ),
                ),
              ],
            ),
            if (_commandId != null) ...[
              const SizedBox(height: 16),
              CommandStatusCard(
                key: ValueKey(_commandId),
                deviceId: tag.deviceId,
                commandId: _commandId!,
              ),
            ],
            if (ble is FakeTagBleService) ...[
              const SizedBox(height: 24),
              _buildSimulationCard(ble, link?.rssi),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(DistanceZoneResult? zone) {
    final color = zone == null ? AppTheme.darkMuted : _zoneColor(zone.zone);
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_pulse.value);
            final outer = 150 + 70 * t;
            return SizedBox(
              width: 230,
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: outer,
                    height: outer,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.08 + 0.12 * (1 - t)),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.darkCard,
                      border: Border.all(color: color, width: 3),
                    ),
                    child: Icon(Icons.bluetooth_searching, size: 56, color: color),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          zone?.label ?? AppStrings.findMeasuring,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color),
        ),
        if (zone != null) ...[
          const SizedBox(height: 8),
          _buildTrend(zone.trend),
        ],
      ],
    );
  }

  Widget _buildTrend(SignalTrend trend) {
    final IconData icon;
    final String text;
    final Color color;
    switch (trend) {
      case SignalTrend.warmer:
        icon = Icons.arrow_upward;
        text = AppStrings.findTrendWarmer;
        color = AppTheme.statusOk;
      case SignalTrend.colder:
        icon = Icons.arrow_downward;
        text = AppStrings.findTrendColder;
        color = AppTheme.statusWarn;
      case SignalTrend.steady:
        icon = Icons.remove;
        text = AppStrings.findTrendSteady;
        color = AppTheme.darkMuted;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildOutOfRange(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkLine),
      ),
      child: Column(
        children: [
          const Icon(Icons.bluetooth_disabled, size: 44, color: AppTheme.darkMuted),
          const SizedBox(height: 12),
          const Text(
            AppStrings.findNotInRange,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.findNotInRangeHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.darkMuted, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => context.push('/map'),
            icon: const Icon(Icons.map_outlined),
            label: const Text(AppStrings.findShowOnMap),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationCard(FakeTagBleService fake, int? rssi) {
    final current = rssi ?? -75;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.accentPurple.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.findSimulation,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => fake.simulateRssi(current + 10),
                child: const Text('Closer'),
              ),
              OutlinedButton(
                onPressed: () => fake.simulateRssi(current - 10),
                child: const Text('Farther'),
              ),
              OutlinedButton(
                onPressed: fake.simulateDisconnect,
                child: const Text('Drop link'),
              ),
              OutlinedButton(
                onPressed: fake.simulateReconnect,
                child: const Text('Restore link'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPressed,
            child: Container(
              constraints: const BoxConstraints(minHeight: 76),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 26),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
