import 'package:equatable/equatable.dart';

/// Question difficulty levels
enum QuestionDifficulty {
  easy,
  difficult;

  String get displayName {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.difficult:
        return 'Difficult';
    }
  }
}

class Question extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int questionNumber;
  final QuestionDifficulty difficulty; // ✨ NEW: Difficulty level

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.questionNumber,
    this.difficulty = QuestionDifficulty.easy, // Default to easy
  });

  @override
  List<Object?> get props => [
    id,
    questionText,
    options,
    correctIndex,
    questionNumber,
    difficulty,
  ];
}