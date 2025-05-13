import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:skiniq/services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final profile = await ProfileService.getProfile(widget.username);
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load profile: ${e.toString()}")),
      );
    }
  }

  Future<File> _fixImageRotation(File imageFile) async {
    final rotatedImage = await FlutterExifRotation.rotateImage(path: imageFile.path);
    return rotatedImage;
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.black87),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.black87),
              title: const Text("Upload from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File imageFile = File(result.files.single.path!);
      imageFile = await _fixImageRotation(imageFile);
      setState(() {
        _profileImage = imageFile;
      });
      await _uploadProfilePicture(imageFile);
    }
  }

  Future<void> _captureImage() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    final File? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(
          camera: firstCamera,
          onImageCaptured: (File image) {},
        ),
      ),
    );

    if (capturedImage != null) {
      File imageFile = await _fixImageRotation(capturedImage);
      setState(() {
        _profileImage = imageFile;
      });
      await _uploadProfilePicture(imageFile);
    }
  }

  Future<void> _uploadProfilePicture(File image) async {
    try {
      await ProfileService.updateProfilePicture(widget.username, image);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload profile picture: ${e.toString()}")),
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 25),
                        _buildUserProfile(context),
                        const SizedBox(height: 30),
                        _buildRoutineSection(
                          "Daily Routine",
                          FontAwesomeIcons.sun,
                          Colors.orangeAccent,
                          _userProfile?['recommended_routine'] ?? [],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "My Profile",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.gear, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(FontAwesomeIcons.rightFromBracket, color: Colors.white),
              onPressed: () {
                // Implement logout functionality
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserProfile(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : _userProfile?['profile_image'] != null
                        ? NetworkImage(_userProfile!['profile_image'])
                        : const AssetImage("assets/img/user_image.jpg") as ImageProvider,
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: GestureDetector(
                  onTap: () => _showImageSourceActionSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 20, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Hello, ${_userProfile?['username'] ?? 'User'}!",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Text(
              "Skin Type: ${_userProfile?['predicted_skin_type'] ?? 'Unknown'}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(String title, IconData icon, Color color, List<dynamic> routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          routine.isEmpty
              ? Center(
                  child: Text(
                    "No routine available",
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                  ),
                )
              : Column(
                  children: routine.map((step) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF6C9478),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
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