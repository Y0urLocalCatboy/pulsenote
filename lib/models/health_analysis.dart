class HealthAnalysis {
  final String pulseCategory;
  final String pulseDescription;
  final bool pulseNeedsAttention;

  final String bloodPressureCategory;
  final String bloodPressureDescription;
  final bool bloodPressureNeedsAttention;

  final double avgPulse;
  final double avgSystolic;
  final double avgDiastolic;

  final int entriesAnalyzed;
  final bool recommendDoctorVisit;

  HealthAnalysis({
    required this.pulseCategory,
    required this.pulseDescription,
    required this.pulseNeedsAttention,
    required this.bloodPressureCategory,
    required this.bloodPressureDescription,
    required this.bloodPressureNeedsAttention,
    required this.avgPulse,
    required this.avgSystolic,
    required this.avgDiastolic,
    required this.entriesAnalyzed,
    required this.recommendDoctorVisit,
  });
}
