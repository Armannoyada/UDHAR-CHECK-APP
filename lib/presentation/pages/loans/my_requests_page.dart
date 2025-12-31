import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/loan_service.dart';
import '../../../data/models/loan_model.dart';
import '../../../core/di/injection_container.dart';
import 'new_request_page.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestsPageState();
}

class _MyRequestsPageState extends State<MyRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Loan> _loans = [];
  String? _errorMessage;

  final List<String> _tabs = ['All', 'Pending', 'Active', 'Completed', 'Overdue'];
  int _selectedTab = 0;

  // Counts for each tab
  int _allCount = 0;
  int _pendingCount = 0;
  int _activeCount = 0;
  int _completedCount = 0;
  int _overdueCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
        _loadLoans();
      }
    });
    _loadLoans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLoans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = getIt<LoanService>();
      String? status;
      
      switch (_selectedTab) {
        case 1:
          status = 'pending';
          break;
        case 2:
          status = 'in_progress';
          break;
        case 3:
          status = 'completed';
          break;
        case 4:
          status = 'overdue';
          break;
        default:
          status = null;
      }

      final response = await loanService.getMyRequests(status: status);
      
      setState(() {
        _loans = response.data ?? [];
        _isLoading = false;
        
        // Update counts (these should come from API ideally)
        if (_selectedTab == 0) {
          _allCount = _loans.length;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _loans = [];
      });
    }
  }

  void _navigateToNewRequest() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewRequestPage()),
    );
    if (result == true) {
      _loadLoans();
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
                'My Loans',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your loan requests and active borrowings',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              
              // New Request Button
              SizedBox(
                child: ElevatedButton.icon(
                  onPressed: _navigateToNewRequest,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedTab == index;
                final count = _getCountForTab(index);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      _tabController.animateTo(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.gray200,
                        ),
                      ),
                      child: Text(
                        '${_tabs[index]} ($count)',
                        style: TextStyle(
                          color: isSelected ? AppColors.white : AppColors.gray600,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Content
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? _buildErrorState()
                  : _loans.isEmpty
                      ? _buildEmptyState()
                      : _buildLoansList(),
        ),
      ],
    );
  }

  int _getCountForTab(int index) {
    switch (index) {
      case 0:
        return _allCount;
      case 1:
        return _pendingCount;
      case 2:
        return _activeCount;
      case 3:
        return _completedCount;
      case 4:
        return _overdueCount;
      default:
        return 0;
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading loans',
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
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadLoans,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
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
              'No loans found',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't made any loan requests yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToNewRequest,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Request Money'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    return RefreshIndicator(
      onRefresh: _loadLoans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _loans.length,
        itemBuilder: (context, index) {
          return _buildLoanCard(_loans[index]);
        },
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final statusColor = _getStatusColor(loan.status);
    
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
              Text(
                '₹${loan.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(loan.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.category_outlined, loan.purpose ?? 'N/A'),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.schedule, '${loan.durationDays} days'),
            ],
          ),
          if (loan.status == LoanStatus.inProgress) ...[
            const SizedBox(height: 12),
            _buildProgressBar(loan),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created: ${_formatDate(loan.createdAt)}',
                style: TextStyle(
                  color: AppColors.gray400,
                  fontSize: 12,
                ),
              ),
              if (loan.status == LoanStatus.pending)
                TextButton(
                  onPressed: () => _cancelLoan(loan),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gray400),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Loan loan) {
    final amountPaid = loan.amountPaid ?? 0;
    final totalRepayable = loan.totalRepayable ?? loan.amount;
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
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return AppColors.warning;
      case LoanStatus.accepted:
        return AppColors.info;
      case LoanStatus.fulfilled:
      case LoanStatus.inProgress:
        return AppColors.primary;
      case LoanStatus.completed:
        return AppColors.success;
      case LoanStatus.rejected:
      case LoanStatus.defaulted:
        return AppColors.danger;
      case LoanStatus.disputed:
        return AppColors.warning;
      case LoanStatus.cancelled:
        return AppColors.gray500;
    }
  }

  String _formatStatus(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.accepted:
        return 'Accepted';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.fulfilled:
        return 'Fulfilled';
      case LoanStatus.inProgress:
        return 'In Progress';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.disputed:
        return 'Disputed';
      case LoanStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _cancelLoan(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Loan Request'),
        content: const Text('Are you sure you want to cancel this loan request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Yes, Cancel',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final loanService = getIt<LoanService>();
        await loanService.cancelLoan(loan.id, 'Cancelled by borrower');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan request cancelled'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadLoans();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      }
    }
  }
}
