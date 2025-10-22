import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class NeonContainer extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final bool pulsing;
  final VoidCallback? onTap;

  const NeonContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 12,
    this.borderWidth = 1.5,
    this.pulsing = false,
    this.onTap,
  });

  @override
  State<NeonContainer> createState() => _NeonContainerState();
}

class _NeonContainerState extends State<NeonContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.pulsing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing != oldWidget.pulsing) {
      if (widget.pulsing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
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

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        final glowIntensity = widget.pulsing ? _glowAnimation.value : 0.5;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: widget.margin,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: neonColor.withOpacity(0.6 * glowIntensity),
                width: widget.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: neonColor.withOpacity(0.3 * glowIntensity),
                  blurRadius: 12 * glowIntensity,
                  spreadRadius: 2 * glowIntensity,
                ),
                BoxShadow(
                  color: neonColor.withOpacity(0.2 * glowIntensity),
                  blurRadius: 24 * glowIntensity,
                  spreadRadius: 4 * glowIntensity,
                ),
              ],
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
