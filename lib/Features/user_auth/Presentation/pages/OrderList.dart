import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/OrderEditPage.dart';
import 'package:senior1/global/common/toast.dart';
import 'dart:async';

class OrderListPage extends StatefulWidget {
  final String orderId;

  const OrderListPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  final CollectionReference containersCollection =
      FirebaseFirestore.instance.collection('Containers Reading');
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    // Set up a periodic timer to check values every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _checkContainerAndOrderValues();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order List'),
        backgroundColor: Colors.pink,
      ),
      body: OrderList(),
    );
  }
}

Future<void> _checkContainerAndOrderValues() async {
  try {
    // Fetch all orders
    QuerySnapshot ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();

    for (QueryDocumentSnapshot orderDocument in ordersSnapshot.docs) {
      String orderId = orderDocument.id;

      // Compare values and move order if necessary
     // await _compareContainerAndOrderValues(orderId);
    }
  } catch (e) {
    print('Error checking container and order values: $e');
  }
}

Future<Map<String, dynamic>> _fetchContainerValues() async {
  try {
    DocumentSnapshot containerSnapshot = await FirebaseFirestore.instance
        .collection('Containers Reading')
        .doc('PNpVeidEoiqbnKqZYUPm')
        .get();

    if (containerSnapshot.exists) {
      return containerSnapshot.data() as Map<String, dynamic>;
    } else {
      // Handle the case where the container document does not exist
      print('Warning: Container document not found ');

      return {};
    }
  } catch (e) {
    // Handle the error fetching container values
    print('Error fetching container values: $e');
    return {};
  }
}

Future<Map<String, dynamic>> _fetchOrderValues(String orderId) async {
  try {
    DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (orderSnapshot.exists) {
      return orderSnapshot.data() as Map<String, dynamic>;
    } else {
      // Handle the case where the order document does not exist
      print('Warning: Container document not found for orderId: $orderId');
      return {};
    }
  } catch (e) {
    // Handle the error fetching order values
    print('Error fetching order values: $e');
    return {};
  }
}

Future<void> _compareContainerAndOrderValues(String orderId) async {
  try {
    // Fetch container values
    Map<String, dynamic> containerData = await _fetchContainerValues();

    // Fetch order values
    Map<String, dynamic> orderData = await _fetchOrderValues(orderId);
    String customerName = orderData['customerName'];
    // Extract relevant values for comparison
    double firstContainerReading =
        (containerData['firstContainer'] ?? 0).toDouble();
    double secondContainerReading =
        (containerData['secondContainer'] ?? 0).toDouble();

    double orderFirstContainer = (orderData['firstContainer'] ?? 0).toDouble();
    double orderSecondContainer =
        (orderData['secondContainer'] ?? 0).toDouble();

    // Check if container values are greater than or equal to order values
    bool isContainerValuesValid =
        firstContainerReading >= orderFirstContainer &&
            secondContainerReading >= orderSecondContainer;

    if (isContainerValuesValid) {
      // Update the Firestore document
      await _moveOrderToCompleted(orderId, orderData);
    } else {
      showToast(
          message:
              'Container values are not valid for customer name: $customerName');
    }
  } catch (e) {
    // Handle the error in the comparison process
    print('Error comparing container and order values: $e');
  }
}

class OrderList extends StatelessWidget {
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('selectedDateTime',
              descending: false) // Order by date and time
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.data?.docs.isEmpty ?? true) {
          return Center(
            child: Text('No orders available.'),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var orderData =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String orderId = snapshot.data!.docs[index].id;

            // Check if the current user is the creator of the order
            bool isCurrentUserOrder =
                FirebaseAuth.instance.currentUser?.uid == orderData['userId'];
            // Extract more details from the orderData
            String customerName = orderData['customerName'] ?? '';

            //DateTime? selectedDate = (orderData['selectedDate'] as Timestamp?)?.toDate();

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

            double roofDepth = orderData['roofDepth'] is int
                ? (orderData['roofDepth'] as int).toDouble()
                : orderData['roofDepth'] ?? 0.0;

            double roofLength = orderData['roofLength'] is int
                ? (orderData['roofLength'] as int).toDouble()
                : orderData['roofLength'] ?? 0.0;

            double roofWidth = orderData['roofWidth'] is int
                ? (orderData['roofWidth'] as int).toDouble()
                : orderData['roofWidth'] ?? 0.0;

            double concreteStrength = orderData['concreteStrength'] is int
                ? (orderData['concreteStrength'] as int).toDouble()
                : orderData['concreteStrength'] ?? 0.0;

            // Extract the order date and time
            DateTime orderDateTime = orderData['selectedDateTime'].toDate();
            // Check if the order date and time are equal to the current date and time
            DateTime NowDateTime = DateTime.now();
            bool isOrderInProgress = false;
            if (NowDateTime.year == orderDateTime.year &&
                NowDateTime.month == orderDateTime.month &&
                NowDateTime.day == orderDateTime.day &&
                NowDateTime.hour == orderDateTime.hour &&
                NowDateTime.minute == orderDateTime.minute) {
              isOrderInProgress = true;
            }
            print('NowDateTime: $NowDateTime');
            print('orderDateTime: $orderDateTime');
            print('isOrderInProgress: $isOrderInProgress');
            if (isOrderInProgress==true) {
              _compareContainerAndOrderValues(orderId);
            }
            else{
              isOrderInProgress=false;
            }
            return ListTile(
              title: Text('Customer: $customerName'),
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
                ],
              ),
              onTap: () {
                if (isCurrentUserOrder) {
                  // Navigate to the editing screen with the orderId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderEditPage(orderId: orderId),
                    ),
                  );
                }
              },
              trailing: isCurrentUserOrder
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        // Show a confirmation dialog before deleting
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete Order"),
                              content: Text(
                                  "Are you sure you want to delete this order?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Call a function to delete the order
                                    await _deleteOrder(orderId);

                                    Navigator.pop(context); // Close the dialog
                                  },
                                  child: Text("Delete"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    )
                  : null, // Disable delete button if the current user is not the creator

              // Change the background color if the order is in progress
              tileColor: isOrderInProgress ? Colors.green : null,
            );
          },
        );
      },
    );
  }
}

Future<void> _deleteOrder(String orderId) async {
  try {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    // Optionally, you can add a snackbar or toast to indicate successful deletion.
  } catch (e) {
    // Handle the case where the delete operation fails
    print('Error deleting order: $e');
    // Optionally, show an error message to the user.
  }
}

Future<void> _moveOrderToCompleted(
    String orderId, Map<String, dynamic> orderData) async {
  try {
    // Add the order to 'Orders Completed' collection
    await FirebaseFirestore.instance
        .collection('Orders Completed')
        .doc(orderId)
        .set(orderData);

    // Delete the order from the 'orders' collection
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
  } catch (e) {
    print('Error moving order to completed: $e');
  }
}
