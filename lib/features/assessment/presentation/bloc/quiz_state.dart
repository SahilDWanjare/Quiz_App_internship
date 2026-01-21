import 'package:equatable/equatable.dart';
import '../../domain/entities/assessment.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class AssessmentLoaded extends QuizState {
  final Assessment assessment;

  const AssessmentLoaded(this.assessment);

  @override
  List<Object?> get props => [assessment];
}

class QuizInProgress extends QuizState {
  final Assessment assessment;
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<int, int> answers;
  final int remainingSeconds;
  final String attemptId;
  final DateTime startTime;

  const QuizInProgress({
    required this.assessment,
    required this.questions,
    required this. currentQuestionIndex,
    required this. answers,
    required this.remainingSeconds,
    required this.attemptId,
    required this. startTime,
  });

  Question get currentQuestion => questions[currentQuestionIndex];
  int get totalQuestions => questions. length;
  int get currentQuestionNumber => currentQuestionIndex + 1;
  int?  get selectedAnswer => answers[currentQuestionNumber];
  bool get isFirstQuestion => currentQuestionIndex == 0;
  bool get isLastQuestion => currentQuestionIndex == questions. length - 1;
  int get answeredCount => answers.length;

  QuizInProgress copyWith({
    Assessment? assessment,
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<int, int>? answers,
    int? remainingSeconds,
    String? attemptId,
    DateTime? startTime,
  }) {
    return QuizInProgress(
      assessment: assessment ?? this.assessment,
      questions: questions ?? this.questions,
      currentQuestionIndex:  currentQuestionIndex ??  this.currentQuestionIndex,
      answers: answers ?? this. answers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      attemptId: attemptId ?? this. attemptId,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [
    assessment,
    questions,
    currentQuestionIndex,
    answers,
    remainingSeconds,
    attemptId,
    startTime,
  ];
}

class QuizSaved extends QuizState {
  final String message;

  const QuizSaved(this.message);

  @override
  List<Object?> get props => [message];
}

class QuizSubmitted extends QuizState {
  final QuizAttempt attempt;
  final int correctAnswers;
  final int totalQuestions;
  final List<Question> questions; // Changed from int to List<Question>

  const QuizSubmitted({
    required this.questions,
    required this.attempt,
    required this.correctAnswers,
    required this.totalQuestions,
  });

  double get percentage => (correctAnswers / totalQuestions) * 100;

  @override
  List<Object?> get props => [attempt, correctAnswers, totalQuestions, questions];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this. message);

  @override
  List<Object?> get props => [message];
}