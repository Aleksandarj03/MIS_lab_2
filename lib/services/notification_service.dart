import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  bool _initialized = false;
  Timer? _dailyNotificationTimer;

  static const String _notificationEnabledKey = 'notification_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';
  static const String _testModeKey = 'notification_test_mode';

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

        _initialized = true;
        await scheduleDailyNotification();
      }
    } catch (e) {
      debugPrint('Notification service initialization error: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showLocalNotification(
      title: message.notification?.title ?? 'New Recipe',
      body: message.notification?.body ?? 'Check out today\'s recipe!',
      payload: message.data['recipeId'],
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'recipe_channel',
      'Recipe Notifications',
      channelDescription: 'Notifications for daily recipe suggestions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  Future<void> scheduleDailyNotification() async {
    _dailyNotificationTimer?.cancel();

    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_notificationEnabledKey) ?? true;
    final testMode = prefs.getBool(_testModeKey) ?? false;

    if (!enabled) return;

    int hour = prefs.getInt(_notificationHourKey) ?? 18;
    int minute = prefs.getInt(_notificationMinuteKey) ?? 0;

    if (testMode) {
      _scheduleTestNotification();
      return;
    }

    _scheduleDailyAt(hour, minute);
  }

  void _scheduleTestNotification() {
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));
    _dailyNotificationTimer = Timer(
      const Duration(seconds: 10),
      () async {
        await _sendDailyRecipeNotification();
        final prefs = await SharedPreferences.getInstance();
        final testMode = prefs.getBool(_testModeKey) ?? false;
        if (testMode) {
          _scheduleTestNotification();
        } else {
          await scheduleDailyNotification();
        }
      },
    );
  }

  void _scheduleDailyAt(int hour, int minute) {
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final duration = scheduledTime.difference(now);

    _dailyNotificationTimer = Timer(duration, () async {
      await _sendDailyRecipeNotification();
      _scheduleDailyAt(hour, minute);
    });
  }

  Future<void> _sendDailyRecipeNotification() async {
    try {
      final recipe = await _apiService.getRandomRecipe();
      if (recipe != null) {
        await _showLocalNotification(
          title: 'Recipe of the Day',
          body: 'Check out ${recipe.strMeal}!',
          payload: recipe.idMeal,
        );
      }
    } catch (e) {
    }
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
    if (enabled) {
      await scheduleDailyNotification();
    } else {
      _dailyNotificationTimer?.cancel();
    }
  }

  Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_notificationHourKey, hour);
    await prefs.setInt(_notificationMinuteKey, minute);
    await scheduleDailyNotification();
  }

  Future<void> setTestMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_testModeKey, enabled);
    await scheduleDailyNotification();
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_notificationEnabledKey) ?? true,
      'hour': prefs.getInt(_notificationHourKey) ?? 18,
      'minute': prefs.getInt(_notificationMinuteKey) ?? 0,
      'testMode': prefs.getBool(_testModeKey) ?? false,
    };
  }

  void dispose() {
    _dailyNotificationTimer?.cancel();
  }
}

