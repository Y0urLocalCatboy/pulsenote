import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/health_viewmodel.dart';
import '../providers/theme_provider.dart';
import '../services/achievement_service.dart';
import '../models/achievement.dart';
import 'widgets/neon_container.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HealthViewModel>();
    final neonColor = context.watch<ThemeProvider>().neonColor;
    final entries = viewModel.entriesForCurrentDevice;

    final progress = AchievementService.calculateProgress(entries);
    final achievements = AchievementService.updateAchievements(
      AchievementService.getAllAchievements(),
      progress,
    );

    final currentRankInfo = AchievementService.getRankInfo(
      progress.currentRank,
    );
    final nextRankInfo = AchievementService.getNextRankInfo(
      progress.currentRank,
    );

    final unlockedAchievements = achievements.where((a) => a.unlocked).toList();
    final lockedAchievements = achievements.where((a) => !a.unlocked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ACHIEVEMENTS',
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
              // Rank Card
              _buildRankCard(
                currentRankInfo,
                nextRankInfo,
                progress,
                neonColor,
              ),
              const SizedBox(height: 24),

              // Progress Stats
              _buildProgressStats(progress, neonColor),
              const SizedBox(height: 24),

              // Unlocked Achievements
              if (unlockedAchievements.isNotEmpty) ...[
                Text(
                  'UNLOCKED (${unlockedAchievements.length})',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: neonColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                ...unlockedAchievements.map(
                  (achievement) =>
                      _buildAchievementCard(achievement, neonColor, true),
                ),
                const SizedBox(height: 24),
              ],

              // Locked Achievements
              Text(
                'IN PROGRESS (${lockedAchievements.length})',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: neonColor.withOpacity(0.6),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ...lockedAchievements.map(
                (achievement) =>
                    _buildAchievementCard(achievement, neonColor, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRankCard(
    RankInfo currentRank,
    RankInfo? nextRank,
    AchievementProgress progress,
    Color neonColor,
  ) {
    return NeonContainer(
      padding: const EdgeInsets.all(24),
      pulsing: true,
      child: Column(
        children: [
          Text(
            'CURRENT RANK',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: neonColor.withOpacity(0.7),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(currentRank.icon, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            currentRank.title,
            style: GoogleFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: neonColor,
              letterSpacing: 3,
              shadows: [
                Shadow(color: neonColor.withOpacity(0.5), blurRadius: 12),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentRank.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
              fontSize: 13,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: neonColor, width: 1.5),
              borderRadius: BorderRadius.circular(20),
              color: neonColor.withOpacity(0.1),
            ),
            child: Text(
              '${progress.healthyDays} HEALTHY DAYS',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: neonColor,
                letterSpacing: 1.5,
              ),
            ),
          ),
          if (nextRank != null) ...[
            const SizedBox(height: 20),
            Divider(color: neonColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NEXT RANK: ${nextRank.title}',
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    color: neonColor.withOpacity(0.7),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${nextRank.healthyDaysRequired - progress.healthyDays} days',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: neonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.healthyDays / nextRank.healthyDaysRequired,
                backgroundColor: neonColor.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(neonColor),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressStats(AchievementProgress progress, Color neonColor) {
    return NeonContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'BIOMETRIC STATS',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: neonColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'CURRENT STREAK',
                  '${progress.currentStreak}',
                  'days',
                  neonColor,
                  Icons.local_fire_department,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: neonColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildStatItem(
                  'LONGEST STREAK',
                  '${progress.longestStreak}',
                  'days',
                  neonColor,
                  Icons.military_tech,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'TOTAL ENTRIES',
                  '${progress.totalEntries}',
                  'logged',
                  neonColor,
                  Icons.analytics,
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: neonColor.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: _buildStatItem(
                  'HEALTHY DAYS',
                  '${progress.healthyDays}',
                  'total',
                  neonColor,
                  Icons.favorite,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    String unit,
    Color neonColor,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: neonColor, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: neonColor,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.robotoMono(
            fontSize: 10,
            color: neonColor.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.orbitron(
            fontSize: 9,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    Color neonColor,
    bool unlocked,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: unlocked
                    ? neonColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: unlocked ? neonColor : Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: unlocked ? null : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: unlocked ? neonColor : Colors.grey[600],
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: GoogleFonts.robotoMono(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (!unlocked) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: achievement.progressPercentage,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          neonColor.withOpacity(0.6),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${achievement.progress}/${achievement.requirement}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  if (unlocked && achievement.unlockedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Unlocked ${DateFormat('MMM d, yyyy').format(achievement.unlockedDate!)}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: neonColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (unlocked) Icon(Icons.check_circle, color: neonColor, size: 28),
          ],
        ),
      ),
    );
  }
}
