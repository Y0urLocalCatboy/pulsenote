import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../data/repositories/device_health_repository.dart';
import '../data/repositories/firestore_health_repository.dart';
import '../models/achievement.dart';
import '../models/health_analysis.dart';
import '../models/health_entry.dart';
import '../models/health_statistics.dart';
import '../models/result.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';

class HealthViewModel extends ChangeNotifier {
  final FirestoreHealthRepository _firestoreRepo;
  final DeviceHealthRepository _deviceHealthRepo;

  HealthViewModel({
    required FirestoreHealthRepository firestoreRepository,
    required DeviceHealthRepository deviceHealthRepository,
  }) : _firestoreRepo = firestoreRepository,
       _deviceHealthRepo = deviceHealthRepository {
    _init();
  }

  StreamSubscription<List<HealthEntry>>? _entriesSubscription;
  List<HealthEntry> _entries = [];
  Result<void> _saveState = Result.idle();
  Result<void> _deleteState = Result.idle();
  Result<void> _syncState = Result.idle();
  Result<void> _updateState = Result.idle();
  bool _healthAuthorized = false;
  String _deviceId = 'unknown';

  // Achievement unlock callbacks
  final _achievementUnlockedController =
      StreamController<Achievement>.broadcast();
  final _rankUpController = StreamController<RankInfo>.broadcast();

  Stream<Achievement> get onAchievementUnlocked =>
      _achievementUnlockedController.stream;
  Stream<RankInfo> get onRankUp => _rankUpController.stream;

  List<HealthEntry> get entries => _entries;
  List<HealthEntry> get entriesForCurrentDevice =>
      _entries.where((entry) => entry.deviceId == _deviceId).toList();
  Result<void> get saveState => _saveState;
  Result<void> get deleteState => _deleteState;
  Result<void> get syncState => _syncState;
  Result<void> get updateState => _updateState;
  bool get healthAuthorized => _healthAuthorized;
  bool get isHealthPlatformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  bool get isLoading =>
      _saveState.isLoading || _deleteState.isLoading || _syncState.isLoading;

