import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:project_driverside/Screens/profile.dart';
import 'package:project_driverside/Screens/OfferedRides.dart';

class AddRide extends StatefulWidget {
  const AddRide({Key? key}) : super(key: key);

  @override
  _AddRideState createState() => _AddRideState();
}

class _AddRideState extends State<AddRide> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController StartLocationController = TextEditingController();
  TextEditingController EndLocationController = TextEditingController();
  TextEditingController PriceController = TextEditingController();
  TextEditingController DateController = TextEditingController();
  late ValueNotifier<String?> selectedTimeNotifier;
  late ValueNotifier<String?> selectedGateNotifier;
  User? _currentUser;

  void signOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    print('User signed out');
  }

  void _addRideToFirestore() async {
    String startLocation = StartLocationController.text.trim();
    String endLocation = EndLocationController.text.trim();
    String price = PriceController.text.trim();
    String? selectedTime = selectedTimeNotifier.value;
    String? selectedGate = selectedGateNotifier.value;
    DateTime? rideDate;
    try {

      rideDate = DateTime.parse(DateController.text.trim());
      if (rideDate.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please choose a future date.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // Check if the selected date is today
      bool isToday = rideDate.year == DateTime.now().year &&
          rideDate.month == DateTime.now().month &&
          rideDate.day == DateTime.now().day;

      // Check if the current time is before 12:00 PM (noon)
      bool isTimeBefore12PM = DateTime.now().hour < 12 ||
          (DateTime.now().hour == 12 && DateTime.now().minute == 0);

      if (isToday && isTimeBefore12PM && selectedTime == '5:30 PM') {
        // Allow adding a ride as it's the same day and time is before 12:00 PM
        // Add your logic here for adding the ride
        print('Adding ride for today before 12:00 PM');
      } else if (!isToday && rideDate.isAfter(DateTime.now())){
        print('Added ride');
      }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only add a ride for today before 12:00 PM and for 5:30 trip.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print("Error parsing date: $e");
      // Handle the error if the string is not in a valid DateTime format
    }


    if (selectedTime == null || selectedGate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select time and gate.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Check location format and Ain Shams requirement
      RegExp alphaExp =RegExp(r'^[a-zA-Z ]+$');
      bool isValidStartLocation = alphaExp.hasMatch(startLocation);
      bool isValidEndLocation = alphaExp.hasMatch(endLocation);
      bool containsAinShams =
          (startLocation.toLowerCase().contains('ain shams') && !endLocation.toLowerCase().contains('ain shams')) ||
              (endLocation.toLowerCase().contains('ain shams') && !startLocation.toLowerCase().contains('ain shams'));

      if (!isValidStartLocation || !isValidEndLocation) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Start and end locations should contain only alphabetic characters.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (!containsAinShams) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Either start or end location must include "Ain Shams", but not both.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (price == null || double.tryParse(price) == null || double.parse(price) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid ride cost.'),
            duration: Duration(seconds: 3),
          ),
        );
      }else if (selectedTime == '7:30 AM' && startLocation.toLowerCase() == 'ain shams') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trips at 7:30 AM should have Ain Shams as the end location, not the start.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (selectedTime == '5:30 PM' && endLocation.toLowerCase() == 'ain shams') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Trips at 5:30 AM should have Ain Shams as the start location, not the end.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else if (rideDate==null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('you should choose date '),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        if (_currentUser != null) {
          QuerySnapshot ridesSnapshot = await firestore
              .collection('rides')
              .where('driver_id',isEqualTo: _currentUser?.uid)
              .where('ride_date', isEqualTo: rideDate)
              .where('selected_time', isEqualTo: selectedTime)
              .get();

          if (ridesSnapshot.docs.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('A ride already exists at this date and time for this user.'),
                duration: Duration(seconds: 3),
              ),
            );
          } else {
            DocumentSnapshot driverSnapshot = await firestore.collection('drivers').doc(_currentUser!.uid).get();

            if (driverSnapshot.exists) {
              Map<String, dynamic> driverData =
              driverSnapshot.data() as Map<String, dynamic>;

              Map<String, dynamic> rideData = {
                'start_location': startLocation,
                'end_location': endLocation,
                'selected_time': selectedTime,
                'selected_gate': selectedGate,
                'ride_date': rideDate,
                'ride_cost': price,
                'driver_id': _currentUser!.uid,
                'driver_username': driverData['username'],
                'driver_email': driverData['email'],
                'car_model': driverData['car_model'],
                'car_color': driverData['car-color'],
                'car_plateNumber': driverData['car_plateNumber'],
                'car_plateLetters': driverData['car_plateLetters'],
                // Add more fields as needed
              };
              await firestore.collection('rides').add(rideData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ride added successfully!'),
                  duration: Duration(seconds: 3),
                ),
              );
            } else {
              print('Driver document not found');
            }
          }
        } else {
          print('User not logged in');
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    selectedTimeNotifier = ValueNotifier<String?>('7:30 AM');
    selectedGateNotifier = ValueNotifier<String?>('Gate 3');
  }
  void _getCurrentUser() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ain Shams CarPooling'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: SingleChildScrollView(
            child: Form(
             key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  child: const Text(
                    'Offer Ride',
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                    ),
                  ),

                ),

                const Divider(
                  height: 2,
                  thickness: 5,
                  color: Colors.purple,
                ),
                SizedBox(height: screenHeight * 0.03),

                RoundedInputField(
                  key: const ValueKey('start'),
                  hintText: "Enter Start Location",
                  controller: StartLocationController,
                  onChanged: (value) {

                  },
                ),
                SizedBox(height: 10),
                RoundedInputField(
                  key: const ValueKey('end'),
                  hintText: "Enter End Location",
                  controller: EndLocationController,
                  onChanged: (value) {

                  },
                ),
                SizedBox(height: 10),
                RoundedInputField(
                  key: const ValueKey('Price'),
                  hintText: "Price",
                  controller: PriceController,
                  onChanged: (value) {

                  },
                ),
                SizedBox(height: 10),
                DateTextField(
                  key: const ValueKey('date'),
                  hintText: "Select Date",
                  controller: DateController,
                  onChanged: (value) {
                  },
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth * 0.85,
                  child: ValueListenableBuilder<String?>(valueListenable: selectedTimeNotifier, builder: (context, selectedTime, _)
                  {
                    return DropdownButtonFormField<String>(
                      value: selectedTime,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(screenWidth * 0.03),
                        labelText: 'Select Time',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '7:30 AM',
                          child: Text('7:30 AM'),
                        ),
                        DropdownMenuItem(
                          value: '5:30 PM',
                          child: Text('5:30 PM'),
                        ),
                      ],
                      onChanged: (value) {
                        selectedTimeNotifier.value = value;
                      },
                    );
                  }
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth * 0.85,

                  child:ValueListenableBuilder<String?>(valueListenable: selectedGateNotifier, builder: (context, selectedGate, _)
                  {
                    return DropdownButtonFormField<String>(
                      value: selectedGate,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(screenWidth * 0.03),
                        labelText: 'Select Gate',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'Gate 3',
                          child: Text('Gate 3'),
                        ),
                        DropdownMenuItem(
                          value: 'Gate 4',
                          child: Text('Gate 4'),
                        ),
                      ],
                      onChanged: (value) {
                        selectedGateNotifier.value = value;
                      },
                    );
                  }
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  //margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.02),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.19, vertical: screenHeight * 0.03),
                      ),

                      backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                      elevation: MaterialStateProperty.all<double>(8.0),
                    ),

                    onPressed: () {
                         if (_formKey.currentState?.validate() ?? false) {
                           // Only proceed if the form is valid
                           _addRideToFirestore();
                         }
                    }, child: const Text(
                    'Offer Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,

                    ),
                  ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return HomePage();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),);
          } else if (i == 2) {
            Navigator.pushReplacement(context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return OfferedRides();
                },
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),);
          } else if (i == 3) {
            signOutUser();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInPage()),
                  (route) => false,
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box,color: Colors.grey,),
            label: "Profile",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,color: Colors.purple,),
            label: "Add Ride",
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_rounded,color: Colors.grey,),
            label: "Offered Rides ",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout,color: Colors.grey,),
            label: "Log Out",
            backgroundColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class RoundedInputField extends StatelessWidget {
  final Key key;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const RoundedInputField({
    required this.key,
    required this.hintText,
    this.icon = Icons.location_on,
    required this.onChanged,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.01),
      //width: screenWidth * 0.85,

      child: TextField(
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
            borderSide: BorderSide(color: Colors.purple, width: 2.0),
            // Adjust border radius
          ),
          prefixIcon: Icon( icon,
            color: Colors.purple,),
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 18,
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }
}

