import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_connect_app/methods/associate_methods.dart';

AssociateMethods associateMethods = AssociateMethods();

String userName = "";
String userPhone = "";
String googleMapKey = "AIzaSyDJ3A_r-loBWsqQR4Y0nEIFsWFc_Ss2Dhk";
const CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,
);