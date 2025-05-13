import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:table_calendar/table_calendar.dart';
import 'dart:io';
import 'package:skiniq/services/diary_service.dart';
import 'package:logger/logger.dart'; // Added for logging

class DiaryScreen extends StatefulWidget {
  final String username;
  const DiaryScreen({super.key, required this.username});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<File> _images = [];
  final TextEditingController _textController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<CameraDescription>? cameras;
  CameraDescription? selectedCamera;
  bool _isSaving = false;
  Map<DateTime, List<Map<String, dynamic>>> _diaryEntries = {};
  final _logger = Logger(); // Logger instance

  @override
  void initState() {
    super.initState();
    _initializeCameras();
    _fetchDiaryEntries();
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

  Future<void> _fetchDiaryEntries() async {
    try {
      final entries = await DiaryService.fetchDiaryEntries(widget.username);
      setState(() {
        _diaryEntries = {};
        for (var entry in entries) {
          final date = DateTime.parse(entry['date']);
          final dateOnly = DateTime(date.year, date.month, date.day);
          if (_diaryEntries[dateOnly] == null) {
            _diaryEntries[dateOnly] = [];
          }
          _diaryEntries[dateOnly]!.add(entry);
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load diary entries: ${e.toString()}")),
      );
    }
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
      if (orientationValue != null && orientationValue.values.isNotEmpty) {
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

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true);
    if (result != null) {
      List<File> newImages = result.files.map((file) => File(file.path!)).toList();
      for (var image in newImages) {
        final rotatedImage = await _fixImageRotation(image);
        setState(() {
          _images.add(rotatedImage);
        });
      }
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
        _images.add(imageFile);
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_images.isEmpty && _textController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one image or description")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DiaryService.uploadDiaryEntry(
        widget.username,
        _images,
        _textController.text,
        _selectedDay.toIso8601String().split('T')[0],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Diary entry saved successfully")),
      );
      setState(() {
        _images.clear();
        _textController.clear();
      });
      await _fetchDiaryEntries();
    } catch (e) {
      if (!mounted) return;
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
                          color: const Color.fromRGBO(255, 255, 255, 0.95),
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
                            markerDecoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          eventLoader: (day) {
                            final dateOnly = DateTime(day.year, day.month, day.day);
                            return _diaryEntries[dateOnly] ?? [];
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: _images.isNotEmpty
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _images.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    File image = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(
                                              image,
                                              height: 180,
                                              width: 180,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  _images.removeAt(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "No Images Selected",
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
                            onPressed: _pickImages,
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
                      Container(
                        height: 200, // Fixed height to match image section
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 16),
                              child: Text(
                                "My Skin Notes",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C9478),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: InputDecoration(
                                  hintText: "Write about your skin changes...",
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_textController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.95),
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