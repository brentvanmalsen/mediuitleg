import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;
  Offset? _startPosition;
  Offset? _endPosition;

  double _currentZoom = 1.0;
  final double _minZoom = 1.0;
  final double _maxZoom = 8.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.max,
      enableAudio: false,
    );

    _initializeControllerFuture = _cameraController.initialize();
    await _initializeControllerFuture;
    _cameraController.setZoomLevel(_currentZoom);
    setState(() {});
  }

  Future<void> _takePhoto() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController.takePicture();
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print("Error bij foto maken: $e");
    }
  }

  void _retakePhoto() {
    setState(() {
      _imageFile = null;
      _startPosition = null;
      _endPosition = null;
    });
  }

  void _confirmSelection() async {
    if (_imageFile != null && _startPosition != null && _endPosition != null) {
      final imagePath = _imageFile!.path;
      final originalImage = img.decodeImage(File(imagePath).readAsBytesSync());

      // Bepaal de schaalfactor voor mapping van schermcoördinaten naar afbeeldingscoördinaten
      final renderBox = context.findRenderObject() as RenderBox;
      final scaleX = originalImage!.width / renderBox.size.width;
      final scaleY = originalImage.height / renderBox.size.height;

      final startX = (_startPosition!.dx * scaleX).toInt();
      final startY = (_startPosition!.dy * scaleY).toInt();
      final endX = (_endPosition!.dx * scaleX).toInt();
      final endY = (_endPosition!.dy * scaleY).toInt();

      final width = (endX - startX).abs();
      final height = (endY - startY).abs();

      final croppedImage = img.copyCrop(
        originalImage,
        x: startX.clamp(0, originalImage.width),
        y: startY.clamp(0, originalImage.height),
        width: width.clamp(0, originalImage.width - startX),
        height: height.clamp(0, originalImage.height - startY),
      );

      final croppedPath = imagePath.replaceFirst('.jpg', '_cropped.jpg');
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

      Navigator.pushNamed(
        context,
        '/home',
        arguments: croppedPath,
      );
    }
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _startPosition = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _endPosition = details.localPosition;
    });
  }

  void _onZoomChanged(double zoom) {
    setState(() {
      _currentZoom = zoom.clamp(_minZoom, _maxZoom);
    });
    _cameraController.setZoomLevel(_currentZoom);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF323536),
      body: _imageFile == null
          ? (_initializeControllerFuture == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRect(
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: _cameraController
                                      .value.previewSize?.height,
                                  height: _cameraController
                                      .value.previewSize?.width,
                                  child: CameraPreview(_cameraController),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 150,
                            left: 20,
                            right: 20,
                            child: Column(
                              children: [
                                Text(
                                  "Zoom: ${_currentZoom.toStringAsFixed(1)}x",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                Slider(
                                  value: _currentZoom,
                                  min: _minZoom,
                                  max: _maxZoom,
                                  onChanged: _onZoomChanged,
                                  activeColor: const Color(0xFFFCDA3D),
                                  inactiveColor: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: GestureDetector(
                                onTap: _takePhoto,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFFCDA3D),
                                      width: 8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ))
          : GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.file(
                      File(_imageFile!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_startPosition != null && _endPosition != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: SelectionPainter(
                          start: _startPosition!,
                          end: _endPosition!,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _retakePhoto,
                            icon: const Icon(Icons.replay, color: Colors.white),
                            label: const Text('Foto opnieuw maken',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: const Color(0xFF323536),
                              side: const BorderSide(
                                  color: Color(0xFFFCDA3D), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _confirmSelection,
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            label: const Text('Verder gaan',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor: const Color(0xFF323536),
                              side: const BorderSide(
                                  color: Color(0xFFFCDA3D), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class SelectionPainter extends CustomPainter {
  final Offset start;
  final Offset end;

  SelectionPainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final blackStroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final yellowStroke = Paint()
      ..color = const Color(0xFFFCDA3D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromPoints(start, end);

    // Zwarte omlijning
    canvas.drawRect(rect, blackStroke);

    // Gele rechthoek erbovenop
    canvas.drawRect(rect, yellowStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
