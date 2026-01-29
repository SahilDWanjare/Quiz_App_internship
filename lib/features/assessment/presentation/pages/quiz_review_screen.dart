import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';

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
  static const Color gold = Color(0xFFD4AF37);
  static const Color gradientStart = Color(0xFF1B9AAA);
  static const Color gradientEnd = Color(0xFF0D1B2A);
  static const Color success = Color(0xFF4CAF50);
}

enum ReviewFilter { all, correct, wrong }

class QuizReviewScreen extends StatefulWidget {
  final QuizAttempt attempt;
  final List<Question> questions;
  final ReviewFilter filter;

  const QuizReviewScreen({
    Key? key,
    required this.attempt,
    required this.questions,
    required this.filter,
  }) : super(key: key);

  @override
  State<QuizReviewScreen> createState() => _QuizReviewScreenState();
}

class _QuizReviewScreenState extends State<QuizReviewScreen> {
  late PageController _pageController;
  late List<ReviewQuestion> _filteredQuestions;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _filterQuestions();
  }

  void _filterQuestions() {
    final allQuestions = widget.questions. map((question) {
      final userAnswer = widget.attempt.answers[question.questionNumber];
      final isCorrect = userAnswer == question.correctIndex;

      return ReviewQuestion(
        questionNumber: question.questionNumber,
        question: question,
        userAnswerIndex: userAnswer,
        isCorrect: isCorrect,
      );
    }).toList();

    switch (widget.filter) {
      case ReviewFilter.correct:
        _filteredQuestions = allQuestions.where((q) => q.isCorrect).toList();
        break;
      case ReviewFilter.wrong:
        _filteredQuestions = allQuestions.where((q) => !q.isCorrect).toList();
        break;
      case ReviewFilter.all:
        _filteredQuestions = allQuestions;
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _filterTitle {
    switch (widget.filter) {
      case ReviewFilter. correct:
        return 'Correct Answers';
      case ReviewFilter.wrong:
        return 'Wrong Answers';
      case ReviewFilter.all:
        return 'All Questions';
    }
  }

  Color get _filterColor {
    switch (widget.filter) {
      case ReviewFilter.correct:
        return AppColors.success;
      case ReviewFilter.wrong:
        return Colors.red;
      case ReviewFilter.all:
        return AppColors.accentTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors. white,
      body: Column(
        children: [
          // Gradient Header
          _buildHeader(),

          // Content
          _filteredQuestions.isEmpty
              ?  Expanded(child: _buildEmptyState())
              : Expanded(
            child: Column(
              children: [
                // Progress Indicator
                Container(
                  height: 4,
                  color: AppColors.silverBorder,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (_currentIndex + 1) / _filteredQuestions.length,
                    child: Container(
                      color: _filterColor,
                    ),
                  ),
                ),

                // Question Cards
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _filteredQuestions. length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(_filteredQuestions[index]);
                    },
                  ),
                ),

                // Navigation
                _buildNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient:  LinearGradient(
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
        child:  Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                        color:  Colors.white. withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border. all(
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
                  Expanded(
                    child: Text(
                      _filterTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors. white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_filteredQuestions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold. withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_currentIndex + 1}/${_filteredQuestions.length}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child:  Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: widget.filter == ReviewFilter.wrong
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors. accentTeal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.filter == ReviewFilter. wrong
                    ? Icons.check_circle_outline
                    :  Icons.quiz_outlined,
                size: 50,
                color: widget.filter == ReviewFilter.wrong
                    ? AppColors.success
                    : AppColors.accentTeal,
              ),
            ),
            const SizedBox(height:  24),
            Text(
              widget.filter == ReviewFilter.wrong
                  ? 'No wrong answers!'
                  : 'No questions to review',
              style: const TextStyle(
                fontSize: 22,
                color: AppColors.primaryNavy,
                fontWeight: FontWeight. bold,
              ),
            ),
            const SizedBox(height:  12),
            Text(
              widget.filter == ReviewFilter. wrong
                  ? 'Great job! You answered all questions correctly.'
                  : 'There are no questions in this category.',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors. secondaryText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors. accentTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets. symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius. circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'GO BACK',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ReviewQuestion reviewQuestion) {
    final question = reviewQuestion.question;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Status Badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical:  6),
                decoration: BoxDecoration(
                  color:  AppColors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(
                  'Question ${reviewQuestion.questionNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: reviewQuestion.isCorrect
                      ? AppColors.success. withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reviewQuestion.isCorrect ? Icons. check :  Icons.close,
                      size: 14,
                      color: reviewQuestion.isCorrect ? AppColors. success : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reviewQuestion.isCorrect ? 'Correct' : 'Wrong',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: reviewQuestion.isCorrect ?  AppColors.success : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height:  16),

          // Question Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightGray,
              borderRadius: BorderRadius. circular(16),
              border:  Border.all(color: AppColors.silverBorder, width: 1),
            ),
            child: Text(
              question.questionText,
              style: const TextStyle(
                fontSize: 16,
                height:  1.6,
                color: AppColors.primaryNavy,
                fontWeight: FontWeight. w500,
              ),
            ),
          ),
          const SizedBox(height:  24),

          // Options
          ... List.generate(
            question.options.length,
                (index) => Padding(
              padding: const EdgeInsets. only(bottom: 12),
              child: _buildOptionCard(
                optionText: question.options[index],
                optionIndex: index,
                isCorrectAnswer: index == question.correctIndex,
                isUserAnswer: index == reviewQuestion.userAnswerIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String optionText,
    required int optionIndex,
    required bool isCorrectAnswer,
    required bool isUserAnswer,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData?  trailingIcon;
    Color? iconColor;

    if (isCorrectAnswer) {
      backgroundColor = AppColors.success. withOpacity(0.1);
      borderColor = AppColors. success;
      textColor = AppColors.success;
      trailingIcon = Icons.check_circle;
      iconColor = AppColors.success;
    } else if (isUserAnswer && !isCorrectAnswer) {
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors.red;
      textColor = Colors.red;
      trailingIcon = Icons.cancel;
      iconColor = Colors. red;
    } else {
      backgroundColor = Colors.white;
      borderColor = AppColors. silverBorder;
      textColor = AppColors.inputText;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Option Letter
          Container(
            width:  36,
            height: 36,
            decoration: BoxDecoration(
              color: isCorrectAnswer || (isUserAnswer && !isCorrectAnswer)
                  ? borderColor. withOpacity(0.2)
                  : AppColors.lightGray,
              borderRadius: BorderRadius. circular(10),
            ),
            child:  Center(
              child: Text(
                String.fromCharCode(65 + optionIndex),
                style:  TextStyle(
                  fontSize:  14,
                  fontWeight: FontWeight.w600,
                  color: isCorrectAnswer || (isUserAnswer && !isCorrectAnswer)
                      ? borderColor
                      : AppColors.labelText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Option Text
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(
                fontSize: 15,
                color:  textColor,
                fontWeight:  isCorrectAnswer || isUserAnswer
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ),

          // Status Icon
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, color: iconColor, size: 24),
          ],

          // Labels
          if (isUserAnswer) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isCorrectAnswer ?  AppColors.success : Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Your Answer',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ] else if (isCorrectAnswer) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Correct',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight. w600,
                  color:  Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.08),
            blurRadius:  20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: OutlinedButton. icon(
                onPressed: _currentIndex > 0
                    ? () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves. easeOutCubic,
                  );
                }
                    : null,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('PREVIOUS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryNavy,
                  disabledForegroundColor: AppColors.labelText,
                  side: BorderSide(
                    color: _currentIndex > 0 ? AppColors.primaryNavy : AppColors.silverBorder,
                    width:  1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width:  12),

            // Next Button
            Expanded(
              child: ElevatedButton(
                onPressed: _currentIndex < _filteredQuestions.length - 1
                    ? () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                }
                    :  null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.silverBorder,
                  disabledForegroundColor: AppColors.labelText,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewQuestion {
  final int questionNumber;
  final Question question;
  final int?  userAnswerIndex;
  final bool isCorrect;

  ReviewQuestion({
    required this.questionNumber,
    required this.question,
    required this.userAnswerIndex,
    required this. isCorrect,
  });
}