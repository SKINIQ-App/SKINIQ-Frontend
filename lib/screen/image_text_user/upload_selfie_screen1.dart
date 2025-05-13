import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:skiniq/screen/image_text_user/skin_description_screen.dart';
import 'package:skiniq/services/skin_service.dart'; // Import SkinService

class UploadSelfieScreen1 extends StatefulWidget {
  final String username; // Add username parameter
  const UploadSelfieScreen1({super.key, required this.username});

  @override
  State<UploadSelfieScreen1> createState() => _UploadSelfieScreenState();
}

class _UploadSelfieScreenState extends State<UploadSelfieScreen1> {
  File? _image;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
  }

  Future<void> _captureImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await cameraController.initialize();

    final image = await cameraController.takePicture();
    setState(() {
      _image = File(image.path);
    });

    await cameraController.dispose();
  }

  Future<void> _uploadSelfie() async {
    if (_image == null) return;
    try {
      // Call /skin/analyze endpoint
      await SkinService.predictSkinType(_image!);
      // The backend will store the skin type for the user
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to analyze skin: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/Background1.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "SKINIQ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your Skin Our Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Let's Analyze Your Skin!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(195, 255, 255, 255),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _image != null
                      ? CircleAvatar(
                          radius: 80,
                          backgroundImage: FileImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                            size: 60,
                          ),
                        ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera, color: Colors.white, size: 45),
                            onPressed: _captureImage,
                          ),
                          const Text("Capture", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.white, size: 45),
                            onPressed: _pickImage,
                          ),
                          const Text("Upload", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    onPressed: () async {
                      if (_image != null) {
                        await _uploadSelfie();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SkinDescriptionScreen(username: widget.username), // Pass username
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please upload or capture a photo!")),
                        );
                      }
                    },
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}