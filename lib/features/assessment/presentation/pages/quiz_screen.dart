import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/circular_timer.dart';
import '../widgets/option_button.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final quizBloc = context.read<QuizBloc>();

    if (state == AppLifecycleState.paused) {
      // App went to background
      quizBloc.pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      // App returned to foreground
      quizBloc.resumeTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button during test
        final shouldPop = await _showExitDialog();
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: BlocBuilder<QuizBloc, QuizState>(
            builder: (context, state) {
              if (state is QuizInProgress) {
                return Text(
                  'Question ${state.currentQuestionNumber} of ${state.totalQuestions}',
                  style: const TextStyle(
                    color: Color(0xFF0D121F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizSubmitted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => ResultScreen(
                    attempt: state.attempt,
                    correctAnswers: state.correctAnswers,
                    totalQuestions: state.totalQuestions,
                  ),
                ),
              );
            } else if (state is QuizSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF00C853),
                  duration: const Duration(seconds: 1),
                ),
              );
            } else if (state is QuizError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0D121F),
                ),
              );
            }

            if (state is QuizInProgress) {
              return _buildQuizContent(state);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildQuizContent(QuizInProgress state) {
    final question = state.currentQuestion;

    return Column(
      children: [
        // Timer
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: CircularTimer(
            remainingSeconds: state.remainingSeconds,
            totalSeconds: state.assessment.durationMinutes * 60,
          ),
        ),

        // Question Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Question ${state.currentQuestionNumber}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Question Text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    question.questionText,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF0D121F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                ...List.generate(
                  question.options.length,
                      (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OptionButton(
                      optionText: question.options[index],
                      optionIndex: index,
                      isSelected: state.selectedAnswer == index,
                      onTap: () {
                        context.read<QuizBloc>().add(
                          SelectAnswer(
                            questionNumber: state.currentQuestionNumber,
                            selectedOption: index,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Bottom Navigation
        _buildBottomNav(state),
      ],
    );
  }

  Widget _buildBottomNav(QuizInProgress state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            if (!state.isFirstQuestion)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<QuizBloc>().add(PreviousQuestion());
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF0D121F)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'PREVIOUS',
                    style: TextStyle(
                      color: Color(0xFF0D121F),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            if (!state.isFirstQuestion && !state.isLastQuestion)
              const SizedBox(width: 12),

            // Next/Submit Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (state.isLastQuestion) {
                    _showSubmitDialog();
                  } else {
                    context.read<QuizBloc>().add(NextQuestion());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D121F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  state.isLastQuestion ? 'SUBMIT' : 'NEXT',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Save Button
            ElevatedButton(
              onPressed: () {
                context.read<QuizBloc>().add(SaveProgress());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SAVE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSubmitDialog() async {
    final shouldSubmit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Submit Quiz?'),
        content: const Text(
          'Are you sure you want to submit your answers? You cannot change them after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D121F),
            ),
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );

    if (shouldSubmit == true && mounted) {
      context.read<QuizBloc>().add(const SubmitQuiz());
    }
  }

  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('EXIT'),
          ),
        ],
      ),
    );
  }
}