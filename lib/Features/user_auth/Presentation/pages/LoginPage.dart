import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/AdminHome.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/SignUpPage.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/mangerHome.dart';
import 'package:senior1/Features/user_auth/Presentation/widgets/form_container_widget.dart';
import 'package:senior1/Features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:senior1/global/common/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isSigning = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Colors.pink,
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Login",
              style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30,
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
              onTap: _signIn,
              child: Container(
                  width: double.infinity,
                  height: 45,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: _isSigning
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Login",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ))),
            ),
          ],
        ),
      )),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    print("Attempting to sign in with email: $email");

    User? user = await _auth.signInWithEmailAndPassword(email, password);

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print("User signed in successfully: ${user.uid}");

      // Retrieve user role from Firestore
      String userRole = await _auth.getUserRole(user.uid);

      print("User role: $userRole");

      showToast(message: "User is successfully signed in");

      if (userRole == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (userRole == "manager") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerHome()),
        );
      } else {
        showToast(message: "Unknown user role");
      }
    } else {
      print("Sign-in failed");
      showToast(message: "Some error occurred");
    }
  }
}
