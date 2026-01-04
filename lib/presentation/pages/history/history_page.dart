import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/loan_service.dart';
import '../../../core/di/injection_container.dart';
import '../../bloc/auth/auth_bloc.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Loan> _loans = [];
  String? _errorMessage;

  final List<String> _tabs = ['All', 'Completed', 'Defaulted'];
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedTab = _tabController.index);
        _loadHistory();
      }
    });
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = getIt<LoanService>();
      final user = context.read<AuthBloc>().state.user;
      
      String? status;
      switch (_selectedTab) {
        case 1:
          status = 'completed';
          break;
        case 2:
          status = 'defaulted';
          break;
        default:
          status = null;
      }

      LoanListResponse response;
      if (user?.role == UserRole.lender) {
        response = await loanService.getMyLending(status: status);
      } else {
        response = await loanService.getMyRequests(status: status);
      }

      setState(() {
        _loans = response.data ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _loans = [];
      });
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
                'History',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your completed and past transactions',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              
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
                      _tabs[index],
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
              'Error loading history',
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
              onPressed: _loadHistory,
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
                Icons.history,
                size: 40,
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No history found',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any ${_tabs[_selectedTab].toLowerCase()} transactions yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
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
    final user = context.read<AuthBloc>().state.user;
    final isLender = user?.role == UserRole.lender;
    
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${loan.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.gray900,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isLender && loan.borrower != null)
                    Text(
                      'To: ${loan.borrower!.firstName} ${loan.borrower!.lastName}',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    )
                  else if (!isLender && loan.lender != null)
                    Text(
                      'From: ${loan.lender!.firstName} ${loan.lender!.lastName}',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    ),
                ],
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
          if (loan.status == LoanStatus.completed && loan.completedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'Completed on ${_formatDate(loan.completedAt)}',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          if (loan.status == LoanStatus.defaulted && loan.defaultedAt != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.cancel, size: 16, color: AppColors.danger),
                const SizedBox(width: 4),
                Text(
                  'Defaulted on ${_formatDate(loan.defaultedAt)}',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
              if (loan.interestRate > 0)
                Text(
                  '${loan.interestRate.toStringAsFixed(1)}% interest',
                  style: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 12,
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

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.completed:
        return AppColors.success;
      case LoanStatus.defaulted:
        return AppColors.danger;
      case LoanStatus.cancelled:
        return AppColors.gray500;
      default:
        return AppColors.warning;
    }
  }

  String _formatStatus(LoanStatus status) {
    switch (status) {
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.cancelled:
        return 'Cancelled';
      default:
        return status.name;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
