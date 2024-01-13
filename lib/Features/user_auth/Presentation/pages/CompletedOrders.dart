import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersCompletedPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Completed Orders"),
        backgroundColor: Colors.pink,
      ),
      body: FutureBuilder(
        future: _getCompletedOrders(),
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No completed orders found."));
          } else {
            List<DocumentSnapshot> completedOrders = snapshot.data!;
            return ListView.builder(
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderListItem(completedOrders[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderListItem(DocumentSnapshot orderSnapshot) {
    Map<String, dynamic> orderData = orderSnapshot.data() as Map<String, dynamic>;

    String selectedTime(Timestamp? timeStamp) {
      if (timeStamp == null) {
        return 'N/A';
      }
      DateTime dataFromTimeStamp = timeStamp.toDate();
      return DateFormat('hh:mm a').format(dataFromTimeStamp);
    }

    String selectedDate(Timestamp? timeStamp) {
      if (timeStamp == null) {
        return 'N/A';
      }
      DateTime dataFromTimeStamp = timeStamp.toDate();
      return DateFormat('dd-MM-yyyy').format(dataFromTimeStamp);
    }

    // double roofDepth = orderData['roofDepth'] ?? 0.0;
    // double roofLength = orderData['roofLength'] ?? 0.0;
    // double roofWidth = orderData['roofWidth'] ?? 0.0;
    // double concreteStrength = orderData['concreteStrength'] ?? 0.0;

    double roofDepth = (orderData['roofDepth'] ?? 0).toDouble();
    double roofLength = (orderData['roofLength'] ?? 0).toDouble();

    double roofWidth = (orderData['roofWidth'] ?? 0).toDouble();
    double concreteStrength = (orderData['concreteStrength'] ?? 0).toDouble();


    // Extract the order date and time
    DateTime orderDateTime = orderData['selectedDateTime'].toDate();

    return FutureBuilder(
      future: _getUserData(orderData['userId']),
      builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
        // if (userSnapshot.connectionState == ConnectionState.waiting) {
        //   return Center(
        //     child: CircularProgressIndicator(),
        //   );
        //
        // } else
         if (userSnapshot.hasError) {
          return Text("Error: ${userSnapshot.error}");
        } else {
          Map<String, dynamic>? userData = userSnapshot.data?.data() as Map<String, dynamic>?;

          // Handle the case when userData is null
          userData ??= {'username': 'Unknown User'};

          return ListTile(
            title: Text("Customer: ${orderData['customerName']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Time: "),
                    Text(selectedDate(orderData['selectedDateTime'])),
                  ],
                ),
                Row(
                  children: [
                    Text("Date: "),
                    Text(selectedTime(orderData['selectedDateTime'])),
                  ],
                ),
                Text('Concrete Strength: $concreteStrength'),
                Text('Roof Depth: $roofDepth'),
                Text('Roof Length: $roofLength'),
                Text('Roof Width: $roofWidth'),
                Text('Added By: ${userData['username']}'),
              ],
            ),
          );
        }
      },
    );
  }

  Future<DocumentSnapshot> _getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print("Error fetching user data: $e");
      throw e;
    }
  }

  Future<List<DocumentSnapshot>> _getCompletedOrders() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('Orders Completed').get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error fetching completed orders: $e");
      throw e;
    }
  }
}
