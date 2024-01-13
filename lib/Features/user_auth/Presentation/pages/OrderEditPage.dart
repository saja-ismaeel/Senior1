import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderEditPage extends StatefulWidget {
  final String orderId;

  const OrderEditPage({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderEditPageState createState() => _OrderEditPageState();
}

class _OrderEditPageState extends State<OrderEditPage> {
  String? _userId;

  TextEditingController _customerNameController = TextEditingController();
  int? _selectedConcreteStrength;
  final List<int> _concreteStrengthOptions = [250, 300, 350];
  DateTime _selectedDate = DateTime.now();
  TextEditingController _roofDepthController = TextEditingController();
  TextEditingController _roofLengthController = TextEditingController();
  TextEditingController _roofWidthController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Fetch the existing order data when the page loads
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      // Fetch the order data using the orderId
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();
      // Extract order data from the snapshot
      Map<String, dynamic> orderData =
      orderSnapshot.data() as Map<String, dynamic>;

      // Set the values in the controllers
      setState(() {
        _userId = orderData['userId'];
        _customerNameController.text = orderData['customerName'];
        _selectedConcreteStrength = orderData['concreteStrength'];
        _roofDepthController.text = orderData['roofDepth'].toString();
        _roofLengthController.text = orderData['roofLength'].toString();
        _roofWidthController.text = orderData['roofWidth'].toString();
        _selectedDate = (orderData['selectedDateTime'] as Timestamp).toDate();
      });
    } catch (e) {
      print('Error fetching order data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink,
        title: Text('Edit Order'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
    child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<int>(
              value: _selectedConcreteStrength,
              decoration: InputDecoration(
                labelText: 'Concrete Strength',
                border: OutlineInputBorder(),
              ),
              items: _concreteStrengthOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedConcreteStrength = newValue;
                  // _calculateResult(); // If needed
                });
              },
              validator: (value) => value == null ? 'Field required' : null,
            ),
            TextField(
              controller: _roofDepthController,
              decoration: InputDecoration(labelText: 'Roof Depth'),
            ),
            TextField(
              controller: _roofLengthController,
              decoration: InputDecoration(labelText: 'Roof Length'),
            ),
            TextField(
              controller: _roofWidthController,
              decoration: InputDecoration(labelText: 'Roof Width'),
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2025, 12, 31),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink,
                   // textStyle: TextStyle(color: Colors.white),

                  ),
                  child: Text("Select Date",
                    style: TextStyle(color: Colors.white),),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_selectedDate),
                    ).then((time) {
                      if (time != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.pink,
                 //   textStyle: TextStyle(color: Colors.white),
                  ),
                  child: Text("select time",
                    style: TextStyle(color: Colors.white),),
                ),
                SizedBox(height: 20),
                Text("selected Date and Time: ${_selectedDate.toLocal()}"),
                SizedBox(height: 20),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Get the updated values from the controllers
                String updatedCustomerName = _customerNameController.text;
                double updatedRoofDepth =
                    double.tryParse(_roofDepthController.text) ?? 0.0;
                double updatedRoofLength =
                    double.tryParse(_roofLengthController.text) ?? 0.0;
                double updatedRoofWidth =
                    double.tryParse(_roofWidthController.text) ?? 0.0;

                // Check if any of the values are empty
                if (updatedCustomerName.isEmpty) {
                  // Show an error message or handle the case where required fields are empty
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(widget.orderId)
                      .update({
                    'userId': _userId,
                    'customerName': updatedCustomerName,
                    'selectedDateTime': _selectedDate,
                    'roofDepth': updatedRoofDepth,
                    'roofLength': updatedRoofLength,
                    'roofWidth': updatedRoofWidth,
                    'concreteStrength': _selectedConcreteStrength,
                    // Add more fields if needed
                  });
                  // Update the first and second containers based on the new values
                  _updateContainers();

                  // Navigate back to the OrderListPage
                  Navigator.pop(context);
                } catch (e) {
                  // Handle the case where the update fails
                  print('Error updating order: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.pink,
               // textStyle: TextStyle(color: Colors.white),
              ),
              child: Text('Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      )
    );
  }


  // Function to update containers
  Future<void> _updateContainers() async {
    try {
      // calculate and update the first and second containers
      // Extract values from controllers, defaulting to 0.0 if parsing fails
      double roofWidth = double.tryParse(_roofWidthController.text) ?? 0.0;
      double roofLength = double.tryParse(_roofLengthController.text) ?? 0.0;
      double roofDepth = double.tryParse(_roofDepthController.text) ?? 0.0;

      // Calculate volume
      double volume = roofWidth * roofLength * roofDepth;

      double firstContainer, secondContainer;

      // Adjust the logic based on requirements
      if (_selectedConcreteStrength == 250) {
        firstContainer = volume * 2 / 3;
        secondContainer = volume * 1 / 3;
      } else if (_selectedConcreteStrength == 300) {
        firstContainer = volume * 1 / 3;
        secondContainer = volume * 2 / 3;
      } else if (_selectedConcreteStrength == 350) {
        firstContainer = volume * 1 / 2;
        secondContainer = volume * 1 / 2;
      } else {
        // Handle the case where concrete strength is not selected
        firstContainer = 0.0;
        secondContainer = 0.0;
      }
      // Update the Firestore document with the new container values
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'userId': _userId,
        'firstContainer': firstContainer,
        'secondContainer': secondContainer,
      });
    } catch (e) {
      print('Error updating containers: $e');
    }
  }}
