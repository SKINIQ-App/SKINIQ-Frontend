import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img; // For image rotation
import 'package:skiniq/screen/image_text_user/skin_description_screen.dart';
import 'package:skiniq/services/skin_service.dart'; // Import SkinService

class UploadSelfieScreen1 extends StatefulWidget {
  final String username;
  const UploadSelfieScreen1({super.key, required this.username});

  @override
  State<UploadSelfieScreen1> createState() => _UploadSelfieScreenState();
}

class _UploadSelfieScreenState extends State<UploadSelfieScreen1> {
  File? _image;
  List<CameraDescription>? cameras;
  CameraDescription? selectedCamera;
  bool isFrontCamera = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    cameras = await availableCameras();
    setState(() {
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras!.first,
      );
    });
  }

  Future<void> _switchCamera() async {
    setState(() {
      isFrontCamera = !isFrontCamera;
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == (isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras!.first,
      );
    });
  }

  Future<File> _fixImageRotation(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes)!;

    // Check EXIF orientation and rotate if needed
    final exif = image.exif;
    final orientationTag = exif?.getTag(0x0112); // Get the orientation tag
    final orientation = orientationTag?.toInt() ?? 1; // Use toInt() to get the value, default to 1 if null
    img.Image rotatedImage = image;

    switch (orientation) {
      case 3:
        rotatedImage = img.copyRotate(image, angle: 180);
        break;
      case 6:
        rotatedImage = img.copyRotate(image, angle: 90);
        break;
      case 8:
        rotatedImage = img.copyRotate(image, angle: -90);
        break;
      default:
        break;
    }

    // Save the rotated image
    final rotatedFile = File(imageFile.path)..writeAsBytesSync(img.encodeJpg(rotatedImage));
    return rotatedFile;
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File imageFile = File(result.files.single.path!);
      imageFile = await _fixImageRotation(imageFile); // Fix rotation
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<void> _captureImage() async {
    if (selectedCamera == null) return;

    final cameraController = CameraController(selectedCamera!, ResolutionPreset.medium);
    await cameraController.initialize();

    if (!mounted) return;

    final image = await cameraController.takePicture();
    File imageFile = File(image.path);
    imageFile = await _fixImageRotation(imageFile); // Fix rotation

    setState(() {
      _image = imageFile;
    });

    await cameraController.dispose();
  }

  Future<void> _uploadSelfie() async {
    if (_image == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      await SkinService.predictSkinType(widget.username, _image!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to analyze skin: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
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
                            icon: Icon(
                              isFrontCamera ? Icons.camera_rear : Icons.camera_front,
                              color: Colors.white,
                              size: 45,
                            ),
                            onPressed: _switchCamera,
                          ),
                          const Text("Switch", style: TextStyle(color: Colors.white70)),
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
                    onPressed: _isUploading
                        ? null
                        : () async {
                            if (_image != null) {
                              await _uploadSelfie();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SkinDescriptionScreen(username: widget.username),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please upload or capture a photo!")),
                              );
                            }
                          },
                    child: _isUploading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
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