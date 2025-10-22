import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/achievement.dart';

class AchievementUnlockDialog extends StatefulWidget {
  final Achievement achievement;
  final Color neonColor;

  const AchievementUnlockDialog({
    super.key,
    required this.achievement,
    required this.neonColor,
  });

  @override
  State<AchievementUnlockDialog> createState() =>
      _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: widget.neonColor, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Achievement icon with glow
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.neonColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: widget.neonColor.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.achievement.icon,
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
                const SizedBox(height: 24),

                // "Achievement Unlocked" text
                Text(
                  'ACHIEVEMENT UNLOCKED',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: widget.neonColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // Achievement title
                Text(
                  widget.achievement.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.neonColor,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: widget.neonColor.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Achievement description
                Text(
                  widget.achievement.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.neonColor.withOpacity(0.2),
                    foregroundColor: widget.neonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: widget.neonColor, width: 1.5),
                    ),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RankUpDialog extends StatefulWidget {
  final RankInfo rankInfo;
  final Color neonColor;

  const RankUpDialog({
    super.key,
    required this.rankInfo,
    required this.neonColor,
  });

  @override
  State<RankUpDialog> createState() => _RankUpDialogState();
}

class _RankUpDialogState extends State<RankUpDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: widget.neonColor, width: 2),
          ),
          content: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.neonColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rank icon with rotation and glow
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: widget.neonColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: widget.neonColor.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      widget.rankInfo.icon,
                      style: const TextStyle(fontSize: 72),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // "Rank Promotion" text
                Text(
                  'RANK PROMOTION',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.neonColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),

                // New rank title
                Text(
                  widget.rankInfo.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.neonColor,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: widget.neonColor.withOpacity(0.8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Rank description
                Text(
                  widget.rankInfo.description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    color: Colors.grey[400],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Close button
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.neonColor.withOpacity(0.2),
                    foregroundColor: widget.neonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: widget.neonColor, width: 1.5),
                    ),
                  ),
                  child: Text(
                    'CONTINUE',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
