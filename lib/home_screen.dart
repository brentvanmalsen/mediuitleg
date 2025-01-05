import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  final ApiService _apiService = ApiService();
  String simplifiedText = '';
  bool isLoading = false;

  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      final explanation = await _apiService.analyzeImageWithPrompt(
          File(imagePath), "What is shown in this image?");
      setState(() {
        simplifiedText = explanation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.setLanguage("nl-NL");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Uitleg'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(File(imagePath)),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _analyzeImage(imagePath),
                    child: const Text('Analyze Image'),
                  ),
                  ElevatedButton(
                    onPressed: () => _speakText(simplifiedText),
                    child: const Text('Read Explanation'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
