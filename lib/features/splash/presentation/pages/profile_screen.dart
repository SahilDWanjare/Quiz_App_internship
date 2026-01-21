import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_app_project/features/splash/presentation/pages/personal_information_screen.dart';
import 'package:test_app_project/features/splash/presentation/pages/settings_screen.dart';
import '../../../assessment/presentation/pages/result_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../assessment/data/repository/assessment_repository.dart';
import '../../../assessment/domain/entities/assessment.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key?  key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0D121F),
            fontSize:  18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children:  [
            const SizedBox(height:  20),

            // Profile Picture
            Container(
              width: 100,
              height:  100,
              decoration: BoxDecoration(
                color:  const Color(0xFFE6E6FA),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 3,
                ),
              ),
              child: user?.photoURL != null
                  ?  ClipOval(
                child: Image.network(
                  user! .photoURL!,
                  fit:  BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 50,
                      color: Color(0xFF6B7FD7),
                    );
                  },
                ),
              )
                  : const Icon(
                Icons.person,
                size:  50,
                color: Color(0xFF6B7FD7),
              ),
            ),
            const SizedBox(height: 20),

            // Name
            Text(
              user?.displayName ??  'User',
              style:  const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color:  Color(0xFF0D121F),
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              user?.email ??  '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey. shade600,
              ),
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildProfileCard(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Update your personal details',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PersonalInformationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildProfileCard(
              icon:  Icons.history,
              title:  'Quiz History',
              subtitle: 'View your past attempts',
              onTap: () {
                _navigateToQuizHistory(context);
              }
            ),
            const SizedBox(height: 12),

            _buildProfileCard(
              icon: Icons. card_membership,
              title:  'Subscription',
              subtitle: 'Manage your subscription',
              onTap: () {
                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subscription management coming soon!'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildProfileCard(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'App preferences',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Sign Out Button
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () => _showSignOutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors. white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),

                      ),
                      elevation: 0,
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color:  Colors.white,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'SIGN OUT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight. w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:  Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow:  [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset:  const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width:  48,
              height:  48,
              decoration: BoxDecoration(
                color:  const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size:  24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight. w600,
                      color: Color(0xFF0D121F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey. shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuizHistory(BuildContext context) async {
    final user = FirebaseAuth. instance.currentUser;
    if (user == null) {
      ScaffoldMessenger. of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to view history'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child:  Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child:  Column(
              mainAxisSize: MainAxisSize. min,
              children: [
                CircularProgressIndicator(
                  color:  Color(0xFFD4AF37),
                ),
                SizedBox(height:  16),
                Text(
                  'Loading Quiz History.. .',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight. w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final repository = AssessmentRepository();

      // Get user's attempts
      final attempts = await repository.getUserAttempts(user. uid);

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (attempts.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Text('No quiz attempts found.  Complete a quiz first! '),
              backgroundColor:  Color(0xFFD4AF37),
            ),
          );
        }
        return;
      }

      // Get the most recent attempt
      final latestAttempt = attempts.first;

      // Fetch questions for this attempt
      final questions = await repository.getQuestions(latestAttempt.assessmentId);

      if (questions.isEmpty) {
        if (context. mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load quiz data'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Calculate correct answers
      int correctAnswers = 0;
      for (final question in questions) {
        final userAnswer = latestAttempt.answers[question.questionNumber];
        if (userAnswer != null && userAnswer == question.correctIndex) {
          correctAnswers++;
        }
      }

      if (context.mounted) {
        // Navigate to ResultScreen with initialTabIndex set to History (index 1)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              attempt: latestAttempt,
              correctAnswers: correctAnswers,
              totalQuestions: latestAttempt. totalQuestions,
              questions: questions,
              initialTabIndex: 1, // Open History tab directly
            ),
          ),
        );
      }
    } catch (e) {
      // Dismiss loading dialog if still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading history: $e'),
            backgroundColor: Colors. red,
          ),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context:  context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator. pop(dialogContext);
                context.read<AuthBloc>().add(SignOutEvent());
              },
              style:  ElevatedButton. styleFrom(
                backgroundColor: Colors.red,
              ),
              child:  Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: const Text('SIGN OUT'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}