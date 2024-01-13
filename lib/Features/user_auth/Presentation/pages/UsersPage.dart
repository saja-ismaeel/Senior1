import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Admin Information'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final admins = snapshot.data?.docs
              .where((doc) => doc['role'] == 'admin')
              .toList();

          return ListView.builder(
            itemCount: admins?.length ?? 0,
            itemBuilder: (context, index) {
              final admin = admins![index].data() as Map<String, dynamic>;
              return ListTile(
                  title: Text('Username: ${admin['username']}'),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Email: ${admin['email']}'),
                    Text('Password: ${admin['password']}'),
                  ]));
            },
          );
        },
      ),
    );
  }
}
