import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/resetPassword.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  void resetPassword(BuildContext context) async {
    String driverEmail = emailController.text;

    if (driverEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('email', isEqualTo: driverEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // User exists in the Firestore collection, navigate to ResetPassword screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset password link sent to ${driverEmail}' ),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return ResetPassword(email: driverEmail);
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
          ),
        );
      } else {
        // User does not exist in the Firestore collection, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User does not exist. This email is not registered.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error occurred. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding:  EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: ListView(
            children: <Widget>[
              Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                  child: Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: CircleAvatar(
                          radius: screenWidth < 600 ? 60.0 : 80.0,
                          backgroundImage: AssetImage('assets/resetpage.jpg'),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      const Text(
                        'Forgot Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      TextField(
                        key: ValueKey("forgotPasswordEmail"),
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Enter your email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.05),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),

                    ],
                ),
              ),

            ),
              ElevatedButton(
                key: ValueKey("resetPassword"),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.08,
                      vertical: screenHeight * 0.03,
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                  elevation: MaterialStateProperty.all<double>(8.0),
                ),
                onPressed: () {
                  resetPassword(context);
                },
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
    ]
        ),

      ),

    );
  }
}
