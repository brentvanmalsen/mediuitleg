import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';

/// Functie om rotatie te corrigeren
Future<File> correctImageRotation(File imageFile) async {
  // Lees de afbeelding
  final bytes = await imageFile.readAsBytes(); // Lees de afbeelding in
  img.Image image = img
      .decodeImage(bytes)!; // Decodeer de afbeelding naar een bruikbaar formaat

  // Zet de afbeelding om naar grijstinten
  img.Image gray = img.grayscale(
      image);

  // Placeholder voor hoekdetectie
  int angle =
      0; // Hoek wordt niet berekend. Hier zou een functie komen om de rotatiehoek te bepalen.

  // Corrigeer de rotatie van de afbeelding met de placeholder-hoek (0 graden in dit geval)
  img.Image rotatedImage = img.copyRotate(image, angle: angle);

  // Sla de gecorrigeerde afbeelding op als een nieuw bestand
  final correctedFile =
      File(imageFile.path.replaceFirst('.jpg', '_corrected.jpg'));
  await correctedFile.writeAsBytes(
      img.encodeJpg(rotatedImage)); // Sla de nieuwe afbeelding op als JPG
  return correctedFile; // Geef het pad naar het gecorrigeerde bestand terug
}

/// Verwerk afbeelding: Rotatiecorrectie + OCR
Future<String> processImage(File imageFile) async {
  try {
    // 1. Corrigeer de rotatie van de afbeelding
    File correctedImage = await correctImageRotation(imageFile);

    // 2. Herken tekst met Tesseract OCR
    String recognizedText = await FlutterTesseractOcr.extractText(
      correctedImage.path,
      language: 'nld', // Gebruik 'nld' voor NEderlands
    );

    return recognizedText; // Geef de herkende tekst terug
  } catch (e) {
    return "Fout tijdens verwerken: $e"; // Geef een foutmelding als er iets misgaat
  }
}
