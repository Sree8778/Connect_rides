// models/ride.dart
class Ride {
  final String id;
  final String fromLocation;
  final String toLocation;
  final DateTime dateTime;
  final String riderId; // ID of the user who requested the ride

  Ride({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.dateTime,
    required this.riderId,
  });

  // Factory method to create Ride from JSON (for backend integration)
  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      dateTime: DateTime.parse(json['dateTime']),
      riderId: json['riderId'],
    );
  }
}
