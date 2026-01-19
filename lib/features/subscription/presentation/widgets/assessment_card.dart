import 'package:flutter/material.dart';

class AssessmentCard extends StatelessWidget {
  final bool isSubscribed;
  final VoidCallback onButtonPressed;

  const AssessmentCard({
    Key? key,
    required this.isSubscribed,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Independent Directors Examination',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D121F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1.7k users took this test',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: Icons.list_alt,
            iconColor: const Color(0xFF6B7FD7),
            title: '7 SECTIONS',
            subtitle: '30 Multiple choice Questions',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.access_time,
            iconColor: const Color(0xFF6B7FD7),
            title: '90 MINUTES',
            subtitle: '15 min per section',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.stars,
            iconColor: const Color(0xFF6B7FD7),
            title: '90% GRADES',
            subtitle: 'For passing the Test',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'BEFORE YOU START',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D121F),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'You must complete this test in one session - make sure your internet is reliable.',
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            '1 mark awarded for a correct answer. No negative/marking will be there for wrong answer.',
          ),
          const SizedBox(height: 8),
          _buildBulletPoint(
            'More you give the correct answer more chance to win the badge.',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D121F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isSubscribed ? 'PROCEED' : 'SUBSCRIBE TO ENROLL',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D121F),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF0D121F),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}