import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/quiz_result.dart';

// --- Professional Palette ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color labelText = Color(0xFF8A9099);
  static const Color gold = Color(0xFF1B9AAA);
  static const Color success = Color(0xFF4CAF50);
}

class HistoryItemCard extends StatelessWidget {
  final AttemptHistory attempt;
  final VoidCallback? onTap;
  final bool isLoading;

  const HistoryItemCard({
    Key? key,
    required this.attempt,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final passed = attempt.scorePercentage >= 90;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors. white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.silverBorder, width: 1),
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
            // Icon Container
            Container(
              width:  52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: passed
                      ? [AppColors. success, AppColors.success. withOpacity(0.7)]
                      : [AppColors.accentTeal, AppColors.accentTeal.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child:  isLoading
                  ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
                  : Icon(
                passed ? Icons. emoji_events :  Icons.assignment,
                color: Colors. white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment. start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          attempt.attemptNumber,
                          style: const TextStyle(
                            fontSize:  15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: passed
                              ? AppColors.success. withOpacity(0.1)
                              : AppColors. gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(attempt.date),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        icon: Icons.access_time,
                        text: _formatTime(attempt.date),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: passed
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors. gold.withOpacity(0.1),
                    borderRadius:  BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        color: passed ? AppColors.success : AppColors.gold,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Text(
                    '${attempt.scorePercentage. toStringAsFixed(0)}%',
                    style:  TextStyle(
                      fontSize:  18,
                      fontWeight: FontWeight.bold,
                      color: passed ? AppColors.success :  AppColors.gold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppColors.labelText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(width:  8),

            // Arrow
            Icon(
              Icons. arrow_forward_ios,
              size: 14,
              color: AppColors. labelText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color:  AppColors.labelText,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}