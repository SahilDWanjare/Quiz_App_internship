import 'package:flutter/material.dart';

enum OptionState {
  normal,
  selected,
  correct,
  wrong,
  correctAnswer, // Shows the correct answer when user selected wrong
}

class OptionButton extends StatelessWidget {
  final String optionText;
  final int optionIndex;
  final bool isSelected;
  final VoidCallback?  onTap;
  final bool isReviewMode;
  final OptionState? reviewState;

  const OptionButton({
    Key? key,
    required this. optionText,
    required this.optionIndex,
    this.isSelected = false,
    this. onTap,
    this.isReviewMode = false,
    this.reviewState,
  }) : super(key:  key);

  String get optionLabel {
    const labels = ['A', 'B', 'C', 'D'];
    return labels[optionIndex];
  }

  @override
  Widget build(BuildContext context) {
    final state = reviewState ?? (isSelected ? OptionState. selected : OptionState.normal);

    return GestureDetector(
      onTap: isReviewMode ? null : onTap,
      child: Container(
        padding:  const EdgeInsets. all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(state),
          borderRadius: BorderRadius. circular(12),
          border: Border. all(
            color: _getBorderColor(state),
            width: _getBorderWidth(state),
          ),
          boxShadow: [
            if (state == OptionState.normal)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius:  8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Option Label Circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _getLabelBackgroundColor(state),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  optionLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getLabelTextColor(state),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Option Text
            Expanded(
              child:  Text(
                optionText,
                style: TextStyle(
                  fontSize:  15,
                  color: _getTextColor(state),
                  fontWeight:  _getTextFontWeight(state),
                ),
              ),
            ),

            // Icon based on state
            _buildTrailingIcon(state),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return const Color(0xFFD4AF37).withOpacity(0.1);
      case OptionState. correct:
        return const Color(0xFF00C853).withOpacity(0.1);
      case OptionState.wrong:
        return Colors.red. withOpacity(0.1);
      case OptionState. correctAnswer:
        return const Color(0xFF00C853).withOpacity(0.1);
      case OptionState.normal:
      default:
        return Colors.white;
    }
  }

  Color _getBorderColor(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return const Color(0xFFD4AF37);
      case OptionState.correct:
        return const Color(0xFF00C853);
      case OptionState.wrong:
        return Colors. red;
      case OptionState.correctAnswer:
        return const Color(0xFF00C853);
      case OptionState.normal:
      default:
        return Colors.grey. shade200;
    }
  }

  double _getBorderWidth(OptionState state) {
    return state == OptionState. normal ? 1 : 2;
  }

  Color _getLabelBackgroundColor(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return const Color(0xFFD4AF37);
      case OptionState.correct:
        return const Color(0xFF00C853);
      case OptionState.wrong:
        return Colors. red;
      case OptionState.correctAnswer:
        return const Color(0xFF00C853);
      case OptionState.normal:
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getLabelTextColor(OptionState state) {
    return state == OptionState.normal ? Colors.grey. shade700 : Colors.white;
  }

  Color _getTextColor(OptionState state) {
    switch (state) {
      case OptionState.correct:
      case OptionState. correctAnswer:
        return const Color(0xFF00C853);
      case OptionState. wrong:
        return Colors.red;
      default:
        return state == OptionState. selected
            ? const Color(0xFF0D121F)
            : Colors.grey.shade800;
    }
  }

  FontWeight _getTextFontWeight(OptionState state) {
    return state == OptionState.normal ? FontWeight.w400 : FontWeight. w600;
  }

  Widget _buildTrailingIcon(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFFD4AF37),
          size: 24,
        );
      case OptionState.correct:
      case OptionState. correctAnswer:
        return const Icon(
          Icons.check_circle,
          color: Color(0xFF00C853),
          size: 24,
        );
      case OptionState.wrong:
        return const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 24,
        );
      case OptionState. normal:
      default:
        return const SizedBox. shrink();
    }
  }
}