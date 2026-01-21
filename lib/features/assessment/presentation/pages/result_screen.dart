import 'package:flutter/material.dart';
import '../../data/repository/assessment_repository.dart';
import '../../domain/entities/assessment.dart';
import 'review_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizAttempt attempt;
  final int correctAnswers;
  final int totalQuestions;
  final List<Question> questions;
  final int initialTabIndex; // Add this parameter

  const ResultScreen({
    Key? key,
    required this.attempt,
    required this.correctAnswers,
    required this. totalQuestions,
    required this.questions,
    this.initialTabIndex = 0, // Default to Summary tab
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AssessmentRepository _repository = AssessmentRepository();

  bool _isLoadingHistory = true;
  List<QuizAttempt> _attemptHistory = [];
  String? _errorMessage;

  // Track loading state for individual history card taps
  String?  _loadingAttemptId;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the initialTabIndex
    _tabController = TabController(
      length:  2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadAttemptHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load attempt history from Firestore using repository
  Future<void> _loadAttemptHistory() async {
    try {
      final attempts = await _repository.getAttemptHistory(
        userId: widget.attempt. userId,
        assessmentId: widget.attempt.assessmentId,
      );

      if (mounted) {
        setState(() {
          _attemptHistory = attempts;
          _isLoadingHistory = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _errorMessage = 'Failed to load history.  Tap to retry.';
        });
      }
    }
  }

  // Navigate to result screen for a specific attempt
  Future<void> _openAttemptResult(QuizAttempt attempt) async {
    // If it's the current attempt, no need to fetch again
    if (attempt.id == widget.attempt.id) {
      ScaffoldMessenger. of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already viewing this attempt'),
          backgroundColor: Color(0xFFD4AF37),
          duration: Duration(seconds:  2),
        ),
      );
      return;
    }

    setState(() {
      _loadingAttemptId = attempt.id;
    });

    try {
      // Fetch questions for this attempt's assessment
      final questions = await _repository.getQuestions(attempt. assessmentId);

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load questions for this attempt'),
              backgroundColor: Colors. red,
            ),
          );
        }
        return;
      }

      // Calculate correct answers for this attempt
      int correctAnswers = 0;
      for (final question in questions) {
        final userAnswer = attempt. answers[question.questionNumber];
        if (userAnswer != null && userAnswer == question.correctIndex) {
          correctAnswers++;
        }
      }

      if (mounted) {
        // Navigate to a new ResultScreen for the selected attempt
        Navigator. of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              attempt: attempt,
              correctAnswers: correctAnswers,
              totalQuestions: attempt.totalQuestions,
              questions: questions,
              initialTabIndex: 0, // Open Summary tab for selected attempt
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening attempt result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load attempt details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingAttemptId = null;
        });
      }
    }
  }

  // Get list of wrong questions
  List<Question> get wrongQuestions {
    return widget.questions. where((question) {
      final userAnswer = widget.attempt.answers[question. questionNumber];
      return userAnswer != null && userAnswer != question.correctIndex;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget. totalQuestions * 100);
    final passed = percentage >= 90;
    final wrongCount = widget.totalQuestions - widget. correctAnswers;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: passed
                ? [
              const Color(0xFF1B5E20),
              const Color(0xFF2E7D32),
              const Color(0xFF43A047),
            ]
                :  [
              const Color(0xFF37474F),
              const Color(0xFF546E7A),
              const Color(0xFF78909C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(),

              const SizedBox(height: 12),

              // Score Section
              _buildScoreSection(percentage, passed),

              const SizedBox(height: 16),

              // Stats Row
              _buildStatsRow(wrongCount),

              const SizedBox(height: 20),

              // Bottom Section with Tabs
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:  Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Custom Tab Bar
                      _buildTabBar(),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSummaryTab(wrongCount),
                            _buildHistoryTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding:  const EdgeInsets. symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Show back button if navigated from history or profile
          if (Navigator.of(context).canPop())
            _buildIconButton(
              icon: Icons.arrow_back_ios_new,
              onPressed: () => Navigator.of(context).pop(),
            )
          else
            const SizedBox(width: 44),
          const Text(
            'RESULT',
            style:  TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:  FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          _buildIconButton(
            icon: Icons. home_rounded,
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height:  44,
      decoration: BoxDecoration(
        color:  Colors.white. withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors. white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildScoreSection(double percentage, bool passed) {
    return Column(
      children: [
        // Animated Score Circle
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percentage / 100),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Container(
              width:  160,
              height:  160,
              decoration: BoxDecoration(
                color:  Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors. black.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child:  Stack(
                alignment: Alignment.center,
                children:  [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey. shade200,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value:  value,
                      strokeWidth: 10,
                      backgroundColor:  Colors.transparent,
                      valueColor:  AlwaysStoppedAnimation<Color>(
                        passed
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFD4AF37),
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment. center,
                    children: [
                      Text(
                        '${(value * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight. bold,
                          color: Color(0xFF0D121F),
                        ),
                      ),
                      Text(
                        'SCORE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight. w600,
                          color: Colors.grey.shade500,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Result Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration:  BoxDecoration(
            color: Colors.white. withOpacity(0.2),
            borderRadius: BorderRadius.circular(30),
            border:  Border.all(
              color: Colors. white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize. min,
            children: [
              Icon(
                passed ? Icons.emoji_events : Icons. refresh,
                color:  passed ? const Color(0xFFFFD700) : Colors.white,
                size:  20,
              ),
              const SizedBox(width: 8),
              Text(
                passed ? 'CONGRATULATIONS!' : 'TRY AGAIN! ',
                style:  const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight. bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        Text(
          passed
              ? "You've successfully passed the exam"
              : "You need 90% to pass",
          style: TextStyle(
            color: Colors.white. withOpacity(0.85),
            fontSize:  13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int wrongCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatCard(
            icon: Icons.quiz_outlined,
            iconColor: const Color(0xFF2196F3),
            value: '${widget.totalQuestions}',
            label:  'Total',
          ),
          _buildStatCard(
            icon: Icons.check_circle,
            iconColor:  const Color(0xFF4CAF50),
            value: '${widget.correctAnswers}',
            label: 'Correct',
          ),
          _buildStatCard(
            icon: Icons.cancel,
            iconColor:  const Color(0xFFE53935),
            value:  '$wrongCount',
            label: 'Wrong',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors. white. withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors. white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment:  MainAxisAlignment.center,
        children:  [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:  BoxDecoration(
              color: iconColor. withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style:  const TextStyle(
                  color: Colors.white,
                  fontSize:  18,
                  fontWeight: FontWeight. bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. circular(16),
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:  const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF0D121F),
          borderRadius: BorderRadius. circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey. shade600,
        labelStyle: const TextStyle(
          fontWeight: FontWeight. w600,
          fontSize: 14,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:  [
                Icon(Icons.summarize_outlined, size: 18),
                SizedBox(width: 8),
                Text('Summary'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 18),
                SizedBox(width: 8),
                Text('History'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab(int wrongCount) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
            children: [
            // Current Attempt Card
            _buildCurrentAttemptCard(),

        const SizedBox(height: 16),

        // Time & Date Row
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.timer_outlined,
                iconColor: const Color(0xFF9C27B0),
                title: 'Time Spent',
                value: _formatTime(widget. attempt.timeSpentSeconds),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:  _buildInfoCard(
                icon:  Icons.calendar_today_outlined,
                iconColor: const Color(0xFF00BCD4),
                title: 'Date',
                value: _formatDate(widget.attempt. endTime ??  DateTime.now()),
              ),
            ),
          ],
        ),

        const SizedBox(height:  20),

        // Review Button
        if (wrongCount > 0) ...[
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () {
    Navigator.of(context).push(
    MaterialPageRoute(
    builder: (_) => ReviewScreen(
    wrongQuestions: wrongQuestions,
    userAnswers: widget.attempt.answers,
    ),
    ),
    );
    },
    style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFD4AF37),
    foregroundColor: Colors. white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    elevation: 0,
    ),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    const Icon(Icons.rate_review_outlined, size: 22),
    const SizedBox(width: 10),
    Text(
    'Review $wrongCount Wrong Answers',
    style: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight. w600,
    ),
    ),
    ],
    ),
    ),
    ),
    const SizedBox(height: 12),
    ],

    // Back to Home Button
    SizedBox(
    width: double.infinity,
    child:  OutlinedButton(
    onPressed: () {
    Navigator. of(context).popUntil((route) => route.isFirst);
    },
    style: OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF0D121F),
    padding: const EdgeInsets.symmetric(vertical: 16),
    side: const BorderSide(color: Color(0xFF0D121F), width: 2),
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    ),
    ),
    child:  const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Icon(Icons. home_outlined, size: 22),
    SizedBox(width:  10),
    Text(
    'Back to Home',
    style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    ),
    ),
    ],
    ),
    ),
    ),
    ],
    ),
    );
  }

  Widget _buildCurrentAttemptCard() {
    final percentage =
    (widget.correctAnswers / widget. totalQuestions * 100).round();
    final passed = percentage >= 90;

    return Container(
      padding:  const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors. grey. shade50,
          ],
        ),
        borderRadius: BorderRadius. circular(20),
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset:  const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: passed
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : const Color(0xFFD4AF37).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height:  48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:  Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: passed
                    ? [const Color(0xFF4CAF50), const Color(0xFF81C784)]
                    :  [const Color(0xFFD4AF37), const Color(0xFFFFD54F)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              passed ? Icons.emoji_events : Icons.stars,
              color:  Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Badge - Wrap to prevent overflow
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment. center,
                  children:  [
                    const Text(
                      'Current Attempt',
                      style:  TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight. bold,
                        color: Color(0xFF0D121F),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration:  BoxDecoration(
                        color: passed
                            ? const Color(0xFF4CAF50).withOpacity(0.1)
                            :  const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius:  BorderRadius.circular(6),
                      ),
                      child:  Text(
                        passed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight. bold,
                          color: passed
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.correctAnswers}/${widget.totalQuestions} correct',
                  style:  TextStyle(
                    fontSize: 12,
                    color: Colors.grey. shade600,
                  ),
                ),
              ],
            ),
          ),

          // Score
          Container(
            padding:  const EdgeInsets. symmetric(horizontal: 10, vertical: 8),
            decoration:  BoxDecoration(
              color: passed
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:  passed
                    ?  const Color(0xFF4CAF50)
                    : const Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius:  BorderRadius.circular(16),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration:  BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey. shade500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight. bold,
                    color: Color(0xFF0D121F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 3,
            ),
            SizedBox(height:  16),
            Text(
              'Loading history...',
              style: TextStyle(
                color: Colors. grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child:  GestureDetector(
          onTap: () {
            setState(() {
              _isLoadingHistory = true;
              _errorMessage = null;
            });
            _loadAttemptHistory();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color:  Colors.red. shade300,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey. shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Icon(
                Icons.refresh,
                color: Color(0xFFD4AF37),
              ),
            ],
          ),
        ),
      );
    }

    if (_attemptHistory.isEmpty) {
      return Center(
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 48,
                color:  Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Previous Attempts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your quiz history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors. grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttemptHistory,
      color: const Color(0xFFD4AF37),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _attemptHistory.length,
        itemBuilder: (context, index) {
          final attempt = _attemptHistory[index];
          final isCurrentAttempt = attempt.id == widget.attempt. id;
          final attemptNumber = _attemptHistory.length - index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:  _buildHistoryCard(
              attemptNumber: attemptNumber,
              attempt: attempt,
              isCurrentAttempt: isCurrentAttempt,
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required int attemptNumber,
    required QuizAttempt attempt,
    bool isCurrentAttempt = false,
  }) {
    final percentage = (attempt.score / attempt.totalQuestions * 100).round();
    final passed = percentage >= 90;
    final isLoading = _loadingAttemptId == attempt.id;

    return GestureDetector(
      onTap: isLoading ? null : () => _openAttemptResult(attempt),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:  Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset:  const Offset(0, 2),
            ),
          ],
          border: isCurrentAttempt
              ? Border.all(color: const Color(0xFFD4AF37), width: 2)
              : null,
        ),
        child: Row(
          children:  [
            // Attempt Number Badge
            Container(
              width: 44,
              height:  44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin:  Alignment.topLeft,
                  end:  Alignment.bottomRight,
                  colors:  isCurrentAttempt
                      ? [const Color(0xFFD4AF37), const Color(0xFFFFD54F)]
                      :  [Colors.grey. shade200, Colors. grey.shade300],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child:  isLoading
                    ?  const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  '#$attemptNumber',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight. bold,
                    color: isCurrentAttempt
                        ? Colors.white
                        : Colors.grey. shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Attempt Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with Wrap
                  Wrap(
                    spacing: 6,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Attempt ${attemptNumber. toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight. bold,
                          color: Color(0xFF0D121F),
                        ),
                      ),
                      if (isCurrentAttempt)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration:  BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.1),
                            borderRadius:  BorderRadius.circular(4),
                          ),
                          child:  const Text(
                            'NOW',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight. bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Stats Row - Use Flexible/Expanded
                  Row(
                    children: [
                      Flexible(
                        child: _buildHistoryDetail(
                          icon: Icons.check_circle_outline,
                          text: '${attempt.score}/${attempt.totalQuestions}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child:  _buildHistoryDetail(
                          icon: Icons.access_time,
                          text: _formatTimeShort(attempt.timeSpentSeconds),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  _buildHistoryDetail(
                    icon:  Icons.calendar_today_outlined,
                    text: _formatDateShort(attempt. endTime ??  attempt.startTime),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical:  6),
              decoration:  BoxDecoration(
                color: passed
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    :  const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: passed
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFD4AF37),
                    width:  3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight. bold,
                      color: passed
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD4AF37),
                    ),
                  ),
                  Text(
                    passed ? 'PASS' : 'FAIL',
                    style: TextStyle(
                      fontSize:  8,
                      fontWeight: FontWeight. bold,
                      color: passed
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color:  Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryDetail({
    required IconData icon,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize. min,
      children: [
        Icon(
          icon,
          size: 12,
          color:  Colors.grey.shade500,
        ),
        const SizedBox(width: 3),
        Flexible(
          child:  Text(
            text,
            style:  TextStyle(
              fontSize: 11,
              color:  Colors.grey.shade600,
            ),
            overflow: TextOverflow. ellipsis,
          ),
        ),
      ],
    );
  }

// Add these helper methods for shorter format
  String _formatTimeShort(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m';
    }
    return '${secs}s';
  }

  String _formatDateShort(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date. month - 1]}';
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
    return '${date. day} ${months[date.month - 1]}, ${date.year}';
  }
}