import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';

class HolographicCard extends StatefulWidget {
  final String title;
  final int maxValue;
  final int minValue;
  final DateTime? maxDate;
  final DateTime? minDate;
  final String unit;

  const HolographicCard({
    super.key,
    required this.title,
    required this.maxValue,
    required this.minValue,
    this.maxDate,
    this.minDate,
    required this.unit,
  });

  @override
  State<HolographicCard> createState() => _HolographicCardState();
}

class _HolographicCardState extends State<HolographicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: neonColor.withOpacity(0.3 + (_controller.value * 0.2)),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: neonColor.withOpacity(0.15),
                blurRadius: 12 + (_controller.value * 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: neonColor.withOpacity(0.1),
                blurRadius: 24 + (_controller.value * 12),
                spreadRadius: 0,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                neonColor.withOpacity(0.05),
                const Color(0xFF1A1A1A),
              ],
              stops: [0.0, _controller.value, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                widget.title,
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: neonColor,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Max and Min values
              Row(
                children: [
                  Expanded(
                    child: _buildValueDisplay(
                      'PEAK',
                      widget.maxValue,
                      widget.maxDate,
                      neonColor,
                      isMax: true,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: neonColor.withOpacity(0.3),
                  ),
                  Expanded(
                    child: _buildValueDisplay(
                      'MINIMUM',
                      widget.minValue,
                      widget.minDate,
                      neonColor,
                      isMax: false,
                    ),
                  ),
                ],
              ),

              // Holographic scan line effect
              const SizedBox(height: 16),
              SizedBox(
                height: 2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            neonColor.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left:
                          MediaQuery.of(context).size.width *
                          _controller.value *
                          0.8,
                      child: Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              neonColor.withOpacity(0.8),
                              neonColor,
                              neonColor.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: neonColor,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValueDisplay(
    String label,
    int value,
    DateTime? date,
    Color neonColor, {
    required bool isMax,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            color: neonColor.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: GoogleFonts.robotoMono(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: neonColor,
                shadows: [
                  Shadow(color: neonColor.withOpacity(0.5), blurRadius: 8),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.unit,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: neonColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        if (date != null) ...[
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d').format(date),
            style: GoogleFonts.robotoMono(fontSize: 9, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
