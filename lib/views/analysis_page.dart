import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../providers/theme_provider.dart';
import 'widgets/neon_container.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthViewModel>();
    final neonColor = context.watch<ThemeProvider>().neonColor;
    final analysis = viewModel.analyzeHealth();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'HEALTH ANALYSIS',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0A0A),
              neonColor.withOpacity(0.08),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Card
              NeonContainer(
                padding: const EdgeInsets.all(20.0),
                pulsing: analysis.recommendDoctorVisit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          analysis.recommendDoctorVisit
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline,
                          color: analysis.recommendDoctorVisit
                              ? Colors.orange
                              : neonColor,
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            analysis.recommendDoctorVisit
                                ? 'ATTENTION REQUIRED'
                                : 'SYSTEMS NORMAL',
                            style: GoogleFonts.orbitron(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: analysis.recommendDoctorVisit
                                  ? Colors.orange
                                  : neonColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${analysis.entriesAnalyzed} ENTRIES ANALYZED',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey[500],
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      'LAST 30 DAYS',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pulse Analysis Card
              _buildAnalysisCard(
                title: 'PULSE RATE',
                category: analysis.pulseCategory.toUpperCase(),
                description: analysis.pulseDescription,
                needsAttention: analysis.pulseNeedsAttention,
                value: '${analysis.avgPulse.toStringAsFixed(0)} BPM',
                icon: Icons.favorite,
                neonColor: neonColor,
              ),
              const SizedBox(height: 16),

              // Blood Pressure Analysis Card
              _buildAnalysisCard(
                title: 'BLOOD PRESSURE',
                category: analysis.bloodPressureCategory.toUpperCase(),
                description: analysis.bloodPressureDescription,
                needsAttention: analysis.bloodPressureNeedsAttention,
                value:
                    '${analysis.avgSystolic.toStringAsFixed(0)}/${analysis.avgDiastolic.toStringAsFixed(0)} mmHg',
                icon: Icons.monitor_heart,
                neonColor: neonColor,
              ),
              const SizedBox(height: 24),

              // Emergency Information
              if (analysis.recommendDoctorVisit)
                NeonContainer(
                  padding: const EdgeInsets.all(20.0),
                  pulsing: true,
                  borderWidth: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.emergency,
                            color: Colors.red,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'MEDICAL ATTENTION',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Biometric anomalies detected. Recommend immediate consultation with medical technician for system diagnostics.',
                        style: GoogleFonts.robotoMono(
                          fontSize: 13,
                          color: Colors.grey[300],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'EMERGENCY: 112',
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Critical alert: Activate if experiencing acute cardiac distress, respiratory failure, or neurological shutdown',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.robotoMono(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard({
    required String title,
    required String category,
    required String description,
    required bool needsAttention,
    required String value,
    required IconData icon,
    required Color neonColor,
  }) {
    final statusColor = needsAttention ? Colors.orange : neonColor;

    return NeonContainer(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: neonColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: statusColor, width: 1.5),
              borderRadius: BorderRadius.circular(6),
              color: statusColor.withOpacity(0.1),
            ),
            child: Text(
              category,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusColor,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: neonColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              color: Colors.grey[400],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
