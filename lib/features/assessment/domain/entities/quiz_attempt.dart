class QuizAttempt {
  final String id;
  final List<Question> questions;
  final List<int? > userAnswers; // User's selected option index for each question
  final int timeSpentSeconds;
  final DateTime startTime;
  final DateTime?  endTime;

  const QuizAttempt({
    required this.id,
    required this.questions,
    required this.userAnswers,
    required this.timeSpentSeconds,
    required this.startTime,
    this.endTime,
  });
}

class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String?  explanation; // Optional explanation for the answer
  final String? category;

  const Question({
    required this.id,
    required this. questionText,
    required this. options,
    required this.correctOptionIndex,
    this.explanation,
    this.category,
  });
}