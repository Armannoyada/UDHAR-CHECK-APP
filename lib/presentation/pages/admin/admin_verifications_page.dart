import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/services/admin_service.dart';

class AdminVerificationsPage extends StatefulWidget {
  const AdminVerificationsPage({super.key});

  @override
  State<AdminVerificationsPage> createState() => _AdminVerificationsPageState();
}

class _AdminVerificationsPageState extends State<AdminVerificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<AdminUser> _users = [];
  int _totalUsers = 0;
  String? _errorMessage;
  String _currentFilter = 'pending'; // pending, verified, rejected

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 0:
        _currentFilter = 'pending';
        break;
      case 1:
        _currentFilter = 'verified';
        break;
      case 2:
        _currentFilter = 'rejected';
        break;
    }
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminService = getIt<AdminService>();
      // Load users that match verification status
      final data = await adminService.getAllUsers();

      final allUsers = data['users'] as List<AdminUser>;
      
      // Filter by verification status
      List<AdminUser> filteredUsers;
      switch (_currentFilter) {
        case 'pending':
          filteredUsers = allUsers.where((u) => !u.isVerified && u.status != 'rejected').toList();
          break;
        case 'verified':
          filteredUsers = allUsers.where((u) => u.isVerified).toList();
          break;
        case 'rejected':
          filteredUsers = allUsers.where((u) => u.status == 'rejected').toList();
          break;
        default:
          filteredUsers = allUsers;
      }

      setState(() {
        _users = filteredUsers;
        _totalUsers = filteredUsers.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tabs
        Container(
          color: AppColors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.gray500,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Pending'),
              Tab(text: 'Verified'),
              Tab(text: 'Rejected'),
            ],
          ),
        ),

        // Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'User Verifications',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and verify user accounts',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          color: AppColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_totalUsers users',
                              style: TextStyle(
                                color: AppColors.gray900,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _currentFilter == 'pending'
                                  ? 'Awaiting verification'
                                  : _currentFilter == 'verified'
                                      ? 'Verified accounts'
                                      : 'Rejected applications',
                              style: TextStyle(
                                color: AppColors.gray500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Users List
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage != null)
                    _buildErrorState()
                  else if (_users.isEmpty)
                    _buildEmptyState()
                  else
                    _buildUsersList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
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
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Users',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gray500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsers,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    switch (_currentFilter) {
      case 'pending':
        message = 'No pending verifications';
        icon = Icons.check_circle_outline;
        break;
      case 'verified':
        message = 'No verified users yet';
        icon = Icons.verified_user_outlined;
        break;
      case 'rejected':
        message = 'No rejected applications';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No users found';
        icon = Icons.person_off_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
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
          Icon(icon, size: 64, color: AppColors.gray300),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return Column(
      children: _users.map((user) => _buildUserCard(user)).toList(),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                backgroundImage: user.profileImage != null
                    ? NetworkImage(user.profileImage!)
                    : null,
                child: user.profileImage == null
                    ? Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.fullName,
                            style: const TextStyle(
                              color: AppColors.gray900,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(user.role),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.phone_outlined,
                  'Phone',
                  user.phone ?? 'Not provided',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.calendar_today_outlined,
                  'Joined',
                  _formatDate(user.createdAt),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  Icons.score_outlined,
                  'Trust Score',
                  user.trustScore.toStringAsFixed(0),
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  Icons.badge_outlined,
                  'Status',
                  user.isVerified ? 'Verified' : 'Unverified',
                ),
              ),
            ],
          ),

          if (_currentFilter == 'pending') ...[
            const SizedBox(height: 16),

            // Verification Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewUserDetails(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verifyUser(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _rejectUser(user),
                  icon: Icon(Icons.close, color: AppColors.danger),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.danger.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (_currentFilter == 'verified') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewUserDetails(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ],

          if (_currentFilter == 'rejected') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewUserDetails(user),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Review'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verifyUser(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Re-approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray400),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.danger;
      case 'lender':
        return AppColors.success;
      case 'borrower':
        return AppColors.info;
      default:
        return AppColors.gray500;
    }
  }

  void _viewUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            backgroundImage: user.profileImage != null
                                ? NetworkImage(user.profileImage!)
                                : null,
                            child: user.profileImage == null
                                ? Text(
                                    user.fullName.isNotEmpty
                                        ? user.fullName[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.role.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildDetailSection('Email', user.email),
                    _buildDetailSection('Phone', user.phone ?? 'Not provided'),
                    _buildDetailSection(
                      'Trust Score',
                      user.trustScore.toStringAsFixed(0),
                    ),
                    _buildDetailSection(
                      'Joined',
                      _formatDate(user.createdAt),
                    ),
                    _buildDetailSection(
                      'Verification Status',
                      user.isVerified ? 'Verified' : 'Unverified',
                    ),
                    _buildDetailSection(
                      'Account Status',
                      user.status ?? 'Active',
                    ),

                    if (_currentFilter == 'pending') ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _verifyUser(user);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: AppColors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Approve'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _rejectUser(user);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: BorderSide(color: AppColors.danger),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyUser(AdminUser user) async {
    try {
      final adminService = getIt<AdminService>();
      await adminService.verifyUser(user.id, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName} has been verified'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadUsers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _rejectUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Verification'),
        content: Text(
          'Are you sure you want to reject ${user.fullName}\'s verification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Note: Backend may need an endpoint for rejection
      // For now, we'll just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.fullName}\'s verification has been rejected'),
          backgroundColor: AppColors.warning,
        ),
      );
      _loadUsers();
    }
  }
}
