import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repository/assessment_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final AssessmentRepository assessmentRepository;
  Timer? _timer;
  DateTime? _startTime;
  DateTime? _lastActiveTime;

  QuizBloc({required this.assessmentRepository}) : super(QuizInitial()) {
    on<LoadAssessment>(_onLoadAssessment);
    on<StartQuiz>(_onStartQuiz);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<GoToQuestion>(_onGoToQuestion);
    on<TimerTick>(_onTimerTick);
    on<SubmitQuiz>(_onSubmitQuiz);
    on<SaveProgress>(_onSaveProgress);
  }

  Future<void> _onLoadAssessment(
      LoadAssessment event,
      Emitter<QuizState> emit,
      ) async {
    emit(QuizLoading());

    try {
      final assessment = await assessmentRepository.getAssessment(
        event.assessmentId,
      );

      if (assessment != null) {
        emit(AssessmentLoaded(assessment));
      } else {
        emit(const QuizError('Assessment not found'));
      }
    } catch (e) {
      emit(QuizError('Failed to load assessment: $e'));
    }
  }

  Future<void> _onStartQuiz(
      StartQuiz event,
      Emitter<QuizState> emit,
      ) async {
    if (state is! AssessmentLoaded) return;

    final assessment = (state as AssessmentLoaded).assessment;

    try {
      // Fetch questions
      final questions = await assessmentRepository.getQuestions(
        assessment.id,
      );

      if (questions.isEmpty) {
        emit(const QuizError('No questions found'));
        return;
      }

      // Create attempt
      _startTime = DateTime.now();
      _lastActiveTime = _startTime;

      final attemptId = await assessmentRepository.createAttempt(
        userId: event.userId,
        assessmentId: assessment.id,
        startTime: _startTime!,
      );

      final totalSeconds = assessment.durationMinutes * 60;

      emit(QuizInProgress(
        assessment: assessment,
        questions: questions,
        currentQuestionIndex: 0,
        answers: {},
        remainingSeconds: totalSeconds,
        attemptId: attemptId,
        startTime: _startTime!,
      ));

      // Start timer
      _startTimer(totalSeconds);
    } catch (e) {
      emit(QuizError('Failed to start quiz: $e'));
    }
  }

  void _startTimer(int totalSeconds) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is QuizInProgress) {
        final remaining = currentState.remainingSeconds - 1;

        if (remaining <= 0) {
          timer.cancel();
          add(const SubmitQuiz(isAutoSubmit: true));
        } else {
          add(TimerTick(remaining));
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onTimerTick(
      TimerTick event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;
      emit(currentState.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }

  Future<void> _onSelectAnswer(
      SelectAnswer event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;
      final updatedAnswers = Map<int, int>.from(currentState.answers);
      updatedAnswers[event.questionNumber] = event.selectedOption;

      emit(currentState.copyWith(answers: updatedAnswers));
    }
  }

  Future<void> _onNextQuestion(
      NextQuestion event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;

      if (!currentState.isLastQuestion) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex + 1,
        ));
      }
    }
  }

  Future<void> _onPreviousQuestion(
      PreviousQuestion event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;

      if (!currentState.isFirstQuestion) {
        emit(currentState.copyWith(
          currentQuestionIndex: currentState.currentQuestionIndex - 1,
        ));
      }
    }
  }

  Future<void> _onGoToQuestion(
      GoToQuestion event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;

      if (event.questionNumber > 0 &&
          event.questionNumber <= currentState.totalQuestions) {
        emit(currentState.copyWith(
          currentQuestionIndex: event.questionNumber - 1,
        ));
      }
    }
  }

  Future<void> _onSaveProgress(
      SaveProgress event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      final currentState = state as QuizInProgress;

      try {
        await assessmentRepository.saveProgress(
          attemptId: currentState.attemptId,
          answers: currentState.answers,
          currentQuestionIndex: currentState.currentQuestionIndex,
        );

        // Show temporary saved message
        emit(const QuizSaved('Progress saved'));

        // Return to quiz state
        await Future.delayed(const Duration(seconds: 1));
        emit(currentState);
      } catch (e) {
        emit(QuizError('Failed to save progress: $e'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
      }
    }
  }

  Future<void> _onSubmitQuiz(
      SubmitQuiz event,
      Emitter<QuizState> emit,
      ) async {
    if (state is QuizInProgress) {
      _timer?.cancel();

      final currentState = state as QuizInProgress;
      final endTime = DateTime.now();
      final timeSpent = endTime.difference(currentState.startTime).inSeconds;

      // Calculate score
      int correctAnswers = 0;
      for (final question in currentState.questions) {
        final userAnswer = currentState.answers[question.questionNumber];
        if (userAnswer != null && userAnswer == question.correctIndex) {
          correctAnswers++;
        }
      }

      try {
        final attempt = await assessmentRepository.submitQuiz(
          attemptId: currentState.attemptId,
          answers: currentState.answers,
          endTime: endTime,
          score: correctAnswers,
          totalQuestions: currentState.totalQuestions,
          timeSpentSeconds: timeSpent,
        );

        emit(QuizSubmitted(
          attempt: attempt,
          correctAnswers: correctAnswers,
          totalQuestions: currentState.totalQuestions,
          questions: currentState.totalQuestions,
        ));
      } catch (e) {
        emit(QuizError('Failed to submit quiz: $e'));
      }
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    _lastActiveTime = DateTime.now();
  }

  void resumeTimer() {
    if (state is QuizInProgress && _lastActiveTime != null) {
      final currentState = state as QuizInProgress;
      final elapsed = DateTime.now().difference(_lastActiveTime!).inSeconds;
      final newRemaining = (currentState.remainingSeconds - elapsed).clamp(0, double.infinity).toInt();

      if (newRemaining > 0) {
        add(TimerTick(newRemaining));
        _startTimer(newRemaining);
      } else {
        add(const SubmitQuiz(isAutoSubmit: true));
      }
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}