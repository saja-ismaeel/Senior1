import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService with ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationsService() {
    _initCustomChannel();
    _requestPermission();
    _initializeFirebaseMessaging();
  }

  Future<void> _initCustomChannel() async {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _initializeFirebaseMessaging() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // get information from message
      String? title = message.notification?.title;
      String? body = message.notification?.body;
      simpleNotificationShow(title: title, body: body);
    });
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> simpleNotificationShow({title = '', body = ''}) async {
    AndroidNotificationDetails androidNotificationDetails =
    const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      priority: Priority.high,
      importance: Importance.max,
      icon: 'mipmap/ic_launcher',
      channelShowBadge: true,
      autoCancel: true,
    );

    NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.show(
        Random().nextInt(1000000000), title, body, notificationDetails);
  }
}
