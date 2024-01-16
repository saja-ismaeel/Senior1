import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/CompletedOrders.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/OrderEditPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/OrderList.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/AdminHome.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/LoginPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/mangerHome.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/SignUpPage.dart';
import 'Features/app/splash_screen/splash_screen.dart';
import 'Features/user_auth/Presentation/pages/AddOrderPage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:senior1/services/notifications_service.dart';
import 'Features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {}
}


// Future<String?> getFcmToken() async {
//   final fCMToken = await FirebaseMessaging.instance.getToken();
//   print('Token : $fCMToken');
//
// }

void showTerminatedNotification(String containerName) async {
  var headers = {
    'Content-Type': 'application/json',
    'Authorization':
    'key=AAAAGDBwKP8:APA91bEzGuOJgtz-fxkVD2ZGhDZUGzy3FKdpU8ZZaTIkw0df77KmffS0CRnBwX_ZOwuYKaGUnQeajSbu6TF_F4Q8ZaNY62Fo9E6ff1TtTvXeTDvkS_ZNgzVHRkq_prBVYYJO0tcmURup'
  };
  var request =
  http.Request('POST', Uri.parse('https://fcm.googleapis.com/fcm/send'));
  request.body = jsonEncode({
    // this token should be stored in users model.
    // and this API should be called from a third party software or hardware.
    "to":
    "dpuLjw44SYCk6mI_ni4zd-:APA91bECdAt-FvQOKPXq7JayveVo0wxnwvlicVFeCkBM5oZw0yf3pZiSxCmMeTsjE8gR-r7PsxiAdmZEFLX6goChHRkWJwumqGFmwgQbGEb4AwFiPVeli5Fil6XRbYqE39UVkx4tO1QP",
    "notification": {
      "body": "Quantity has reached 0",
      "title": "$containerName",
    }
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    print(await response.stream.bytesToString());
  } else {
    print(response.reasonPhrase);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationsService();

  final User? user = FirebaseAuth.instance.currentUser;
  // Check if there's a user already logged in
  String? role;

  if (user != null) {
    try {
      DocumentSnapshot<Map<String, dynamic>> userData =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userData.exists) {
        role = userData['role'];
      }
    } catch (e) {
      print('Error getting user role: $e');
    }
  }

  runApp(MyApp(user: user, role: role));
}

class MyApp extends StatelessWidget {
  final User? user;
  final String? role;

  const MyApp({Key? key, required this.user, required this.role})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget homePage;

    if (role == "admin") {
      homePage = HomePage();
    } else if (role == "manager") {
      homePage = ManagerHome();
    } else {
      homePage = LoginPage(); // Default home page for other roles or guests
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      //home: homePage,
      home: SplashScreen(child: homePage),
      routes: {
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/add': (context) => add_order_page(),
        '/list': (context) => OrderListPage(orderId: ''),
        '/order_edit': (context) => OrderEditPage(orderId: ''),
        '/managerHome': (context) => ManagerHome(),
        '/completedOrders': (context) => OrdersCompletedPage(),
      },
    );
  }
}