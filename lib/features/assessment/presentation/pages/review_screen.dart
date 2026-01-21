import 'package:flutter/material.dart';
import '../../domain/entities/assessment.dart';
import '../widgets/option_button.dart';

class ReviewScreen extends StatefulWidget {
  final List<Question> wrongQuestions;
  final Map<int, int> userAnswers;

  const ReviewScreen({
    Key? key,
    required this.wrongQuestions,
    required this.userAnswers,
  }) : super(key:  key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _currentIndex = 0;

  Question get currentQuestion => widget. wrongQuestions[_currentIndex];
  int get totalWrongQuestions => widget.wrongQuestions.length;
  bool get isFirstQuestion => _currentIndex == 0;
  bool get isLastQuestion => _currentIndex == totalWrongQuestions - 1;

  void _goToNext() {
    if (! isLastQuestion) {
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
    final userAnswer = widget. userAnswers[currentQuestion.questionNumber];
    final correctAnswer = currentQuestion. correctIndex;

    if (optionIndex == correctAnswer) {
      return OptionState.correctAnswer;
    } else if (optionIndex == userAnswer) {
      return OptionState. wrong;
    }
    return OptionState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        backgroundColor:  Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0D121F)),
          onPressed:  () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Review ${_currentIndex + 1} of $totalWrongQuestions',
          style:  const TextStyle(
            color: Color(0xFF0D121F),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children:  [
          // Progress Indicator
          LinearProgressIndicator(
            value: (_currentIndex + 1) / totalWrongQuestions,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            minHeight: 4,
          ),

          // Question Content
          Expanded(
            child:  SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child:  Column(
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
                        child:  Row(
                          mainAxisSize: MainAxisSize. min,
                          children: [
                            const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.red,
                            ),
                            const SizedBox(width:  4),
                            Text(
                              'Question ${currentQuestion.questionNumber}',
                              style: const TextStyle(
                                fontSize:  12,
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
                    decoration: BoxDecoration(
                      color:  Colors.white,
                      borderRadius: BorderRadius. circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors. black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      currentQuestion.questionText,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Color(0xFF0D121F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legend
                  Row(
                    children:  [
                      _buildLegendItem(Colors.red, 'Your Answer'),
                      const SizedBox(width: 20),
                      _buildLegendItem(const Color(0xFF00C853), 'Correct Answer'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Options
                  ... List.generate(
                    currentQuestion.options.length,
                        (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: OptionButton(
                        optionText: currentQuestion. options[index],
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

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize. min,
      children: [
        Container(
          width: 12,
          height:  12,
          decoration: BoxDecoration(
            color:  color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width:  6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors. grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding:  const EdgeInsets. all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Previous Button
            if (! isFirstQuestion)
              Expanded(
                child:  OutlinedButton(
                  onPressed: _goToPrevious,
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
                      fontSize:  14,
                      fontWeight: FontWeight. w600,
                    ),
                  ),
                ),
              ),

            if (! isFirstQuestion) const SizedBox(width: 12),

            // Next/Done Button
            Expanded(
              child:  ElevatedButton(
                onPressed: () {
                  if (isLastQuestion) {
                    Navigator.of(context).pop();
                  } else {
                    _goToNext();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D121F),
                  foregroundColor: Colors. white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius:  BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isLastQuestion ? 'DONE' : 'NEXT',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight:  FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}