import 'package:flutter/material.dart';
import 'package:project_driverside/Screens/Add ride.dart';
import 'package:project_driverside/Screens/profile.dart';
import 'package:project_driverside/Screens/login.dart';
import 'package:project_driverside/Screens/RidesRequest.dart';

class OfferedRides extends StatefulWidget {
  @override
  _OfferedRidesState createState() => _OfferedRidesState();
}

class _OfferedRidesState extends State<OfferedRides> {
  var rideList = <Map<String, dynamic>>[]; // Replace with actual data structure
  String email = '';

  @override
  void initState() {
    email = 'example@email.com';
    getDummyCartData();
    super.initState();
  }

  void getDummyCartData() {
    final dummyData = <Map<String, dynamic>>[
      {
        'start': 'Ainshams univirsty',
        'end': 'New cairo',
        'time': '5:00 PM',
        'email': 'user1@example.com',
        'Date':'12/12/2023',
        'id': 1,
        'pendingRequests': 4, // Number of pending requests for this ride
      },
      {
        'start': 'New cairo',
        'end': 'Ainshams univirsty',
        'time': '7:00 PM',
        'email': 'user1@example.com',
        'Date':'13/12/2023',
        'id': 2,
        'pendingRequests': 4, // Number of pending requests for this ride
      },
    ];

    setState(() {
      rideList = dummyData;
    });
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
      body: SingleChildScrollView(
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
                                '${rideList[index]['start']} To ${rideList[index]['end']}',
                                style:  TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.bold,
                        ),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                '${rideList[index]['time']}',
                                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                'Date of trip: ${rideList[index]['Date']}',
                                style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.grey[600]),
                              ),
                              SizedBox(height: screenHeight * 0.001),
                              Text(
                                'Pending Requests: ${rideList[index]['pendingRequests']}',
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
                            navigateToRequests(rideList[index]);
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

  void navigateToRequests(Map<String, dynamic> ride) {
    Navigator.push(context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return RideRequests(pendingRequests: ride['pendingRequests'] ?? 0);
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
