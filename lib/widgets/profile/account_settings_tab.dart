import 'package:flutter/material.dart';
import '../../utils/validators.dart';

/// Account Settings Tab with Password Validation
/// Password modal with minimum 6 characters validation
/// Confirm button disabled until password is valid
class AccountSettingsTab extends StatelessWidget {
  const AccountSettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: Colors.purple[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your account preferences and security',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Settings Options
          _buildSettingsOption(
            context: context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password',
            color: Colors.blue,
            onTap: () => _showPasswordModal(context, 'Change Password'),
          ),

          _buildSettingsOption(
            context: context,
            icon: Icons.email_outlined,
            title: 'Update Email',
            subtitle: 'Change your registered email',
            color: Colors.green,
            onTap: () => _showPasswordModal(context, 'Update Email'),
          ),

          _buildSettingsOption(
            context: context,
            icon: Icons.phone_outlined,
            title: 'Update Mobile Number',
            subtitle: 'Change your contact number',
            color: Colors.orange,
            onTap: () => _showPasswordModal(context, 'Update Mobile'),
          ),

          _buildSettingsOption(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notification Preferences',
            subtitle: 'Manage push notifications',
            color: Colors.purple,
            onTap: () =>
                _showInfoSnackBar(context, 'Notification settings would open'),
          ),

          _buildSettingsOption(
            context: context,
            icon: Icons.security_outlined,
            title: 'Privacy & Security',
            subtitle: 'Review security settings',
            color: Colors.teal,
            onTap: () =>
                _showInfoSnackBar(context, 'Privacy settings would open'),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red[600],
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Danger Zone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showDeleteAccountDialog(context),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    label: const Text('Delete Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildSettingsOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordModal(BuildContext context, String action) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PasswordModalContent(action: action),
    );
  }

  void _showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Delete Account'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Account deletion requested (UI only)'),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Password Modal Content Widget with Validation
class _PasswordModalContent extends StatefulWidget {
  final String action;

  const _PasswordModalContent({required this.action});

  @override
  State<_PasswordModalContent> createState() => _PasswordModalContentState();
}

class _PasswordModalContentState extends State<_PasswordModalContent> {
  bool _obscurePassword = true;
  final TextEditingController _passwordController = TextEditingController();
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  void _validatePassword() {
    setState(() {
      if (_passwordController.text.isEmpty) {
        _passwordError = null; // Don't show error for empty field initially
      } else {
        _passwordError = ProfileValidators.validatePassword(
          _passwordController.text,
        );
      }
    });
  }

  bool get _isPasswordValid {
    return _passwordController.text.isNotEmpty &&
        ProfileValidators.validatePassword(_passwordController.text) == null;
  }

  @override
  void dispose() {
    _passwordController.removeListener(_validatePassword);
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enter Current Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Illustration
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(height: 120, child: _buildIllustration()),
              ),

              // Password Instructions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Enter your Password to ${widget.action.toLowerCase()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const Text(
                          ' *',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Minimum 6 characters required',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Password Input Field with Validation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _passwordError != null
                              ? Colors.red
                              : _isPasswordValid
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: _passwordError != null || _isPasswordValid
                              ? 2
                              : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter password',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: _passwordError != null
                                ? Colors.red
                                : _isPasswordValid
                                ? Colors.green
                                : Colors.grey[500],
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isPasswordValid)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[500],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Error message
                    if (_passwordError != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _passwordError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Success indicator
                    if (_isPasswordValid) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Password meets requirements',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm Button (Disabled until valid)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPasswordValid
                            ? () {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${widget.action} confirmed (UI only)',
                                        ),
                                      ],
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPasswordValid
                              ? const Color(0xFF2196F3)
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isPasswordValid ? Icons.check : Icons.lock,
                              size: 20,
                              color: _isPasswordValid
                                  ? Colors.white
                                  : Colors.grey[500],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPasswordValid
                                  ? 'Confirm'
                                  : 'Enter Valid Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isPasswordValid
                                    ? Colors.white
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!_isPasswordValid &&
                        _passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Complete the password field to continue',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background
        Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        // Lock icon illustration
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.lock_outline, size: 40, color: Colors.blue[600]),
        ),
      ],
    );
  }
}
