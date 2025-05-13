import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:skiniq/screen/image_text_user/skin_description_screen.dart';
import 'package:skiniq/services/skin_service.dart';

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
    final rotatedImage = await FlutterExifRotation.rotateImage(path: imageFile.path);
    return rotatedImage;
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File imageFile = File(result.files.single.path!);
      imageFile = await _fixImageRotation(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<void> _captureImage() async {
    if (selectedCamera == null) return;

    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(
          camera: selectedCamera!,
          onImageCaptured: (File image) {},
        ),
      ),
    );

    if (capturedImage != null) {
      File imageFile = await _fixImageRotation(capturedImage);
      setState(() {
        _image = imageFile;
      });
    }
  }

  Future<void> _uploadSelfie() async {
    if (_image == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      await SkinService.predictSkinType(widget.username, _image!);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinDescriptionScreen(username: widget.username),
        ),
      );
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
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
                      backgroundColor: const Color.fromARGB(255, 198, 232, 189),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  final Function(File) onImageCaptured;

  const CameraPreviewScreen({
    super.key,
    required this.camera,
    required this.onImageCaptured,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      widget.onImageCaptured(File(image.path));
      Navigator.pop(context, File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to capture image: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: FloatingActionButton(
                      onPressed: _captureImage,
                      backgroundColor: const Color.fromARGB(255, 198, 232, 189),
                      child: const Icon(Icons.camera, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}