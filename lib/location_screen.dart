import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  ValueNotifier<File?> file = ValueNotifier(null);
  ValueNotifier<Position?> position = ValueNotifier(null);
  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Permission Handlers"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async => await _getFromGallery(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Pick Image"),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<File?>(
            valueListenable: file,
            builder: (context, value, child) {
              if (value != null) {
                return Image.file(value,
                    height: 200, width: 200, fit: BoxFit.cover);
              }
              return const Text("No image taken so far");
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () async => await _getCurrentLocation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Get Location"),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ValueListenableBuilder<Position?>(
              valueListenable: position,
              builder: (context, value, child) {
                if (value != null) {
                  return GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(value.latitude, value.longitude),
                      zoom: 14.0,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId("current_location"),
                        position: LatLng(value.latitude, value.longitude),
                      )
                    },
                  );
                }
                return const Text("Location not available");
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getFromGallery() async {
    try {
      PermissionStatus status = await Permission.storage.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        if (await Permission.storage.request().isDenied) {
          showAlertDialog();
          return;
        }
      }

      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        file.value = File(pickedFile.path);
        log("Rasm tanlandi: \${pickedFile.path}");
      } else {
        log("Rasm tanlanmadi");
      }
    } catch (e) {
      log("Xatolik (Gallery): \$e");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (serviceEnabled == false) {
        log("Location services are disabled");
        return;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          log("Location permissions are permanently denied");
          return;
        }
      }

      Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      position.value = currentPosition;
      log("Current location: \${currentPosition.latitude}, \${currentPosition.longitude}");
    } catch (e) {
      log("Xatolik (Location): \$e");
      throw Exception(e.toString());
    }
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
