import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/Add ride.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:project_driverside/Screens/editProfile.dart';
import 'package:project_driverside/Screens/OfferedRides.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late User? _currentUser;
  late Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndSyncData();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ain_shams car pooling'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: const Text(
                'Profile',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.w600,
                  fontSize: 30,
                ),
              ),
            ),
            Card(
              elevation: 7.0,
              color: Colors.purple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.07),
              ),
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07, vertical: screenHeight * 0.025),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.3, // Adjust the value for image size
                        backgroundImage: AssetImage('assets/female-avatar-profile.jpg'),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['username'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['email'] ?? ''}',
                        style: const TextStyle(fontSize: 17),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['phoneNumber'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['car_model'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['car-color'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['car_plateNumber'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${_userData['car_plateLetters'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),

            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03, vertical: screenHeight * 0.02),
              child: ElevatedButton(
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
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,

                  ),
                ),
                onPressed: () {
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile()),);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 3) {
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => SignInPage()),
                  (route) => false,
            );
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

          } else if (i == 1) {
            Navigator.pushReplacement(context,
              PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return AddRide();
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
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box,color: Colors.purple,),
            label: "Profile",
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,color: Colors.grey,),
            label: "Add Ride",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_rounded,color: Colors.grey,),
            label: "Offerd Rides",
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
