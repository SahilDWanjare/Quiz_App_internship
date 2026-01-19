import 'package:equatable/equatable.dart';

class QuizResult extends Equatable {
  final String attemptId;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double percentage;
  final Duration timeTaken;
  final DateTime attemptDate;
  final List<CategoryScore> categoryScores;

  const QuizResult({
    required this.attemptId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.percentage,
    required this.timeTaken,
    required this.attemptDate,
    required this.categoryScores,
  });

  bool get isPassed => percentage >= 90.0;

  @override
  List<Object?> get props => [
    attemptId,
    totalQuestions,
    correctAnswers,
    incorrectAnswers,
    percentage,
    timeTaken,
    attemptDate,
    categoryScores,
  ];
}

class CategoryScore extends Equatable {
  final String categoryName;
  final String sectionNumber;
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String iconName;

  const CategoryScore({
    required this.categoryName,
    required this.sectionNumber,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.iconName,
  });

  @override
  List<Object?> get props => [
    categoryName,
    sectionNumber,
    totalQuestions,
    correctAnswers,
    percentage,
    iconName,
  ];
}

class AttemptHistory extends Equatable {
  final String attemptId;
  final String attemptNumber;
  final DateTime date;
  final double scorePercentage;
  final int correctAnswers;
  final int totalQuestions;

  const AttemptHistory({
    required this.attemptId,
    required this.attemptNumber,
    required this.date,
    required this.scorePercentage,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  @override
  List<Object?> get props => [
    attemptId,
    attemptNumber,
    date,
    scorePercentage,
    correctAnswers,
    totalQuestions,
  ];
}