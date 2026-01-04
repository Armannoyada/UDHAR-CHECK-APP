import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;

  // Controllers for editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _streetAddressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pinCodeController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _streetAddressController = TextEditingController(text: user?.address ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _stateController = TextEditingController(text: user?.state ?? '');
    _pinCodeController = TextEditingController(text: user?.pincode ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title & Edit Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        color: AppColors.gray900,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Edit Profile Button
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _isEditing = !_isEditing);
                        if (!_isEditing) {
                          // Reset controllers when canceling
                          _firstNameController.text = user?.firstName ?? '';
                          _lastNameController.text = user?.lastName ?? '';
                          _emailController.text = user?.email ?? '';
                          _phoneController.text = user?.phoneNumber ?? '';
                          _streetAddressController.text = user?.address ?? '';
                          _cityController.text = user?.city ?? '';
                          _stateController.text = user?.state ?? '';
                          _pinCodeController.text = user?.pincode ?? '';
                        }
                      },
                      icon:
                          Icon(_isEditing ? Icons.close : Icons.edit, size: 18),
                      label: Text(_isEditing ? 'Cancel' : 'Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Header Card with gradient
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Profile Avatar with camera icon
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.9),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: user?.profilePhoto != null &&
                                    user!.profilePhoto!.isNotEmpty
                                ? Image.network(
                                    user.profilePhoto!,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar(user);
                                    },
                                  )
                                : _buildDefaultAvatar(user),
                          ),
                        ),
                        // Camera icon overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.gray700,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppColors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'
                          .toLowerCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Role Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user?.role == UserRole.lender ? 'Lender' : 'Borrower',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Score Cards (stacked vertically in white boxes)
              if (user?.role == UserRole.borrower) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Trust Score Card
                      _buildScoreCard(
                        icon: Icons.shield_outlined,
                        score: user?.trustScore?.toInt() ?? 50,
                        label: 'TRUST SCORE',
                        color: const Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 12),
                      // Repayment Score Card
                      _buildScoreCard(
                        icon: Icons.credit_card_outlined,
                        score: user?.repaymentScore?.toInt() ?? 50,
                        label: 'REPAYMENT',
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 12),
                      // Ratings Card
                      _buildScoreCard(
                        icon: Icons.star_outline,
                        score: user?.totalRatings ?? 0,
                        label: 'RATINGS',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Verification Status Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VERIFICATION STATUS',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Email Verification
                    _buildVerificationRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      isVerified: user?.isEmailVerified ?? false,
                    ),
                    const SizedBox(height: 12),
                    // Phone Verification
                    _buildVerificationRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      isVerified: user?.isPhoneVerified ?? false,
                    ),
                    const SizedBox(height: 12),
                    // Face Verification (highlighted blue background)
                    _buildVerificationRowHighlighted(
                      icon: Icons.face_outlined,
                      label: 'Face',
                      isVerified: user?.isFaceVerified ?? false,
                    ),
                    const SizedBox(height: 12),
                    // ID Verification (highlighted blue background)
                    _buildVerificationRowHighlighted(
                      icon: Icons.badge_outlined,
                      label: 'ID',
                      isVerified: user?.isIdVerified ?? false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Personal Information Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // First Name
                    _buildInputField(
                      label: 'FIRST NAME',
                      controller: _firstNameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // Last Name
                    _buildInputField(
                      label: 'LAST NAME',
                      controller: _lastNameController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // Email
                    _buildInputField(
                      label: 'EMAIL',
                      controller: _emailController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    // Phone
                    _buildInputField(
                      label: 'PHONE',
                      controller: _phoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Address Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Address',
                          style: TextStyle(
                            color: AppColors.gray900,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Street Address
                    _buildInputField(
                      label: 'STREET ADDRESS',
                      controller: _streetAddressController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // City
                    _buildInputField(
                      label: 'CITY',
                      controller: _cityController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // State
                    _buildInputField(
                      label: 'STATE',
                      controller: _stateController,
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // PIN Code
                    _buildInputField(
                      label: 'PIN CODE',
                      controller: _pinCodeController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Save Button (when editing)
              if (_isEditing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Save Changes'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isEditing) const SizedBox(height: 16),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar(User? user) {
    final firstName = user?.firstName ?? '';
    final lastName = user?.lastName ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();

    return Center(
      child: Text(
        initials.isNotEmpty ? initials : 'U',
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required int score,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            score.toString(),
            style: TextStyle(
              color: color,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow({
    required IconData icon,
    required String label,
    required bool isVerified,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.gray500, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.gray700,
              fontSize: 14,
            ),
          ),
        ),
        if (isVerified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: AppColors.success, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Verified',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Verification coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              'Verify',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationRowHighlighted({
    required IconData icon,
    required String label,
    required bool isVerified,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.gray700,
                fontSize: 14,
              ),
            ),
          ),
          if (isVerified)
            Icon(
              Icons.check,
              color: AppColors.primary,
              size: 20,
            )
          else
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool enabled = true,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.gray500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintStyle: TextStyle(color: AppColors.gray400),
              filled: true,
              fillColor: enabled ? AppColors.white : AppColors.gray50,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    // TODO: Implement save profile logic with API call
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile update coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() => _isEditing = false);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
