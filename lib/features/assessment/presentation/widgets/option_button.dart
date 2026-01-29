import 'package:flutter/material.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color inputText = Color(0xFF5A6169);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFFD4AF37);
  static const Color success = Color(0xFF4CAF50);
}

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
  final VoidCallback? onTap;
  final bool isReviewMode;
  final OptionState?  reviewState;

  const OptionButton({
    Key? key,
    required this.optionText,
    required this.optionIndex,
    this.isSelected = false,
    this.onTap,
    this.isReviewMode = false,
    this.reviewState,
  }) : super(key: key);

  String get optionLabel {
    const labels = ['A', 'B', 'C', 'D'];
    return optionIndex < labels.length ? labels[optionIndex] : '';
  }

  @override
  Widget build(BuildContext context) {
    final state = reviewState ?? (isSelected ? OptionState.selected : OptionState.normal);

    return GestureDetector(
      onTap: isReviewMode ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(state),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _getBorderColor(state),
            width: _getBorderWidth(state),
          ),
          boxShadow: state != OptionState.normal
              ?  [
            BoxShadow(
              color: _getBorderColor(state).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            // Option Label Circle
            Container(
              width:  40,
              height: 40,
              decoration: BoxDecoration(
                color: _getLabelBackgroundColor(state),
                borderRadius: BorderRadius.circular(12),
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
            const SizedBox(width: 14),

            // Option Text
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 15,
                  color: _getTextColor(state),
                  fontWeight: _getTextFontWeight(state),
                  height: 1.4,
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
        return AppColors.accentTeal.withOpacity(0.1);
      case OptionState.correct:
        return AppColors.success.withOpacity(0.1);
      case OptionState.wrong:
        return Colors.red.withOpacity(0.1);
      case OptionState.correctAnswer:
        return AppColors.success.withOpacity(0.1);
      case OptionState.normal:
      default:
        return Colors.white;
    }
  }

  Color _getBorderColor(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return AppColors.accentTeal;
      case OptionState.correct:
        return AppColors.success;
      case OptionState. wrong:
        return Colors.red;
      case OptionState. correctAnswer:
        return AppColors.success;
      case OptionState.normal:
      default:
        return AppColors.silverBorder;
    }
  }

  double _getBorderWidth(OptionState state) {
    return state == OptionState.normal ? 1 : 2;
  }

  Color _getLabelBackgroundColor(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return AppColors.accentTeal;
      case OptionState.correct:
        return AppColors.success;
      case OptionState. wrong:
        return Colors.red;
      case OptionState. correctAnswer:
        return AppColors.success;
      case OptionState.normal:
      default:
        return AppColors.lightGray;
    }
  }

  Color _getLabelTextColor(OptionState state) {
    return state == OptionState.normal ?  AppColors.labelText : Colors.white;
  }

  Color _getTextColor(OptionState state) {
    switch (state) {
      case OptionState.correct:
      case OptionState.correctAnswer:
        return AppColors.success;
      case OptionState. wrong:
        return Colors.red;
      case OptionState. selected:
        return AppColors.primaryNavy;
      default:
        return AppColors.inputText;
    }
  }

  FontWeight _getTextFontWeight(OptionState state) {
    return state == OptionState.normal ?  FontWeight.w400 : FontWeight.w600;
  }

  Widget _buildTrailingIcon(OptionState state) {
    switch (state) {
      case OptionState.selected:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.accentTeal,
            shape: BoxShape. circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        );
      case OptionState.correct:
      case OptionState.correctAnswer:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 16,
          ),
        );
      case OptionState.wrong:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            color: Colors.white,
            size: 16,
          ),
        );
      case OptionState.normal:
      default:
        return const SizedBox. shrink();
    }
  }
}