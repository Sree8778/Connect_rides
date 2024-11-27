import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:users_connect_app/appInfo/app_info.dart';
import 'package:users_connect_app/global.dart';
import 'package:http/http.dart' as http;
import 'package:users_connect_app/model/address_model.dart';

class GoogleMapMethods
{

  static sendRequestToAPI(String apiUrl) async
  {
    http.Response responseFromAPI = await http.get(Uri.parse(apiUrl));
    try
    {
      if(responseFromAPI.statusCode == 200)
      {
        String dataFromApi = responseFromAPI.body;
        var dataDecoded = jsonDecode(dataFromApi);
        return dataDecoded;
      }
      else
      {

        return "error";
      }

    }
    catch(errorMsg)
    {
      print("\n\nError Occoured:\n$errorMsg\n\n");
      return "error";
    }
  }

  ///Reverse Geo coding
  static Future<String> convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(Position position,BuildContext context) async
  {
    String humanReadableAddress = "";
    String geoCodingApiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleMapKey";

    var responseFromAPI = await sendRequestToAPI(geoCodingApiUrl);

    if(responseFromAPI != "error")
    {
      humanReadableAddress = responseFromAPI["results"][0]["formatted_address"];

      print("humanReadableAddress =" + humanReadableAddress);
      AddressModel addressModel = AddressModel();
      addressModel.humanReadableAddress = humanReadableAddress;
      addressModel.placeName = humanReadableAddress;
      addressModel.placeID = responseFromAPI["results"][0]["place_id"];
      addressModel.latitudePosition = position.latitude;
      addressModel.longitudePosition = position.longitude;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocation(addressModel);

    }
    else
    {
      print("\n\nError Occoured\n\n");
    }

    return humanReadableAddress;


  }

}