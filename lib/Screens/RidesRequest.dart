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

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('ride_id', isEqualTo: widget.rideid)
        .where('status', isNotEqualTo: 'cart')
        .get();

    setState(() {
      allrequests = snapshot.docs;
    });
  }

  Future<void> acceptRequest(DocumentSnapshot request) async {
    await request.reference.update({'status': 'Accepted'});
    fetchRequests(); // Refresh the list after updating
  }

  Future<void> rejectRequest(DocumentSnapshot request) async {
    await request.reference.update({'status': 'Rejected'});
    fetchRequests(); // Refresh the list after updating
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
                      backgroundColor: status == 'Rejected'
                        ? Colors.red.shade400
                        : Colors.green.shade400,
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
}
