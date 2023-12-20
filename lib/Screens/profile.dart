import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/Add ride.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:project_driverside/Screens/editProfile.dart';
import 'package:project_driverside/Screens/OfferedRides.dart';
import 'package:project_driverside/Database.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Map<String, dynamic> _userData = {};
  late bool _isConnected;
  Timer? _timer;
  static const Duration reloadDuration = const Duration(minutes:10);
  late User? _currentUser;
  late String userId;
  DatabaseService _databaseService = DatabaseService();

  void signOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    print('User signed out');
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      userId = _currentUser!.uid; // Initialize userId only if _currentUser is not null
      print('userid: $userId');
    } else {
      print('null');
    }
    setState(() {});

    initialize(); // Call the initialize method

    _timer = Timer.periodic(reloadDuration, (Timer timer) {
      setState(() {});
    });

  }
  Future<void> initialize() async {
    await _databaseService.initialize(); // Initialize the database
    print('Initialized from profile');
    await _databaseService.checkData();
    print('Done checking');
    await checkConnectivity1();
    print('Done connect');
    await _databaseService.printDatabaseContent();
    print('Done printing');
  }

  Future<bool> checkInternetConnectivity() async {
    print('hancheck aho el connection');
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  @override
  void dispose() {
    // Cancel the timer to prevent memory leaks when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkConnectivity1() async {
    _isConnected = await checkInternetConnectivity();
    if (_isConnected) {
      print(_isConnected);
      // If online, sync data with Firestore
      await _getCurrentUserAndSyncData();
      await startPeriodicSync();
    } else {
      // If offline, display data from SQLite
      print(_isConnected);
      await displayDataFromSQLite();
    }
  }

  Future<void> startPeriodicSync() async {
    Timer.periodic(Duration(minutes:1), (timer) async {
      if (_isConnected) {
        print('hansync aho');
        await syncWithFirestore();
      }
    });
  }

  Future<Map<String, dynamic>> _fetchUserData(String driverId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('drivers').doc(driverId).get();

      if (snapshot.exists) {
        return snapshot.data() ?? {}; // Return user data or an empty map if null
      } else {
        print('Driver document does not exist');
        return {}; // Return an empty map if the document doesn't exist
      }
    } catch (e) {
      print('Error fetching driver data: $e');
      return {}; // Return an empty map or handle error accordingly
    }
  }

  Future<void> syncWithFirestore() async {
    try {
      print('dkhlna 3shan nesync');
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection('drivers').doc(userId).get();
      print('gebna l data');
      if (snapshot.exists) {
        final Map<String, dynamic> userData = snapshot.data()!;
        print(userData);
        await _databaseService.syncFirestoreDataToSQLite(userData);
        print('khlsna syncing mn profile');
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error syncing data: $e');
    }
  }
  Future<Map<String, dynamic>> displayDataFromSQLite() async {
    try {
      final userData = await _databaseService.fetchDriverDataFromSQLite();
      return userData;
    } catch (e) {
      print('Error fetching data from SQLite: $e');
      return {}; // Return an empty map or handle error accordingly
    }
  }
  Future<void> _getCurrentUserAndSyncData() async {
    if (_currentUser != null) {
      print("user mish null");
      //_userData=
      await _fetchUserData(userId);
      //print("b3d ma reg3t met fetch function");
      //print(_userData);

    }
  }

 /* Future<void> _getCurrentUserAndSyncData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      await _fetchUserData(_currentUser!.uid);
    }
  }*/

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
        child:  FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserData(_currentUser!.uid),
          builder: (context, snapshot) {
            print('hasData: ${snapshot.hasData}');
            print('dataIsEmpty: ${snapshot.data?.isEmpty ?? true}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data!.isEmpty || !snapshot.hasData) {
              return Center(child: Text('No user data available'));
            } else {
            final userData = snapshot.data!;
            return ListView(
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
                    borderRadius: BorderRadius.circular(MediaQuery
                        .of(context)
                        .size
                        .width * 0.07),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.07,
                      vertical: screenHeight * 0.025),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: screenWidth * 0.3,
                        // Adjust the value for image size
                        backgroundImage: AssetImage(
                            'assets/female-avatar-profile.jpg'),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${ userData['username'] ?? ''}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['email'] ?? ''}',
                        style: const TextStyle(fontSize: 17),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['phoneNumber'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['car_model'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['car-color'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['car_plateNumber'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        '${userData['car_plateLetters'] ?? ''}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),

                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.02),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              screenWidth * 0.05),
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.08,
                            vertical: screenHeight * 0.03),
                      ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors
                          .purple),
                      elevation: MaterialStateProperty.all<double>(8.0),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,

                      ),
                    ),
                    onPressed: () async {
                      final updatedData = await Navigator.push(context, MaterialPageRoute(
                        builder: (context) => EditProfile(
                          initialData: userData,
                        ),
                      ),
                      );
                      // Handling the returned data after EditProfile screen is popped
                      if (updatedData != null && updatedData is Map<String, dynamic>) {
                        setState(() {
                          _userData = updatedData;
                        });
                      } else {
                        print('No data updated');
                      }
                    },
                  ),
                ),
              ],
            );
          }
        },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (i) {
          if (i == 3) {
            signOutUser();
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
