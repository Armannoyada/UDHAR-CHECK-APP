import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MyLendingPage extends StatefulWidget {
  const MyLendingPage({super.key});

  @override
  State<MyLendingPage> createState() => _MyLendingPageState();
}

class _MyLendingPageState extends State<MyLendingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _lendingHistory = [];
  int _selectedTab = 0;

  final List<String> _tabs = ['All', 'In Progress', 'Completed', 'Defaulted'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
        _loadLendingHistory();
      }
    });
    _loadLendingHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLendingHistory() async {
    setState(() => _isLoading = true);

    // TODO: Implement actual API call with filter
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lendingHistory = []; // Empty for now
    });
  }

  String get _currentFilter {
    switch (_selectedTab) {
      case 1:
        return 'in_progress';
      case 2:
        return 'completed';
      case 3:
        return 'defaulted';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Lending History',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track all your lending activities',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: AppColors.gray900,
            unselectedLabelColor: AppColors.gray500,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _lendingHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildLendingList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.attach_money,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Lending History',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't lent any money yet.\nBrowse loan requests to start lending.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to loan requests - handled by parent
                  if (context.mounted) {
                    // This will be handled by the parent LenderHomePage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Navigate to Loan Requests from sidebar'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Browse Requests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLendingList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _lendingHistory.length,
      itemBuilder: (context, index) {
        final loan = _lendingHistory[index];
        return _buildLendingCard(loan);
      },
    );
  }

  Widget _buildLendingCard(dynamic loan) {
    final status = loan['status'] ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.gray200,
                    child: Text(
                      (loan['borrower']?['fullName'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan['borrower']?['fullName'] ?? 'Unknown',
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Trust Score: ${loan['borrower']?['trustScore'] ?? 0}',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Amount', '₹${loan['amount'] ?? 0}'),
              _buildInfoColumn('Interest', '${loan['interestRate'] ?? 0}%'),
              _buildInfoColumn('Duration', '${loan['durationDays'] ?? 0} days'),
            ],
          ),
          if (status == 'in_progress') ...[
            const SizedBox(height: 16),
            _buildProgressBar(loan),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(dynamic loan) {
    final amountPaid = (loan['amountPaid'] ?? 0).toDouble();
    final totalRepayable = (loan['totalRepayable'] ?? 1).toDouble();
    final progress = totalRepayable > 0 ? amountPaid / totalRepayable : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Repayment Progress',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amountPaid.toStringAsFixed(0)} of ₹${totalRepayable.toStringAsFixed(0)}',
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'in_progress':
        return AppColors.info;
      case 'defaulted':
        return AppColors.danger;
      case 'disputed':
        return AppColors.warning;
      default:
        return AppColors.gray500;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}
