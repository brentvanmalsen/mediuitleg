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
      print("TTS wordt aangeroepen: $text");
      await _flutterTts.setLanguage("nl-NL");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(text);
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  /// Genereer uitleg voor het woord en speel het af via TTS
  Future<void> _explainWord(String sampleText) async {
    try {
      final explanation =
          await _apiService.generateSimplifiedExplanation(sampleText);

      setState(() {
        simplifiedText = explanation;
      });

      print("Spreek de uitleg uit: $simplifiedText");
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
    // Haal de gescande tekst op vanuit ModalRoute
    final String sampleText =
        ModalRoute.of(context)?.settings.arguments as String? ??
            'Geen tekst gevonden';

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
              'Gescande Tekst:',
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
              onPressed: () => _speakText(sampleText),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Voorlezen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _explainWord(sampleText),
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
