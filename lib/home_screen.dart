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
  String sampleText = 'Dosering'; // Dynamisch aanpasbare tekst
  String simplifiedText = ''; // Hier wordt de gesimplificeerde tekst opgeslagen

  @override
  void initState() {
    super.initState();
    _configureAudio();
  }

  /// Configureer audio-instellingen voor iOS
  void _configureAudio() {
    if (Platform.isIOS) {
      _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
        ],
      );
    }
  }

  /// Laat tekst horen via Text-to-Speech
  Future<void> _speakText(String text) async {
    try {
      print(
          "TTS wordt aangeroepen: $text"); // Debug: Log de tekst die wordt uitgesproken
      await _flutterTts.setLanguage("nl-NL"); // Zorg dat de taal Nederlands is
      await _flutterTts.setPitch(1.0); // Normale toonhoogte
      await _flutterTts
          .setSpeechRate(0.5); // Langzamer spreektempo voor duidelijke uitleg
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e"); // Debug: Log een fout als TTS niet werkt
    }
  }

  /// Genereer uitleg voor het woord en speel het af via TTS
  Future<void> _explainWord() async {
    try {
      // Genereer de versimpelde uitleg
      final explanation =
          await _apiService.generateSimplifiedExplanation(sampleText);

      // Update de UI
      setState(() {
        simplifiedText = explanation;
      });

      // Spreek de tekst uit
      print("Spreek de uitleg uit: $simplifiedText"); // Debug
      await _speakText(simplifiedText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      print("Error in _explainWord: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uitleg'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Voorbeeldtekst:',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                sampleText,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () =>
                  _speakText(sampleText), // Spreek originele tekst uit
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Voorlezen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _explainWord, // Genereer uitleg en versimpel
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Uitleg'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
