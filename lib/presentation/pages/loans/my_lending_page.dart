import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/loan_service.dart';
import '../../../data/models/loan_model.dart';
import '../../../core/di/injection_container.dart';

class MyLendingPage extends StatefulWidget {
  const MyLendingPage({super.key});

  @override
  State<MyLendingPage> createState() => _MyLendingPageState();
}

class _MyLendingPageState extends State<MyLendingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Loan> _lendingHistory = [];
  String? _errorMessage;
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = getIt<LoanService>();
      final response = await loanService.getMyLending(status: _currentFilter);

      setState(() {
        _isLoading = false;
        _lendingHistory = response.data ?? [];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _lendingHistory = [];
      });
    }
  }

  String? get _currentFilter {
    switch (_selectedTab) {
      case 1:
        return 'in_progress';
      case 2:
        return 'completed';
      case 3:
        return 'defaulted';
      default:
        return null; // All
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  Color _getStatusColor(LoanStatus status) {
    switch (status) {
      case LoanStatus.completed:
        return AppColors.success;
      case LoanStatus.inProgress:
        return AppColors.info;
      case LoanStatus.defaulted:
        return AppColors.danger;
      case LoanStatus.disputed:
        return AppColors.warning;
      case LoanStatus.accepted:
        return const Color(0xFF2196F3);
      case LoanStatus.pending:
        return AppColors.gray500;
      case LoanStatus.rejected:
        return AppColors.danger;
      case LoanStatus.cancelled:
        return AppColors.gray500;
      default:
        return AppColors.gray500;
    }
  }

  String _getStatusText(LoanStatus status) {
    switch (status) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.accepted:
        return 'Accepted';
      case LoanStatus.inProgress:
        return 'In Progress';
      case LoanStatus.completed:
        return 'Completed';
      case LoanStatus.defaulted:
        return 'Defaulted';
      case LoanStatus.rejected:
        return 'Rejected';
      case LoanStatus.cancelled:
        return 'Cancelled';
      case LoanStatus.disputed:
        return 'Disputed';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLendingHistory,
      child: Column(
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
                    color: AppColors.gray500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Material(
            color: Colors.transparent,
            child: Container(
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
                      color: Colors.black.withOpacity(0.05),
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
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorState()
                    : _lendingHistory.isEmpty
                        ? _buildEmptyState()
                        : _buildLendingList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLendingHistory,
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
            Text(
              _selectedTab == 0
                  ? 'No Lending History'
                  : 'No ${_tabs[_selectedTab]} Loans',
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0
                  ? "You haven't lent any money yet.\nBrowse loan requests to start lending."
                  : "No loans found with this status.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
                height: 1.5,
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

  Widget _buildLendingCard(Loan loan) {
    final borrower = loan.borrower;
    final borrowerName = borrower != null
        ? '${borrower.firstName ?? ''} ${borrower.lastName ?? ''}'.trim()
        : 'Unknown';
    final borrowerInitials = borrower != null
        ? '${borrower.firstName?.isNotEmpty == true ? borrower.firstName![0] : ''}${borrower.lastName?.isNotEmpty == true ? borrower.lastName![0] : ''}'
            .toUpperCase()
        : 'U';
    final statusColor = _getStatusColor(loan.status);
    final statusText = _getStatusText(loan.status);
    final amountPaid = loan.amountPaid ?? 0;
    final totalRepayable =
        loan.totalRepayable ?? (loan.amount * (1 + loan.interestRate / 100));
    final progress = totalRepayable > 0 ? amountPaid / totalRepayable : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with borrower info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: borrower?.profilePhoto != null &&
                          borrower!.profilePhoto!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            'http://10.0.2.2:5000${borrower.profilePhoto}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                borrowerInitials,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            borrowerInitials,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrowerName,
                        style: const TextStyle(
                          color: AppColors.gray900,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatDate(loan.createdAt),
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: AppColors.gray100),

          // Loan Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child:
                      _buildInfoColumn('Amount', _formatCurrency(loan.amount)),
                ),
                Expanded(
                  child:
                      _buildInfoColumn('Duration', '${loan.durationDays} days'),
                ),
                Expanded(
                  child: _buildInfoColumn(
                    'Repaid',
                    _formatCurrency(amountPaid),
                  ),
                ),
              ],
            ),
          ),

          // Progress bar for in-progress loans
          if (loan.status == LoanStatus.inProgress) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(amountPaid)} of ${_formatCurrency(totalRepayable)}',
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _viewLoanDetails(loan),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
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
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _viewLoanDetails(Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLoanDetailsSheet(loan),
    );
  }

  Widget _buildLoanDetailsSheet(Loan loan) {
    final borrower = loan.borrower;
    final borrowerName = borrower != null
        ? '${borrower.firstName ?? ''} ${borrower.lastName ?? ''}'.trim()
        : 'Unknown';
    final totalRepayable =
        loan.totalRepayable ?? (loan.amount * (1 + loan.interestRate / 100));
    final amountPaid = loan.amountPaid ?? 0;
    final remaining = totalRepayable - amountPaid;
    final statusColor = _getStatusColor(loan.status);
    final statusText = _getStatusText(loan.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Loan Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gray900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Loan Amount',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(loan.amount),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  _formatCurrency(amountPaid),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Repaid',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            Container(
                              height: 30,
                              width: 1,
                              color: Colors.white30,
                            ),
                            Column(
                              children: [
                                Text(
                                  _formatCurrency(
                                      remaining > 0 ? remaining : 0),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Text(
                                  'Remaining',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details
                  _buildDetailRow('Borrower', borrowerName),
                  _buildDetailRow('Purpose', loan.purpose ?? 'N/A'),
                  _buildDetailRow('Duration', '${loan.durationDays} days'),
                  _buildDetailRow('Interest Rate',
                      '${loan.interestRate.toStringAsFixed(2)}%'),
                  _buildDetailRow(
                      'Total Repayable', _formatCurrency(totalRepayable)),
                  _buildDetailRow('Date', _formatDate(loan.createdAt)),
                  if (loan.description != null && loan.description!.isNotEmpty)
                    _buildDetailRow('Description', loan.description!),

                  const SizedBox(height: 24),

                  // Action buttons based on status
                  if (loan.status == LoanStatus.accepted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _fulfillLoan(loan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Confirm Disbursement'),
                      ),
                    ),

                  if (loan.status == LoanStatus.inProgress)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _recordRepayment(loan);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Record Repayment'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fulfillLoan(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Disbursement'),
        content: Text(
          'Confirm that you have disbursed ${_formatCurrency(loan.amount)} to the borrower?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final loanService = getIt<LoanService>();
        await loanService.fulfillLoan(loan.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan disbursement confirmed!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadLendingHistory();
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

  Future<void> _recordRepayment(Loan loan) async {
    final amountController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Repayment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the repayment amount received:'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                hintText: 'Amount',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      try {
        final loanService = getIt<LoanService>();
        await loanService.recordRepayment(loan.id, amount);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Repayment of ${_formatCurrency(amount)} recorded!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadLendingHistory();
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
