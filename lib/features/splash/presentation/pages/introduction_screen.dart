import 'package:flutter/material.dart';
import 'home_screen_full.dart'; // Import your dashboard/home screen

// --- Professional Palette (Reused for consistency) ---
class AppColors {
  static const Color primaryNavy = Color(0xFF0D1B2A);
  static const Color accentTeal = Color(0xFF1B9AAA);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color silverBorder = Color(0xFFDDE1E6);
  static const Color secondaryText = Color(0xFF6D7175);
  static const Color inputBackground = Color(0xFFF5F7FA);
}

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({Key? key}) : super(key: key);

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  bool _hasRead = false;
  final ScrollController _scrollController = ScrollController();

  void _navigateToHome() {
    if (_hasRead) {
      // Navigate to Home and remove all previous routes (so they can't go back to Intro)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Gradient Header
          _buildHeader(),

          // Scrollable Content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Welcome Aboard!'),
                    _buildBodyText(
                        'Congratulations for taking the first step towards your boardroom leadership journey!'
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('About ID Aspire'),
                    _buildBodyText(
                        'The App (ID Aspire -- with ID as short form of Independent Director) is developed with the objective of helping you (typically the working professional hard pressed for time) in successfully clearing the qualifying examination (online assessment) of becoming an Independent Director.'
                    ),
                    const SizedBox(height: 12),
                    _buildBodyText(
                        'ID Aspire would give you the experience and confidence through the concise study material and several practice tests.'
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Exam Pattern'),
                    _buildBulletPoint('50 Multiple Choice Questions (MCQs)'),
                    _buildBulletPoint('Duration: 75 minutes'),
                    _buildBulletPoint('Each question carries 2 marks'),
                    _buildBulletPoint('No negative marking. Passing score is 50%'),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Syllabus Coverage'),
                    _buildBodyText('The assessment covers the following key areas:'),
                    const SizedBox(height: 8),
                    _buildTopicChip(Icons.gavel, 'Companies Law (Companies Act 2013)'),
                    _buildTopicChip(Icons.show_chart, 'Securities Law & SEBI Regulations'),
                    _buildTopicChip(Icons.account_balance, 'Financial literacy & accounting basics'),
                    _buildTopicChip(Icons.policy, 'Corporate Governance fundamentals'),
                    _buildTopicChip(Icons.psychology, 'Case studies - Applied knowledge'),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Registration Process'),
                    _buildBodyText(
                        'Before you appear for your online assessment examination of Independent Director, you need to complete the following steps:'
                    ),
                    const SizedBox(height: 12),
                    _buildNumberedPoint('1', 'Register on the MCA (Ministry of Corporate Affairs) portal'),
                    _buildNumberedPoint('2', 'After receiving login credentials, go to MCA Services tab & choose ID Databank Registration and select "Individual Registration"'),
                    _buildNumberedPoint('3', 'After profile completion and due verification, you\'ll receive credentials for the Independent Directors Databank via email and SMS'),
                    _buildNumberedPoint('4', 'With those credentials you can book assessment slot on independentdirectorsdatabank portal'),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGray,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.silverBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: AppColors.primaryNavy),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search for "independentdirectorsdatabank" & choose the right one with the website domain .in (URLs not provided as they might get changed/tweaked in future)',
                              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    _buildBodyText(
                        'You can complete the above registration formalities after studying enough/giving enough practice tests through ID Aspire or can do it now also.'
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('A Word of Caution'),
                    _buildBodyText(
                        'Do NOT take this examination lightly (Especially Engineers/HR professionals without any formal background of accountancy/corporate law). Though multiple attempts are allowed, target to clear it in the first attempt itself. (Very difficult to maintain the motivation and exam readiness for long.)'
                    ),
                    const SizedBox(height: 12),
                    _buildBodyText(
                        'If you\'re juggling with your current high-profile job, you need to spare/invest enough time to understand, study and get well-versed with all the topics under the syllabus. And accordingly choose the right subscription of ID Aspire (2 months or 12 months or unlimited).'
                    ),
                    const SizedBox(height: 12),
                    _buildBodyText(
                        'ID Aspire provides enough thrust through \'Foundational Finance for non-finance folks\'.'
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle('Certification'),
                    _buildBodyText(
                        'Once you clear the said online Assessment examination, you would get the certificate from Indian Institute of Corporate Affairs (IICA) and which would be valid for your life. (There are no renewals required for this certification)'
                    ),
                    const SizedBox(height: 12),
                    _buildBodyText(
                        'It would enable you joining a boardroom (of a listed and or a public company with some conditions) as an \'Independent Director\'.'
                    ),

                    const SizedBox(height: 24),
                    // Disclaimer Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Disclaimer',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "This app is a preparatory tool only and is not affiliated with, endorsed by, or partnered with the Indian Institute of Corporate Affairs (IICA) or the Ministry of Corporate Affairs (MCA) or any other Government agency/institute.",
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Best of luck message
                    Center(
                      child: Text(
                        'Best of luck!!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _hasRead = !_hasRead;
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _hasRead,
                          activeColor: AppColors.accentTeal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _hasRead = value ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'I have read and understood all the aspects.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _hasRead ? _navigateToHome : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.silverBorder,
                      disabledForegroundColor: AppColors.secondaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _hasRead ? 4 : 0,
                    ),
                    child: const Text(
                      'CONTINUE TO DASHBOARD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accentTeal, AppColors.primaryNavy],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Getting Started',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Essential information before you begin.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryNavy,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
        color: AppColors.secondaryText,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: AppColors.accentTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedPoint(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.accentTeal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.silverBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accentTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}