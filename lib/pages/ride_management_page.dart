import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import '../methods/google_maps_methods.dart';
import '../auth/signin_page.dart';
import 'destination_selection_page.dart';

class RideManagementPage extends StatefulWidget {
  const RideManagementPage({super.key});

  @override
  State<RideManagementPage> createState() => _RideManagementPageState();
}

class _RideManagementPageState extends State<RideManagementPage> {
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionofUser;
  LatLng? pickupLocation;
  LatLng? dropOffLocation;
  String fromAddress = "Fetching current location...";
  String toAddress = "Where to go?";
  Set<Marker> markers = {};
  Polyline? routePolyline;
  double fare = 0.0;
  DateTime? selectedDateTime;
  int numberOfPersons = 1;
  bool isLoading = false;

  final GooglePlace googlePlace = GooglePlace('AIzaSyDJ3A_r-loBWsqQR4Y0nEIFsWFc_Ss2Dhk'); // Replace with your API key

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    getUserInfoAndCheckBlockStatus();
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPositionofUser = userPosition;

      LatLng userLatLng = LatLng(currentPositionofUser!.latitude, currentPositionofUser!.longitude);
      CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);

      controllerGoogleMap?.animateCamera(CameraUpdate.newCameraPosition(positionCamera));
      await GoogleMapMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(currentPositionofUser!, context);

      setState(() {
        pickupLocation = userLatLng;
        fromAddress = "Current Location";
        markers.add(Marker(
          markerId: const MarkerId("pickup"),
          position: pickupLocation!,
          infoWindow: const InfoWindow(title: "From"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
    } catch (e) {
      associateMethods.showSnackBarMsg("Error getting location: $e", context);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getUserInfoAndCheckBlockStatus() async {
    DatabaseReference reference = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await reference.once().then((dataSnap) {
      if (dataSnap.snapshot.value != null) {
        if ((dataSnap.snapshot.value as Map)["blockStatus"] == "no") {
          // User is not blocked
        } else {
          associateMethods.showSnackBarMsg("You are blocked. Contact admin: sreeram3354@gmail.com", context);
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SigninPage()));
      }
    });
  }

  Future<void> handleLocationSelection(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DestinationSelectionPage(isPickup: isPickup)),
    );

    if (result != null) {
      var placeDetails = await googlePlace.details.get(result.placeId!);
      if (placeDetails?.result?.geometry?.location != null) {
        double lat = placeDetails!.result!.geometry!.location!.lat!;
        double lng = placeDetails!.result!.geometry!.location!.lng!;
        LatLng selectedLatLng = LatLng(lat, lng);

        if (isPickup) {
          setState(() {
            pickupLocation = selectedLatLng;
            fromAddress = placeDetails!.result!.formattedAddress ?? "Pickup Location";
            markers.add(Marker(
              markerId: const MarkerId('pickup'),
              position: selectedLatLng,
              infoWindow: const InfoWindow(title: "From"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ));
          });
        } else {
          setState(() {
            dropOffLocation = selectedLatLng;
            toAddress = placeDetails!.result!.formattedAddress ?? "Destination";
            markers.add(Marker(
              markerId: const MarkerId('dropoff'),
              position: selectedLatLng,
              infoWindow: const InfoWindow(title: "To"),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ));
          });

          if (pickupLocation != null) {
            drawRoute();
            calculateFare();
            controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(dropOffLocation!));
          }
        }
      }
    }
  }

  Future<void> drawRoute() async {
    if (pickupLocation != null && dropOffLocation != null) {
      String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${pickupLocation!.latitude},${pickupLocation!.longitude}&'
          'destination=${dropOffLocation!.latitude},${dropOffLocation!.longitude}&'
          'key=AIzaSyDJ3A_r-loBWsqQR4Y0nEIFsWFc_Ss2Dhk'; // Replace with your API key

      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);
          if (data['routes'].isNotEmpty) {
            List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
            List<LatLng> polylinePoints = steps.map((step) {
              var startLocation = step['start_location'];
              return LatLng(startLocation['lat'], startLocation['lng']);
            }).toList();

            polylinePoints.add(dropOffLocation!);

            setState(() {
              routePolyline = Polyline(
                polylineId: const PolylineId('route'),
                points: polylinePoints,
                color: Colors.blue,
                width: 4,
              );
            });
          } else {
            associateMethods.showSnackBarMsg("No routes found", context);
          }
        } else {
          associateMethods.showSnackBarMsg("Error fetching directions: ${response.statusCode}", context);
        }
      } catch (e) {
        associateMethods.showSnackBarMsg("Error drawing route: $e", context);
      }
    }
  }

  void calculateFare() {
    if (pickupLocation != null && dropOffLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        pickupLocation!.latitude,
        pickupLocation!.longitude,
        dropOffLocation!.latitude,
        dropOffLocation!.longitude,
      );

      double distanceInMiles = distanceInMeters / 1609.34;
      setState(() => fare = distanceInMiles * 1);
    }
  }

  Future<void> selectDateTime() async {
    DateTime? picked = await showDateTimePicker();
    if (picked != null && picked != selectedDateTime) {
      setState(() => selectedDateTime = picked);
    }
  }

  Future<DateTime?> showDateTimePicker() {
    return showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((date) {
      if (date != null) {
        return showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
        ).then((time) {
          if (time != null) {
            return DateTime(date.year, date.month, date.day, time.hour, time.minute);
          }
          return null;
        });
      }
      return null;
    });
  }

  void requestRide() {
    if (pickupLocation != null && dropOffLocation != null && selectedDateTime != null) {
      Map<String, dynamic> rideData = {
        "pickup": fromAddress,
        "dropoff": toAddress,
        "fare": fare,
        "dateTime": selectedDateTime!.toIso8601String().replaceFirst(RegExp(r'Z$'), ''),
        "numberOfPersons": numberOfPersons,
        "pickupLocation": {
          "latitude": pickupLocation!.latitude,
          "longitude": pickupLocation!.longitude,
        },
        "dropOffLocation": {
          "latitude": dropOffLocation!.latitude,
          "longitude": dropOffLocation!.longitude,
        },
      };

      DatabaseReference rideRef = FirebaseDatabase.instance.ref().child("rideRequests").push();
      rideRef.set(rideData).then((_) {
        associateMethods.showSnackBarMsg("Ride request sent successfully!", context);
        clearFields();
      }).catchError((error) {
        associateMethods.showSnackBarMsg("Error requesting ride: $error", context);
      });
    } else {
      associateMethods.showSnackBarMsg("Please complete the ride request fields.", context);
    }
  }

  void clearFields() {
    setState(() {
      pickupLocation = null;
      dropOffLocation = null;
      fromAddress = "Fetching current location...";
      toAddress = "Where to go?";
      markers.clear();
      routePolyline = null;
      fare = 0.0;
      selectedDateTime = null;
      numberOfPersons = 1;
    });
    getCurrentLocation();
  }

  void increasePassengers() {
    setState(() {
      if (numberOfPersons < 4) numberOfPersons++;
    });
  }

  void decreasePassengers() {
    setState(() {
      if (numberOfPersons > 1) numberOfPersons--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: clearFields,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: pickupLocation ?? LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 12,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              polylines: routePolyline != null ? {routePolyline!} : {},
              onMapCreated: (controller) {
                googleMapCompleterController.complete(controller);
                controllerGoogleMap = controller;
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.blue),
            title: Text(fromAddress),
            trailing: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => handleLocationSelection(true),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on, color: Colors.red),
            title: Text(toAddress),
            trailing: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => handleLocationSelection(false),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: decreasePassengers,
              ),
              Text('Passengers: $numberOfPersons'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: increasePassengers,
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(selectedDateTime != null
                ? "${selectedDateTime!.toLocal()}".split(' ')[0]
                : "Select date"),
            onTap: selectDateTime,
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text("Fare: \$$fare"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: requestRide,
              child: const Text("Request Ride"),
            ),
          ),
        ],
      ),
    );
  }
}
