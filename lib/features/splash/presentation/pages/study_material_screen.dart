import 'package:flutter/material.dart';

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
}

class StudyMaterialItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  StudyMaterialItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });
}

class StudyMaterialScreen extends StatelessWidget {
  const StudyMaterialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<StudyMaterialItem> materials = [
      StudyMaterialItem(
        title: 'Companies Law',
        subtitle: '(Companies Act 2013)',
        icon: Icons.business_rounded,
        iconColor: const Color(0xFF6366F1),
      ),
      StudyMaterialItem(
        title: 'Securities Law & SEBI Regulations',
        subtitle: '',
        icon: Icons.security_rounded,
        iconColor: const Color(0xFFEC4899),
      ),
      StudyMaterialItem(
        title: 'Financial literacy & accounting basics',
        subtitle: '(Foundational Finance for non-finance folks)',
        icon: Icons.account_balance_wallet_rounded,
        iconColor: const Color(0xFF14B8A6),
      ),
      StudyMaterialItem(
        title: 'Corporate Governance fundamentals',
        subtitle: '',
        icon: Icons.gavel_rounded,
        iconColor: const Color(0xFFF59E0B),
      ),
      StudyMaterialItem(
        title: 'Case studies-',
        subtitle: '(Applied knowledge)',
        icon: Icons.menu_book_rounded,
        iconColor: AppColors.accentTeal,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.silverBorder,
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'STUDY MATERIAL',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                  letterSpacing: 1,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Material List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildMaterialCard(context, materials[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, StudyMaterialItem item) {
    return GestureDetector(
      onTap: () {
        // Show coming soon message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('${item.title} - Coming Soon!'),
                ),
              ],
            ),
            backgroundColor: AppColors.accentTeal,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.silverBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
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
                color: item.iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: item.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.labelText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.labelText,
            ),
          ],
        ),
      ),
    );
  }
}