import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for managing foreground notifications during timer execution.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  static const String _channelId = 'timer_channel';
  static const String _channelName = 'Timer Notifications';
  static const int _notificationId = 1;

  /// Initialize the notification service.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Shows timer progress while running',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Show or update the timer notification.
  Future<void> showTimerNotification({
    required String planName,
    required String elapsedTime,
    String? remainingTime,
    required bool isRunning,
  }) async {
    if (!_initialized) await initialize();

    final String contentText = remainingTime != null
        ? 'Elapsed: $elapsedTime | Remaining: $remainingTime'
        : 'Elapsed: $elapsedTime';

    final String statusIcon = isRunning ? '▶️' : '⏸️';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows timer progress while running',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      styleInformation: BigTextStyleInformation(contentText),
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      '$statusIcon $planName',
      contentText,
      notificationDetails,
    );
  }

  /// Cancel the timer notification.
  Future<void> cancelTimerNotification() async {
    await _notifications.cancel(_notificationId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
