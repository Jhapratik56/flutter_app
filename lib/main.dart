import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'TextRecognitionService.dart';
import 'OpenAIService.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan to MCQ',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
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
  File? _image;
  String _extractedText = '';
  String _mcqs = '';
  bool _loading = false;

  final ImagePicker _picker = ImagePicker();
  final TextRecognitionService _ocr = TextRecognitionService();
  final OpenAIService _openAI = OpenAIService();

  Future<void> _getImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _extractedText = '';
        _mcqs = '';
      });
      await _processImage(_image!);
    }
  }

  Future<void> _processImage(File image) async {
    setState(() => _loading = true);

    final text = await _ocr.recognizeTextFromImage(image);
    setState(() => _extractedText = text);

    final mcqs = await _openAI.generateMCQs(text);
    setState(() {
      _mcqs = mcqs.trim();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📚 Scan to MCQ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text("Scan with Camera"),
            ),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text("Upload from Gallery"),
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_extractedText.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📄 Extracted Text:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_extractedText),
                  const SizedBox(height: 16),
                ],
              ),
            if (_mcqs.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📝 Generated MCQs:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_mcqs),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
