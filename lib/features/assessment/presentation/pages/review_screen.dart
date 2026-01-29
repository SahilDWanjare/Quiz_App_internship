import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';
import '../widgets/option_button.dart';

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
}

class ReviewScreen extends StatefulWidget {
  final List<Question> wrongQuestions;
  final Map<int, int> userAnswers;

  const ReviewScreen({
    Key? key,
    required this. wrongQuestions,
    required this.userAnswers,
  }) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;

  Question get currentQuestion => widget.wrongQuestions[_currentIndex];
  int get totalWrongQuestions => widget.wrongQuestions. length;
  bool get isFirstQuestion => _currentIndex == 0;
  bool get isLastQuestion => _currentIndex == totalWrongQuestions - 1;

  void _goToNext() {
    if (!isLastQuestion) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _goToPrevious() {
    if (!isFirstQuestion) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  OptionState _getOptionState(int optionIndex) {
    final userAnswer = widget.userAnswers[currentQuestion.questionNumber];
    final correctAnswer = currentQuestion.correctIndex;

    if (optionIndex == correctAnswer) {
      return OptionState.correctAnswer;
    } else if (optionIndex == userAnswer) {
      return OptionState.wrong;
    }
    return OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Gradient Header
          _buildGradientHeader(),

          // Progress Indicator
          Container(
            height: 4,
            color: AppColors. silverBorder,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (_currentIndex + 1) / totalWrongQuestions,
              child: Container(
                color: Colors.red,
              ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:  BoxDecoration(
                          color: Colors.red. withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize:  MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Question ${currentQuestion.questionNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight. w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question Text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration:  BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.silverBorder, width: 1),
                    ),
                    child: Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize:  16,
                        height: 1.6,
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legend
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.silverBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(Colors.red, 'Your Answer'),
                        const SizedBox(width: 24),
                        _buildLegendItem(AppColors.success, 'Correct Answer'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options
                  ... List.generate(
                    currentQuestion.options.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child:  OptionButton(
                        optionText: currentQuestion.options[index],
                        optionIndex: index,
                        isReviewMode: true,
                        reviewState: _getOptionState(index),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient:  LinearGradient(
          begin:  Alignment.topCenter,
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
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color:  Colors.white. withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white. withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Review ${_currentIndex + 1} of $totalWrongQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.red. withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize:  MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalWrongQuestions',
                      style: const TextStyle(
                        color: Colors. white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets. all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous Button
            if (! isFirstQuestion)
              Expanded(
                child: OutlinedButton. icon(
                  onPressed:  _goToPrevious,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('PREVIOUS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors. primaryNavy, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            if (! isFirstQuestion) const SizedBox(width: 12),

            // Next/Done Button
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (isLastQuestion) {
                    Navigator.of(context).pop();
                  } else {
                    _goToNext();
                  }
                },
                style:  ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion ?  'DONE' : 'NEXT',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLastQuestion ? Icons.check :  Icons.arrow_forward,
                      size: 18,
                    ),
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