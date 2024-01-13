import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/LoginPage.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
            SizedBox(height: 20),
            Text(
              'Permission Denied',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'You do not have permission to access this page.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Back",
                style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
