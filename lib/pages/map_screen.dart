import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../appInfo/app_info.dart';
import '../global.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Map")),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
          _getCurrentLocation();
        },
        initialCameraPosition: kGooglePlex,
        markers: {
          if (Provider.of<AppInfo>(context).pickUpLocation != null)
            Marker(
              markerId: MarkerId('pickup'),
              position: LatLng(
                Provider.of<AppInfo>(context).pickUpLocation!.latitudePosition!,
                Provider.of<AppInfo>(context).pickUpLocation!.longitudePosition!,
              ),
            ),
          if (Provider.of<AppInfo>(context).dropOffLocation != null)
            Marker(
              markerId: MarkerId('dropoff'),
              position: LatLng(
                Provider.of<AppInfo>(context).dropOffLocation!.latitudePosition!,
                Provider.of<AppInfo>(context).dropOffLocation!.longitudePosition!,
              ),
            ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.location_searching),
      ),
    );
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)));
  }
}
