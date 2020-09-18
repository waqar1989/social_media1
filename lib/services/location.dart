import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

TextEditingController locationTextEditingController = TextEditingController();

getUserCurrentLocation() async {
  Position position =
      await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark mPlaceMark = placemarks[0];
  String completeAddressinfo =
      '${mPlaceMark.subThoroughfare} ${mPlaceMark.thoroughfare}, ${mPlaceMark.subLocality} ${mPlaceMark.locality}, ${mPlaceMark.subAdministrativeArea} ${mPlaceMark.administrativeArea}, ${mPlaceMark.postalCode} ${mPlaceMark.country}';
  String speceficAddress = '${mPlaceMark.locality}, ${mPlaceMark.country}';
  locationTextEditingController.text = speceficAddress;
}
