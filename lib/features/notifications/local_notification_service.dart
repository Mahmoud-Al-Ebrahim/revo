import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
class LocalNotificationService {
  static final _localNotificationPlugin = FlutterLocalNotificationsPlugin();

  final String _androidChannelId = r'$_$_1_$_$';
  final String _androidChannelName = "Notification";

  static FlutterLocalNotificationsPlugin get localNotificationPlugin =>
      _localNotificationPlugin;

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('app_icon');


    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotificationPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
            LocalNotificationService().getAndroidChannel);

    await _localNotificationPlugin.initialize(
      settings,
    );
  }

  @pragma('vm:entry-point')
  Future<void> showNotificationWithPayload(
      {required RemoteMessage message}) async {
    await _localNotificationPlugin.show(
        0,
        message.notification?.title.toString(),
        message.notification?.body.toString(),
        _notificationDetails(),
        payload: '');
  }

  _notificationDetails() {
    final channel = LocalNotificationService().getAndroidChannel;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description,
      ticker: 'ticker',
      importance: channel.importance,
      priority: Priority.max,
      playSound: channel.playSound,
      enableVibration: channel.enableVibration,
    );

    return NotificationDetails(
        android: androidNotificationDetails);
  }

  AndroidNotificationChannel get getAndroidChannel =>
      AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName, // title
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
}
