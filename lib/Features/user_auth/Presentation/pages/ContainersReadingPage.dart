import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainersReadingPage extends StatefulWidget {
  @override
  _ContainersReadingPageState createState() => _ContainersReadingPageState();
}

class _ContainersReadingPageState extends State<ContainersReadingPage> {
  final CollectionReference containersCollection =
  FirebaseFirestore.instance.collection('Containers Reading');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Firebase Data'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: containersCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          // Process the data and display it
          final data = snapshot.data!.docs;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final containerData = data[index].data() as Map<String, dynamic>;

              final firstContainer = containerData['firstContainer'];
              final secondContainer = containerData['secondContainer'];

              return ListTile(
                title: Text('First Container: $firstContainer'),
                subtitle: Text('Second Container: $secondContainer'),

              );
            },
          );
        },
      ),
    );
  }
}