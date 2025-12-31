import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../loans/loan_requests_page.dart';
import '../loans/my_lending_page.dart';

class LenderHomePage extends StatefulWidget {
  const LenderHomePage({super.key});

  @override
  State<LenderHomePage> createState() => _LenderHomePageState();
}

class _LenderHomePageState extends State<LenderHomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Check if user is a borrower and redirect to borrower home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthBloc>().state.user;
      if (user?.role == UserRole.borrower) {
        Navigator.of(context).pushReplacementNamed(AppRouter.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        }
        // Also check if user is a borrower after state change
        if (state.user?.role == UserRole.borrower) {
          Navigator.of(context).pushReplacementNamed(AppRouter.home);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(context),
        body: _buildBody(context),
      ),
    );
  }

  /// Build the lender sidebar drawer
  Widget _buildDrawer(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final firstName = user?.firstName ?? 'User';
        final lastName = user?.lastName ?? '';
        final initials =
            '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
                .toUpperCase();

        return Drawer(
          backgroundColor: AppColors.white,
          child: SafeArea(
            child: Column(
              children: [
                // Header with logo and close button
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.gray200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // U Logo
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'उधार',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'CHECK',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gray600),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_outlined,
                        label: 'Dashboard',
                        isSelected: _currentIndex == 0,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.list_alt_outlined,
                        label: 'Loan Requests',
                        isSelected: _currentIndex == 1,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 1);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'My Lending',
                        isSelected: _currentIndex == 2,
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 2);
                        },
                      ),
                    ],
                  ),
                ),

                // Bottom Section
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.gray200, width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDrawerItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        badgeCount: 3,
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to notifications
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to profile
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        isLogout: true,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                // User Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.gray50,
                    border: Border(
                      top: BorderSide(color: AppColors.gray200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // User Avatar
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.gray300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.gray700,
                              fontWeight: FontWeight.bold,
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
                              '$firstName $lastName',
                              style: const TextStyle(
                                color: AppColors.gray900,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Lender',
                          style: TextStyle(
                            color: AppColors.gray700,
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
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isSelected = false,
    bool isLogout = false,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    final color = isLogout
        ? AppColors.danger
        : isSelected
            ? AppColors.primary
            : AppColors.gray700;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: color, size: 22),
          if (badgeCount != null)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.gray700),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // U Logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'उधार',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' CHECK',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.gray700),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard(context);
      case 1:
        return const LoanRequestsPage();
      case 2:
        return const MyLendingPage();
      default:
        return _buildDashboard(context);
    }
  }

  Widget _buildDashboard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final totalLent = user?.totalLent ?? 0.0;
        final availableBalance = user?.availableBalance ?? 0.0;
        final trustScore = user?.trustScore ?? 50;
        final averageRating = user?.averageRating ?? 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header text
              Text(
                "Here's your lending overview",
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Stats Cards
              _buildStatsCard(
                icon: Icons.attach_money,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                value: '₹${totalLent.toStringAsFixed(0)}',
                label: 'Total Lent',
                valueColor: AppColors.primary,
              ),
              const SizedBox(height: 12),

              _buildStatsCard(
                icon: Icons.attach_money,
                iconColor: AppColors.warning,
                iconBgColor: AppColors.warning.withValues(alpha: 0.1),
                value: '₹${availableBalance.toStringAsFixed(0)}',
                label: 'Available Balance',
                valueColor: AppColors.warning,
              ),
              const SizedBox(height: 12),

              _buildStatsCard(
                icon: Icons.access_time,
                iconColor: AppColors.info,
                iconBgColor: AppColors.info.withValues(alpha: 0.1),
                value: '0',
                label: 'Active Loans',
                valueColor: AppColors.info,
              ),
              const SizedBox(height: 12),

              _buildStatsCard(
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                iconBgColor: AppColors.success.withValues(alpha: 0.1),
                value: '0',
                label: 'Completed',
                valueColor: AppColors.success,
              ),
              const SizedBox(height: 24),

              // Loan Requests Section
              _buildSectionHeader(
                title: 'Loan Requests',
                onViewAll: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(height: 12),
              _buildEmptyState(
                icon: Icons.people_outline,
                message: 'No pending loan requests',
              ),
              const SizedBox(height: 24),

              // Recent Lending Section
              _buildSectionHeader(
                title: 'Recent Lending',
                onViewAll: () => setState(() => _currentIndex = 2),
              ),
              const SizedBox(height: 12),
              _buildEmptyState(
                icon: Icons.attach_money,
                message: 'No lending history yet',
              ),
              const SizedBox(height: 24),

              // Trust Score Card
              _buildScoreCard(
                value: trustScore.toString(),
                label: 'Trust Score',
                subtitle: 'Based on your activity and ratings',
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),

              // Average Rating Card
              _buildScoreCard(
                value: averageRating.toStringAsFixed(1),
                label: 'Average Rating',
                subtitle: '0 ratings received',
                color: AppColors.warning,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 4,
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
