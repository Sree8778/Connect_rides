// widgets/ride_card.dart
import 'package:flutter/material.dart';
import '../models/ride.dart';

class RideCard extends StatelessWidget {
  final Ride ride;
  final String currentUserId;
  final Function() onAccept;
  final Function() onChat;

  const RideCard({
    Key? key,
    required this.ride,
    required this.currentUserId,
    required this.onAccept,
    required this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the current user is the ride requester
    bool isRequester = ride.riderId == currentUserId;

    return Card(
      child: ListTile(
        title: Text('${ride.fromLocation} to ${ride.toLocation}'),
        subtitle: Text(
          '${ride.dateTime.toLocal()}'.split(' ')[0] +
              ' ' +
              '${ride.dateTime.toLocal()}'.split(' ')[1].substring(0, 5),
        ),
        trailing: isRequester
            ? Text(
          'Yours',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check, color: Colors.blue),
              tooltip: 'Accept Ride',
              onPressed: onAccept,
            ),
            IconButton(
              icon: Icon(Icons.chat, color: Colors.blue),
              tooltip: 'Join Ride Chat',
              onPressed: onChat,
            ),
          ],
        ),
      ),
    );
  }
}
