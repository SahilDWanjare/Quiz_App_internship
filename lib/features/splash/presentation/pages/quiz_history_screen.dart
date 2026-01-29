import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../assessment/data/repository/assessment_repository.dart';
import '../../../assessment/domain/entities/assessment.dart';
import '../../../assessment/presentation/pages/result_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  const QuizHistoryScreen({Key? key}) : super(key: key);

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  final AssessmentRepository _repository = AssessmentRepository();

  bool _isLoading = true;
  List<QuizAttempt> _attempts = [];
  String?  _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllAttempts();
  }

  Future<void> _loadAllAttempts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view history';
      });
      return;
    }

    try {
      final attempts = await _repository.getUserAttempts(user.uid);

      if (mounted) {
        setState(() {
          _attempts = attempts;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load history.  Tap to retry.';
        });
      }
    }
  }

  Future<void> _openAttemptResult(QuizAttempt attempt) async {
    // Show loading indicator
    showDialog(
      context:  context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child:  CircularProgressIndicator(
          color: Color(0xFF1B9AAA),
        ),
      ),
    );

    try {
      // Fetch questions for this attempt
      final questions = await _repository.getQuestions(attempt.assessmentId);

      if (! mounted) return;

      // Dismiss loading
      Navigator.of(context).pop();

      if (questions.isEmpty) {
        ScaffoldMessenger. of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load questions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Calculate correct answers
      int correctAnswers = 0;
      for (final question in questions) {
        final userAnswer = attempt.answers[question.questionNumber];
        if (userAnswer != null && userAnswer == question.correctIndex) {
          correctAnswers++;
        }
      }

      // Navigate to result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            attempt: attempt,
            correctAnswers: correctAnswers,
            totalQuestions: attempt.totalQuestions,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load attempt details'),
            backgroundColor:  Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        backgroundColor: Colors. white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0D121F)),
          onPressed:  () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Quiz History',
          style: TextStyle(
            color: Color(0xFF0D121F),
            fontSize: 18,
            fontWeight: FontWeight. w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF1B9AAA),
            ),
            SizedBox(height:  16),
            Text(
              'Loading history...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: GestureDetector(
          onTap: () {
            setState(() {
              _isLoading = true;
              _errorMessage = null;
            });
            _loadAllAttempts();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons. error_outline,
                size: 64,
                color:  Colors.red. shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height:  8),
              const Icon(
                Icons. refresh,
                color: Color(0xFF1B9AAA),
              ),
            ],
          ),
        ),
      );
    }

    if (_attempts.isEmpty) {
      return Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration:  BoxDecoration(
                color: Colors. grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size:  64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Quiz Attempts Yet',
              style: TextStyle(
                fontSize:  20,
                fontWeight: FontWeight.w600,
                color: Colors.grey. shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete a quiz to see your history here',
              style: TextStyle(
                fontSize: 14,
                color:  Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh:  _loadAllAttempts,
      color: const Color(0xFF1B9AAA),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _attempts.length,
        itemBuilder: (context, index) {
          final attempt = _attempts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAttemptCard(
              attemptNumber: _attempts.length - index,
              attempt: attempt,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttemptCard({
    required int attemptNumber,
    required QuizAttempt attempt,
  }) {
    final percentage = (attempt.score / attempt.totalQuestions * 100).round();
    final passed = percentage >= 90;

    return GestureDetector(
      onTap: () => _openAttemptResult(attempt),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Attempt Number Badge
            Container(
              width: 50,
              height:  50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment. bottomRight,
                  colors: [Colors.grey. shade200, Colors.grey. shade300],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:  Text(
                  '#$attemptNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Attempt Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attempt ${attemptNumber. toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight. bold,
                      color: Color(0xFF0D121F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildDetailItem(
                        icon: Icons.check_circle_outline,
                        text: '${attempt.score}/${attempt.totalQuestions}',
                      ),
                      const SizedBox(width: 16),
                      _buildDetailItem(
                        icon: Icons.access_time,
                        text:  _formatTime(attempt. timeSpentSeconds),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildDetailItem(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDate(attempt. endTime ??  attempt.startTime),
                  ),
                ],
              ),
            ),

            // Score Badge with Arrow
            Row(
              children:  [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color:  passed
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        :  const Color(0xFF1B9AAA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: passed
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFF1B9AAA),
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight. bold,
                          color: passed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF1B9AAA),
                        ),
                      ),
                      Text(
                        passed ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          fontSize:  9,
                          fontWeight: FontWeight. bold,
                          color: passed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF1B9AAA),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width:  8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize. min,
      children: [
        Icon(
          icon,
          size: 14,
          color:  Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize:  12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}