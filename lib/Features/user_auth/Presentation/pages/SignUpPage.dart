
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/LoginPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/mangerHome.dart';
import 'package:senior1/Features/user_auth/Presentation/widgets/form_container_widget.dart';
import 'package:senior1/Features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:senior1/global/common/toast.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        automaticallyImplyLeading: false,
        title: Text("New Account Page"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create new employee account",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              FormContainerWidget(
                controller: _usernameController,
                hintText: "Username",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 10,
              ),
              FormContainerWidget(
                controller: _passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  _signUp();
                },
                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: isSigningUp ? CircularProgressIndicator(
                        color: Colors.white,) : Text(
                        "Create",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },

                child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                      child: Text(
                        "Home",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ),
              ),

            ],
              ),
        )

          ),

      );

  }

  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      // Create the user using Firebase Authentication
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        // Save all user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'username': username,
          'email': email,
          'password': password, // Note: It's not recommended to store passwords in plaintext in Firestore for security reasons.
          'uid': user.uid,
          'role': "admin",
        });

        showToast(message: "User is successfully created");

        // Clear text fields
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();

      } else {
        showToast(message: "Some error happened");
      }
    } catch (e) {
      showToast(message: "Error during sign-up: $e");
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }
}

