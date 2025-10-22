enum AchievementType { streak, entries, healthyDays, rank }

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementType type;
  final int requirement;
  final String icon;
  final bool unlocked;
  final DateTime? unlockedDate;
  final int progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requirement,
    required this.icon,
    this.unlocked = false,
    this.unlockedDate,
    this.progress = 0,
  });

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedDate,
    int? progress,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      type: type,
      requirement: requirement,
      icon: icon,
      unlocked: unlocked ?? this.unlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      progress: progress ?? this.progress,
    );
  }

  double get progressPercentage =>
      requirement > 0 ? (progress / requirement).clamp(0.0, 1.0) : 0.0;
}

enum HealthRank {
  recruit,
  private,
  corporal,
  sergeant,
  lieutenant,
  captain,
  major,
  colonel,
  general,
}

class RankInfo {
  final HealthRank rank;
  final String title;
  final String description;
  final int healthyDaysRequired;
  final String icon;

  RankInfo({
    required this.rank,
    required this.title,
    required this.description,
    required this.healthyDaysRequired,
    required this.icon,
  });
}

class AchievementProgress {
  final int currentStreak;
  final int longestStreak;
  final int totalEntries;
  final int healthyDays;
  final HealthRank currentRank;
  final DateTime? lastEntryDate;

  AchievementProgress({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalEntries = 0,
    this.healthyDays = 0,
    this.currentRank = HealthRank.recruit,
    this.lastEntryDate,
  });

  AchievementProgress copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalEntries,
    int? healthyDays,
    HealthRank? currentRank,
    DateTime? lastEntryDate,
  }) {
    return AchievementProgress(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalEntries: totalEntries ?? this.totalEntries,
      healthyDays: healthyDays ?? this.healthyDays,
      currentRank: currentRank ?? this.currentRank,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
    );
  }
}
