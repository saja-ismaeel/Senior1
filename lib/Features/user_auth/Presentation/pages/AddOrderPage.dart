import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior1/Features/user_auth/Presentation/pages/AdminHome.dart';

import '../../../../global/common/toast.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import '../widgets/form_container_widget.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:senior1/global/common/toast.dart';

class add_order_page extends StatefulWidget {
  const add_order_page({Key? key}) : super(key: key);

  @override
  State<add_order_page> createState() => _add_order_pageState();
}

class _add_order_pageState extends State<add_order_page> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  TextEditingController _customernameController = TextEditingController();
  TextEditingController _RoofdepthController = TextEditingController();
  TextEditingController _RooflengthController = TextEditingController();
  TextEditingController _RoofwidthController = TextEditingController();
  double? _calculatedResult;
  int? _selectedConcreteStrength;
  final List<int> _concreteStrengthOptions = [250, 300, 350];
  double? _firstContainer;
  double? _secondContainer;
  bool _isDateSelected = false;
  bool _isTimeSelected = false;

  @override
  void dispose() {
    _customernameController.dispose();
    _RoofdepthController.dispose();
    _RooflengthController.dispose();
    _RoofwidthController.dispose();
    super.dispose();
  }

  @override
  void _calculateResult() {
    double? depth = double.tryParse(_RoofdepthController.text);
    double? length = double.tryParse(_RooflengthController.text);
    double? width = double.tryParse(_RoofwidthController.text);

    if (depth != null &&
        length != null &&
        width != null &&
        _selectedConcreteStrength != null) {
      double volume = width * length * depth;
      setState(() {
        _calculatedResult = volume;
        if (_selectedConcreteStrength == 250) {
          _firstContainer = volume * 2 / 3;
          _secondContainer = volume * 1 / 3;
        } else if (_selectedConcreteStrength == 300) {
          _firstContainer = volume * 1 / 3;
          _secondContainer = volume * 2 / 3;
        } else if (_selectedConcreteStrength == 350) {
          _firstContainer = volume * 1 / 2;
          _secondContainer = volume * 1 / 2;
        } else {
          _firstContainer = null;
          _secondContainer = null;
          _calculatedResult = null;
        }
      });
    } else {
      setState(() {
        _calculatedResult = null;
        _firstContainer = null;
        _secondContainer = null;
      });
    }
  }

  @override
  Future<void> _addOrderToFirestore() async {
    try {
      double? roofDepth = double.tryParse(_RoofdepthController.text);
      double? roofLength = double.tryParse(_RooflengthController.text);
      double? roofWidth = double.tryParse(_RoofwidthController.text);

      if (roofDepth == null || roofLength == null || roofWidth == null) {
        showToast(message: 'Please enter valid numbers for roof dimensions.');
        return;
      }
      //String userId = FirebaseAuthService().getCurrentUserId();
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      Map<String, dynamic> orderData = {
        'userId': userId,
        'customerName': _customernameController.text,
        'concreteStrength': _selectedConcreteStrength,
        'roofDepth': roofDepth,
        'roofLength': roofLength,
        'roofWidth': roofWidth,
        'selectedDateTime': Timestamp.fromDate(_selectedDate),
        'firstContainer': _firstContainer,
        'secondContainer': _secondContainer,
      };
      // Check if there is an order booked within the ten minutes surrounding the selected time
      DateTime tenMinutesBefore = _selectedDate.subtract(Duration(minutes: 10));
      DateTime tenMinutesAfter = _selectedDate.add(Duration(minutes: 10));

      QuerySnapshot ordersWithinTimeRange = await _firestore
          .collection('orders')
          .where('selectedDateTime', isGreaterThan: Timestamp.fromDate(tenMinutesBefore))
          .where('selectedDateTime', isLessThan: Timestamp.fromDate(tenMinutesAfter))
          .get();

      if (ordersWithinTimeRange.docs.isNotEmpty) {
        showToast(message: 'Another order is already booked within the ten minutes surrounding the selected time.');
        return;
      }
      await _firestore.collection('orders').add(orderData);

      showToast(message: 'Order added successfully');
      //clean data after saving to Firestore
      setState(() {
        _customernameController.text = '';
        _RoofdepthController.text = '';
        _RooflengthController.text = '';
        _RoofwidthController.text = '';
        _selectedConcreteStrength = null;
        _calculatedResult = null;
        _firstContainer = null;
        _secondContainer = null;
        _isDateSelected = false;
        _isTimeSelected = false;
      });
    } catch (e) {
      showToast(message: 'Failed to add order: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Order"),
        backgroundColor: Colors.pink,

        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),

      ),


      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Add Order",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                FormContainerWidget(
                  controller: _customernameController,
                  hintText: "Customer name",
                  isPasswordField: false,
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
                      _calculateResult();
                    });
                  },
                  validator: (value) => value == null ? 'Field required' : null,
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _RoofdepthController,
                  hintText: "Roof Depth",
                  isPasswordField: false,
                  onChanged: (value) {
                    // Add this line
                    _calculateResult();
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _RooflengthController,
                  hintText: "Roof Length",
                  isPasswordField: false,
                  onChanged: (value) {
                    _calculateResult();
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                FormContainerWidget(
                  controller: _RoofwidthController,
                  hintText: "Roof Width",
                  isPasswordField: false,
                  onChanged: (value) {
                    _calculateResult();
                  },
                ),
                SizedBox(
                  height: 10,
                ),
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
                            if (date.isAfter(DateTime.now().subtract(Duration(days: 1)))) {

                              setState(() {
                                _selectedDate = date;
                                _isDateSelected = true;
                              });
                            } else {
                              showToast(message: 'Please select a date today or the day after today');
                            }
                          }
                        });

                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink,
                      ),
                      child: Text("select date",style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_selectedDate),
                        ).then((time) {
                          if (time != null) {
                            DateTime selectedDateTime = DateTime(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                              time.hour,
                              time.minute,
                            );
                            if (selectedDateTime.isAfter(DateTime.now())) {
                              setState(() {
                                _selectedDate = selectedDateTime;
                                _isTimeSelected = true;
                              });
                            } else {
                              showToast(message: 'Please select a time in the future.');
                            }
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.pink,
                      ),
                      child: Text("select time",style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),),
                    ),

                    SizedBox(height: 20),
                    Text("selected Date and Time: ${_isTimeSelected ? _selectedDate.toLocal() : 'Not selected'}"),
                    SizedBox(height: 20),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    if (_customernameController.text.isNotEmpty &&
                        _RoofdepthController.text.isNotEmpty &&
                        _RooflengthController.text.isNotEmpty &&
                        _RoofwidthController.text.isNotEmpty &&
                        _isDateSelected &&
                        _isTimeSelected
                    ) {

                      _addOrderToFirestore();
                    } else {
                      showToast(
                          message:
                          'Please fill all fields and select date and time.');
                    }


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
                          "Add Order",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
                if (_calculatedResult != null) ...[
                  SizedBox(height: 20),
                  Text(
                    'Quantity of concrete: ${_calculatedResult?.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_selectedConcreteStrength != null &&
                      _firstContainer != null &&
                      _secondContainer != null) ...[
                    SizedBox(height: 10),
                    Text(
                      'First Container : ${_firstContainer?.toStringAsFixed(2)}',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Second Container : ${_secondContainer?.toStringAsFixed(2)}',
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}