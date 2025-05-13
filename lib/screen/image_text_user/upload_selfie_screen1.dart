import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:skiniq/screen/image_text_user/skin_description_screen.dart';
import 'package:skiniq/services/skin_service.dart';
import 'package:logger/logger.dart'; // Added for logging

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
  final _logger = Logger(); // Logger instance

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
    _logger.i('Fixing image orientation: ${imageFile.path}');
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      _logger.e('Failed to decode image');
      return imageFile;
    }

    final exif = image.exif;
    int orientation = 1;
    if (exif.containsKey('Orientation')) {
      final orientationValue = exif['Orientation'];
      if (orientationValue.values.isNotEmpty) {
        orientation = orientationValue.values.first as int? ?? 1;
      }
    }

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
    }

    final rotatedFile = File('${imageFile.path}_rotated.jpg')
      ..writeAsBytesSync(img.encodeJpg(rotatedImage));
    _logger.i('Image orientation fixed: ${rotatedFile.path}');
    return rotatedFile;
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
          initialCamera: selectedCamera!,
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
      _logger.i('Uploading selfie for username: ${widget.username}');
      await SkinService.predictSkinType(widget.username, _image!);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SkinDescriptionScreen(username: widget.username),
        ),
      );
    } catch (e) {
      if (!mounted) return;
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
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
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
                                  if (!mounted) return;
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
            ),
          ),
        ],
      ),
    );
  }
}

class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription initialCamera;
  final Function(File) onImageCaptured;

  const CameraPreviewScreen({
    super.key,
    required this.initialCamera,
    required this.onImageCaptured,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  late int _selectedCameraIndex;
  final _logger = Logger(); // Logger instance

  @override
  void initState() {
    super.initState();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();
    _selectedCameraIndex = _cameras.indexWhere((camera) => camera == widget.initialCamera);
    if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  Future<void> _switchCamera() async {
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _controller.dispose();
    _controller = CameraController(
      _cameras[_selectedCameraIndex],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
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
      if (!mounted) return;
      Navigator.pop(context, File(image.path));
    } catch (e) {
      if (!mounted) return;
      _logger.e("Failed to capture image: ${e.toString()}");
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: _switchCamera,
                          backgroundColor: const Color.fromARGB(255, 198, 232, 189),
                          child: const Icon(Icons.flip_camera_ios, color: Colors.black),
                        ),
                        const SizedBox(width: 20),
                        FloatingActionButton(
                          onPressed: _captureImage,
                          backgroundColor: const Color.fromARGB(255, 198, 232, 189),
                          child: const Icon(Icons.camera, color: Colors.black),
                        ),
                      ],
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