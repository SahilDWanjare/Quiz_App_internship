import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

import '../../../assessment/presentation/pages/question.dart';

// --- Shared Professional Palette (From your provided code) ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFFD4AF37);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
  static const Color success = Color(0xFF4CAF50);

  // Specific Category Colors (Harmonized with the theme)
  static const Color companyLaw = Color(0xFF5D3FD3); // Iris Purple
  static const Color securityLaws = Color(0xFF1B9AAA); // Teal (Brand Match)
  static const Color finance = Color(0xFF2E8B57); // Sea Green
  static const Color governance = Color(0xFFE67E22); // Burnt Orange
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

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // --- BUSINESS LOGIC (UNCHANGED) ---
  bool _isLoading = true;
  List<CategoryAnalysis> _categoryAnalysis = [];
  int _totalAttempts = 0;
  double _averageScore = 0;
  int _totalQuestionsAnswered = 0;
  int _bestScore = 0;
  static const double passingPercentage = 50.0;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _fetchAndCalculateAnalytics(user.uid);
      } else {
        _generateDefaultAnalysis();
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
      _generateDefaultAnalysis();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchAndCalculateAnalytics(String userId) async {
    try {
      final attemptsSnapshot = await FirebaseFirestore.instance
          .collection('quiz_attempts')
          .where('user_id', isEqualTo: userId)
          .where('is_completed', isEqualTo: true)
          .get();

      if (attemptsSnapshot.docs.isEmpty) {
        _generateDefaultAnalysis();
        return;
      }

      _totalAttempts = attemptsSnapshot.docs.length;

      final sortedAttempts = attemptsSnapshot.docs;
      sortedAttempts.sort((a, b) {
        final aTime = (a.data()['end_time'] as Timestamp?)?.toDate() ??
            (a.data()['start_time'] as Timestamp).toDate();
        final bTime = (b.data()['end_time'] as Timestamp?)?.toDate() ??
            (b.data()['start_time'] as Timestamp).toDate();
        return bTime.compareTo(aTime);
      });

      double totalScore = 0;
      int maxScore = 0;
      for (var doc in sortedAttempts) {
        final data = doc.data();
        final score = data['score'] ?? 0;
        final total = data['total_questions'] ?? 1;
        final percentage = (score / total * 100).round();
        totalScore += percentage;
        if (percentage > maxScore) {
          maxScore = percentage;
        }
      }
      _averageScore = totalScore / _totalAttempts;
      _bestScore = maxScore;

      final latestAttempt = sortedAttempts.first.data();
      final assessmentId = latestAttempt['assessment_id'];

      final questionsSnapshot = await FirebaseFirestore.instance
          .collection('assessments')
          .doc(assessmentId)
          .collection('questions')
          .orderBy('question_number')
          .get();

      final answersMap = latestAttempt['answers'] as Map<String, dynamic>?;
      final userAnswers = answersMap?.map(
            (key, value) => MapEntry(int.parse(key), value as int),
      ) ??
          {};

      final questions = questionsSnapshot.docs.map((doc) {
        final data = doc.data();
        return Question(
          id: doc.id,
          questionText: data['question_text'] ?? '',
          options: List<String>.from(data['options'] ?? []),
          correctIndex: data['correct_index'] ?? 0,
          questionNumber: data['question_number'] ?? 0,
          difficulty: QuestionDifficulty.easy,
        );
      }).toList();

      _totalQuestionsAnswered = questions.length;
      _generateCategoryAnalysisFromQuestions(questions, userAnswers);
    } catch (e) {
      debugPrint('Error calculating analytics: $e');
      _generateDefaultAnalysis();
    }
  }

  void _generateCategoryAnalysisFromQuestions(
      List<Question> questions,
      Map<int, int> answers,
      ) {
    final totalQ = questions.length;
    final questionsPerCategory = (totalQ / 4).ceil();

    int companyLawCorrect = 0;
    int securityLawsCorrect = 0;
    int financeCorrect = 0;
    int governanceCorrect = 0;

    int companyLawTotal = 0;
    int securityLawsTotal = 0;
    int financeTotal = 0;
    int governanceTotal = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final userAnswer = answers[question.questionNumber];
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
        icon: Icons.gavel_rounded,
      ),
      CategoryAnalysis(
        name: 'Security Laws',
        shortName: 'Security\nLaws',
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
        icon: Icons.account_balance_wallet_rounded,
      ),
      CategoryAnalysis(
        name: 'Governance',
        shortName: 'Governance',
        correctAnswers: governanceCorrect,
        totalQuestions: governanceTotal,
        color: AppColors.governance,
        icon: Icons.balance_rounded,
      ),
    ];
  }

  void _generateDefaultAnalysis() {
    _totalAttempts = 0;
    _averageScore = 0;
    _totalQuestionsAnswered = 0;
    _bestScore = 0;

    _categoryAnalysis = [
      CategoryAnalysis(
        name: 'Company Law',
        shortName: 'Company\nLaw',
        correctAnswers: 0,
        totalQuestions: 0,
        color: AppColors.companyLaw,
        icon: Icons.gavel_rounded,
      ),
      CategoryAnalysis(
        name: 'Security Laws',
        shortName: 'Security\nLaws',
        correctAnswers: 0,
        totalQuestions: 0,
        color: AppColors.securityLaws,
        icon: Icons.security_rounded,
      ),
      CategoryAnalysis(
        name: 'Finance',
        shortName: 'Finance',
        correctAnswers: 0,
        totalQuestions: 0,
        color: AppColors.finance,
        icon: Icons.account_balance_wallet_rounded,
      ),
      CategoryAnalysis(
        name: 'Governance',
        shortName: 'Governance',
        correctAnswers: 0,
        totalQuestions: 0,
        color: AppColors.governance,
        icon: Icons.balance_rounded,
      ),
    ];
  }

  // --- UPDATED UI IMPLEMENTATION ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Matches your ProfileScreen bg
      body: Column(
        children: [
          _buildHeader(), // Custom Gradient Header
          Expanded(
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppColors.accentTeal,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing performance...',
                    style: TextStyle(
                      color: AppColors.labelText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
                : _buildAnalyticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 44), // Balance the back button
                ],
              ),
              const SizedBox(height: 24),
              // Big Icon for Analytics
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    final hasData = _categoryAnalysis.any((cat) => cat.totalQuestions > 0);

    if (!hasData) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Attempts',
                  _totalAttempts.toString(),
                  Icons.history_edu_rounded,
                  AppColors.accentTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'High Score',
                  '$_bestScore%',
                  Icons.emoji_events_rounded,
                  AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Average Score Full Width
          _buildStatCard(
            'Average Proficiency',
            '${_averageScore.toStringAsFixed(0)}%',
            Icons.donut_large_rounded,
            _averageScore >= passingPercentage ? AppColors.success : Colors.orange,
            fullWidth: true,
          ),
          const SizedBox(height: 24),

          // Section Title
          const Text(
            'Category Performance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.labelText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Bar Chart Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.silverBorder, width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Score Distribution',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PASS > 50%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildBarChart(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed Breakdown
          const Text(
            'Subject Breakdown',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.labelText,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _categoryAnalysis.length,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCategoryDetailCard(_categoryAnalysis[index]),
            ),
          ),
          const SizedBox(height: 24),
          _buildRecommendationsCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label,
      String value,
      IconData icon,
      Color color, {
        bool fullWidth = false,
      }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.silverBorder),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: AppColors.labelText,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete your first assessment to view detailed performance analytics.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    const double barMaxHeight = 120.0;
    const double barWidth = 32.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutQuart,
      builder: (context, animationValue, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: _categoryAnalysis.map((category) {
            final barHeight =
                (category.percentage / 100) * barMaxHeight * animationValue;
            final isPassing = category.percentage >= passingPercentage;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${category.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isPassing ? category.color : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: barMaxHeight,
                  width: barWidth,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Background
                      Container(
                        width: barWidth,
                        height: barMaxHeight,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.silverBorder),
                        ),
                      ),
                      // Fill
                      Container(
                        width: barWidth,
                        height: math.max(barHeight, 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              category.color,
                              category.color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  category.icon,
                  color: category.color,
                  size: 16,
                ),
                const SizedBox(height: 4),
                Text(
                  category.shortName.replaceAll('\n', ' '),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategoryDetailCard(CategoryAnalysis category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.silverBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    Text(
                      '${category.percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: category.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: category.percentage / 100,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(category.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final hasData = _categoryAnalysis.any((cat) => cat.totalQuestions > 0);
    if (!hasData) return const SizedBox.shrink();

    final weakestCategory = _categoryAnalysis.reduce(
          (a, b) => a.percentage < b.percentage ? a : b,
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
          color: AppColors.accentTeal.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildRecommendationItem(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.success,
            title: 'Strongest Area',
            description: '${strongestCategory.name} is your best performing subject.',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.primaryNavy.withOpacity(0.1), height: 1),
          ),
          _buildRecommendationItem(
            icon: Icons.trending_up,
            iconColor: Colors.orange,
            title: 'Needs Improvement',
            description: 'Focus on ${weakestCategory.name} to boost your overall score.',
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
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
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
}