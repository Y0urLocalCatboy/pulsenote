import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ECGLineWidget extends StatefulWidget {
  final int pulseRate;
  final double width;
  final double height;
  final bool animate;

  const ECGLineWidget({
    super.key,
    required this.pulseRate,
    this.width = 100,
    this.height = 40,
    this.animate = true,
  });

  @override
  State<ECGLineWidget> createState() => _ECGLineWidgetState();
}

class _ECGLineWidgetState extends State<ECGLineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Convert pulse rate (bpm) to animation duration
    // 60 bpm = 1 beat per second = 1000ms
    // pulse bpm = 60000/pulse ms per beat
    final durationMs = (60000 / widget.pulseRate).clamp(300, 2000).toInt();

    _controller = AnimationController(
      duration: Duration(milliseconds: durationMs),
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ECGLineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulseRate != oldWidget.pulseRate) {
      final durationMs = (60000 / widget.pulseRate).clamp(300, 2000).toInt();
      _controller.duration = Duration(milliseconds: durationMs);
    }
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ECGPainter(progress: _controller.value, color: neonColor),
          );
        },
      ),
    );
  }
}

class ECGPainter extends CustomPainter {
  final double progress;
  final Color color;

  ECGPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final path = Path();
    final baselineY = size.height * 0.5;

    // ECG waveform pattern
    // P wave, QRS complex, T wave
    final points = <Offset>[
      Offset(0, baselineY),
      Offset(size.width * 0.1, baselineY),
      // P wave (small bump)
      Offset(size.width * 0.15, baselineY - size.height * 0.1),
      Offset(size.width * 0.2, baselineY),
      Offset(size.width * 0.3, baselineY),
      // QRS complex (sharp spike)
      Offset(size.width * 0.35, baselineY + size.height * 0.1),
      Offset(size.width * 0.4, baselineY - size.height * 0.4),
      Offset(size.width * 0.42, baselineY + size.height * 0.15),
      Offset(size.width * 0.45, baselineY),
      Offset(size.width * 0.55, baselineY),
      // T wave (medium bump)
      Offset(size.width * 0.6, baselineY - size.height * 0.15),
      Offset(size.width * 0.65, baselineY),
      Offset(size.width * 1.0, baselineY),
    ];

    // Build the path
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Animate by clipping the path based on progress
    final pathMetrics = path.computeMetrics();
    final metric = pathMetrics.first;
    final animatedPath = metric.extractPath(0, metric.length * progress);

    // Draw glow
    canvas.drawPath(animatedPath, glowPaint);
    // Draw main line
    canvas.drawPath(animatedPath, paint);

    // Draw pulsing dot at the end
    if (progress > 0.4 && progress < 0.5) {
      final dotPosition = metric
          .getTangentForOffset(metric.length * progress)!
          .position;
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dotPosition, 3, dotPaint);

      // Glow around dot
      final dotGlowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(dotPosition, 6, dotGlowPaint);
    }
  }

  @override
  bool shouldRepaint(ECGPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
