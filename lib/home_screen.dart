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
  bool isAnalyzed = false; // Controleer of de tekst geanalyseerd is
  bool isLoading = false;

  /// Analyseer afbeelding
  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      final explanation = await _apiService.analyzeImageWithPrompt(
          File(imagePath), "What is shown in this image?");
      print("API Explanation: $explanation");

      setState(() {
        simplifiedText = explanation;
        isAnalyzed = true; // Zet de status op geanalyseerd
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

  /// Voorlezen met TTS
  Future<void> _speakText() async {
    if (simplifiedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No explanation available to read.')),
      );
      return;
    }

    try {
      print("Text to Speak: $simplifiedText");
      await _flutterTts.setLanguage("nl-NL");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(simplifiedText);
    } catch (e) {
      print("TTS Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while reading explanation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Versimpel'),
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
                    child: const Text('Analyseren'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: isAnalyzed ? Colors.green : Colors.grey,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isAnalyzed ? 'Analysis Complete' : 'Wacht op analyseren',
                        style: TextStyle(
                          fontSize: 16,
                          color: isAnalyzed ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isAnalyzed
                        ? _speakText
                        : null, // Disable knop als niet geanalyseerd
                    child: const Text('Lees uitleg'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