class DateTextField extends StatefulWidget {
  final Key key;
  final String hintText;
  final ValueChanged<String> onChanged;
  final double hintFontSize; // Added for customizing hint text size
  final TextEditingController controller;

  const DateTextField({
    required this.key,
    required this.hintText,
    required this.onChanged,
    this.hintFontSize = 18.0, // Default hint text size
    required this.controller,
  });

  @override
  _DateTextFieldState createState() => _DateTextFieldState();
}

class _DateTextFieldState extends State<DateTextField> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      // Set the initial value if the controller has an initial date
      final DateTime? initialDate = DateTime.tryParse(widget.controller!.text);
      if (initialDate != null) {
        selectedDate = initialDate;
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.purple,
            hintColor: Colors.purple,
            colorScheme: ColorScheme.light(primary: Colors.purple),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });

      widget.onChanged(selectedDate!.toLocal().toString().split(' ')[0]);
      if (widget.controller != null) {
        widget.controller!.text = selectedDate!.toLocal().toString().split(' ')[0];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.055, vertical: screenHeight * 0.01),
      width: screenWidth * 0.85,
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        border: Border.all(color: Colors.blueGrey.shade100, width: 2.0),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(
              Icons.date_range,
              color: Colors.purple,
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: TextButton(
              onPressed: () => _selectDate(context),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
              ),
              child: Text(
                selectedDate != null
                    ? "${selectedDate!.toLocal()}".split(' ')[0]
                    : widget.hintText,
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: widget.hintFontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}