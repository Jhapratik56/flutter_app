import 'package:flutter/material.dart';
import 'models/question.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;
  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestion = 0;
  int score = 0;
  int? selectedIndex;

  void _nextQuestion() {
    if (selectedIndex == widget.questions[currentQuestion].correctIndex) {
      score++;
    }

    if (currentQuestion < widget.questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedIndex = null;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🎉 Quiz Completed!"),
        content: Text("Your score: $score/${widget.questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentQuestion];
    return Scaffold(
      appBar: AppBar(
        title: const Text("🧠 Quiz"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Q${currentQuestion + 1}. ${q.question}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...List.generate(q.options.length, (i) {
              final isSelected = selectedIndex == i;
              return ListTile(
                title: Text(q.options[i]),
                leading: Radio<int>(
                  value: i,
                  groupValue: selectedIndex,
                  onChanged: (value) {
                    setState(() {
                      selectedIndex = value!;
                    });
                  },
                ),
              );
            }),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: selectedIndex != null ? _nextQuestion : null,
                child: Text(currentQuestion == widget.questions.length - 1
                    ? "Finish"
                    : "Next"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
