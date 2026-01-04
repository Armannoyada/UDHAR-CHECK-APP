import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/services/admin_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();
  String _selectedRole = '';
  String _selectedStatus = '';
  bool _isLoading = true;
  List<AdminUser> _users = [];
  int _totalUsers = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminService = getIt<AdminService>();
      final data = await adminService.getAllUsers(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        role: _selectedRole.isNotEmpty ? _selectedRole : null,
        verificationStatus: _selectedStatus.isNotEmpty ? _selectedStatus : null,
        page: _currentPage,
      );

      setState(() {
        _users = data['users'] as List<AdminUser>;
        _totalUsers = data['total'] as int;
        _totalPages = data['totalPages'] as int;
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
    return DateFormat('M/d/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Users',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage all platform users',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Search and Filter Card
            Container(
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
                children: [
                  // Search Bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search by name, email, or phone...',
                              hintStyle: TextStyle(
                                color: AppColors.gray400,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.gray400,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onSubmitted: (_) => _loadUsers(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Search'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedRole,
                          hint: 'All Roles',
                          items: const [
                            {'value': '', 'label': 'All Roles'},
                            {'value': 'lender', 'label': 'Lender'},
                            {'value': 'borrower', 'label': 'Borrower'},
                          ],
                          onChanged: (value) {
                            setState(() => _selectedRole = value ?? '');
                            _loadUsers();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          value: _selectedStatus,
                          hint: 'All Status',
                          items: const [
                            {'value': '', 'label': 'All Status'},
                            {'value': 'pending', 'label': 'Pending'},
                            {'value': 'approved', 'label': 'Approved'},
                            {'value': 'rejected', 'label': 'Rejected'},
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value ?? '');
                            _loadUsers();
                          },
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
            else
              _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String hint,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value.isEmpty ? null : value,
          hint: Text(
            hint,
            style: TextStyle(color: AppColors.gray600, fontSize: 14),
          ),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray500),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(
                item['label']!,
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
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

  Widget _buildUsersList() {
    return Container(
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
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'USER',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'ROLE',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'JOINED',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Users
          if (_users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.gray300),
                  const SizedBox(height: 16),
                  const Text(
                    'No users found',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(color: AppColors.gray500, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ..._users.map((user) => _buildUserRow(user)),

          // Pagination
          if (_users.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.gray200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Showing ${_users.length} of $_totalUsers users',
                    style: TextStyle(color: AppColors.gray500, fontSize: 13),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _currentPage > 1
                            ? () {
                                setState(() => _currentPage--);
                                _loadUsers();
                              }
                            : null,
                        color: _currentPage > 1
                            ? AppColors.gray700
                            : AppColors.gray300,
                      ),
                      Text(
                        'Page $_currentPage of $_totalPages',
                        style: TextStyle(color: AppColors.gray600, fontSize: 13),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _currentPage < _totalPages
                            ? () {
                                setState(() => _currentPage++);
                                _loadUsers();
                              }
                            : null,
                        color: _currentPage < _totalPages
                            ? AppColors.gray700
                            : AppColors.gray300,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUserRow(AdminUser user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray100)),
      ),
      child: Row(
        children: [
          // User Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.initials.isNotEmpty ? user.initials : 'U',
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : 'Unknown',
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                      if (user.phone != null && user.phone!.isNotEmpty)
                        Text(
                          user.phone!,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role Badge
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user.role).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.role == 'lender' ? 'Lender' : 'Borrower',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Joined Date
          Expanded(
            flex: 1,
            child: Text(
              _formatDate(user.createdAt),
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 13,
              ),
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.gray500),
            onSelected: (value) => _handleUserAction(user, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'view',
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              if (!user.isAdminVerified && user.isOnboardingComplete)
                const PopupMenuItem(
                  value: 'verify',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Verify User'),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: user.isBlocked ? 'unblock' : 'block',
                child: Row(
                  children: [
                    Icon(
                      user.isBlocked ? Icons.lock_open : Icons.block,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(user.isBlocked ? 'Unblock User' : 'Block User'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete User', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    return role == 'lender' ? AppColors.primary : AppColors.info;
  }

  void _handleUserAction(AdminUser user, String action) async {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'verify':
        _verifyUser(user);
        break;
      case 'block':
      case 'unblock':
        _toggleBlockUser(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _showUserDetails(AdminUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
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
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              user.initials.isNotEmpty ? user.initials : 'U',
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName.isNotEmpty
                                    ? user.fullName
                                    : 'Unknown',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _getRoleColor(user.role).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  user.role == 'lender' ? 'Lender' : 'Borrower',
                                  style: TextStyle(
                                    color: _getRoleColor(user.role),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Details
                    _buildDetailRow('Email', user.email),
                    _buildDetailRow('Phone', user.phone ?? 'Not provided'),
                    _buildDetailRow('Joined', _formatDate(user.createdAt)),
                    _buildDetailRow(
                      'Verification',
                      user.verificationStatus.toUpperCase(),
                    ),
                    _buildDetailRow(
                      'Status',
                      user.isBlocked ? 'Blocked' : 'Active',
                    ),
                    _buildDetailRow(
                      'Trust Score',
                      user.trustScore.toStringAsFixed(0),
                    ),
                    _buildDetailRow(
                      'Repayment Score',
                      user.repaymentScore.toStringAsFixed(0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.gray500, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _verifyUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify User'),
        content: Text('Are you sure you want to verify ${user.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final adminService = getIt<AdminService>();
        await adminService.verifyUser(user.id, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User verified successfully'),
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
  }

  void _toggleBlockUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          user.isBlocked
              ? 'Are you sure you want to unblock ${user.fullName}?'
              : 'Are you sure you want to block ${user.fullName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(user.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final adminService = getIt<AdminService>();
        await adminService.toggleBlockUser(user.id, !user.isBlocked);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isBlocked ? 'User unblocked' : 'User blocked',
            ),
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
  }

  void _deleteUser(AdminUser user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.fullName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final adminService = getIt<AdminService>();
        await adminService.deleteUser(user.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
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
  }
}
