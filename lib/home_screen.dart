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
  bool isAnalyzed = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String imagePath =
          ModalRoute.of(context)?.settings.arguments as String;
      _analyzeImage(imagePath);
    });
  }

  /// Analyseer afbeelding
  Future<void> _analyzeImage(String imagePath) async {
    setState(() {
      isLoading = true;
    });

    try {
      final explanation = await _apiService.analyzeImageWithPrompt(
        File(imagePath),
        "Leg uit wat het woord betekent in de context van een medische verpakking. Gebruik taal op simpel A1-niveau maar sla geen kritische informatie over, leg uit wat belangrijk is, maximaal 35 woorden.",
      );
      print("API Explanation: $explanation");

      setState(() {
        simplifiedText = explanation;
        isAnalyzed = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout: $e')),
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
        const SnackBar(
            content: Text('Geen uitleg beschikbaar om voor te lezen.')),
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
        const SnackBar(content: Text('Fout bij het voorlezen van de uitleg.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imagePath =
        ModalRoute.of(context)?.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFF323536),
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isAnalyzed ? Colors.green : Colors.grey,
                      size: 30,
                    ),
                    const SizedBox(width: 8),
                    if (isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    Text(
                      isAnalyzed ? 'Analyse voltooid' : 'Analyse bezig...',
                      style: TextStyle(
                        fontSize: 16,
                        color: isAnalyzed ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 16, right: 16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: isAnalyzed ? _speakText : null,
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  label: const Text(
                    'Uitleg voorlezen',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFF323536),
                    side: const BorderSide(color: Color(0xFFFCDA3D), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'Terug',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: const Color(0xFF323536),
                    side: const BorderSide(color: Color(0xFFFCDA3D), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
