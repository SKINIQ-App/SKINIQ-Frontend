import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:skiniq/screen/cameraPreviewScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'package:skiniq/services/diary_service.dart';

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
    final rotatedImage = await FlutterExifRotation.rotateImage(path: imageFile.path);
    return rotatedImage;
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
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
      if (_image != null) {
        await DiaryService.uploadDiaryEntry(
          widget.username,
          _image!,
          _textController.text,
          _selectedDay.toIso8601String(),
        );
      }
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Skin Diary",
                    style: TextStyle(
                      fontSize: 28,
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
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
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
                        formatButtonDecoration: BoxDecoration(
                          color: Color(0xFF6C9478),
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        formatButtonTextStyle: TextStyle(color: Colors.white),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF6C9478).withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF6C9478),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
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
                              fit: BoxFit.cover,
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
                        label: const Text("Capture"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C9478),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload, color: Colors.white),
                        label: const Text("Upload"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C9478),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _textController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Write about your skin changes...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      fillColor: Colors.white.withOpacity(0.95),
                      filled: true,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  if (_textController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
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
                  const SizedBox(height: 10),
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
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the CameraPreviewScreen from upload_selfie_screen1.dart