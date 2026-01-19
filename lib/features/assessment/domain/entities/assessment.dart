import 'package:equatable/equatable.dart';

class Assessment extends Equatable {
  final String id;
  final String title;
  final String passage;
  final String? imageUrl;
  final int durationMinutes;
  final int totalQuestions;
  final DateTime createdAt;

  const Assessment({
    required this.id,
    required this.title,
    required this.passage,
    this.imageUrl,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    passage,
    imageUrl,
    durationMinutes,
    totalQuestions,
    createdAt,
  ];
}

class Question extends Equatable {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final int questionNumber;

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.questionNumber,
  });

  @override
  List<Object?> get props => [
    id,
    questionText,
    options,
    correctIndex,
    questionNumber,
  ];
}

class QuizAttempt extends Equatable {
  final String id;
  final String userId;
  final String assessmentId;
  final Map<int, int> answers; // questionNumber -> selectedOptionIndex
  final DateTime startTime;
  final DateTime? endTime;
  final int score;
  final int totalQuestions;
  final bool isCompleted;
  final int timeSpentSeconds;

  const QuizAttempt({
    required this.id,
    required this.userId,
    required this.assessmentId,
    required this.answers,
    required this.startTime,
    this.endTime,
    required this.score,
    required this.totalQuestions,
    required this.isCompleted,
    required this.timeSpentSeconds,
  });

  double get percentage => (score / totalQuestions) * 100;

  @override
  List<Object?> get props => [
    id,
    userId,
    assessmentId,
    answers,
    startTime,
    endTime,
    score,
    totalQuestions,
    isCompleted,
    timeSpentSeconds,
  ];
}