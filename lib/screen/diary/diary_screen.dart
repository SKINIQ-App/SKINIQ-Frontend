import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:table_calendar/table_calendar.dart';
import 'package:camera/camera.dart'; // Add camera package
import 'package:skiniq/services/diary_service.dart'; // Import DiaryService
import 'package:image/image.dart' as img; // For image rotation

class DiaryScreen extends StatefulWidget {
  final String username;
  const DiaryScreen({super.key, required this.username});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  File? _image;
  final TextEditingController _textController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<CameraDescription>? cameras;
  CameraDescription? selectedCamera;
  bool _isSaving = false;

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

  Future<File> _fixImageRotation(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes)!;

    // Check EXIF orientation and rotate if needed
    final exif = image.exif;
    final orientationTag = exif.getTag(0x0112); // Get the orientation tag
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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      imageFile = await _fixImageRotation(imageFile);
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
    imageFile = await _fixImageRotation(imageFile);

    setState(() {
      _image = imageFile;
    });

    await cameraController.dispose();
  }

  Future<void> _saveEntry() async {
    if (_image == null && _textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add an image or description")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DiaryService.uploadDiaryEntry(
        widget.username,
        _image!,
        _textController.text,
        _selectedDay.toIso8601String(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diary entry saved successfully")),
      );
      setState(() {
        _image = null;
        _textController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save diary entry: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isSaving = false;
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Skin Diary",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _image!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.contain, // Constrain image size
                          ),
                        )
                      : const Center(
                          child: Text(
                            "No Image Selected",
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera, color: Colors.white),
                      label: const Text("Capture Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C9478),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text("Upload Image"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C9478),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Write about your skin changes...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fillColor: Colors.white.withOpacity(0.9),
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                if (_textController.text.isNotEmpty) // Display the saved text
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      _textController.text,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveEntry,
                  icon: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.save, color: Colors.white),
                  label: const Text("Save Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C9478),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}