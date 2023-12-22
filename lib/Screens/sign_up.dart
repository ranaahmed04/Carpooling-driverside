import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<SignupPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  /////////////////////////////////////////////////////////////////////////
  TextEditingController carmodelController = TextEditingController();
  TextEditingController carcolorController = TextEditingController();
  TextEditingController plateLettersController = TextEditingController();
  TextEditingController plateNumbersController = TextEditingController();

  Future<void> signUpWithEmailAndPassword(BuildContext context) async {
    String email = emailController.text.trim();
    String username = nameController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String carModel = carmodelController.text.trim();
    String carColor = carcolorController.text.trim();
    String carPlateNumber = plateNumbersController.text.trim();
    String carPlateLetters = plateLettersController.text.trim();


    if (email.isEmpty || username.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty || phoneNumber.isEmpty || carModel.isEmpty
        || carPlateNumber.isEmpty || carPlateLetters.isEmpty
        || carColor.isEmpty)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You must fill in all fields "),
        ),
      );
      return;
    }
    // Check if the email has the correct domain
    if (!email.endsWith('@eng.asu.edu.eg')) {
      // Show an error message to the user if the email domain is incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please use an @eng.asu.edu.eg email address.'),
        ),
      );
      return;
    }
       // Validate phone number format and length
    if (phoneNumber.length != 11 || !phoneNumber.startsWith('01')) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number that start with 01 and of length 11 number only '),
        ),
      );
      return;
    }
    // Check if the password is strong (at least 6 characters, include numbers, etc.)
    if (password.length < 6 || !containsNumbers(password)) {
      // Show an error message for a weak password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password should be at least 6 characters long and include numbers.'),
        ),
      );
      return;
    }

    // Check if the entered password and confirm password match
    if (password != confirmPassword) {
      // Show an error message for mismatched passwords
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }
    // Validation for car plate number format and length
    if (carPlateNumber.length < 3 || carPlateNumber.length > 4 || !containsOnlyNumbers(carPlateNumber)) {
      // Show error for invalid car plate number
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Car plate number should contain 3 to 4 numbers only.'),
        ),
      );
      return;
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
    // Check if the email is already in use
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Access the current user after sign-up
      User? currentUser = userCredential.user;

      // Save additional user information to Firestore
      await FirebaseFirestore.instance.collection('drivers').doc(currentUser?.uid).set({
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'username': username,
        'car_model': carModel,
        'car_plateNumber': carPlateNumber,
        'car_plateLetters': carPlateLetters,
        'car-color':carColor,
        // Add more fields as needed
      });

      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
      );
    } catch (e) {
      // Firebase createUserWithEmailAndPassword failed, handle the error
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign up failed. Please try again.'),
        ),
      );
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ain_shams car pooling'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: const Text(
                'Sign-Up',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                ),
              ),
            ),
            const Divider(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: TextField(
                key: ValueKey("emailID"),
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                  ),
                  labelText: 'example@eng.asu.edu.eg',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: TextField(
                key: ValueKey("userName"),
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                  ),
                  labelText: 'User Name',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: TextField(
                key: ValueKey("password"),
                obscureText: true,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                  ),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: TextField(
                key: ValueKey("confirmPassword"),
                obscureText: true,
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                  ),
                  labelText: 'Confirm Password',
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
              child: TextField(
                key: ValueKey("number"),
                keyboardType: TextInputType.number,
                controller: phoneController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                  ),
                  labelText: 'Phone Number',
                ),
              ),
            ),

            Container(
                  padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
                  child: TextField(
                    key: ValueKey("Car Model"),
                    controller: carmodelController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                      ),
                      labelText: 'Car Model',
                    ),
                  ),
                ),

                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
                  child: TextField(
                    key: ValueKey("Car color"),
                    controller: carcolorController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                      ),
                      labelText: 'Car Color',
                    ),
                  ),
                ),

            Row(
              children: [
               Expanded(
                 child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
                  child: TextField(
                    key: ValueKey("Car plate letter"),
                    controller: plateLettersController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                      ),
                      labelText: 'Car plate letters',
                    ),
                  ),
                ),
               ),
               Expanded(
                 child: Container(
                  padding: EdgeInsets.all(screenWidth * 0.03), // Adjust padding
                  child: TextField(
                    key: ValueKey("Car plate numbers"),
                    controller: plateNumbersController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                        borderSide: BorderSide(color: Colors.purple, width: 2.0),// Adjust border radius
                      ),
                      labelText: 'Car plate numbers ',
                    ),
                  ),
                ),
               ),
              ],
            ),

            Container(
              height: screenHeight * 0.08, // Adjust button height
              padding: EdgeInsets.fromLTRB(screenWidth * 0.03, 0, screenWidth * 0.03, 0), // Adjust padding
              child: ElevatedButton(
                key: ValueKey("submit"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05), // Adjust border radius
                    ),
                  ),
                ),
                child: const Text(
                    'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,

                  ),
                ),
                onPressed: () async {
                  signUpWithEmailAndPassword(context);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
