import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'TextRecognitionService.dart';
import 'A4FService.dart';
import 'QuizParser.dart';
import 'QuizScreen.dart';
import 'models/question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan to MCQs',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
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
  bool _textExtracted = false;
  bool _mcqGenerated = false;

  final ImagePicker _picker = ImagePicker();
  final TextRecognitionService _ocr = TextRecognitionService();
  final A4FService _a4f = A4FService();

  Future<void> _getImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _extractedText = '';
        _mcqs = '';
        _textExtracted = false;
        _mcqGenerated = false;
      });
      await _processImage(_image!);
    }
  }

  Future<void> _processImage(File image) async {
    setState(() => _loading = true);

    final text = await _ocr.recognizeTextFromImage(image);

    setState(() {
      _extractedText = text;
      _loading = false;
      _textExtracted = true;
      _mcqGenerated = false;
    });
  }

  Future<void> _generateMCQs() async {
    setState(() {
      _loading = true;
      _mcqs = '';
      _mcqGenerated = false;
    });

    try {
      final mcqs = await _a4f.generateMCQs(_extractedText);
       print("Raw MCQ text:\n$mcqs"); 
      final questions = QuizParser.parseMCQs(mcqs);

      setState(() {
        _mcqs = mcqs.trim();
        _loading = false;
        _mcqGenerated = true;
      });

      // Navigate to quiz
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(questions: questions),
        ),
      );
    } catch (e) {
      setState(() {
        _mcqs = '❌ Error generating MCQs: $e';
        _loading = false;
        _mcqGenerated = false;
      });
    }
  }

  Widget buildImageSection() {
    if (_image == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text("Scan Image"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _getImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text("Upload Image"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _image!,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  Widget buildTextSection() {
    if (_textExtracted) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📄 Extracted Text:", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SelectableText(
                _extractedText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _generateMCQs,
                  icon: const Icon(Icons.quiz),
                  label: const Text("Generate MCQ Quiz"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildMCQSection() {
    if (_mcqGenerated) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("📝 Generated MCQs:", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SelectableText(
                _mcqs,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 Scan to MCQs"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              buildImageSection(),
              if (_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(
                    color: Colors.deepPurple.shade400,
                    strokeWidth: 4,
                  ),
                ),
              buildTextSection(),
              buildMCQSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
