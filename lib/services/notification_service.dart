import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _local = FlutterLocalNotificationsPlugin();

  static const _channelId = 'pm_alerts_high';
  static const _channelName = 'PM Alerts (High Priority)';
  static const _channelDesc = 'Alerts when PM2.5/PM10 becomes unhealthy';

  static Future<void> init() async {
    // Ask permission (iOS + Android 13+)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,);
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    // await _local.initialize(initSettings);
    await _local.initialize(
      settings: initSettings,
      // optional:
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // handle notification tap if you want
      },
    );


    // Android notification channel with alarm sound
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
    );

    final androidPlugin =
        _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);

    // If FCM arrives while app is open, show it as a local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await showFromFCM(message);
    });
  }

  static Future<void> showAlarm({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm'),
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(sound: 'alarm.aiff');

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails:
          const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  static Future<void> showFromFCM(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Air alert';
    final body = message.notification?.body ?? 'PM changed';
    await showAlarm(title: title, body: body);
  }
}


