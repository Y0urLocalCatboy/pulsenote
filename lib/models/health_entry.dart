import 'package:cloud_firestore/cloud_firestore.dart';

class HealthEntry {
  final String? id;
  final int pulse;
  final int systolic;
  final int diastolic;
  final DateTime timestamp;
  final String deviceId;

  HealthEntry({
    this.id,
    required this.pulse,
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
    required this.deviceId,
  });

  factory HealthEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthEntry(
      id: doc.id,
      pulse: data['pulse'] as int,
      systolic: data['systolic'] as int,
      diastolic: data['diastolic'] as int,
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.parse(data['date'] as String),
      deviceId: data['deviceId'] as String? ?? 'unknown',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pulse': pulse,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': FieldValue.serverTimestamp(),
      'date': timestamp.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  HealthEntry copyWith({
    String? id,
    int? pulse,
    int? systolic,
    int? diastolic,
    DateTime? timestamp,
    String? deviceId,
  }) {
    return HealthEntry(
      id: id ?? this.id,
      pulse: pulse ?? this.pulse,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      timestamp: timestamp ?? this.timestamp,
      deviceId: deviceId ?? this.deviceId,
    );
  }

  bool get isValidPulse => pulse >= 40 && pulse <= 200;
  bool get isValidBloodPressure =>
      systolic >= 70 && systolic <= 190 && diastolic >= 40 && diastolic <= 130;
  bool get isValid => isValidPulse && isValidBloodPressure;

  @override
  String toString() {
    return 'HealthEntry(pulse: $pulse, BP: $systolic/$diastolic, time: $timestamp, deviceId: $deviceId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HealthEntry &&
        other.id == id &&
        other.pulse == pulse &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.timestamp == timestamp &&
        other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    return Object.hash(id, pulse, systolic, diastolic, timestamp, deviceId);
  }
}
