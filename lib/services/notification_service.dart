import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showDataSavedNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'health_updates',
      'Health Updates',
      channelDescription: 'Notifications about health data updates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'VITALS STABLE',
      'All systems nominal',
      details,
    );
  }

  Future<void> showCriticalAlertNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'health_alerts',
      'Health Alerts',
      channelDescription: 'Critical health alerts',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      2,
      'ALERT: Abnormal vitals detected',
      message,
      details,
    );
  }

  Future<void> showWeeklyComparisonNotification(String message) async {
    const androidDetails = AndroidNotificationDetails(
      'health_insights',
      'Health Insights',
      channelDescription: 'Weekly health comparisons and insights',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(3, 'WEEKLY ANALYSIS COMPLETE', message, details);
  }

  Future<void> showAchievementUnlockedNotification(
    String title,
    String description,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement unlock notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      4,
      'ACHIEVEMENT UNLOCKED: $title',
      description,
      details,
    );
  }

  Future<void> showRankUpNotification(String rankName) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Achievements',
      channelDescription: 'Achievement unlock notifications',
      importance: Importance.max,
      priority: Priority.max,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      5,
      'RANK PROMOTION',
      'Congratulations! You are now a $rankName',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
