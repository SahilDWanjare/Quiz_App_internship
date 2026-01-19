import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';

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
      case ReviewFilter. wrong:
        return 'Wrong Answers';
      case ReviewFilter.all:
        return 'All Questions';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:  const Icon(Icons.arrow_back, color: Color(0xFF0D121F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _filterTitle,
          style: const TextStyle(
            color: Color(0xFF0D121F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_filteredQuestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius. circular(20),
              ),
              child: Center(
                child: Text(
                  '${_currentIndex + 1}/${_filteredQuestions.length}',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _filteredQuestions.isEmpty
          ?  _buildEmptyState()
          : Column(
        children: [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _filteredQuestions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.filter == ReviewFilter.wrong
                  ? Colors.red
                  : const Color(0xFF00C853),
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.filter == ReviewFilter.wrong
                ? Icons.check_circle_outline
                : Icons.quiz_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            widget.filter == ReviewFilter.wrong
                ? 'No wrong answers!'
                : 'No questions to review',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight. w500,
            ),
          ),
          const SizedBox(height:  8),
          Text(
            widget.filter == ReviewFilter.wrong
                ? 'Great job! You answered all questions correctly.'
                : 'There are no questions in this category.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
          // Question Status Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical:  6),
                decoration: BoxDecoration(
                  color:  const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:  Text(
                  'Question ${reviewQuestion.questionNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: reviewQuestion.isCorrect
                      ? const Color(0xFF00C853).withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reviewQuestion.isCorrect ? Icons. check :  Icons.close,
                      size: 14,
                      color: reviewQuestion.isCorrect
                          ? const Color(0xFF00C853)
                          :  Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reviewQuestion. isCorrect ? 'Correct' : 'Wrong',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: reviewQuestion.isCorrect
                            ?  const Color(0xFF00C853)
                            : Colors.red,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow:  [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius:  10,
                  offset:  const Offset(0, 2),
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
          const SizedBox(height:  24),

          // Options
          ... List.generate(
            question.options.length,
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
    Color?  iconColor;

    if (isCorrectAnswer) {
      // This is the correct answer - always show in green
      backgroundColor = const Color(0xFF00C853).withOpacity(0.1);
      borderColor = const Color(0xFF00C853);
      textColor = const Color(0xFF00C853);
      trailingIcon = Icons.check_circle;
      iconColor = const Color(0xFF00C853);
    } else if (isUserAnswer && !isCorrectAnswer) {
      // User selected this but it's wrong - show in red
      backgroundColor = Colors.red.withOpacity(0.1);
      borderColor = Colors. red;
      textColor = Colors.red;
      trailingIcon = Icons.cancel;
      iconColor = Colors. red;
    } else {
      // Not selected and not correct - neutral
      backgroundColor = Colors.white;
      borderColor = Colors. grey.shade300;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          // Option Letter
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCorrectAnswer || (isUserAnswer && !isCorrectAnswer)
                  ? borderColor. withOpacity(0.2)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                String.fromCharCode(65 + optionIndex), // A, B, C, D
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCorrectAnswer || (isUserAnswer && !isCorrectAnswer)
                      ? borderColor
                      : Colors.grey.shade600,
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
                color: textColor,
                fontWeight: isCorrectAnswer || isUserAnswer
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
                color: isCorrectAnswer ?  const Color(0xFF00C853) : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child:  const Text(
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
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(4),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:  Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            Expanded(
              child: OutlinedButton. icon(
                onPressed: _currentIndex > 0
                    ? () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
                    : null,
                icon: const Icon(Icons. arrow_back),
                label: const Text('PREVIOUS'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0D121F),
                  side: BorderSide(
                    color: _currentIndex > 0
                        ? const Color(0xFF0D121F)
                        : Colors.grey.shade300,
                  ),
                  padding:  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                  _pageController. nextPage(
                    duration:  const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
                    : null,
                style:  ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D121F),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors. grey.shade300,
                  padding:  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons. arrow_forward, size: 18),
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