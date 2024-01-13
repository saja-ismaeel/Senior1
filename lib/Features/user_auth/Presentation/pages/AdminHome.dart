import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/CompletedOrders.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/ErrorPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/AddOrderPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/LoginPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/OrdersPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/mangerHome.dart';
import 'package:senior1/main.dart';
import '../../../../global/common/toast.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? username;
  String? role;
  int? firstContainer;
  int? secondContainer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
   //_configureFirebaseMessaging();
    _loadUserData();
  }
  //
  // void _configureFirebaseMessaging() {
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     _handleMessage(message);
  //   });
  //
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     _handleMessage(message);
  //   });
  //
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // }
  //
  // Future<void> _firebaseMessagingBackgroundHandler(
  //     RemoteMessage message) async {
  //   print('A Background message just showed up :  ${message.messageId}');
  // }

  // Future<void> _handleMessage(RemoteMessage message) async {
  //   RemoteNotification? notification = message.notification;
  //   AndroidNotification? android = message.notification?.android;
  //   if (notification != null && android != null) {
  //     flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title,
  //       notification.body,
  //       NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           channel.id,
  //           channel.name,
  //           channelDescription: channel.description,
  //           color: Colors.blue,
  //           playSound: true,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),
  //     );
  //   }
  // }

  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    final CollectionReference containersCollection =
    FirebaseFirestore.instance.collection('Containers Reading');

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (mounted && userData.exists) {
          setState(() {
            username = userData['username'];
            role = userData['role'];
          });

          if (role != null && role == 'admin') {
            containersCollection.snapshots().listen((snapshot) {
              if (snapshot.docs.isNotEmpty) {
                final containerData =
                snapshot.docs[0].data() as Map<String, dynamic>;

                setState(() {
                  firstContainer = containerData['firstContainer'];
                  secondContainer = containerData['secondContainer'];
                });

                checkContainersAndNotify();
              }
            });
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ErrorPage()),
            );
          }
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  void checkContainersAndNotify() {
    if (firstContainer == 0) {
      showTerminatedNotification("First Container");
    }

    if (secondContainer == 0) {
      showTerminatedNotification("Second Container");
    }
  }


  // void showNotification(String containerName) {
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     "$containerName",
  //     "Quantity has reached 0",
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         channelDescription: channel.description,
  //         importance: Importance.high,
  //         color: Colors.blue,
  //         playSound: true,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text("Admin Home Page"),
        actions: [
          IconButton(
            onPressed: () async {
              // Show a dialog to confirm the sign-out
              bool confirmed = await showSignOutConfirmationDialog(context);

              if (confirmed) {
                // User confirmed sign-out, perform the sign-out
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
                showToast(message: "Successfully signed out");
              }
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Welcome, ${username ?? 'Guest'}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          SizedBox(height: 30),
          Column(
            children: [

              Text(

                'First Container: ${firstContainer ?? 'N/A'}',
                style: TextStyle(
                  color: (firstContainer == 0 || firstContainer == null) ? Colors.red : Colors.green,
                ),
              ),
              Text(
                'Second Container: ${secondContainer ?? 'N/A'}',
                style: TextStyle(
                  color: (secondContainer == 0 || secondContainer == null) ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 30),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildGestureDetector("Add Order", () {
                  print("Tapped Add Order!");
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => add_order_page()),
                        (route) => false,
                  );
                }),

                SizedBox(width: 20),
                _buildGestureDetector("Orders", () {
                  Navigator.pushNamed(context, '/list');
                }),
              ],
            ),
          ),


        ],
      ),
    );
  }
// Helper method to show a sign-out confirmation dialog
  Future<bool> showSignOutConfirmationDialog(BuildContext context) async {
    return await gshowDialo(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sign Out"),
          content: Text("Are you sure you want to sign out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("Sign Out"),
            ),
          ],
        );
      },
    );
  }
}
  GestureDetector _buildGestureDetector(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 120,
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
