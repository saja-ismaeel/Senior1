import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();

    // Subscribe to a topic for FCM
    _firebaseMessaging.subscribeToTopic('orders');

    // Configure Firebase Cloud Messaging
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");
      // Handle incoming messages here
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: $message");
      // Handle when the app is open and the user taps on the notification
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders Page'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              // Replace with logic to fetch and display Load Cells readings
              // from 'Containers Reading' collection
              _firestore
                  .collection('Containers Reading')
                  .doc('firstContainer')
                  .get()
                  .then((DocumentSnapshot documentSnapshot) {
                if (documentSnapshot.exists) {
                  print('Load Cells Reading: ${documentSnapshot.data()}');
                } else {
                  print('Document does not exist');
                }
              });
            },
            child: Text('Fetch Load Cells Reading'),
          ),
          ElevatedButton(
            onPressed: () {
              // Replace with logic to fetch and display selectedDateTime
              // from 'orders' collection
              _firestore
                  .collection('orders')
                  .doc('selectedDateTime')
                  .get()
                  .then((DocumentSnapshot documentSnapshot) {
                if (documentSnapshot.exists) {
                  print('Selected DateTime: ${documentSnapshot.data()}');
                  // Add logic to open the servo motor based on the fetched time
                } else {
                  print('Document does not exist');
                }
              });
            },
            child: Text('Fetch Selected DateTime'),
          ),
        ],
      ),
    );
  }
}
