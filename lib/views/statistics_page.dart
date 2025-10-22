import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../providers/theme_provider.dart';
import 'widgets/neon_container.dart';
import 'widgets/holographic_card.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthViewModel>();
    final neonColor = context.watch<ThemeProvider>().neonColor;
    final stats = viewModel.calculateStatistics();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BIOMETRIC STATISTICS',
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
              // Week Comparison
              Text(
                'WEEKLY COMPARISON',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: neonColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildWeekComparisonCard(stats, neonColor),
              const SizedBox(height: 24),

              // Records
              Text(
                'VITAL RECORDS',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: neonColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecordsCard(stats, neonColor),
              const SizedBox(height: 24),

              // Improvements
              if (stats.improvements.isNotEmpty) ...[
                Text(
                  'DETECTED CHANGES',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: neonColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ...stats.improvements.map(
                  (improvement) =>
                      _buildImprovementCard(improvement, neonColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekComparisonCard(stats, Color neonColor) {
    if (!stats.weekComparison.hasData) {
      return NeonContainer(
        padding: const EdgeInsets.all(20),
        child: Text(
          'INSUFFICIENT DATA FOR COMPARISON',
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            color: neonColor.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return NeonContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildComparisonRow(
            'PULSE RATE',
            stats.weekComparison.lastWeekAvgPulse,
            stats.weekComparison.thisWeekAvgPulse,
            'BPM',
            neonColor,
            lowerIsBetter: true,
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'SYSTOLIC BP',
            stats.weekComparison.lastWeekAvgSystolic,
            stats.weekComparison.thisWeekAvgSystolic,
            'mmHg',
            neonColor,
            lowerIsBetter: true,
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'DIASTOLIC BP',
            stats.weekComparison.lastWeekAvgDiastolic,
            stats.weekComparison.thisWeekAvgDiastolic,
            'mmHg',
            neonColor,
            lowerIsBetter: true,
          ),
          const SizedBox(height: 16),
          Divider(color: neonColor.withOpacity(0.3)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeekDataPoint(
                'LAST WEEK',
                stats.weekComparison.lastWeekEntries,
                neonColor.withOpacity(0.6),
              ),
              _buildWeekDataPoint(
                'THIS WEEK',
                stats.weekComparison.thisWeekEntries,
                neonColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    double lastWeek,
    double thisWeek,
    String unit,
    Color neonColor, {
    bool lowerIsBetter = true,
  }) {
    if (lastWeek == 0 && thisWeek == 0) {
      return const SizedBox.shrink();
    }

    final difference = thisWeek - lastWeek;
    final isImproved = lowerIsBetter ? difference < 0 : difference > 0;
    final changeColor = difference == 0
        ? neonColor
        : (isImproved ? Colors.green : Colors.orange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            color: neonColor.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LAST',
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    lastWeek == 0
                        ? 'NO DATA'
                        : '${lastWeek.toStringAsFixed(1)} $unit',
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      color: neonColor.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              difference == 0
                  ? Icons.remove
                  : (difference > 0
                        ? Icons.arrow_upward
                        : Icons.arrow_downward),
              color: changeColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'THIS',
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    thisWeek == 0
                        ? 'NO DATA'
                        : '${thisWeek.toStringAsFixed(1)} $unit',
                    style: GoogleFonts.robotoMono(
                      fontSize: 16,
                      color: neonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (difference != 0 && lastWeek != 0 && thisWeek != 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)} $unit',
              style: GoogleFonts.robotoMono(
                fontSize: 11,
                color: changeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWeekDataPoint(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            color: color.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: GoogleFonts.robotoMono(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          'ENTRIES',
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            color: color.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsCard(stats, Color neonColor) {
    if (!stats.records.hasData) {
      return NeonContainer(
        padding: const EdgeInsets.all(20),
        child: Text(
          'NO RECORDS AVAILABLE',
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            color: neonColor.withOpacity(0.6),
            letterSpacing: 1.5,
          ),
        ),
      );
    }

    return Column(
      children: [
        HolographicCard(
          title: 'PULSE RATE',
          maxValue: stats.records.maxPulse,
          minValue: stats.records.minPulse,
          maxDate: stats.records.maxPulseDate,
          minDate: stats.records.minPulseDate,
          unit: 'BPM',
        ),
        const SizedBox(height: 12),
        HolographicCard(
          title: 'SYSTOLIC BP',
          maxValue: stats.records.maxSystolic,
          minValue: stats.records.minSystolic,
          maxDate: stats.records.maxSystolicDate,
          minDate: stats.records.minSystolicDate,
          unit: 'mmHg',
        ),
        const SizedBox(height: 12),
        HolographicCard(
          title: 'DIASTOLIC BP',
          maxValue: stats.records.maxDiastolic,
          minValue: stats.records.minDiastolic,
          maxDate: stats.records.maxDiastolicDate,
          minDate: stats.records.minDiastolicDate,
          unit: 'mmHg',
        ),
      ],
    );
  }

  Widget _buildImprovementCard(improvement, Color neonColor) {
    final color = improvement.isPositive ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color, width: 1.5),
              ),
              child: Icon(
                improvement.isPositive
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    improvement.metric,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: neonColor,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    improvement.description,
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${improvement.isPositive ? '-' : '+'}${improvement.improvement.toStringAsFixed(1)}',
              style: GoogleFonts.robotoMono(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
