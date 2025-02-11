import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<File?> file = ValueNotifier(null);

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
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("Pick Image"),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<File?>(
            valueListenable: file,
            builder: (context, value, child) {
              if (value != null) {
                return Image.file(value, height: 200, width: 200, fit: BoxFit.cover);
              }
              return const Text("No image taken so far");
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getFromGallery() async {
    PermissionStatus status = await Permission.camera.status;

    if (status.isDenied || status.isPermanentlyDenied) {
      if (await Permission.storage.request().isDenied) {
        showAlertDialog();
        return;
      }
    }

    try {
      XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile != null) {
        file.value = File(pickedFile.path);
        log("Rasm tanlandi: ${pickedFile.path}");
      } else {
        log("Rasm tanlanmadi");
      }
    } catch (e) {
      log("Xatolik: $e");
    }
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ruxsat berilmagan"),
          content: const Text("Ilovaga galereyadan rasm olish uchun ruxsat berishingiz kerak."),
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
