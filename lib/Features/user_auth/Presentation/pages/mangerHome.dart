import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/ErrorPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/UsersPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/LoginPage.dart';
import '../../../../global/common/toast.dart';

class ManagerHome extends StatefulWidget {
  const ManagerHome({super.key});

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  String? username;
  String? role;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            username = userData['username'];
            role = userData['role'];
          });

          // Check if the role is "manager"
          if (role != null && role == 'manager') {
            // Continue with the usual logic
          } else {
            // Redirect to an error page or handle unauthorized access
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

  Widget _buildButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 240,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        automaticallyImplyLeading: false,
        title: Text("Manager Home Page"),
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
              "Welcome, $username",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ),
          SizedBox(height: 30),
          _buildButton("Create new employee account ", () {
            Navigator.pushNamed(context, '/signUp');
          }),
          SizedBox(height: 30),
          _buildButton("Completed Orders", () {
            Navigator.pushNamed(context, '/completedOrders');
          }),
          SizedBox(height: 30),
          _buildButton("View Admins Details", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UsersPage()),
            );
          }),
        ],
      ),
    );
  }
  Future<bool> showSignOutConfirmationDialog(BuildContext context) async {
    return await showDialog(
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