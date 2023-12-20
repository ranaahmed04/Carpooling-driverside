import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_driverside/Screens/Add ride.dart';
import 'package:project_driverside/Screens/profile.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:project_driverside/Screens/RidesRequest.dart';

class OfferedRides extends StatefulWidget {
  @override
  _OfferedRidesState createState() => _OfferedRidesState();
}

class _OfferedRidesState extends State<OfferedRides> {
  List<DocumentSnapshot> rideList = [];

  @override
  void initState() {
    super.initState();
    fetchRidesByDriverId();
  }
  void signOutUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    print('User signed out');
  }
  Future<void> fetchRidesByDriverId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String currentUserId = user.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('driver_id', isEqualTo: currentUserId)
          .get();

      setState(() {
        rideList = snapshot.docs;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Ain Shams CarPooling"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding:EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    borderRadius:BorderRadius.circular(MediaQuery.of(context).size.width * 0.07), // Adjust the value as needed
                  ),
                  child: Center(
                    child: Text(
                      'Your offered Rides',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 30,
                      ),
                    ),
                  ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(screenWidth * 0.01),
                  itemCount: rideList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.all(screenWidth * 0.01),
                      child: Card(
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.07),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.07),
                          ),
                          title: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                '${rideList[index]['start_location']} To ${rideList[index]['end_location']}',
                                style:  TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                        ),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                '${rideList[index]['selected_time']}',
                                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                               'Date of trip: ${DateFormat('dd.MM.yyyy').format(rideList[index]['ride_date'].toDate())}',
                                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                'Pending Requests: Tap to see',
                                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                            ],
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.purple,
                            size: screenWidth * 0.07,
                          ),
                          tileColor: Colors.purple.shade50,
                          onTap: () {
                            String rideId = rideList[index].id;
                            navigateToRequests(rideId);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
          }  else if (i == 1) {
            Navigator.pushReplacement(context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return AddRide();
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
          }else if (i == 0) {
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
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box,color: Colors.grey,),
            label: "Profile",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,color: Colors.grey,),
            label: "Add Ride",
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart_rounded,color: Colors.purple,),
            label: "Offerd Rides",
            backgroundColor: Colors.purple,
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

  void navigateToRequests(String rideId) {
    Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return RideRequests(rideid: rideId);
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
}
