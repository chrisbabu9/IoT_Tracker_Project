import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trackpoint/core/strings.dart';
import 'package:trackpoint/domain/alert_rules.dart';

/// Key of the app's root ScaffoldMessenger (set in MaterialApp.router).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// In-process channel for alert events raised while the app is open.
class AlertBus {
  final StreamController<AlertEvent> _controller =
      StreamController<AlertEvent>.broadcast();

  final StreamController<AlertEvent> _accepted =
      StreamController<AlertEvent>.broadcast();

  /// Raw events from producers (monitor, geofence, push).
  Stream<AlertEvent> get stream => _controller.stream;

  /// Events the store accepted (category enabled, not duplicate): toast + notify.
  Stream<AlertEvent> get accepted => _accepted.stream;

  void emit(AlertEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void accept(AlertEvent event) {
    if (!_accepted.isClosed) _accepted.add(event);
  }

  void dispose() {
    _controller.close();
    _accepted.close();
  }
}

final alertBusProvider = Provider<AlertBus>((ref) {
  final bus = AlertBus();
  ref.onDispose(bus.dispose);
  return bus;
});

/// Screen that should open when an alert is tapped.
String alertRoute(AlertEvent event) {
  switch (event.type) {
    case AlertType.geofenceLeft:
    case AlertType.geofenceReEntered:
      return '/geofence';
    case AlertType.sosAlert:
    case AlertType.lostModeUpdate:
    case AlertType.movementDetected:
      return '/map';
    default:
      return '/dashboard';
  }
}

/// Shows a snackbar for every alert event while the app is in the foreground.
/// Place it inside `MaterialApp.router(builder: ...)`.
class AlertToastHost extends ConsumerStatefulWidget {
  const AlertToastHost({
    super.key,
    required this.child,
    required this.messengerKey,
    required this.onOpen,
  });

  final Widget child;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final void Function(AlertEvent event) onOpen;

  @override
  ConsumerState<AlertToastHost> createState() => _AlertToastHostState();
}

class _AlertToastHostState extends ConsumerState<AlertToastHost> {
  StreamSubscription<AlertEvent>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(alertBusProvider).accepted.listen(_show);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _show(AlertEvent event) {
    final messenger = widget.messengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(event.message),
          ],
        ),
        action: SnackBarAction(
          label: AppStrings.alertOpen,
          onPressed: () => widget.onOpen(event),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
