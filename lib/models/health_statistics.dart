class HealthStatistics {
  final WeekComparison weekComparison;
  final VitalRecords records;
  final List<HealthImprovement> improvements;

  HealthStatistics({
    required this.weekComparison,
    required this.records,
    required this.improvements,
  });
}

class WeekComparison {
  final double thisWeekAvgPulse;
  final double lastWeekAvgPulse;
  final double thisWeekAvgSystolic;
  final double lastWeekAvgSystolic;
  final double thisWeekAvgDiastolic;
  final double lastWeekAvgDiastolic;
  final int thisWeekEntries;
  final int lastWeekEntries;

  WeekComparison({
    required this.thisWeekAvgPulse,
    required this.lastWeekAvgPulse,
    required this.thisWeekAvgSystolic,
    required this.lastWeekAvgSystolic,
    required this.thisWeekAvgDiastolic,
    required this.lastWeekAvgDiastolic,
    required this.thisWeekEntries,
    required this.lastWeekEntries,
  });

  double get pulseDifference => thisWeekAvgPulse - lastWeekAvgPulse;
  double get systolicDifference => thisWeekAvgSystolic - lastWeekAvgSystolic;
  double get diastolicDifference => thisWeekAvgDiastolic - lastWeekAvgDiastolic;

  bool get hasData => thisWeekEntries > 0 || lastWeekEntries > 0;
}

class VitalRecords {
  final int maxPulse;
  final int minPulse;
  final int maxSystolic;
  final int minSystolic;
  final int maxDiastolic;
  final int minDiastolic;
  final DateTime? maxPulseDate;
  final DateTime? minPulseDate;
  final DateTime? maxSystolicDate;
  final DateTime? minSystolicDate;
  final DateTime? maxDiastolicDate;
  final DateTime? minDiastolicDate;

  VitalRecords({
    required this.maxPulse,
    required this.minPulse,
    required this.maxSystolic,
    required this.minSystolic,
    required this.maxDiastolic,
    required this.minDiastolic,
    this.maxPulseDate,
    this.minPulseDate,
    this.maxSystolicDate,
    this.minSystolicDate,
    this.maxDiastolicDate,
    this.minDiastolicDate,
  });

  bool get hasData =>
      maxPulse > 0 || minPulse < 999 || maxSystolic > 0 || minSystolic < 999;
}

class HealthImprovement {
  final String metric;
  final double improvement;
  final String description;
  final bool isPositive;

  HealthImprovement({
    required this.metric,
    required this.improvement,
    required this.description,
    required this.isPositive,
  });
}
