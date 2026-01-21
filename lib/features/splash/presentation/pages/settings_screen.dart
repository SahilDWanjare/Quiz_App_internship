import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _autoSaveEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
        _soundEnabled = prefs.getBool('sound_enabled') ?? true;
        _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
        _autoSaveEnabled = prefs. getBool('auto_save_enabled') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey. shade50,
      appBar: AppBar(
        backgroundColor: Colors. white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0D121F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF0D121F),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            const SizedBox(height: 16),

            _buildSwitchTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive quiz reminders and updates',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                _saveSetting('notifications_enabled', value);
              },
            ),
            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            const SizedBox(height: 16),

            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title:  'Dark Mode',
              subtitle:  'Switch to dark theme',
              value: _darkModeEnabled,
              onChanged:  (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                _saveSetting('dark_mode_enabled', value);
                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content:  Text('Dark mode will be available in the next update! '),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Quiz Settings Section
            _buildSectionHeader('Quiz Settings'),
            const SizedBox(height: 16),

            _buildSwitchTile(
              icon: Icons. volume_up_outlined,
              title:  'Sound Effects',
              subtitle: 'Play sounds during quiz',
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
                _saveSetting('sound_enabled', value);
              },
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              icon: Icons.vibration,
              title:  'Vibration',
              subtitle: 'Vibrate on answer selection',
              value: _vibrationEnabled,
              onChanged: (value) {
                setState(() {
                  _vibrationEnabled = value;
                });
                _saveSetting('vibration_enabled', value);
              },
            ),
            const SizedBox(height: 12),

            _buildSwitchTile(
              icon: Icons. save_outlined,
              title: 'Auto-Save Progress',
              subtitle: 'Automatically save quiz progress',
              value: _autoSaveEnabled,
              onChanged: (value) {
                setState(() {
                  _autoSaveEnabled = value;
                });
                _saveSetting('auto_save_enabled', value);
              },
            ),
            const SizedBox(height: 32),

            // About Section
            _buildSectionHeader('About'),
            const SizedBox(height: 16),

            _buildInfoTile(
              icon: Icons. info_outline,
              title: 'App Version',
              trailing: 'v1.0.0',
            ),
            const SizedBox(height:  12),

            _buildActionTile(
              icon:  Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {
                _showContentDialog(
                  context,
                  'Terms of Service',
                  _termsOfServiceContent,
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              icon:  Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap:  () {
                _showContentDialog(
                  context,
                  'Privacy Policy',
                  _privacyPolicyContent,
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                _showHelpSupportDialog(context);
              },
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              icon:  Icons.star_outline,
              title: 'Rate This App',
              onTap: () {
                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your support!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              icon:  Icons.share_outlined,
              title: 'Share App',
              onTap: () {
                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality coming soon!'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Account Section
            _buildSectionHeader('Account'),
            const SizedBox(height: 16),

            _buildActionTile(
              icon: Icons. password_outlined,
              title: 'Change Password',
              onTap: () {
                _showChangePasswordDialog(context);
              },
            ),
            const SizedBox(height:  12),

            _buildActionTile(
              icon:  Icons.logout,
              title:  'Sign Out',
              iconColor: Colors.orange,
              textColor: Colors.orange,
              onTap: () {
                _showSignOutDialog(context);
              },
            ),
            const SizedBox(height: 32),

            // Danger Zone
            _buildSectionHeader('Danger Zone', color: Colors.red),
            const SizedBox(height:  16),

            _buildActionTile(
              icon: Icons.delete_forever_outlined,
              title: 'Clear All Data',
              iconColor: Colors.red. shade400,
              textColor: Colors.red. shade400,
              onTap: () {
                _showClearDataDialog(context);
              },
            ),
            const SizedBox(height: 12),

            _buildActionTile(
              icon:  Icons.person_remove_outlined,
              title: 'Delete Account',
              iconColor: Colors. red,
              textColor: Colors.red,
              onTap: () {
                _showDeleteAccountDialog(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Color? color}) {
    return Text(
      title. toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color:  color ?? Colors.grey.shade600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding:  const EdgeInsets. all(16),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius:  10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 22,
            ),
          ),
          const SizedBox(width:  16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:  FontWeight.w600,
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
          ),
          Switch(
            value:  value,
            onChanged: onChanged,
            activeColor:  const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors. white,
        borderRadius: BorderRadius. circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors. black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Icon(
              icon,
              color:  const Color(0xFFD4AF37),
              size:  22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:  Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight:  FontWeight.w600,
                color:  Color(0xFF0D121F),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration:  BoxDecoration(
              color: Colors. grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child:  Text(
              trailing,
              style:  TextStyle(
                fontSize: 13,
                fontWeight: FontWeight. w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color?  textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:  Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow:  [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius:  10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children:  [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFFD4AF37)).withOpacity(0.1),
                borderRadius: BorderRadius. circular(10),
              ),
              child: Icon(
                icon,
                color: iconColor ?? const Color(0xFFD4AF37),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor ??  const Color(0xFF0D121F),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color:  Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showContentDialog(BuildContext context, String title, String content) {
    showDialog(
      context:  context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight. bold,
            color: Color(0xFF0D121F),
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child:  SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color:  Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLOSE',
              style:  TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight. w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:  (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight. bold,
            color: Color(0xFF0D121F),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpOption(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@idaspire.com',
              onTap: () {
                Navigator. pop(context);
                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening email client...'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildHelpOption(
              icon: Icons. chat_outlined,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Live chat coming soon!'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
            const SizedBox(height:  12),
            _buildHelpOption(
              icon:  Icons.question_answer_outlined,
              title: 'FAQs',
              subtitle: 'Frequently asked questions',
              onTap:  () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('FAQs coming soon! '),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  const Text(
              'CLOSE',
              style: TextStyle(
                color:  Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration:  BoxDecoration(
          color: Colors. grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height:  40,
              decoration: BoxDecoration(
                color:  const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:  Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight. w600,
                      color: Color(0xFF0D121F),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors. grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius. circular(16),
          ),
          title: const Text(
            'Change Password',
            style: TextStyle(
              fontWeight: FontWeight. bold,
              color: Color(0xFF0D121F),
            ),
          ),
          content:  Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller:  currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText:  'Confirm New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger. of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text. length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setDialogState(() {
                  isLoading = true;
                });

                try {
                  final user = FirebaseAuth.instance. currentUser;
                  if (user != null && user.email != null) {
                    // Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: currentPasswordController.text,
                    );
                    await user. reauthenticateWithCredential(credential);

                    // Update password
                    await user.updatePassword(newPasswordController.text);

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger. of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully! '),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() {
                    isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update password: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D121F),
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color:  Colors.white,
                ),
              )
                  :  const Text('UPDATE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed:  () => Navigator.pop(dialogContext),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children:  [
            Icon(Icons.warning_amber_rounded, color: Colors. red. shade400),
            const SizedBox(width:  8),
            const Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will clear all your local app data including settings and cached information.  Your quiz history will remain saved in the cloud.\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                ScaffoldMessenger. of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All local data cleared successfully'),
                    backgroundColor:  Color(0xFF4CAF50),
                  ),
                );

                // Reload settings
                _loadSettings();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to clear data: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red. shade400,
            ),
            child: const Text('CLEAR DATA'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context:  context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:  RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(16),
          ),
          title: Row(
            children:  [
              const Icon(Icons.warning, color: Colors.red),
              const SizedBox(width: 8),
              const Text(
                'Delete Account',
                style:  TextStyle(color: Colors.red),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize. min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This action is permanent and cannot be undone.  All your data including: ',
                style:  TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              _buildDeleteWarningItem('Quiz history and progress'),
              _buildDeleteWarningItem('Personal information'),
              _buildDeleteWarningItem('Subscription details'),
              _buildDeleteWarningItem('All account data'),
              const SizedBox(height: 16),
              const Text(
                'Enter your password to confirm: ',
                style:  TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller:  passwordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText:  'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed:  () => Navigator.pop(dialogContext),
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ?  null
                  :  () async {
                if (passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setDialogState(() {
                  isLoading = true;
                });

                try {
                  final user = FirebaseAuth. instance.currentUser;
                  if (user != null && user.email != null) {
                    // Re-authenticate user
                    final credential = EmailAuthProvider.credential(
                      email:  user.email!,
                      password:  passwordController.text,
                    );
                    await user. reauthenticateWithCredential(credential);

                    // Delete user account
                    await user.delete();

                    Navigator.pop(dialogContext);

                    // Sign out and navigate to sign in
                    context.read<AuthBloc>().add(SignOutEvent());

                    ScaffoldMessenger. of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Account deleted successfully'),
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } catch (e) {
                  setDialogState(() {
                    isLoading = false;
                  });

                  String errorMessage = 'Failed to delete account';
                  if (e. toString().contains('wrong-password')) {
                    errorMessage = 'Incorrect password';
                  } else if (e.toString().contains('requires-recent-login')) {
                    errorMessage = 'Please sign in again before deleting your account';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:  Text(errorMessage),
                      backgroundColor:  Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('DELETE ACCOUNT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Icon(Icons.remove, size: 16, color: Colors.red. shade300),
          const SizedBox(width:  8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Content strings
  static const String _termsOfServiceContent = '''
Terms of Service

Last updated: January 2026

1.  Acceptance of Terms
By accessing and using ID Aspire, you agree to be bound by these Terms of Service. 

2. Description of Service
ID Aspire provides an online quiz and assessment platform designed to help users test their knowledge and track their learning progress. 

3. User Accounts
- You must provide accurate information when creating an account
- You are responsible for maintaining the security of your account
- You must be at least 13 years old to use this service

4. User Conduct
You agree not to: 
- Use the service for any unlawful purpose
- Attempt to gain unauthorized access to any part of the service
- Share your account credentials with others
- Copy, modify, or distribute any content from the service

5. Subscription and Payments
- Subscription fees are billed in advance
- Refunds are subject to our refund policy
- We reserve the right to change pricing with notice

6. Intellectual Property
All content, features, and functionality are owned by ID Aspire and are protected by copyright, trademark, and other intellectual property laws.

7. Limitation of Liability
ID Aspire shall not be liable for any indirect, incidental, special, consequential, or punitive damages. 

8. Changes to Terms
We may modify these terms at any time.  Continued use of the service constitutes acceptance of modified terms.

9. Contact Information
For questions about these Terms, please contact us at support@idaspire.com. 
''';

  static const String _privacyPolicyContent = '''
Privacy Policy

Last updated: January 2026

1. Information We Collect
We collect information you provide directly: 
- Name and email address
- Quiz responses and scores
- Usage data and preferences

2. How We Use Your Information
- To provide and maintain our service
- To notify you about changes to our service
- To provide customer support
- To gather analysis to improve our service

3. Data Storage and Security
- Your data is stored securely using industry-standard encryption
- We implement appropriate security measures to protect your information
- Data is stored on secure cloud servers

4. Information Sharing
We do not sell your personal information.  We may share information: 
- With your consent
- To comply with legal obligations
- To protect our rights and safety

5. Your Rights
You have the right to:
- Access your personal data
- Correct inaccurate data
- Delete your account and data
- Export your data

6. Cookies and Tracking
We use cookies and similar technologies to: 
- Remember your preferences
- Analyze how our service is used
- Improve user experience

7. Children's Privacy
Our service is not intended for children under 13. We do not knowingly collect data from children under 13.

8. Changes to This Policy
We may update this policy from time to time. We will notify you of any changes by posting the new policy on this page.

9. Contact Us
If you have questions about this Privacy Policy, please contact us at: 
- Email: privacy@idaspire. com
- Address: 123 Tech Street, San Francisco, CA 94102
''';
}