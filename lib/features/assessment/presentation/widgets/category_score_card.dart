import 'package:flutter/material.dart';
import '../../domain/entities/quiz_result.dart';

class CategoryScoreCard extends StatelessWidget {
  final CategoryScore category;

  const CategoryScoreCard({
    Key? key,
    required this.category,
  }) : super(key: key);

  IconData _getIconForCategory(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'legal':
        return Icons.gavel;
      case 'technology':
        return Icons.computer;
      case 'science':
        return Icons.science;
      case 'ai':
      case 'ml':
        return Icons.psychology;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.article;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForCategory(category.iconName),
              color: const Color(0xFF0D121F),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D121F),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.sectionNumber,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${category.percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${category.correctAnswers}/${category.totalQuestions}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}