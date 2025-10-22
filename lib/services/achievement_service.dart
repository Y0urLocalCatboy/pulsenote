import '../models/achievement.dart';
import '../models/health_entry.dart';

class AchievementService {
  static List<Achievement> getAllAchievements() {
    return [
      // Streak achievements
      Achievement(
        id: 'streak_7',
        title: 'WEEK WARRIOR',
        description: 'Log vitals for 7 consecutive days',
        type: AchievementType.streak,
        requirement: 7,
        icon: '🔥',
      ),
      Achievement(
        id: 'streak_30',
        title: 'MONTHLY MONITOR',
        description: 'Log vitals for 30 consecutive days',
        type: AchievementType.streak,
        requirement: 30,
        icon: '⚡',
      ),
      Achievement(
        id: 'streak_365',
        title: 'ANNUAL ANALYST',
        description: 'Log vitals for 365 consecutive days',
        type: AchievementType.streak,
        requirement: 365,
        icon: '👑',
      ),

      // Entry achievements
      Achievement(
        id: 'entries_10',
        title: 'DATA INITIATE',
        description: 'Record 10 total health entries',
        type: AchievementType.entries,
        requirement: 10,
        icon: '📊',
      ),
      Achievement(
        id: 'entries_50',
        title: 'DATA COLLECTOR',
        description: 'Record 50 total health entries',
        type: AchievementType.entries,
        requirement: 50,
        icon: '📈',
      ),
      Achievement(
        id: 'entries_100',
        title: 'DATA MASTER',
        description: 'Record 100 total health entries',
        type: AchievementType.entries,
        requirement: 100,
        icon: '💎',
      ),
      Achievement(
        id: 'entries_500',
        title: 'DATA LEGEND',
        description: 'Record 500 total health entries',
        type: AchievementType.entries,
        requirement: 500,
        icon: '🏆',
      ),

      // Healthy days achievements
      Achievement(
        id: 'healthy_7',
        title: 'WELLNESS STARTER',
        description: 'Maintain healthy vitals for 7 days',
        type: AchievementType.healthyDays,
        requirement: 7,
        icon: '💚',
      ),
      Achievement(
        id: 'healthy_30',
        title: 'WELLNESS CHAMPION',
        description: 'Maintain healthy vitals for 30 days',
        type: AchievementType.healthyDays,
        requirement: 30,
        icon: '🌟',
      ),
      Achievement(
        id: 'healthy_90',
        title: 'WELLNESS ELITE',
        description: 'Maintain healthy vitals for 90 days',
        type: AchievementType.healthyDays,
        requirement: 90,
        icon: '⭐',
      ),
      Achievement(
        id: 'healthy_365',
        title: 'WELLNESS IMMORTAL',
        description: 'Maintain healthy vitals for 365 days',
        type: AchievementType.healthyDays,
        requirement: 365,
        icon: '🔱',
      ),
    ];
  }

  static List<RankInfo> getAllRanks() {
    return [
      RankInfo(
        rank: HealthRank.recruit,
        title: 'RECRUIT',
        description: 'Beginning your health journey',
        healthyDaysRequired: 0,
        icon: '🎖️',
      ),
      RankInfo(
        rank: HealthRank.private,
        title: 'PRIVATE',
        description: 'Learning the basics',
        healthyDaysRequired: 7,
        icon: '🏅',
      ),
      RankInfo(
        rank: HealthRank.corporal,
        title: 'CORPORAL',
        description: 'Building consistency',
        healthyDaysRequired: 14,
        icon: '🎗️',
      ),
      RankInfo(
        rank: HealthRank.sergeant,
        title: 'SERGEANT',
        description: 'Showing dedication',
        healthyDaysRequired: 30,
        icon: '🥉',
      ),
      RankInfo(
        rank: HealthRank.lieutenant,
        title: 'LIEUTENANT',
        description: 'Demonstrating discipline',
        healthyDaysRequired: 60,
        icon: '🥈',
      ),
      RankInfo(
        rank: HealthRank.captain,
        title: 'CAPTAIN',
        description: 'Leading by example',
        healthyDaysRequired: 90,
        icon: '🥇',
      ),
      RankInfo(
        rank: HealthRank.major,
        title: 'MAJOR',
        description: 'Mastering wellness',
        healthyDaysRequired: 180,
        icon: '🏆',
      ),
      RankInfo(
        rank: HealthRank.colonel,
        title: 'COLONEL',
        description: 'Elite health status',
        healthyDaysRequired: 270,
        icon: '👑',
      ),
      RankInfo(
        rank: HealthRank.general,
        title: 'GENERAL',
        description: 'Supreme wellness achieved',
        healthyDaysRequired: 365,
        icon: '⭐',
      ),
    ];
  }

