import 'package:flutter/material.dart';
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

    // Request notification permissions for Android 13+
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      
      // Create notification channel for Android
      const androidChannel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Shows timer progress while running',
        importance: Importance.high,
        playSound: false,
        enableVibration: false,
        showBadge: true,
      );

      await androidPlugin.createNotificationChannel(androidChannel);
    }

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

    final String statusText = isRunning ? 'Running' : 'Paused';
    
    // Build rich notification content
    final inboxLines = <String>[];
    inboxLines.add('Elapsed: $elapsedTime');
    if (remainingTime != null) {
      inboxLines.add('Remaining: $remainingTime');
    }
    inboxLines.add('Status: $statusText');

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows timer progress while running',
      importance: Importance.high,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      playSound: false,
      enableVibration: false,
      styleInformation: InboxStyleInformation(
        inboxLines,
        contentTitle: planName,
        summaryText: 'RidePulse Timer',
      ),
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFF00D9FF),
      colorized: true,
      category: AndroidNotificationCategory.workout,
      visibility: NotificationVisibility.public,
      subText: statusText,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
      categoryIdentifier: 'timer',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _notificationId,
      planName,
      '$elapsedTime${remainingTime != null ? ' | $remainingTime' : ''} • $statusText',
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
