import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RideRequests extends StatefulWidget {
  final String rideid;

  RideRequests({required this.rideid});

  @override
  _RideRequestsState createState() => _RideRequestsState();
}

class _RideRequestsState extends State<RideRequests> {
  late List<DocumentSnapshot> allrequests = [];
  //DateTime? _selectedDate; // Variable to hold the selected date for filtering

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }
  Future<void> fetchRequests() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('status', isNotEqualTo: 'cart')
        .get();

    List<DocumentSnapshot> allRequests = snapshot.docs;
    DateTime currentTime = DateTime.now();

    for (DocumentSnapshot request in allRequests) {
      final rideDate = (request['Ride_date'] as Timestamp).toDate();
      final rideTime = request['Rideselected_time'] as String;
      DateTime rideDateTime = DateTime(rideDate.year, rideDate.month, rideDate.day);

      // Parse the selected time string to get the time components
      final timeComponents = rideTime.split(':');
       int hours = int.parse(timeComponents[0]);
      hours=hours+12;
      final int minutes = int.parse(timeComponents[1].split(' ')[0]);

      rideDateTime = rideDateTime.add(Duration(hours: hours, minutes: minutes));

      final rideStatus = request['status'];

      // Check if the request has a ride date and the status is 'pending' or 'accepted'
      if (rideDateTime != null && (rideStatus == 'pending' || rideStatus == 'Accepted')) {

        if (currentTime.isAfter(rideDateTime)) {
          // Trip date has passed
          if (rideStatus == 'pending') {
            await request.reference.update({'status': 'Expired'});
          } else if (rideStatus == 'accepted') {
            await request.reference.update({'status': 'Completed'});
          }
        }
      }
    }
    // Refresh the list after updating statuses
    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('requests')
        .where('ride_id', isEqualTo: widget.rideid)
        .where('status', isNotEqualTo: 'cart')
        .get();

    setState(() {
      allrequests = snapshot2.docs;
    });
  }
  Future<void> acceptRequest(DocumentSnapshot request) async {
    if (canAccept(request)) {
      await request.reference.update({'status': 'Accepted'});
      fetchRequests(); // Refresh the list after updating
    } else {
      // Show a dialog or message indicating the request cannot be accepted
      showStatusErrorDialog(context, 'accept');
    }
  }

  Future<void> rejectRequest(DocumentSnapshot request) async {
    if (canReject(request)) {
      await request.reference.update({'status': 'Rejected'});
      fetchRequests(); // Refresh the list after updating
    } else {
      // Show a dialog or message indicating the request cannot be rejected
      showStatusErrorDialog(context, 'reject');
    }
  }

  bool canAccept(DocumentSnapshot request) {

    // Email for which you want to bypass the restrictions
    String allowedEmail = 'testdriver@eng.asu.edu.eg';

    // Check if the user's email matches the allowed email
    if (request['Ridedriver_email'] == allowedEmail) {
      return true; // Allow this email to bypass restrictions
    }
    Timestamp? rideTimestamp = request['Ride_date'] as Timestamp?;
    String? rideTimeString = request['Rideselected_time'] as String?;

    if (rideTimestamp == null || rideTimeString == null) {
      // Handle null values
      print('Missing ride date or time.');
      return false;
    }

    DateTime rideDateTime = rideTimestamp.toDate();
    int rideDay = rideDateTime.day;
    int rideMonth = rideDateTime.month;
    int rideYear = rideDateTime.year;

    List<String> timeComponents = rideTimeString.split(':');
    int rideHour = int.parse(timeComponents[0]);
    int rideMinute = int.parse(timeComponents[1].split(' ')[0]);

    DateTime currentTime = DateTime.now();
    DateTime reservationCutoff=DateTime.now();

    if (rideHour < 7 || (rideHour == 7 && rideMinute <= 30)) {
      reservationCutoff = DateTime(rideYear, rideMonth, rideDay - 1, 23, 30); // Before 11:30 PM of the previous day
    } else if (rideHour < 17 || (rideHour == 17 && rideMinute <= 30)) {
      reservationCutoff = DateTime(rideYear, rideMonth, rideDay, 16, 30); // Before 4:30 PM of the same day
    }
    bool isValid = currentTime.isBefore(reservationCutoff);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation is overdue.'),
        ),
      );
    }

    return isValid;
  }


  bool canReject(DocumentSnapshot request) {

    // Email for which you want to bypass the restrictions
    String allowedEmail = 'testdriver@eng.asu.edu.eg';

    // Check if the user's email matches the allowed email
    if (request['Ridedriver_email'] == allowedEmail) {
      return true; // Allow this email to bypass restrictions
    }
    Timestamp? rideTimestamp = request['Ride_date'] as Timestamp?;
    String? rideTimeString = request['Rideselected_time'] as String?;

    if (rideTimestamp == null || rideTimeString == null) {
      // Handle null values
      print('Missing ride date or time.');
      return false;
    }

    DateTime rideDateTime = rideTimestamp.toDate();
    int rideDay = rideDateTime.day;
    int rideMonth = rideDateTime.month;
    int rideYear = rideDateTime.year;

    List<String> timeComponents = rideTimeString.split(':');
    int rideHour = int.parse(timeComponents[0]);
    int rideMinute = int.parse(timeComponents[1].split(' ')[0]);

    DateTime currentTime = DateTime.now();
    DateTime reservationCutoff=DateTime.now();

    if (rideHour < 7 || (rideHour == 7 && rideMinute <= 30)) {
      // For rides before 7:30 AM
      reservationCutoff = DateTime(rideYear, rideMonth, rideDay - 1, 23, 30); // Before 11:30 PM of the previous day
    } else if (rideHour < 17 || (rideHour == 17 && rideMinute <= 30)) {
      // For rides before 5:30 PM
      reservationCutoff = DateTime(rideYear, rideMonth, rideDay, 16, 30); // Before 4:30 PM of the same day
    }
    bool isValid = currentTime.isBefore(reservationCutoff);

    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation is overdue.'),
        ),
      );
    }

    return isValid;
  }

  void showStatusErrorDialog(BuildContext context, String action) {
    String errorMessage = action == 'accept'
        ? 'You cannot accept the request at this time.'
        : 'You cannot reject the request at this time.';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Status Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRequestCard(DocumentSnapshot request) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final String status = request['status']; // Get the status

    return Card(
      elevation: 7,
      margin: EdgeInsets.only(bottom: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.07),
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.01),
        child: ListTile(
          title: Text('${request['userName']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${request['userEmail']}'),
              Text('Phone: ${request['userphone']}'),
            ],
          ),
          trailing: status == 'pending' // Check if status is 'Pending'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => acceptRequest(request),
                style: ElevatedButton.styleFrom(
                  primary: Colors.green.shade400,
                ),
                child: Text('Accept'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => rejectRequest(request),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade400,
                ),
                child: Text('Reject'),
              ),
            ],
          )
              : Chip(
                   label: Text(
                   status, // Show the status
                    style: TextStyle(color: Colors.white),
                       ),
                      backgroundColor: getStatusColor(status), // Get color based on status
                      ),
          tileColor: Colors.purple.shade50,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Requests'),
        centerTitle: true,
        /*actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _selectDate(context);
            },
          ),
          if (_selectedDate != null) // Show clear button only when date is selected
            IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedDate = null; // Clear selected date
                });
              },
            ),
        ],*/
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenWidth * 0.07),
                ),
                child: Center(
                  child: Text(
                    'Pending Requests',
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: allrequests.length,
                itemBuilder: (BuildContext context, int index) {
                  final request = allrequests[index];

                  return buildRequestCard(request);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
        return Colors.red.shade400;
      case 'accepted':
        return Colors.green.shade400;
      case 'completed':
        return Colors.purple;
      case 'expired':
        return Colors.black54;
      default:
        return Colors.grey.shade400;
    }
  }
}