  static HealthRank calculateRank(int healthyDays) {
    final ranks = getAllRanks();
    for (int i = ranks.length - 1; i >= 0; i--) {
      if (healthyDays >= ranks[i].healthyDaysRequired) {
        return ranks[i].rank;
      }
    }
    return HealthRank.recruit;
  }

  static RankInfo getRankInfo(HealthRank rank) {
    return getAllRanks().firstWhere((r) => r.rank == rank);
  }

  static RankInfo? getNextRankInfo(HealthRank currentRank) {
    final ranks = getAllRanks();
    final currentIndex = ranks.indexWhere((r) => r.rank == currentRank);
    if (currentIndex >= 0 && currentIndex < ranks.length - 1) {
      return ranks[currentIndex + 1];
    }
    return null;
  }

  static AchievementProgress calculateProgress(List<HealthEntry> entries) {
    if (entries.isEmpty) {
      return AchievementProgress();
    }

    final sortedEntries = List<HealthEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate streak
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 1;
    DateTime? lastDate;

    for (final entry in sortedEntries.reversed) {
      final entryDate = DateTime(
        entry.timestamp.year,
        entry.timestamp.month,
        entry.timestamp.day,
      );

      if (lastDate == null) {
        lastDate = entryDate;
        currentStreak = 1;
        tempStreak = 1;
      } else {
        final difference = lastDate.difference(entryDate).inDays;

        if (difference == 1) {
          tempStreak++;
          if (currentStreak > 0) {
            currentStreak++;
          }
        } else if (difference > 1) {
          if (currentStreak > 0) {
            currentStreak = 0;
          }
          tempStreak = 1;
        }

        lastDate = entryDate;
      }

      if (tempStreak > longestStreak) {
        longestStreak = tempStreak;
      }
    }

    // Check if streak is broken
    if (lastDate != null) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final daysSinceLastEntry = todayDate.difference(lastDate).inDays;

      if (daysSinceLastEntry > 1) {
        currentStreak = 0;
      }
    }

    // Calculate healthy days
    int healthyDays = 0;
    for (final entry in sortedEntries) {
      if (_isHealthyEntry(entry)) {
        healthyDays++;
      }
    }

    final rank = calculateRank(healthyDays);

    return AchievementProgress(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalEntries: entries.length,
      healthyDays: healthyDays,
      currentRank: rank,
      lastEntryDate: sortedEntries.last.timestamp,
    );
  }

  static bool _isHealthyEntry(HealthEntry entry) {
    // Healthy criteria:
    // Pulse: 60-100 BPM
    // Systolic: 90-120 mmHg
    // Diastolic: 60-80 mmHg
    return entry.pulse >= 60 &&
        entry.pulse <= 100 &&
        entry.systolic >= 90 &&
        entry.systolic <= 120 &&
        entry.diastolic >= 60 &&
        entry.diastolic <= 80;
  }

  static List<Achievement> updateAchievements(
    List<Achievement> achievements,
    AchievementProgress progress,
  ) {
    return achievements.map((achievement) {
      int currentProgress = 0;
      bool isUnlocked = achievement.unlocked;

      switch (achievement.type) {
        case AchievementType.streak:
          currentProgress = progress.longestStreak;
          break;
        case AchievementType.entries:
          currentProgress = progress.totalEntries;
          break;
        case AchievementType.healthyDays:
          currentProgress = progress.healthyDays;
          break;
        case AchievementType.rank:
          currentProgress = progress.healthyDays;
          break;
      }

      if (!isUnlocked && currentProgress >= achievement.requirement) {
        return achievement.copyWith(
          unlocked: true,
          unlockedDate: DateTime.now(),
          progress: currentProgress,
        );
      }

      return achievement.copyWith(progress: currentProgress);
    }).toList();
  }
}
