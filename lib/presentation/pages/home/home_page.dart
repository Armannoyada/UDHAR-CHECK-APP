import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../loans/new_request_page.dart';
import '../loans/my_requests_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Check if user is a lender and redirect
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthBloc>().state.user;
      if (user?.role == UserRole.lender) {
        Navigator.of(context).pushReplacementNamed(AppRouter.lenderHome);
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
        // Also check if user becomes a lender after state change
        if (state.user?.role == UserRole.lender) {
          Navigator.of(context).pushReplacementNamed(AppRouter.lenderHome);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        drawer: _buildDrawer(context),
        body: _buildBody(context),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  /// Build the sidebar drawer
  Widget _buildDrawer(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state.user;
        final firstName = user?.firstName ?? 'User';
        final lastName = user?.lastName ?? '';
        final role = user?.role.name ?? 'borrower';
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
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.gray600),
                        onPressed: () => _scaffoldKey.currentState?.closeDrawer(),
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
                          _scaffoldKey.currentState?.closeDrawer();
                          setState(() => _currentIndex = 0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.add_circle_outline,
                        label: 'New Request',
                        onTap: () {
                          // Close drawer first
                          _scaffoldKey.currentState?.closeDrawer();
                          // Navigate to new request page
                          Navigator.of(this.context).push(
                            MaterialPageRoute(builder: (_) => const NewRequestPage()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.list_alt_outlined,
                        label: 'My Requests',
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          setState(() => _currentIndex = 1);
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
                          _scaffoldKey.currentState?.closeDrawer();
                          Navigator.of(this.context).pushNamed('/notifications');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          setState(() => _currentIndex = 3);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        label: 'Logout',
                        isLogout: true,
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          _showLogoutDialog(this.context);
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
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primary,
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
                            Text(
                              role[0].toUpperCase() + role.substring(1),
                              style: const TextStyle(
                                color: AppColors.gray500,
                                fontSize: 12,
                              ),
                            ),
                          ],
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' CHECK',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 20,
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.gray700),
              onPressed: () {
                Navigator.of(context).pushNamed('/notifications');
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // Show different content based on current index
    if (_currentIndex == 1) {
      // My Requests page
      return const MyRequestsPage();
    }
    
    // Dashboard (index 0 and default)
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo Mode Banner
          _buildDemoBanner(),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 20),

                // Request Money Button
                _buildRequestMoneyButton(),
                const SizedBox(height: 24),

                // Trust Score Card
                _buildScoreCard(
                  score: 78,
                  title: 'Trust Score',
                  subtitle: 'Based on your profile verification',
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 16),

                // Repayment Score Card
                _buildScoreCard(
                  score: 85,
                  title: 'Repayment Score',
                  subtitle: 'Based on your payment history',
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 16),

                // Stats Row
                _buildStatsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '👋 Demo Mode',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '- You\'re viewing sample data. Login with real credentials to use the full platform.',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final firstName = state.user?.firstName ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $firstName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage your loan requests and track your repayments',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRequestMoneyButton() {
    return ElevatedButton.icon(
      onPressed: () {
        // Navigate to request money page
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewRequestPage()),
        );
      },
      icon: const Icon(Icons.add, color: AppColors.white, size: 20),
      label: const Text(
        'Request Money',
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildScoreCard({
    required int score,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Score
          _buildCircularScore(score, color),
          const SizedBox(width: 20),
          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularScore(int score, Color color) {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 70,
            height: 70,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 6,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          // Score text
          Text(
            score.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        // Total Borrowed
        _buildStatCard(
          icon: Icons.attach_money,
          iconColor: AppColors.primary,
          iconBgColor: AppColors.primary.withValues(alpha: 0.1),
          value: '₹23,000',
          label: 'TOTAL BORROWED',
        ),
        const SizedBox(height: 12),

        // Active Loans
        _buildStatCard(
          icon: Icons.access_time,
          iconColor: AppColors.warning,
          iconBgColor: AppColors.warning.withValues(alpha: 0.1),
          value: '1',
          label: 'ACTIVE LOANS',
        ),
        const SizedBox(height: 12),

        // Completed Loans
        _buildStatCard(
          icon: Icons.trending_up,
          iconColor: AppColors.secondary,
          iconBgColor: AppColors.secondary.withValues(alpha: 0.1),
          value: '1',
          label: 'COMPLETED LOANS',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.gray200.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray400,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