  void _init() {
    _entriesSubscription = _firestoreRepo.watchEntries().listen(
      (entries) {
        _entries = entries;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error watching entries: $error');
      },
    );
    if (isHealthPlatformSupported) {
      requestHealthPermissions();
    }
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        _deviceId = webInfo.vendor ?? 'web';
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          _deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          _deviceId = iosInfo.identifierForVendor ?? 'ios_unknown';
        } else if (Platform.isLinux) {
          final linuxInfo = await deviceInfo.linuxInfo;
          _deviceId = linuxInfo.machineId ?? 'linux_unknown';
        } else if (Platform.isMacOS) {
          final macInfo = await deviceInfo.macOsInfo;
          _deviceId = macInfo.systemGUID ?? 'macos_unknown';
        } else if (Platform.isWindows) {
          final windowsInfo = await deviceInfo.windowsInfo;
          _deviceId = windowsInfo.deviceId;
        }
      }
    } catch (e) {
      debugPrint('Failed to get device ID: $e');
    }
  }

  Future<void> requestHealthPermissions() async {
    if (!isHealthPlatformSupported) return;
    try {
      _healthAuthorized = await _deviceHealthRepo.requestAuthorization();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to request health permissions: $e');
      _healthAuthorized = false;
    }
  }

  Future<void> saveEntry({
    required int pulse,
    required int systolic,
    required int diastolic,
    bool syncToDevice = true,
  }) async {
    _saveState = Result.loading();
    notifyListeners();

    try {
      // Get progress before saving
      final progressBefore = AchievementService.calculateProgress(
        entriesForCurrentDevice,
      );

      final entry = HealthEntry(
        pulse: pulse,
        systolic: systolic,
        diastolic: diastolic,
        timestamp: DateTime.now(),
        deviceId: _deviceId,
      );

      if (!entry.isValid) {
        _saveState = Result.error('Invalid health values');
        notifyListeners();
        return;
      }

      await _firestoreRepo.addEntry(entry);

      if (syncToDevice && isHealthPlatformSupported && _healthAuthorized) {
        await _deviceHealthRepo.writeHealthData(entry);
      }

      _saveState = Result.success(null);
      notifyListeners();

      // Smart notifications - check for abnormal values
      _checkAndNotifyAbnormalVitals(pulse, systolic, diastolic);

      // Check for achievement unlocks
      _checkAchievementProgress(progressBefore);
    } catch (e) {
      _saveState = Result.error(e.toString());
      notifyListeners();
    }
  }

  void _checkAchievementProgress(AchievementProgress progressBefore) async {
    final progressAfter = AchievementService.calculateProgress(
      entriesForCurrentDevice,
    );
    final notificationService = NotificationService();

    // Check for rank up
    if (progressAfter.currentRank != progressBefore.currentRank) {
      final rankInfo = AchievementService.getRankInfo(
        progressAfter.currentRank,
      );
      await notificationService.showRankUpNotification(rankInfo.title);

      // Emit rank up event for in-app notification
      _rankUpController.add(rankInfo);
    }

    // Check for new achievements
    final achievementsBefore = AchievementService.updateAchievements(
      AchievementService.getAllAchievements(),
      progressBefore,
    );
    final achievementsAfter = AchievementService.updateAchievements(
      AchievementService.getAllAchievements(),
      progressAfter,
    );

    for (int i = 0; i < achievementsAfter.length; i++) {
      if (achievementsAfter[i].unlocked && !achievementsBefore[i].unlocked) {
        await notificationService.showAchievementUnlockedNotification(
          achievementsAfter[i].title,
          achievementsAfter[i].description,
        );

        // Emit achievement unlock event for in-app notification
        _achievementUnlockedController.add(achievementsAfter[i]);
      }
    }
  }

  void _checkAndNotifyAbnormalVitals(
    int pulse,
    int systolic,
    int diastolic,
  ) async {
    final notificationService = NotificationService();

    // Check for critical pulse
    if (pulse > 120 || pulse < 50) {
      await notificationService.showCriticalAlertNotification(
        'Pulse rate: $pulse BPM - Outside normal range',
      );
      return;
    }

    // Check for high blood pressure
    if (systolic >= 140 || diastolic >= 90) {
      await notificationService.showCriticalAlertNotification(
        'Blood pressure: $systolic/$diastolic mmHg - Hypertension detected',
      );
      return;
    }

    // Check for low blood pressure
    if (systolic < 90 || diastolic < 60) {
      await notificationService.showCriticalAlertNotification(
        'Blood pressure: $systolic/$diastolic mmHg - Hypotension detected',
      );
    }
  }

  Future<void> deleteEntry(String id) async {
    _deleteState = Result.loading();
    notifyListeners();

    try {
      await _firestoreRepo.deleteEntry(id);
      _deleteState = Result.success(null);
      notifyListeners();
    } catch (e) {
      _deleteState = Result.error(e.toString());
      notifyListeners();
    }
  }

  Future<void> updateEntry(HealthEntry entry) async {
    _updateState = Result.loading();
    notifyListeners();

    try {
      if (!entry.isValid) {
        _updateState = Result.error('Invalid health values');
        notifyListeners();
        return;
      }

      await _firestoreRepo.updateEntry(entry);
      _updateState = Result.success(null);
      notifyListeners();
    } catch (e) {
      _updateState = Result.error(e.toString());
      notifyListeners();
    }
  }

  HealthAnalysis analyzeHealth() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentEntries = entriesForCurrentDevice
        .where((entry) => entry.timestamp.isAfter(thirtyDaysAgo))
        .toList();

    if (recentEntries.isEmpty) {
      return HealthAnalysis(
        pulseCategory: 'No Data',
        pulseDescription: 'Not enough data to analyze pulse rate.',
        pulseNeedsAttention: false,
        bloodPressureCategory: 'No Data',
        bloodPressureDescription: 'Not enough data to analyze blood pressure.',
        bloodPressureNeedsAttention: false,
        avgPulse: 0,
        avgSystolic: 0,
        avgDiastolic: 0,
        entriesAnalyzed: 0,
        recommendDoctorVisit: false,
      );
    }

    final avgPulse =
        recentEntries.map((e) => e.pulse).reduce((a, b) => a + b) /
        recentEntries.length;
    final avgSystolic =
        recentEntries.map((e) => e.systolic).reduce((a, b) => a + b) /
        recentEntries.length;
    final avgDiastolic =
        recentEntries.map((e) => e.diastolic).reduce((a, b) => a + b) /
        recentEntries.length;

    // Pulse analysis
    String pulseCategory;
    String pulseDescription;
    bool pulseNeedsAttention;

    if (avgPulse < 60) {
      pulseCategory = 'Low (Bradycardia)';
      pulseDescription =
          'Your average pulse is below 60 bpm. This may be normal for athletes, but consult a doctor if you experience dizziness or fatigue.';
      pulseNeedsAttention = true;
    } else if (avgPulse >= 60 && avgPulse <= 100) {
      pulseCategory = 'Normal';
      pulseDescription =
          'Your average pulse is within the normal range (60-100 bpm). Keep up the good work!';
      pulseNeedsAttention = false;
    } else {
      pulseCategory = 'High (Tachycardia)';
      pulseDescription =
          'Your average pulse is above 100 bpm. This could indicate stress, dehydration, or a medical condition. Please consult a doctor.';
      pulseNeedsAttention = true;
    }

    // Blood pressure analysis
    String bpCategory;
    String bpDescription;
    bool bpNeedsAttention;

    if (avgSystolic < 120 && avgDiastolic < 80) {
      bpCategory = 'Normal';
      bpDescription =
          'Your blood pressure is within the normal range. Continue maintaining a healthy lifestyle.';
      bpNeedsAttention = false;
    } else if (avgSystolic >= 120 && avgSystolic < 130 && avgDiastolic < 80) {
      bpCategory = 'Elevated';
      bpDescription =
          'Your blood pressure is elevated. Consider lifestyle changes like diet and exercise to prevent hypertension.';
      bpNeedsAttention = true;
    } else if ((avgSystolic >= 130 && avgSystolic < 140) ||
        (avgDiastolic >= 80 && avgDiastolic < 90)) {
      bpCategory = 'Stage 1 Hypertension';
      bpDescription =
          'You have stage 1 hypertension. Lifestyle changes and possibly medication may be needed. Consult your doctor.';
      bpNeedsAttention = true;
    } else if (avgSystolic >= 140 || avgDiastolic >= 90) {
      bpCategory = 'Stage 2 Hypertension';
      bpDescription =
          'You have stage 2 hypertension. This requires medical attention. Please schedule an appointment with your doctor soon.';
      bpNeedsAttention = true;
    } else {
      bpCategory = 'Low';
      bpDescription =
          'Your blood pressure may be too low. If you experience symptoms like dizziness, consult a doctor.';
      bpNeedsAttention = true;
    }

    return HealthAnalysis(
      pulseCategory: pulseCategory,
      pulseDescription: pulseDescription,
      pulseNeedsAttention: pulseNeedsAttention,
      bloodPressureCategory: bpCategory,
      bloodPressureDescription: bpDescription,
      bloodPressureNeedsAttention: bpNeedsAttention,
      avgPulse: avgPulse,
      avgSystolic: avgSystolic,
      avgDiastolic: avgDiastolic,
      entriesAnalyzed: recentEntries.length,
      recommendDoctorVisit: pulseNeedsAttention || bpNeedsAttention,
    );
  }

  Future<void> syncFromDevice({int daysBack = 7}) async {
    if (!isHealthPlatformSupported || !_healthAuthorized) {
      _syncState = Result.error(
        'Health permissions not granted or platform not supported',
      );
      notifyListeners();
      return;
    }

    _syncState = Result.loading();
    notifyListeners();

    try {
      final end = DateTime.now();
      final start = end.subtract(Duration(days: daysBack));

      final deviceEntries = await _deviceHealthRepo.readHealthData(start, end);
      final firestoreEntries = await _firestoreRepo.getEntriesInRange(
        start,
        end,
      );

      final entriesToSync = _filterNewEntries(deviceEntries, firestoreEntries);

      for (final entry in entriesToSync) {
        // When syncing from device, we don't know the original deviceId, so we assign the current one.
        await _firestoreRepo.addEntry(entry.copyWith(deviceId: _deviceId));
      }

      _syncState = Result.success(null);
      notifyListeners();
    } catch (e) {
      _syncState = Result.error(e.toString());
      notifyListeners();
    }
  }

  List<HealthEntry> _filterNewEntries(
    List<HealthEntry> deviceEntries,
    List<HealthEntry> firestoreEntries,
  ) {
    return deviceEntries.where((deviceEntry) {
      return !firestoreEntries.any(
        (firestoreEntry) => _isSameEntry(deviceEntry, firestoreEntry),
      );
    }).toList();
  }

  bool _isSameEntry(HealthEntry a, HealthEntry b) {
    final timeDiff = a.timestamp.difference(b.timestamp).abs();
    return a.pulse == b.pulse &&
        a.systolic == b.systolic &&
        a.diastolic == b.diastolic &&
        timeDiff.inMinutes < 2;
  }

  HealthStatistics calculateStatistics() {
    final now = DateTime.now();
    final entries = entriesForCurrentDevice;

    if (entries.isEmpty) {
      return HealthStatistics(
        weekComparison: WeekComparison(
          thisWeekAvgPulse: 0,
          lastWeekAvgPulse: 0,
          thisWeekAvgSystolic: 0,
          lastWeekAvgSystolic: 0,
          thisWeekAvgDiastolic: 0,
          lastWeekAvgDiastolic: 0,
          thisWeekEntries: 0,
          lastWeekEntries: 0,
        ),
        records: VitalRecords(
          maxPulse: 0,
          minPulse: 999,
          maxSystolic: 0,
          minSystolic: 999,
          maxDiastolic: 0,
          minDiastolic: 999,
        ),
        improvements: [],
      );
    }

    // Week comparison
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    final thisWeekEntries = entries
        .where(
          (e) => e.timestamp.isAfter(
            thisWeekStart.subtract(const Duration(days: 1)),
          ),
        )
        .toList();
    final lastWeekEntries = entries
        .where(
          (e) =>
              e.timestamp.isAfter(
                lastWeekStart.subtract(const Duration(days: 1)),
              ) &&
              e.timestamp.isBefore(lastWeekEnd),
        )
        .toList();

    final weekComparison = WeekComparison(
      thisWeekAvgPulse: thisWeekEntries.isEmpty
          ? 0
          : thisWeekEntries.map((e) => e.pulse).reduce((a, b) => a + b) /
                thisWeekEntries.length,
      lastWeekAvgPulse: lastWeekEntries.isEmpty
          ? 0
          : lastWeekEntries.map((e) => e.pulse).reduce((a, b) => a + b) /
                lastWeekEntries.length,
      thisWeekAvgSystolic: thisWeekEntries.isEmpty
          ? 0
          : thisWeekEntries.map((e) => e.systolic).reduce((a, b) => a + b) /
                thisWeekEntries.length,
      lastWeekAvgSystolic: lastWeekEntries.isEmpty
          ? 0
          : lastWeekEntries.map((e) => e.systolic).reduce((a, b) => a + b) /
                lastWeekEntries.length,
      thisWeekAvgDiastolic: thisWeekEntries.isEmpty
          ? 0
          : thisWeekEntries.map((e) => e.diastolic).reduce((a, b) => a + b) /
                thisWeekEntries.length,
      lastWeekAvgDiastolic: lastWeekEntries.isEmpty
          ? 0
          : lastWeekEntries.map((e) => e.diastolic).reduce((a, b) => a + b) /
                lastWeekEntries.length,
      thisWeekEntries: thisWeekEntries.length,
      lastWeekEntries: lastWeekEntries.length,
    );

    // Records
    final pulses = entries.map((e) => e.pulse).toList();
    final systolics = entries.map((e) => e.systolic).toList();
    final diastolics = entries.map((e) => e.diastolic).toList();

    final maxPulse = pulses.reduce((a, b) => a > b ? a : b);
    final minPulse = pulses.reduce((a, b) => a < b ? a : b);
    final maxSystolic = systolics.reduce((a, b) => a > b ? a : b);
    final minSystolic = systolics.reduce((a, b) => a < b ? a : b);
    final maxDiastolic = diastolics.reduce((a, b) => a > b ? a : b);
    final minDiastolic = diastolics.reduce((a, b) => a < b ? a : b);

    final records = VitalRecords(
      maxPulse: maxPulse,
      minPulse: minPulse,
      maxSystolic: maxSystolic,
      minSystolic: minSystolic,
      maxDiastolic: maxDiastolic,
      minDiastolic: minDiastolic,
      maxPulseDate: entries.firstWhere((e) => e.pulse == maxPulse).timestamp,
      minPulseDate: entries.firstWhere((e) => e.pulse == minPulse).timestamp,
      maxSystolicDate: entries
          .firstWhere((e) => e.systolic == maxSystolic)
          .timestamp,
      minSystolicDate: entries
          .firstWhere((e) => e.systolic == minSystolic)
          .timestamp,
      maxDiastolicDate: entries
          .firstWhere((e) => e.diastolic == maxDiastolic)
          .timestamp,
      minDiastolicDate: entries
          .firstWhere((e) => e.diastolic == minDiastolic)
          .timestamp,
    );

    // Improvements
    final improvements = <HealthImprovement>[];

    if (weekComparison.hasData &&
        weekComparison.thisWeekEntries > 0 &&
        weekComparison.lastWeekEntries > 0) {
      // Pulse improvement
      if (weekComparison.pulseDifference.abs() >= 2) {
        final isPositive = weekComparison.pulseDifference < 0;
        improvements.add(
          HealthImprovement(
            metric: 'PULSE RATE',
            improvement: weekComparison.pulseDifference.abs(),
            description: isPositive
                ? 'Resting pulse decreased ${weekComparison.pulseDifference.abs().toStringAsFixed(1)} BPM'
                : 'Resting pulse increased ${weekComparison.pulseDifference.abs().toStringAsFixed(1)} BPM',
            isPositive: isPositive,
          ),
        );
      }

      // Systolic improvement
      if (weekComparison.systolicDifference.abs() >= 3) {
        final isPositive = weekComparison.systolicDifference < 0;
        improvements.add(
          HealthImprovement(
            metric: 'SYSTOLIC BP',
            improvement: weekComparison.systolicDifference.abs(),
            description: isPositive
                ? 'Systolic pressure decreased ${weekComparison.systolicDifference.abs().toStringAsFixed(1)} mmHg'
                : 'Systolic pressure increased ${weekComparison.systolicDifference.abs().toStringAsFixed(1)} mmHg',
            isPositive: isPositive,
          ),
        );
      }

      // Diastolic improvement
      if (weekComparison.diastolicDifference.abs() >= 3) {
        final isPositive = weekComparison.diastolicDifference < 0;
        improvements.add(
          HealthImprovement(
            metric: 'DIASTOLIC BP',
            improvement: weekComparison.diastolicDifference.abs(),
            description: isPositive
                ? 'Diastolic pressure decreased ${weekComparison.diastolicDifference.abs().toStringAsFixed(1)} mmHg'
                : 'Diastolic pressure increased ${weekComparison.diastolicDifference.abs().toStringAsFixed(1)} mmHg',
            isPositive: isPositive,
          ),
        );
      }
    }

    return HealthStatistics(
      weekComparison: weekComparison,
      records: records,
      improvements: improvements,
    );
  }

  void resetSaveState() {
    _saveState = Result.idle();
    notifyListeners();
  }

  void resetDeleteState() {
    _deleteState = Result.idle();
    notifyListeners();
  }

  void resetSyncState() {
    _syncState = Result.idle();
    notifyListeners();
  }

  void resetUpdateState() {
    _updateState = Result.idle();
    notifyListeners();
  }

  @override
  void dispose() {
    _entriesSubscription?.cancel();
    _achievementUnlockedController.close();
    _rankUpController.close();
    super.dispose();
  }
}
