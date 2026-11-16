/// Cloud command model written to `/devices/{deviceId}/commands/{pushId}`.
class TagCommand {
  final String id;
  final String type; // BUZZER_ON, BUZZER_OFF, LOST_ON, LOST_OFF, REPORT_NOW
  final String status; // pending, sent, completed, failed, expired, cancelled
  final int createdAt; // epoch ms
  final int expiresAt; // createdAt + 120000 (2 min)
  final int? ackedAt; // epoch ms
  final String? error;

  const TagCommand({
    required this.id,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.ackedAt,
    this.error,
  });

  bool get isPending => status == 'pending';
  bool get isSent => status == 'sent';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  /// Returns true if command is still active and awaiting tag execution.
  bool get isActive => status == 'pending' || status == 'sent';

  factory TagCommand.fromJson(Map<dynamic, dynamic> json, {required String id}) {
    return TagCommand(
      id: id,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      expiresAt: (json['expiresAt'] as num?)?.toInt() ?? 0,
      ackedAt: (json['ackedAt'] as num?)?.toInt(),
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'status': status,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      if (ackedAt != null) 'ackedAt': ackedAt,
      if (error != null) 'error': error,
    };
  }

  TagCommand copyWith({
    String? id,
    String? type,
    String? status,
    int? createdAt,
    int? expiresAt,
    int? ackedAt,
    String? error,
  }) {
    return TagCommand(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      ackedAt: ackedAt ?? this.ackedAt,
      error: error ?? this.error,
    );
  }
}
