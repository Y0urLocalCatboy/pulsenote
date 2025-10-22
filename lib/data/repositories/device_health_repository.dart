import 'package:health/health.dart';

import '../../models/health_entry.dart';

class DeviceHealthRepository {
  final Health _health;

  DeviceHealthRepository({Health? health}) : _health = health ?? Health();

  Future<bool> requestAuthorization() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ];

    return await _health.requestAuthorization(types);
  }

  Future<void> writeHealthData(HealthEntry entry) async {
    final now = entry.timestamp;

    await _health.writeHealthData(
      value: entry.pulse.toDouble(),
      type: HealthDataType.HEART_RATE,
      startTime: now,
      endTime: now,
    );

    await _health.writeHealthData(
      value: entry.systolic.toDouble(),
      type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      startTime: now,
      endTime: now,
    );

    await _health.writeHealthData(
      value: entry.diastolic.toDouble(),
      type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
      startTime: now,
      endTime: now,
    );
  }

  Future<List<HealthEntry>> readHealthData(DateTime start, DateTime end) async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
      HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    ];

    final healthData = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: types,
    );

    return _aggregateHealthData(healthData);
  }

  List<HealthEntry> _aggregateHealthData(List<HealthDataPoint> dataPoints) {
    final Map<DateTime, Map<String, int>> groupedData = {};

    for (final point in dataPoints) {
      final timestamp = point.dateFrom;
      final roundedTime = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
        timestamp.hour,
        timestamp.minute,
      );

      groupedData.putIfAbsent(roundedTime, () => {});

      switch (point.type) {
        case HealthDataType.HEART_RATE:
          groupedData[roundedTime]!['pulse'] =
              (point.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
          groupedData[roundedTime]!['systolic'] =
              (point.value as NumericHealthValue).numericValue.toInt();
          break;
        case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
          groupedData[roundedTime]!['diastolic'] =
              (point.value as NumericHealthValue).numericValue.toInt();
          break;
        default:
          break;
      }
    }

    return groupedData.entries
        .where(
          (entry) =>
              entry.value.containsKey('pulse') &&
              entry.value.containsKey('systolic') &&
              entry.value.containsKey('diastolic'),
        )
        .map(
          (entry) => HealthEntry(
            pulse: entry.value['pulse']!,
            systolic: entry.value['systolic']!,
            diastolic: entry.value['diastolic']!,
            timestamp: entry.key,
            deviceId: 'synced_from_device',
          ),
        )
        .toList();
  }
}
