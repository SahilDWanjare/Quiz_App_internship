import 'package:flutter/material.dart';
import '../../data/repository/assessment_repository.dart';
import '../../domain/entities/assessment.dart';
import 'review_screen.dart';
import 'dart:math' as math;

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color inputBackground = Color(0xFFF5F7FA);
  static const Color inputBorder = Color(0xFFE8EAED);
  static const Color inputText = Color(0xFF5A6169);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFF1B9AAA);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
  static const Color success = Color(0xFF4CAF50);

  // Category Colors
  static const Color companyLaw = Color(0xFF6366F1);
  static const Color securityLaws = Color(0xFFEC4899);
  static const Color finance = Color(0xFF14B8A6);
  static const Color governance = Color(0xFFF59E0B);
}

// Category Analysis Model
class CategoryAnalysis {
  final String name;
  final String shortName;
  final int correctAnswers;
  final int totalQuestions;
  final Color color;
  final IconData icon;

  CategoryAnalysis({
    required this.name,
    required this.shortName,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.color,
    required this.icon,
  });

  double get percentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
}

class ResultScreen extends StatefulWidget {
  final QuizAttempt attempt;
  final int correctAnswers;
  final int totalQuestions;
  final List<Question> questions;
  final int initialTabIndex;

  const ResultScreen({
    Key? key,
    required this.attempt,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.questions,
    this.initialTabIndex = 0,
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
  String?  _errorMessage;
  String? _loadingAttemptId;

  late List<CategoryAnalysis> _categoryAnalysis;

  static const double passingPercentage = 50.0;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadAttemptHistory();
    _generateCategoryAnalysis();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateCategoryAnalysis() {
    final totalQ = widget.totalQuestions;
    final questionsPerCategory = (totalQ / 4).ceil();

    int companyLawCorrect = 0;
    int securityLawsCorrect = 0;
    int financeCorrect = 0;
    int governanceCorrect = 0;

    int companyLawTotal = 0;
    int securityLawsTotal = 0;
    int financeTotal = 0;
    int governanceTotal = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      final question = widget.questions[i];
      final userAnswer = widget.attempt.answers[question.questionNumber];
      final isCorrect = userAnswer == question.correctIndex;

      if (i < questionsPerCategory) {
        companyLawTotal++;
        if (isCorrect) companyLawCorrect++;
      } else if (i < questionsPerCategory * 2) {
        securityLawsTotal++;
        if (isCorrect) securityLawsCorrect++;
      } else if (i < questionsPerCategory * 3) {
        financeTotal++;
        if (isCorrect) financeCorrect++;
      } else {
        governanceTotal++;
        if (isCorrect) governanceCorrect++;
      }
    }

    _categoryAnalysis = [
      CategoryAnalysis(
        name: 'Company Law',
        shortName: 'Company\nLaw',
        correctAnswers: companyLawCorrect,
        totalQuestions: companyLawTotal,
        color: AppColors.companyLaw,
        icon: Icons.business_rounded,
      ),
      CategoryAnalysis(
        name: 'Security Laws',
        shortName:  'Security\nLaws',
        correctAnswers: securityLawsCorrect,
        totalQuestions: securityLawsTotal,
        color: AppColors.securityLaws,
        icon: Icons.security_rounded,
      ),
      CategoryAnalysis(
        name: 'Finance',
        shortName: 'Finance',
        correctAnswers: financeCorrect,
        totalQuestions: financeTotal,
        color: AppColors.finance,
        icon: Icons.account_balance_rounded,
      ),
      CategoryAnalysis(
        name: 'Governance',
        shortName:  'Governance',
        correctAnswers: governanceCorrect,
        totalQuestions: governanceTotal,
        color: AppColors.governance,
        icon: Icons.gavel_rounded,
      ),
    ];
  }

  Future<void> _loadAttemptHistory() async {
    try {
      final attempts = await _repository.getAttemptHistory(
        userId: widget.attempt.userId,
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

  Future<void> _openAttemptResult(QuizAttempt attempt) async {
    if (attempt.id == widget.attempt.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('You are already viewing this attempt'),
            ],
          ),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _loadingAttemptId = attempt.id;
    });

    try {
      final questions = await _repository.getQuestions(attempt.assessmentId);

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children:  [
                  Icon(Icons. error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('Failed to load questions for this attempt'),
                ],
              ),
              backgroundColor: Colors.red. shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin:  const EdgeInsets.all(16),
            ),
          );
        }
        return;
      }

      int correctAnswers = 0;
      for (final question in questions) {
        final userAnswer = attempt.answers[question.questionNumber];
        if (userAnswer != null && userAnswer == question.correctIndex) {
          correctAnswers++;
        }
      }

      if (mounted) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ResultScreen(
                  attempt: attempt,
                  correctAnswers: correctAnswers,
                  totalQuestions: attempt.totalQuestions,
                  questions: questions,
                  initialTabIndex: 0,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:  Tween<Offset>(
                  begin: const Offset(1, 0),
                  end:  Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve:  Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error opening attempt result: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children:  [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Failed to load attempt details'),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
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

  List<Question> get wrongQuestions {
    return widget.questions.where((question) {
      final userAnswer = widget.attempt.answers[question. questionNumber];
      return userAnswer != null && userAnswer != question. correctIndex;
    }).toList();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  String _formatTimeShort(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}, ${date.year}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.correctAnswers / widget. totalQuestions * 100);
    final passed = percentage >= passingPercentage;
    final wrongCount = widget.totalQuestions - widget.correctAnswers;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildGradientHeader(percentage, passed, wrongCount),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                borderRadius:  BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight:  Radius.circular(32),
                ),
              ),
              child:  Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      controller:  _tabController,
                      children: [
                        _buildSummaryTab(wrongCount),
                        _buildAnalysisTab(),
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
    );
  }

  Widget _buildGradientHeader(double percentage, bool passed, int wrongCount) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment. bottomCenter,
          colors: passed
              ? [AppColors.accentTeal, AppColors.gradientEnd]
              : [const Color(0xFF546E7A), AppColors.primaryNavy],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child:  Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Navigator.of(context).canPop())
                    _buildHeaderIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  else
                    const SizedBox(width: 44),
                  const Text(
                    'RESULT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  _buildHeaderIconButton(
                    icon: Icons.home_rounded,
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildScoreCircle(percentage, passed),
              const SizedBox(height: 16),
              Container(
                padding:
                const EdgeInsets. symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border. all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      passed ? Icons. emoji_events :  Icons.refresh,
                      color: passed ? AppColors.gold : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      passed ? 'CONGRATULATIONS!' : 'TRY AGAIN! ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                passed
                    ?  "You've successfully passed the exam"
                    : "You need 50% to pass",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatsRow(wrongCount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height:  44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildScoreCircle(double percentage, bool passed) {
    return TweenAnimationBuilder<double>(
      tween:  Tween(begin: 0, end: percentage / 100),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder:  (context, value, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 115,
                height: 115,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.silverBorder,
                  ),
                ),
              ),
              SizedBox(
                width: 115,
                height: 115,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    passed ? AppColors.success : AppColors.gold,
                  ),
                  strokeCap: StrokeCap. round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${(value * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.labelText,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(int wrongCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:  [
        _buildStatCard(
          icon: Icons.quiz_outlined,
          iconColor: AppColors.accentTeal,
          value: '${widget.totalQuestions}',
          label: 'Total',
        ),
        _buildStatCard(
          icon: Icons. check_circle,
          iconColor: AppColors. success,
          value: '${widget.correctAnswers}',
          label: 'Correct',
        ),
        _buildStatCard(
          icon: Icons. cancel,
          iconColor: Colors.red,
          value: '$wrongCount',
          label: 'Wrong',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white. withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor. withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size:  14),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius. circular(16),
        border: Border.all(color: AppColors.silverBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.accentTeal,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.labelText,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.summarize_outlined, size: 16),
                SizedBox(width: 4),
                Text('Summary'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons. bar_chart_rounded, size: 16),
                SizedBox(width: 4),
                Text('Analysis'),
              ],
            ),
          ),
          Tab(
            child:  Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 16),
                SizedBox(width: 4),
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
          _buildCurrentAttemptCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.timer_outlined,
                  iconColor: AppColors.accentTeal,
                  title: 'Time Spent',
                  value: _formatTime(widget. attempt.timeSpentSeconds),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: AppColors.gold,
                  title: 'Date',
                  value: _formatDate(widget.attempt.endTime ??  DateTime.now()),
                ),
              ),
            ],
          ),
          const SizedBox(height:  20),
          if (wrongCount > 0) ...[
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ReviewScreen(
                          wrongQuestions: wrongQuestions,
                          userAnswers: widget.attempt.answers,
                        ),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end:  Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                );
              },
              child:  Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration:  BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors. gold,
                      AppColors.gold.withOpacity(0.8),
                    ],
                    begin: Alignment.centerLeft,
                    end:  Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.4),
                      blurRadius:  12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.rate_review_outlined,
                        size: 22, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Review $wrongCount Wrong Answers',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: () {
              _tabController.animateTo(1);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accentTeal. withOpacity(0.1),
                borderRadius: BorderRadius. circular(16),
                border:  Border.all(color: AppColors.accentTeal, width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded,
                      size: 22, color: AppColors.accentTeal),
                  SizedBox(width:  10),
                  Text(
                    'View Detailed Analysis',
                    style:  TextStyle(
                      fontSize:  16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentTeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius. circular(16),
                border: Border.all(color: AppColors.primaryNavy, width: 2),
              ),
              child:  const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined,
                      size:  22, color: AppColors. primaryNavy),
                  SizedBox(width: 10),
                  Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
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
    (widget.correctAnswers / widget.totalQuestions * 100).round();
    final passed = percentage >= passingPercentage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.lightGray,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: passed
              ? AppColors.success. withOpacity(0.3)
              : AppColors.gold.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: passed
                    ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                    : [AppColors.gold, AppColors.gold. withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              passed ? Icons.emoji_events : Icons.stars,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Current Attempt',
                      style:  TextStyle(
                        fontSize:  14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: passed
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors. gold.withOpacity(0.1),
                        borderRadius:  BorderRadius.circular(6),
                      ),
                      child: Text(
                        passed ? 'PASSED' : 'FAILED',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: passed ?  AppColors.success : AppColors. gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.correctAnswers}/${widget.totalQuestions} correct',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: passed
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors. gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: passed ? AppColors.success : AppColors.gold,
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
        borderRadius: BorderRadius. circular(16),
        border: Border.all(color: AppColors.silverBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.05),
            blurRadius:  10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor. withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.labelText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize:  15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:  const Icon(
                  Icons. analytics_rounded,
                  color: AppColors.accentTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width:  12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  Text(
                    'Category-wise breakdown',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.labelText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.silverBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius:  10,
                  offset:  const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Score by Category',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.success. withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color:  AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '50% Pass',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBarChart(),
              ],
            ),
          ),
          const SizedBox(height:  24),
          const Text(
            'Detailed Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _categoryAnalysis.length,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryDetailCard(_categoryAnalysis[index]),
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    const double barMaxHeight = 100.0;
    const double barWidth = 32.0;

    return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1500),
    curve: Curves.easeOutCubic,
    builder:  (context, animationValue, child) {
    return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: _categoryAnalysis.map((category) {
    final barHeight =
    (category.percentage / 100) * barMaxHeight * animationValue;
    final isPassing = category.percentage >= passingPercentage;

    return SizedBox(
    width: 70,
    child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
    Container(
    padding: const EdgeInsets.symmetric(
    horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
    color: isPassing
    ? AppColors.success.withOpacity(0.1)
        : Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
    '${category.percentage. toStringAsFixed(0)}%',
    style:  TextStyle(
    fontSize:  10,
    fontWeight: FontWeight.bold,
    color: isPassing ?  AppColors.success : Colors.red,
    ),
    ),
    ),
    const SizedBox(height: 6),
    SizedBox(
    height:  barMaxHeight,
    width: barWidth,
    child: Stack(
    alignment: Alignment.bottomCenter,
    children: [
    Container(
    width: barWidth,
    height: barMaxHeight,
    decoration: BoxDecoration(
    color:  AppColors.lightGray,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(
    color: AppColors.silverBorder,
    width: 1,
    ),
    ),
    ),
    Positioned(
    bottom: barMaxHeight * 0.5,
    left: -4,
    right: -4,
    child: Container(
    height:  2,
    color: AppColors.success,
    ),
    ),
    Container(
    width: barWidth,
    height: math.max(barHeight, 2),
    decoration: BoxDecoration(
    gradient: LinearGradient(
    begin: Alignment.bottomCenter,
    end:  Alignment.topCenter,
    colors: [
    category.color,
    category.color. withOpacity(0.7),
    ],
    ),
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
    BoxShadow(
    color: category.color.withOpacity(0.3),
    blurRadius: 4,
    offset: const Offset(0, 2),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    const SizedBox(height: 8),
    Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
    color: category.color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(6),
    ),
    child: Icon(
    category.icon,
    color: category.color,
    size: 14,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    category.shortName,
    style: const TextStyle(
    fontSize:  8,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    height: 1.2,
    ),
    textAlign: TextAlign.center,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    ),
    ],
    ),
    );
    }).toList(),
    ),
    );
    },
    );
  }

  Widget _buildCategoryDetailCard(CategoryAnalysis category) {
    final isPassing = category.percentage >= passingPercentage;

    return Container(
      padding:  const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.silverBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color. withOpacity(0.1),
              borderRadius: BorderRadius. circular(10),
            ),
            child:  Icon(
              category.icon,
              color: category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:  FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets. symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPassing
                            ? AppColors. success.withOpacity(0.1)
                            : Colors. red.withOpacity(0.1),
                        borderRadius:  BorderRadius.circular(4),
                      ),
                      child:  Text(
                        isPassing ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: isPassing ? AppColors.success : Colors. red,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${category. correctAnswers}/${category.totalQuestions}',
                      style:  const TextStyle(
                        fontSize: 11,
                        color: AppColors.labelText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value:  category.percentage / 100,
                          backgroundColor: AppColors.lightGray,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(category.color),
                          minHeight: 5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical:  6),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Text(
              '${category.percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final weakestCategory = _categoryAnalysis.reduce(
          (a, b) => a.percentage < b.percentage ?  a : b,
    );
    final strongestCategory = _categoryAnalysis.reduce(
          (a, b) => a.percentage > b.percentage ? a : b,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentTeal.withOpacity(0.1),
            AppColors.primaryNavy.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.accentTeal. withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppColors.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            icon: Icons.star_rounded,
            iconColor: AppColors.success,
            title: 'Your Strength',
            description:
            '${strongestCategory.name} - ${strongestCategory.percentage.toStringAsFixed(0)}% score',
          ),
          const SizedBox(height: 14),
          _buildRecommendationItem(
            icon: Icons.trending_up_rounded,
            iconColor: Colors.orange,
            title: 'Focus Area',
            description:
            'Improve ${weakestCategory.name} - Currently at ${weakestCategory.percentage.toStringAsFixed(0)}%',
          ),
          const SizedBox(height: 14),
          _buildRecommendationItem(
            icon: Icons.tips_and_updates_rounded,
            iconColor: AppColors.accentTeal,
            title:  'Pro Tip',
            description:
            'Review the wrong answers and practice more questions in ${weakestCategory.name}.',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size:  18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:  const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors. primaryNavy,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize:  13,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingHistory) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentTeal,
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading history...',
              style: TextStyle(
                color: AppColors.labelText,
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
              _isLoadingHistory = true;
              _errorMessage = null;
            });
            _loadAttemptHistory();
          },
          child: Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors. red. shade400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height:  12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
                    color: AppColors.accentTeal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_attemptHistory.isEmpty) {
      return Center(
        child:  Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors. accentTeal,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Previous Attempts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your quiz history will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAttemptHistory,
      color: AppColors.accentTeal,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _attemptHistory.length,
        itemBuilder: (context, index) {
          final attempt = _attemptHistory[index];
          final isCurrentAttempt = attempt.id == widget.attempt.id;
          final attemptNumber = _attemptHistory.length - index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildHistoryCard(
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
    final passed = percentage >= passingPercentage;
    final isLoading = _loadingAttemptId == attempt.id;

    return GestureDetector(
      onTap: isLoading ? null : () => _openAttemptResult(attempt),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentAttempt
              ? Border. all(color: AppColors.gold, width: 2)
              : Border.all(color: AppColors.silverBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isCurrentAttempt
                      ?  [AppColors.gold, AppColors.gold.withOpacity(0.7)]
                      : [AppColors.lightGray, AppColors.silverBorder],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                  width:  18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  '#$attemptNumber',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isCurrentAttempt
                        ?  Colors.white
                        : AppColors.primaryNavy,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing:  2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Attempt ${attemptNumber.toString().padLeft(2, '0')}',
                        style:  const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      if (isCurrentAttempt)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold. withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NOW',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildHistoryDetail(
                        icon: Icons. check_circle_outline,
                        text: '${attempt.score}/${attempt.totalQuestions}',
                      ),
                      const SizedBox(width: 12),
                      _buildHistoryDetail(
                        icon: Icons.access_time,
                        text: _formatTimeShort(attempt.timeSpentSeconds),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildHistoryDetail(
                    icon: Icons.calendar_today_outlined,
                    text:
                    _formatDateShort(attempt.endTime ??  attempt.startTime),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: passed
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors. gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(
                    color: passed ?  AppColors.success : AppColors. gold,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: passed ? AppColors.success : AppColors.gold,
                    ),
                  ),
                  Text(
                    passed ? 'PASS' : 'FAIL',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: passed ? AppColors.success : AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors. labelText,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: AppColors. labelText,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors. secondaryText,
          ),
        ),
      ],
    );
  }
}