import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:skiniq/screen/image_text_user/skin_description_screen.dart';

class UploadSelfieScreen1 extends StatefulWidget {
  const UploadSelfieScreen1({super.key});

  @override
  State<UploadSelfieScreen1> createState() => _UploadSelfieScreenState();
}

class _UploadSelfieScreenState extends State<UploadSelfieScreen1> {
  File? _image;

  /// Function to pick image from gallery
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _image = File(result.files.single.path!);
      });
    }
  }

  /// Function to capture image using Camera
  Future<void> _captureImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await cameraController.initialize();


    final image =  await cameraController.takePicture();
    setState(() {
      _image = File(image.path);
    });

    await cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/img/Background1.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Main Content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// App Logo
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    width: 120, // Increased logo size
                    height: 120,
                  ),

                  const SizedBox(height: 20),

                  /// App Name
                  const Text(
                    "SKINIQ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30, // Increased font size
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Subtitle
                  const Text(
                    "Your Skin Our Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18, // Slightly larger subtitle
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// Distinct Subtitle: Let's Analyze Your Skin
                  const Text(
                    "Let's Analyze Your Skin!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromARGB(195, 255, 255, 255), // Changed to yellow for distinction
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Display selected image
                  _image != null
                      ? CircleAvatar(
                          radius: 80, // Increased the circle size
                          backgroundImage: FileImage(_image!),
                        )
                      : const CircleAvatar(
                          radius: 80,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white70,
                            size: 60, // Enlarged icon
                          ),
                        ),

                  const SizedBox(height: 30),

                  /// Upload and Capture Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute evenly
                    children: [
                      /// Capture Photo
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.camera, color: Colors.white, size: 45),
                            onPressed: _captureImage,
                          ),
                          const Text("Capture", style: TextStyle(color: Colors.white70)),
                        ],
                      ),

                      /// Upload from Gallery
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

                  /// Continue Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    onPressed: () {
                      if (_image != null) {
                         Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SkinDescriptionScreen()),
                            );// Navigate to next screen
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
                        fontSize: 20, // Larger button text
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