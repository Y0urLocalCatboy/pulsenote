import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class NeonButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool small;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.small = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final neonColor = context.watch<ThemeProvider>().neonColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: widget.small ? 16 : 24,
          vertical: widget.small ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? neonColor.withOpacity(0.2)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: neonColor, width: 2),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: neonColor.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: neonColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: neonColor, size: widget.small ? 18 : 20),
              const SizedBox(width: 8),
            ],
            Text(
              widget.label,
              style: GoogleFonts.orbitron(
                color: neonColor,
                fontSize: widget.small ? 12 : 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
