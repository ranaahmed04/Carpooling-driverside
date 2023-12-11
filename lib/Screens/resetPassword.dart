import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/profile.dart';

class ResetPassword extends StatefulWidget {
  final String email;

  ResetPassword({required this.email});
  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  /*late User? _currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndSyncData();
  }

  Future<void> updatePasswordInFirestore(String newPassword) async {
    try {

      await FirebaseFirestore.instance
          .collection('drivers')
          .where('email', isEqualTo: widget.email)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          // User exists in Firestore, update password
          FirebaseAuth.instance.currentUser?.updatePassword(newPassword);
        }
      });
    } catch (e) {
      print('Error updating password in Firestore: $e');
      // Handle error updating password in Firestore
    }
  }

  void setNewPassword(BuildContext context) async {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in both password fields.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    // Check if the password is strong (at least 6 characters, include numbers, etc.)
    if (newPassword.length < 6 || !containsNumbers(newPassword)) {
      // Show an error message for a weak password
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password should be at least 6 characters long and include numbers.'
          ),
        ),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {

      // Update Firestore document only with the changed fields
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(_currentUser!.uid)
          .update({
      'password': newPassword,
      // Update other fields similarly
      });
    } catch (e) {
      print('Error updating password in Firestore: $e');
      // Handle error updating password in Firestore
    }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password updated successfully'),
          duration: Duration(seconds: 3),
        ),
      );

      Future.delayed(Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return SignInPage();
            },
            transitionsBuilder: (context, animation, secondaryAnimation,
                child) {
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
      });
    }

  bool containsNumbers(String value) {
    return RegExp(r'\d').hasMatch(value);
  }*/
 void setNewPassword(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password updated successfully'),
        duration: Duration(seconds: 5),
      ),
    );

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return HomePage();
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

    });
  }

/*
  Future<void> _getCurrentUserAndSyncData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
  }
*/
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
        child: ListView(
            children: <Widget> [
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
                      SizedBox(height: 20),
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        key: ValueKey("newPassword"),
                        controller: newPasswordController,
                        obscureText: true, // Hides the entered text
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        key: ValueKey("confirmPassword"),
                        controller: confirmPasswordController,
                        obscureText: true, // Hides the entered text
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                    ],
                  ),
                ),
              ),
              ElevatedButton(
                key: ValueKey("updatePassword"),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                    ),
                  ),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.03),
                  ),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple),
                  elevation: MaterialStateProperty.all<double>(8.0),
                ),
                onPressed: () {
                  setNewPassword(context);
                },
                child: const Text(
                  'Update Password',
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
