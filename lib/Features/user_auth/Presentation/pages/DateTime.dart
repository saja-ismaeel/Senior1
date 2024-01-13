// import 'package:flutter/material.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:scroll_date_picker/scroll_date_picker.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   DateTime selectedDateTime = DateTime.now();
//
//   // Add Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   DateTime _selectedDate = DateTime.now();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("select date and time app"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 showDatePicker(
//                   context: context,
//                   initialDate: _selectedDate,
//                   firstDate: DateTime.now().subtract(Duration(days: 365)),
//                   lastDate: DateTime(2025, 12, 31),
//                 ).then((date) {
//                   if (date != null) {
//                     setState(() {
//                       _selectedDate = date;
//                     });
//                   }
//                 });
//               },
//               child: Text("select date"),
//             ),
//
//
//             SizedBox(height: 20),
//             Text("selectedDate: ${_selectedDate.toLocal()}"),
//
//             SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () {
//                 showTimePicker(
//                   context: context,
//                   initialTime: TimeOfDay.fromDateTime(_selectedDate),
//                 ).then((time) {
//                   if (time != null) {
//                     setState(() {
//                       _selectedDate = DateTime(
//                         _selectedDate.year,
//                         _selectedDate.month,
//                         _selectedDate.day,
//                         time.hour,
//                         time.minute,
//                       );
//                     });
//                   }
//                 });
//               },
//               child: Text("select time"),
//             ),
//             SizedBox(height: 20),
//             Text("selectedDate: ${_selectedDate.toLocal()}"),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _saveDataToFirestore();
//               },
//               child: Text("save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
// // Save data to Firestore
//   void _saveDataToFirestore() {
//     _firestore.collection('your_collection_name').add({
//       'selectedDateTime': Timestamp.fromDate(_selectedDate),
//     }).then((value) {
//       print("Data saved successfully");
//       // Clear the text widgets after saving to Firestore
//       // setState(() {
//       //   _selectedDate = DateTime.now();
//       // });
//     }).catchError((error) {
//       print("Error saving data: $error");
//     });
//   }
// }