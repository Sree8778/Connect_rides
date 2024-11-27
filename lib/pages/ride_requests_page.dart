import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RideRequestsPage extends StatefulWidget {
  const RideRequestsPage({super.key});

  @override
  _RideRequestsPageState createState() => _RideRequestsPageState();
}

class _RideRequestsPageState extends State<RideRequestsPage> {
  List<Map<String, dynamic>> rideRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRideRequests();
  }

  // Fetch ride requests from Firebase
  void fetchRideRequests() async {
    DatabaseReference rideRef = FirebaseDatabase.instance.ref().child("rideRequests");

    rideRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          rideRequests = data.values.map((e) => Map<String, dynamic>.from(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          rideRequests = [];
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Requests"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : rideRequests.isEmpty
          ? const Center(child: Text("No ride requests available"))
          : ListView.builder(
        itemCount: rideRequests.length,
        itemBuilder: (context, index) {
          final ride = rideRequests[index];
          DateTime dateTime = DateTime.parse(ride['dateTime']); // Assuming dateTime is stored as a string in Firebase
          String formattedTime = "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"; // Format time to hh:mm
          return ListTile(
            title: Text("${ride['pickup']} ➔ ${ride['dropoff']}"),
            subtitle: Text("Fare: \$${ride['fare']} | Persons: ${ride['numberOfPersons']} | Time: $formattedTime"),
          );
        },
      ),
    );
  }
}
