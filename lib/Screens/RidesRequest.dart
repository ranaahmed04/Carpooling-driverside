import 'package:flutter/material.dart';

class RideRequests extends StatefulWidget {
  final int pendingRequests;

  RideRequests({required this.pendingRequests});

  @override
  _RideRequestsState createState() => _RideRequestsState();
}

class _RideRequestsState extends State<RideRequests> {
  final List<Map<String, String>> pendingRequests = [
    {'name': 'Rana Ahmed', 'email': 'rana@example.com', 'phone': '123-456-7890', 'status': 'Pending'},
    {'name': 'Ahmed mohamed', 'email': 'ahmed@example.com', 'phone': '987-654-3210', 'status': 'Approved'},
    {'name': 'Alaa Hamdy', 'email': 'alaa@example.com', 'phone': '987-777-8880', 'status': 'Rejected'},
    {'name': 'Rawda ahmed', 'email': 'rawda@example.com', 'phone': '997-444-8240', 'status': 'Pending'},
    // Add more dummy data as needed
  ];

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
                  borderRadius: BorderRadius.circular(screenWidth * 0.07), // Updated to screenWidth
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
                shrinkWrap: true, // Added this line
                physics: NeverScrollableScrollPhysics(), // Added this line
                itemCount: pendingRequests.length,
                itemBuilder: (BuildContext context, int index) {
                  final request = pendingRequests[index];
                  void acceptRequest() {
                    setState(() {
                      request['status'] = 'Approved';
                    });
                  }
                  void rejectRequest() {
                    setState(() {
                      request['status'] = 'Rejected';
                    });
                  }

                  return buildRequestCard(request, acceptRequest, rejectRequest);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build each individual request card
  Widget buildRequestCard(Map<String, String> request, Function() acceptRequest, Function() rejectRequest) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 7,
      margin: EdgeInsets.only(bottom: 25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.07), // Updated to screenWidth
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.01),
        child: ListTile(
          title: Text('${request['name']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email: ${request['email']}'),
              Text('Phone: ${request['phone']}'),
            ],
          ),
          trailing: request['status'] == 'Pending'
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: acceptRequest,
                style: ElevatedButton.styleFrom(
                  primary: Colors.green.shade400,
                ),
                child: Text('Accept'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: rejectRequest,
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade400,
                ),
                child: Text('Reject'),
              ),
            ],
          )
              : Chip(
            label: Text(
              '${request['status']}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: request['status'] == 'Rejected' ? Colors.red.shade400 : Colors.green.shade400,
          ),
          tileColor: Colors.purple.shade50,
        ),
      ),
    );
  }
}

