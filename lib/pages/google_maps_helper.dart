import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsHelper {
  static Future<List<LatLng>> getRouteCoordinates(String start, String end, String apiKey) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$start&destination=$end&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> routeCoordinates = [];

      if (data['routes'].isNotEmpty) {
        var route = data['routes'][0]['legs'][0]['steps'];
        for (var step in route) {
          var polyline = step['polyline']['points'];
          routeCoordinates.addAll(decodePoly(polyline));
        }
      }

      return routeCoordinates;
    } else {
      throw Exception('Failed to load directions');
    }
  }

  static List<LatLng> decodePoly(String poly) {
    List<LatLng> coordinates = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = poly.codeUnitAt(index) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index++ < len);

      int dlat = ((result >> 1) ^ (~(result >> 1) << 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index++ < len);

      int dlng = ((result >> 1) ^ (~(result >> 1) << 1));
      lng += dlng;

      LatLng coordinate = LatLng((lat / 1E5), (lng / 1E5));
      coordinates.add(coordinate);
    }

    return coordinates;
  }
}
