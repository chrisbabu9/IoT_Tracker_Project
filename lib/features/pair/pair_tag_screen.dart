import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/core/theme.dart';
import 'package:trackpoint/data/ble/tag_ble_service.dart';
import 'package:trackpoint/features/auth/auth_state.dart';

enum PairStep {
  permissions,
  instructionAndScan,
  bondingAndClaiming,
  naming,
  success,
  error,
}

/// Complete step-by-step pairing flow for TrackPoint smart tags.
/// Handles permission gating, 60s pairing countdown, BLE discovery,
/// LE Secure Connection bonding, DEVICE_INFO extraction, Firebase ownership claiming,
/// custom naming, and full error recovery.
class PairTagScreen extends ConsumerStatefulWidget {
  const PairTagScreen({super.key});

  @override
  ConsumerState<PairTagScreen> createState() => _PairTagScreenState();
}

class _PairTagScreenState extends ConsumerState<PairTagScreen>
    with SingleTickerProviderStateMixin {
  PairStep _currentStep = PairStep.permissions;

  // Countdown timer for 60-second discovery window
  Timer? _countdownTimer;
  int _secondsRemaining = 60;

  // Scan state
  StreamSubscription<List<ScannedTag>>? _scanSub;
  List<ScannedTag> _discoveredTags = [];
  ScannedTag? _selectedTag;
  PairedTag? _pairedTag;

  // Progress and error messages
  String _statusMessage = '';
  String? _errorMessage;
  bool _canRetry = true;
  final List<String> _diagnosticLogs = [];

  void _log(String message) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final entry = '[$timeStr] $message';
    debugPrint('[DIAGNOSTIC] $entry');
    if (mounted) {
      setState(() {
        _diagnosticLogs.add(entry);
      });
    } else {
      _diagnosticLogs.add(entry);
    }
  }

  // Naming controller
  final TextEditingController _nameController = TextEditingController();

  // Animation controller for pulsing search radar
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // after first frame: _log() calls setState and must not run inside initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _checkPermissions();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scanSub?.cancel();
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // 1. Permission Check
  Future<void> _checkPermissions() async {
    final isSimulation = ref.read(simulationModeProvider);
    _log('Permissions check. Simulation mode: $isSimulation');
    if (isSimulation) {
      _startPairingWindow();
      return;
    }

    final bluetoothScan = await Permission.bluetoothScan.status;
    final bluetoothConnect = await Permission.bluetoothConnect.status;
    final location = await Permission.locationWhenInUse.status;
    _log('Permissions: BT_Scan=$bluetoothScan, BT_Connect=$bluetoothConnect, Location=$location');

    if (bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        (location.isGranted || location.isLimited)) {
      _startPairingWindow();
    } else {
      _log('Permissions missing; requesting user grant...');
      setState(() {
        _currentStep = PairStep.permissions;
      });
    }
  }

  Future<void> _requestPermissions() async {
    _log('Requesting runtime permissions...');
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();

    final allGranted =
        (statuses[Permission.bluetoothScan]?.isGranted ?? false) &&
            (statuses[Permission.bluetoothConnect]?.isGranted ?? false);
    _log('Permissions result: allGranted=$allGranted');

    if (allGranted) {
      _startPairingWindow();
    } else {
      setState(() {
        _errorMessage = AppStrings.pairPermissionError;
      });
    }
  }

  // 2. Start 60-Second Countdown & Scan
  void _startPairingWindow() {
    _countdownTimer?.cancel();
    _scanSub?.cancel();
    _log('Starting 60s BLE scan window...');

    setState(() {
      _currentStep = PairStep.instructionAndScan;
      _secondsRemaining = 60;
      _discoveredTags = [];
      _selectedTag = null;
      _errorMessage = null;
      _statusMessage = AppStrings.pairScanning;
    });

    final bleService = ref.read(bleServiceProvider);
    _scanSub = bleService.scanForPairableTags().listen(
      (tags) {
        if (!mounted) return;
        _log('Scan update: found ${tags.length} candidate(s)');
        setState(() {
          _discoveredTags = tags;
        });
      },
      onError: (err) {
        _log('Scan error: $err');
        if (!mounted) return;
        _showError(err.toString(), canRetry: true);
      },
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        _scanSub?.cancel();
        _bleServiceStopScan();
        _log('Scan window expired. Discovered: ${_discoveredTags.length}');
        if (_discoveredTags.isEmpty) {
          _showError(AppStrings.pairScanTimeout, canRetry: true);
        }
      }
    });
  }

  void _bleServiceStopScan() {
    ref.read(bleServiceProvider).stopScan();
  }

  // 3. Connect, Bond, Read DEVICE_INFO & Claim
  Future<void> _pairTag(ScannedTag tag) async {
    _countdownTimer?.cancel();
    _scanSub?.cancel();
    _bleServiceStopScan();

    _log('Selected tag: "${tag.name}" (${tag.bleId})');

    setState(() {
      _selectedTag = tag;
      _currentStep = PairStep.bondingAndClaiming;
      _statusMessage = AppStrings.pairConnecting;
      _errorMessage = null;
    });

    final bleService = ref.read(bleServiceProvider);
    final deviceRepo = ref.read(deviceRepositoryProvider);
    final user = ref.read(currentUserProvider);

    if (user == null) {
      _log('FAILED: No user signed in');
      _showError('You must be signed in to pair a tag.', canRetry: false);
      return;
    }
    _log('Authenticated user: ${user.email} (UID: ${user.uid})');

    try {
      setState(() {
        _statusMessage = AppStrings.pairBonding;
      });

      _log('Starting BLE connect & read...');
      final paired = await bleService
          .pairAndBond(tag)
          .timeout(const Duration(seconds: 30));
      if (!mounted) return;

      _log('BLE paired: deviceId=${paired.deviceId}, name=${paired.name}, fw=${paired.fw}');
      _pairedTag = paired;

      setState(() {
        _statusMessage = AppStrings.pairClaiming;
      });

      _log('Writing ownership claim to Firebase RTDB for deviceId=${paired.deviceId}...');
      final claimResult = await deviceRepo
          .claimDevice(
            uid: user.uid,
            deviceId: paired.deviceId,
            name: paired.name,
            bleId: paired.bleId,
            fw: paired.fw,
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;

      _log('Firebase claim result: isSuccess=${claimResult.isSuccess}');

      if (claimResult.isFailure) {
        final err = claimResult.exceptionOrNull!;
        _log('Firebase claim failed: code=${err.code}, message=${err.message}');
        // don't leave a half-paired BLE link open when the claim failed
        unawaited(bleService.disconnect(paired.bleId));
        final alreadyOwned = err.code == 'already-owned';
        _showError(
          alreadyOwned ? AppStrings.pairAlreadyOwned : err.message,
          canRetry: !alreadyOwned,
        );
        return;
      }

      _log('Claim succeeded! Moving to naming step.');
      _nameController.text = paired.name;
      setState(() {
        _currentStep = PairStep.naming;
      });
    } on TimeoutException catch (te) {
      _log('TimeoutException: $te');
      if (mounted) {
        _showError(AppStrings.pairNoInternet, canRetry: true);
      }
    } catch (e, st) {
      _log('Pairing Exception: $e');
      debugPrint('[PAIR] $st');
      if (!mounted) return;
      _showError(
        e.toString().contains('bond') || e.toString().contains('rejected')
            ? AppStrings.pairBondRejected
            : 'Pairing failed: $e',
        canRetry: true,
      );
    }
  }

  // 4. Save Final Name & Finish
  Future<void> _saveNameAndFinish() async {
    final customName = _nameController.text.trim();
    final paired = _pairedTag;
    final user = ref.read(currentUserProvider);

    if (paired != null && user != null && customName.isNotEmpty) {
      final deviceRepo = ref.read(deviceRepositoryProvider);
      await deviceRepo.renameDevice(
        uid: user.uid,
        deviceId: paired.deviceId,
        newName: customName,
      );
    }

    if (!mounted) return;
    setState(() {
      _currentStep = PairStep.success;
    });
  }

  void _showError(String message, {required bool canRetry}) {
    setState(() {
      _currentStep = PairStep.error;
      _errorMessage = message;
      _canRetry = canRetry;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.pairTagTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _bleServiceStopScan();
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: switch (_currentStep) {
                PairStep.permissions => _buildPermissionsView(),
                PairStep.instructionAndScan => _buildInstructionAndScanView(),
                PairStep.bondingAndClaiming => _buildBondingAndClaimingView(),
                PairStep.naming => _buildNamingView(),
                PairStep.success => _buildSuccessView(),
                PairStep.error => _buildErrorView(),
              },
            ),
          ),
        ),
      ),
    );
  }

  // Permissions View
  Widget _buildPermissionsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.bluetooth_audio,
              size: 40, color: AppTheme.accentCyan),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bluetooth & Location Permissions',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          AppStrings.pairPermissionError,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.darkMuted, fontSize: 14),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.statusBad, fontSize: 13),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _requestPermissions,
          icon: const Icon(Icons.check),
          label: const Text('Grant Permissions'),
        ),
      ],
    );
  }

  // 60-Second Instruction & Scan View
  Widget _buildInstructionAndScanView() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Pulsing Button Instruction Icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.accentCyan.withValues(alpha: 0.35),
                  AppTheme.accentBlue.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(color: AppTheme.accentCyan, width: 2),
            ),
            child: const Center(
              child:
                  Icon(Icons.touch_app, size: 48, color: AppTheme.accentCyan),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.pairStep1Title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppStrings.pairStep1Instruction,
            textAlign: TextAlign.center,
            style:
                TextStyle(color: AppTheme.darkMuted, fontSize: 13, height: 1.4),
          ),
        ),
        const SizedBox(height: 16),

        // Countdown Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _secondsRemaining > 15
                ? AppTheme.accentBlue.withValues(alpha: 0.15)
                : AppTheme.statusBad.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _secondsRemaining > 15
                  ? AppTheme.accentCyan.withValues(alpha: 0.4)
                  : AppTheme.statusBad.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: _secondsRemaining > 15
                    ? AppTheme.accentCyan
                    : AppTheme.statusBad,
              ),
              const SizedBox(width: 8),
              Text(
                '${AppStrings.pairCountdownPrefix}$_secondsRemaining${AppStrings.pairCountdownSeconds}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _secondsRemaining > 15
                      ? AppTheme.accentCyan
                      : AppTheme.statusBad,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scanning Indicator / Discovered Tags List
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            AppStrings.pairAvailableTags,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkMuted,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: _discoveredTags.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.darkLine),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.darkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _discoveredTags.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final tag = _discoveredTags[idx];
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _pairTag(tag),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.accentCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.accentBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bluetooth,
                                  color: AppTheme.accentCyan, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tag.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Signal: ${tag.rssi} dBm',
                                    style: const TextStyle(
                                      color: AppTheme.darkMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _pairTag(tag),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              child: const Text('Pair'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        _buildDiagnosticLogViewer(),
      ],
    );
  }

  // Bonding & Claiming View
  Widget _buildBondingAndClaimingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 3.5,
            color: AppTheme.accentCyan,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          _selectedTag?.name ?? 'TrackPoint Tag',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _statusMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.accentCyan,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Keep your phone and tag close together while pairing completes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.darkMuted, fontSize: 13),
        ),
      ],
    );
  }

  // Naming View
  Widget _buildNamingView() {
    final quickNames = ['Keys', 'Wallet', 'Backpack', 'Luggage', 'Watch'];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.statusOk.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppTheme.statusOk, size: 48),
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Tag Paired & Claimed!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Hardware ID: ${_pairedTag?.deviceId ?? ""}',
              style: const TextStyle(color: AppTheme.darkMuted, fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            AppStrings.pairNameYourTag,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: AppStrings.pairNamePlaceholder,
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: quickNames.map((name) {
              return ActionChip(
                label: Text(name),
                backgroundColor: AppTheme.darkCard,
                side: const BorderSide(color: AppTheme.darkLine),
                onPressed: () {
                  setState(() {
                    _nameController.text = name;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveNameAndFinish,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(AppStrings.pairFinish),
            ),
          ),
        ],
      ),
    );
  }

  // Success View
  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppTheme.statusOk.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.statusOk, width: 2),
          ),
          child: const Icon(Icons.done_all, color: AppTheme.statusOk, size: 50),
        ),
        const SizedBox(height: 24),
        const Text(
          AppStrings.tagClaimedSuccess,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          '${_nameController.text.trim()} is ready to be tracked on your dashboard and live map.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppTheme.darkMuted, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: const Text('Go to Dashboard'),
          ),
        ),
      ],
    );
  }

  // Error View
  Widget _buildErrorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.statusBad.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border:
                Border.all(color: AppTheme.statusBad.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.error_outline,
              color: AppTheme.statusBad, size: 44),
        ),
        const SizedBox(height: 24),
        const Text(
          'Pairing Unsuccessful',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            _errorMessage ?? 'An unexpected error occurred during pairing.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.darkMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              child: const Text(AppStrings.cancel),
            ),
            if (_canRetry) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _startPairingWindow,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _buildDiagnosticLogViewer(),
      ],
    );
  }

  Widget _buildDiagnosticLogViewer() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppTheme.darkLine),
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          dense: true,
        leading: const Icon(Icons.bug_report, size: 18, color: AppTheme.accentCyan),
        title: Text(
          'Diagnostic Logs (${_diagnosticLogs.length})',
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.accentCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 16, color: AppTheme.darkMuted),
              tooltip: 'Copy Logs',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _diagnosticLogs.join('\n')));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diagnostic logs copied to clipboard')),
                );
              },
            ),
            const Icon(Icons.expand_more, size: 18, color: AppTheme.darkMuted),
          ],
        ),
        children: [
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.black87,
            child: ListView.builder(
              reverse: true,
              itemCount: _diagnosticLogs.length,
              itemBuilder: (context, idx) {
                final logLine = _diagnosticLogs[_diagnosticLogs.length - 1 - idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    logLine,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Colors.greenAccent,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}
