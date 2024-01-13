//
// import 'dart:async';
//
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:senior1/main.dart';
// import 'package:senior1/services/notifications_service.dart';
//
// class BackGroundNotificationService {
//   static Future<void> initializeService() async {
//     final service = FlutterBackgroundService();
//
//     await service.configure(
//         iosConfiguration: IosConfiguration(
//           autoStart: false,
//         ),
//         androidConfiguration: AndroidConfiguration(
//           onStart: onStart,
//           isForegroundMode: true,
//           // foregroundServiceNotificationId: 1,
//           autoStart: true,
//           autoStartOnBoot: true,
//         ));
//   }
//
//   static Future<void> onStart(ServiceInstance service) async {}
//
//
// }
