import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/health_viewmodel.dart';
import '../providers/theme_provider.dart';
import 'widgets/neon_container.dart';

class ChartsPage extends StatelessWidget {
  const ChartsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthViewModel>();
    final neonColor = context.watch<ThemeProvider>().neonColor;
    final entries = viewModel.entriesForCurrentDevice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DATA VISUALIZATION',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0A0A0A),
              neonColor.withOpacity(0.05),
              const Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: entries.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 64,
                      color: neonColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NO DATA AVAILABLE',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        color: neonColor.withOpacity(0.7),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildChartCard(
                      title: 'PULSE RATE',
                      chart: _buildLineChart(
                        context,
                        spots: entries
                            .map(
                              (e) => FlSpot(
                                e.timestamp.millisecondsSinceEpoch.toDouble(),
                                e.pulse.toDouble(),
                              ),
                            )
                            .toList(),
                        color: neonColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildChartCard(
                      title: 'BLOOD PRESSURE',
                      showLegend: true,
                      chart: _buildLineChart(
                        context,
                        spots: entries
                            .map(
                              (e) => FlSpot(
                                e.timestamp.millisecondsSinceEpoch.toDouble(),
                                e.systolic.toDouble(),
                              ),
                            )
                            .toList(),
                        spots2: entries
                            .map(
                              (e) => FlSpot(
                                e.timestamp.millisecondsSinceEpoch.toDouble(),
                                e.diastolic.toDouble(),
                              ),
                            )
                            .toList(),
                        color: neonColor,
                        color2: neonColor.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required Widget chart,
    bool showLegend = false,
  }) {
    return Builder(
      builder: (context) {
        final neonColor = context.watch<ThemeProvider>().neonColor;

        return NeonContainer(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: neonColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  if (showLegend) ...[
                    _buildLegendItem(neonColor, 'SYSTOLIC', neonColor),
                    const SizedBox(width: 16),
                    _buildLegendItem(
                      neonColor,
                      'DIASTOLIC',
                      neonColor.withOpacity(0.5),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(height: 220, child: chart),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color neonColor, String label, Color lineColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: lineColor,
            boxShadow: [
              BoxShadow(color: lineColor.withOpacity(0.5), blurRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            color: neonColor.withOpacity(0.7),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(
    BuildContext context, {
    required List<FlSpot> spots,
    List<FlSpot>? spots2,
    required Color color,
    Color? color2,
  }) {
    final allSpots = [...spots];
    if (spots2 != null) {
      allSpots.addAll(spots2);
    }

    double minY = 40;
    double maxY = 100;

    if (allSpots.isNotEmpty) {
      final minSpot = allSpots.reduce((a, b) => a.y < b.y ? a : b);
      final maxSpot = allSpots.reduce((a, b) => a.y > b.y ? a : b);
      minY = (minSpot.y - 20).clamp(0, double.infinity);
      maxY = maxSpot.y + 20;
    }

    final List<LineChartBarData> lineBarsData = [
      LineChartBarData(
        spots: spots,
        isCurved: false,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            return FlDotCirclePainter(radius: 3, color: color, strokeWidth: 0);
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        shadow: Shadow(color: color.withOpacity(0.5), blurRadius: 8),
      ),
    ];

    if (spots2 != null && color2 != null) {
      lineBarsData.add(
        LineChartBarData(
          spots: spots2,
          isCurved: false,
          color: color2,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: color2,
                strokeWidth: 0,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [color2.withOpacity(0.2), color2.withOpacity(0.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: color.withOpacity(0.1), strokeWidth: 1);
          },
          getDrawingVerticalLine: (value) {
            return FlLine(color: color.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: GoogleFonts.robotoMono(
                    color: color.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1000 * 60 * 60 * 24, // One day interval
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Text(
                  '${date.day}/${date.month}',
                  style: GoogleFonts.robotoMono(
                    color: color.withOpacity(0.6),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        lineBarsData: lineBarsData,
        backgroundColor: const Color(0xFF0F0F0F),
      ),
    );
  }
}
