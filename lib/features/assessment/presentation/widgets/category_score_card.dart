import 'package:flutter/material.dart';
import '../../domain/entities/quiz_result.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFFD4AF37);
  static const Color success = Color(0xFF4CAF50);
}

class CategoryScoreCard extends StatelessWidget {
  final CategoryScore category;
  final VoidCallback? onTap;

  const CategoryScoreCard({
    Key? key,
    required this.category,
    this. onTap,
  }) : super(key: key);

  IconData _getIconForCategory(String iconName) {
    switch (iconName. toLowerCase()) {
      case 'legal':
        return Icons.gavel_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'ai':
      case 'ml':
        return Icons.psychology_rounded;
      case 'health':
        return Icons.local_hospital_rounded;
      case 'finance':
        return Icons.account_balance_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'marketing':
        return Icons.campaign_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) {
      return AppColors.success;
    } else if (percentage >= 70) {
      return AppColors.gold;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(category.percentage);

    return GestureDetector(
      onTap:  onTap,
      child:  Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors. silverBorder, width: 1),
          boxShadow:  [
            BoxShadow(
              color: Colors.black. withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentTeal.withOpacity(0.15),
                    AppColors.accentTeal.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius. circular(14),
                border: Border.all(
                  color: AppColors.accentTeal. withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIconForCategory(category.iconName),
                color: AppColors.accentTeal,
                size: 28,
              ),
            ),
            const SizedBox(width:  16),

            // Content
            Expanded(
              child:  Column(
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [
                  Text(
                    category.categoryName. toUpperCase(),
                    style: const TextStyle(
                      fontSize:  14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category.sectionNumber,
                          style: const TextStyle(
                            fontSize:  10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.labelText,
                          ),
                        ),
                      ),
                      const SizedBox(width:  8),
                      Text(
                        '${category.correctAnswers}/${category.totalQuestions} correct',
                        style: const TextStyle(
                          fontSize:  11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Container(
              padding: const EdgeInsets. symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: scoreColor. withOpacity(0.1),
                borderRadius: BorderRadius. circular(12),
                border: Border(
                  left: BorderSide(
                    color: scoreColor,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '${category.percentage.toStringAsFixed(0)}%',
                    style:  TextStyle(
                      fontSize:  20,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    'SCORE',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: scoreColor. withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors. labelText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Compact version for lists
class CategoryScoreCardCompact extends StatelessWidget {
  final String categoryName;
  final int correctAnswers;
  final int totalQuestions;
  final double percentage;

  const CategoryScoreCardCompact({
    Key? key,
    required this.categoryName,
    required this.correctAnswers,
    required this.totalQuestions,
    required this. percentage,
  }) : super(key: key);

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) {
      return AppColors.success;
    } else if (percentage >= 70) {
      return AppColors.gold;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(percentage);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical:  12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.silverBorder, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$correctAnswers/$totalQuestions correct',
                  style: const TextStyle(
                    fontSize:  12,
                    color:  AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Text(
              '${percentage. toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}