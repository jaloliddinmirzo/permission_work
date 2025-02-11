import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GetCurrentLocationService {
  Location location = Location();

  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  
  Future<void> enableService() async {
    _serviceEnabled = await location.serviceEnabled();
    if (_serviceEnabled == false) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled == false) {
        return;
      }
    }
  }

  Future<void> askPermission() async {
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<LocationData> getCurrentLocation() async {
    await enableService();
    await askPermission();
    return _locationData = await location.getLocation();
  }

  LatLng? primaryMarkerPosition;
  LatLng? secondaryMarkerPosition;
  
  void updatePrimaryMarker(double latitude, double longitude) {
    primaryMarkerPosition = LatLng(latitude, longitude);
  }

  void addSecondaryMarker(double latitude, double longitude) {
    secondaryMarkerPosition = LatLng(latitude, longitude);
  }
  
}
