import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:permission_work/servicies/get_location.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  ValueNotifier<File?> file = ValueNotifier(null);
  ValueNotifier<LatLng?> position = ValueNotifier(null);
  ValueNotifier<Set<Marker>> markers = ValueNotifier({});
  GoogleMapController? mapController;
  GetCurrentLocationService currentLocation = GetCurrentLocationService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    var loc = await currentLocation.getCurrentLocation();
    if (loc != null) {
      position.value = LatLng(loc.latitude!, loc.longitude!);
      markers.value = {
        Marker(
          markerId: const MarkerId("current_location"),
          position: position.value!,
        ),
      };
    }
  }

  Future<void> goToMakkah() async {
    final LocationData currentLoc =
        await GetCurrentLocationService().getCurrentLocation();

    var userPosition = LatLng(currentLoc.latitude!, currentLoc.longitude!);
    markers.value = {
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: userPosition,
      ),
      Marker(
        markerId: const MarkerId("makkahLocation"),
        position: const LatLng(21.4225, 39.8262),
        icon: AssetMapBitmap("assets/flag.png", width: 50, height: 50),
      ),
    };

    log("User Location: ${currentLoc.latitude}, ${currentLoc.longitude}");

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(21.4225, 39.8262),
            zoom: 12.0,
          ),
        ),
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Permission Handlers"),
          backgroundColor: Colors.teal,
        ),
        body: ValueListenableBuilder<LatLng?>(
          valueListenable: position,
          builder: (context, value, child) {
            return ValueListenableBuilder<Set<Marker>>(
              valueListenable: markers,
              builder: (context, markerSet, child) {
                if (value != null) {
                  return GoogleMap(
                    mapType: MapType.satellite,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: value,
                      zoom: 10.0,
                    ),
                    markers: markerSet,
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.center_focus_strong_outlined),
          onPressed: goToMakkah,
        ));
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ruxsat berilmagan"),
          content: const Text(
              "Ilovaga galereyadan rasm olish uchun ruxsat berishingiz kerak."),
          actions: [
            TextButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: const Text("Sozlamalarni ochish"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Bekor qilish"),
            ),
          ],
        );
      },
    );
  }
}
