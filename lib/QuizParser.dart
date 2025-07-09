import 'models/question.dart';

class QuizParser {
  static List<Question> parseMCQs(String rawText) {
    final List<Question> questions = [];
    final blocks = rawText.split(RegExp(r"\n(?=\d+\.)")); // Split at 1. 2. 3.

    for (var block in blocks) {
      final lines = block.trim().split('\n');
      if (lines.length < 6) continue; // Question + 4 options + Answer

      final qText = lines[0].replaceFirst(RegExp(r"\d+\."), '').trim();

      // Extract options (A-D)
      final options = lines.sublist(1, 5).map((line) {
        return line.replaceFirst(RegExp(r"[A-D]\)"), '').trim();
      }).toList();

      // Validate we got 4 options
      if (options.length < 4 || options.any((o) => o.isEmpty)) {
        print("❌ Skipped due to invalid or missing options in: $qText");
        continue;
      }

      // Extract correct answer line (accepts 'answer:', 'correct answer:', etc.)
      final answerLine = lines.firstWhere(
        (line) => line.toLowerCase().contains("answer"),
        orElse: () => '',
      );

      String correctOptionLetter = '';
      if (answerLine.isNotEmpty) {
        final parts = answerLine.split(":");
        if (parts.length > 1) {
          final answerPart = parts[1].trim();
          final match = RegExp(r'^([A-D])').firstMatch(answerPart);
          if (match != null) {
            correctOptionLetter = match.group(1)!;
          }
        }
      }

      final correctIndex = ['A', 'B', 'C', 'D'].indexOf(correctOptionLetter);

      if (correctIndex == -1) {
        print("❌ Skipped due to missing or invalid answer for: $qText");
        continue;
      }

      // Add question
      questions.add(Question(
        question: qText,
        options: options,
        correctIndex: correctIndex,
      ));
    }

    print("✅ Total parsed questions: ${questions.length}");
    return questions;
  }
}
