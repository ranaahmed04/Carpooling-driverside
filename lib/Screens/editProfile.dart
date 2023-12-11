import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/profile.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  /////////////////////////////////////////////////////////////////////
  TextEditingController carmodelController = TextEditingController();
  TextEditingController carcolorController = TextEditingController();
  TextEditingController plateLettersController = TextEditingController();
  TextEditingController plateNumbersController = TextEditingController();
  late User? _currentUser;
  late Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndSyncData();
  }
  Future<void> updateDriverInfo() async {
    String username = nameController.text;
    String phoneNumber = phoneController.text;
    String carModel = carmodelController.text;
    String carColor = carcolorController.text;
    String carPlateLetters = plateLettersController.text;
    String carPlateNumber = plateNumbersController.text;

    try {
      // Your validation code goes here
      if (phoneNumber.isNotEmpty) {
        if (phoneNumber.length != 11 || !phoneNumber.startsWith('01')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Please enter a valid phone number that start with 01 and of length 11 number only '),
            ),
          );
          return;
        }
      }
      if (carPlateNumber.isNotEmpty) {
        if (carPlateNumber.length < 3 || carPlateNumber.length > 4 ||
            !containsOnlyNumbers(carPlateNumber)) {
          // Show error for invalid car plate number
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Car plate number should contain 3 to 4 numbers only.'),
            ),
          );
          return;
        }
      }
      // Check if the email, car model, car color, car plate number, and car plate letters are already in use
      QuerySnapshot existingUsers3 = await FirebaseFirestore.instance
          .collection('drivers')
          .where('car_model', isEqualTo: carModel)
          .where('car_color', isEqualTo: carColor)
          .where('car_plateNumber', isEqualTo: carPlateNumber)
          .where('car_plateLetters', isEqualTo: carPlateLetters)
          .limit(1)
          .get();

      if (existingUsers3.docs.isNotEmpty) {
        // Show error for existing data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('this car is used by another user'),
          ),
        );
        return;
      }
      QuerySnapshot existingUsers2 = await FirebaseFirestore.instance
          .collection('drivers')
          .where('car_plateNumber', isEqualTo: carPlateNumber)
          .limit(1)
          .get();

      if (existingUsers2.docs.isNotEmpty) {
        // Show error for existing data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('this car numbers is used by another user'),
          ),
        );
        return;
      }
      // Create a map to store the fields that need to be updated in Firestore
      Map<String, dynamic> updatedData = {};

      // Check which fields are updated and add them to the update map
      if (username.isNotEmpty) {
        // Add username to the update map
        updatedData['username'] = username;
      }
      if (phoneNumber.isNotEmpty) {
        // Add username to the update map
        updatedData['phoneNumber'] = phoneNumber;
      }
      if (carModel.isNotEmpty) {
        // Add username to the update map
        updatedData['car_model'] = carModel;
      }
      if (carPlateNumber.isNotEmpty) {
        // Add username to the update map
        updatedData['car_plateNumber'] = carPlateNumber;
      }
      if (carPlateLetters.isNotEmpty) {
        // Add username to the update map
        updatedData['car_plateLetters'] = carPlateLetters;
      }
      if (carColor.isNotEmpty) {
        // Add username to the update map
        updatedData['car-color'] = carColor;
      }


      // Update Firestore document only with the changed fields
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(_currentUser!.uid)
          .update(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile updated successfully!"),
        ),
      );
      // Optionally, navigate back to the profile screen after updating
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false, );
    } catch (e) {
      // Handle any potential errors while updating Firestore
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile. Please try again."),
        ),
      );
    }
  }

  Future<void> _fetchUserData(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('drivers').doc(userId).get();
      if (snapshot.exists) {
        setState(() {
          _userData = snapshot.data()!;
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _getCurrentUserAndSyncData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _fetchUserData(_currentUser!.uid);
    }
  }
  bool containsNumbers(String value) {
    return RegExp(r'\d').hasMatch(value);
  }

  bool containsOnlyNumbers(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ain Shams CarPooling'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Use your desired return icon
          onPressed: () {
            Navigator.of(context).pop(); // This will pop the current screen off the navigation stack
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: const Text(
                'Edit Your Profile',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                ),
              ),
            ),
            SizedBox(height: 10,),
            const Divider(
              height: 2,
              thickness: 5,
              color: Colors.purple,
            ),
            const SizedBox(height: 20),
            TextField(
              key: ValueKey("emailID"),
              controller: emailController,
              enabled: false,
              decoration: InputDecoration(
                hintText: '${_userData['email'] ?? ''}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),


            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['username'] ?? ''}', nameController, Icons.edit_note,TextInputType.emailAddress),
            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['phoneNumber'] ?? ''}', phoneController, Icons.phone,TextInputType.number),
            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['car_model'] ?? ''}', carmodelController, Icons.directions_car,TextInputType.text),
            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['car-color'] ?? ''}', carcolorController, Icons.color_lens_outlined,TextInputType.text),
            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['car_plateLetters'] ?? ''}', plateLettersController, Icons.sort_by_alpha,TextInputType.text),
            const SizedBox(height: 2),
            buildTextFieldWithEditIcon('${_userData['car_plateNumber'] ?? ''}', plateNumbersController, Icons.numbers,TextInputType.number),
            const SizedBox(height: 20),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                key: ValueKey("submit"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                    ),
                  ),
                ),
                child: const Text('Save Changes'),

                onPressed: () {
                  updateDriverInfo();
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

    );
  }

  Widget buildTextFieldWithEditIcon(String label, TextEditingController controller, IconData icon,TextInputType keyboardType) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: ValueKey(label),
              keyboardType: keyboardType,
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                hintText: label,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(icon),
          ),
        ],
      ),
    );
  }
}



