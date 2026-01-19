import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class LoadAssessment extends QuizEvent {
  final String assessmentId;

  const LoadAssessment(this.assessmentId);

  @override
  List<Object?> get props => [assessmentId];
}

class StartQuiz extends QuizEvent {
  final String userId;

  const StartQuiz(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SelectAnswer extends QuizEvent {
  final int questionNumber;
  final int selectedOption;

  const SelectAnswer({
    required this.questionNumber,
    required this.selectedOption,
  });

  @override
  List<Object?> get props => [questionNumber, selectedOption];
}

class NextQuestion extends QuizEvent {}

class PreviousQuestion extends QuizEvent {}

class GoToQuestion extends QuizEvent {
  final int questionNumber;

  const GoToQuestion(this.questionNumber);

  @override
  List<Object?> get props => [questionNumber];
}

class TimerTick extends QuizEvent {
  final int remainingSeconds;

  const TimerTick(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class SubmitQuiz extends QuizEvent {
  final bool isAutoSubmit;

  const SubmitQuiz({this.isAutoSubmit = false});

  @override
  List<Object?> get props => [isAutoSubmit];
}

class SaveProgress extends QuizEvent {}