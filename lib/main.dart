import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const TekstHelderApp());
}

class TekstHelderApp extends StatelessWidget {
  const TekstHelderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TekstHelder Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterTts _flutterTts = FlutterTts();
  String sampleText =
      "This is sample text that will eventually come from text scanned in an image.";

  // Text-to-Speech function
  Future<void> _speakText() async {
    await _flutterTts.setLanguage("nl-NL"); // Set the language to Dutch
    await _flutterTts.setPitch(1.0); // Set pitch to normal level
    await _flutterTts.speak(sampleText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TekstHelder Mobile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voorbeeldtekst:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              sampleText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakText,
              child: const Text('Voorlezen'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Logic for the 'Explain' button can be added here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Uitleg-functie nog niet geïmplementeerd')),
                );
              },
              child: const Text('Uitleg'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Logic for the 'Rephrase' button can be added here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Herformuleer-functie nog niet geïmplementeerd')),
                );
              },
              child: const Text('Herformuleer'),
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
