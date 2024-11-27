import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequest {
  String id;
  String userId;
  LatLng pickupLocation;
  LatLng dropOffLocation;
  DateTime dateTime;
  int passengers;
  bool isImmediate;

  RideRequest({
    required this.id,
    required this.userId,
    required this.pickupLocation,
    required this.dropOffLocation,
    required this.dateTime,
    required this.passengers,
    required this.isImmediate,
  });
}
