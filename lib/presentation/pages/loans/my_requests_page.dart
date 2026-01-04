import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class _MyRequestsPageState extends State<MyRequestsPage> {
  bool _isLoading = true;
  List<Loan> _allLoans = [];
  List<Loan> _filteredLoans = [];
  String? _errorMessage;

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
    _loadAllLoans();
  }

  Future<void> _loadAllLoans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = getIt<LoanService>();

      // Load all loans first to get counts
      final response = await loanService.getMyRequests();
      final allLoans = response.data ?? [];

      // Calculate counts for each category
      int pending = 0;
      int active = 0;
      int completed = 0;
      int overdue = 0;

      for (final loan in allLoans) {
        switch (loan.status) {
          case LoanStatus.pending:
            pending++;
            break;
          case LoanStatus.accepted:
          case LoanStatus.fulfilled:
          case LoanStatus.inProgress:
            active++;
            // Check if overdue
            if (loan.dueDate != null &&
                loan.dueDate!.isBefore(DateTime.now())) {
              overdue++;
            }
            break;
          case LoanStatus.completed:
            completed++;
            break;
          case LoanStatus.defaulted:
            overdue++;
            break;
          default:
            break;
        }
      }

      setState(() {
        _allLoans = allLoans;
        _allCount = allLoans.length;
        _pendingCount = pending;
        _activeCount = active;
        _completedCount = completed;
        _overdueCount = overdue;
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _allLoans = [];
        _filteredLoans = [];
      });
    }
  }

  void _applyFilters() {
    List<Loan> filtered = List.from(_allLoans);

    // Apply tab filter
    switch (_selectedTab) {
      case 1: // Pending
        filtered =
            filtered.where((l) => l.status == LoanStatus.pending).toList();
        break;
      case 2: // Active
        filtered = filtered
            .where((l) =>
                l.status == LoanStatus.accepted ||
                l.status == LoanStatus.fulfilled ||
                l.status == LoanStatus.inProgress)
            .toList();
        break;
      case 3: // Completed
        filtered =
            filtered.where((l) => l.status == LoanStatus.completed).toList();
        break;
      case 4: // Overdue
        filtered = filtered
            .where((l) =>
                l.status == LoanStatus.defaulted ||
                (l.dueDate != null &&
                    l.dueDate!.isBefore(DateTime.now()) &&
                    l.status != LoanStatus.completed))
            .toList();
        break;
    }

    setState(() {
      _filteredLoans = filtered;
    });
  }

  void _navigateToNewRequest() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewRequestPage()),
    );
    if (result == true) {
      _loadAllLoans();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              const SizedBox(height: 4),
              Text(
                'Track your loan requests and active borrowings',
                style: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        // New Request Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            onPressed: _navigateToNewRequest,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // Tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(0, 'All', _allCount),
                const SizedBox(width: 8),
                _buildTab(1, 'Pending', _pendingCount),
                const SizedBox(width: 8),
                _buildTab(2, 'Active', _activeCount),
                const SizedBox(width: 8),
                _buildTab(3, 'Completed', _completedCount),
                const SizedBox(width: 8),
                _buildTab(4, 'Overdue', _overdueCount),
              ],
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
                  : _filteredLoans.isEmpty
                      ? _buildEmptyState()
                      : _buildLoansList(),
        ),
      ],
    );
  }

  Widget _buildTab(int index, String label, int count) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        _applyFilters();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.gray600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
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
            Icon(Icons.error_outline, size: 64, color: AppColors.gray400),
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
              style: TextStyle(color: AppColors.gray500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAllLoans,
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
              child:
                  Icon(Icons.attach_money, size: 40, color: AppColors.gray400),
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
              style: TextStyle(color: AppColors.gray500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoansList() {
    return RefreshIndicator(
      onRefresh: _loadAllLoans,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredLoans.length,
        itemBuilder: (context, index) {
          return _buildLoanCard(_filteredLoans[index]);
        },
      ),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final dateFormat = DateFormat('M/d/yyyy');
    final totalRepayable = loan.totalRepayable ??
        (loan.amount + (loan.amount * loan.interestRate / 100));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Amount and Status Badge
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${_formatAmount(loan.amount)}',
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loan.purpose ?? 'Personal Loan',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(loan.status),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Loan Details Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailColumn(
                      'DURATION', '${loan.durationDays} days'),
                ),
                Expanded(
                  child: _buildDetailColumn(
                      'INTEREST', '${loan.interestRate.toStringAsFixed(2)}%'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailColumn(
                      'TOTAL REPAYABLE', '₹${_formatAmount(totalRepayable)}'),
                ),
                Expanded(
                  child: _buildDetailColumn(
                    'REQUESTED ON',
                    loan.createdAt != null
                        ? dateFormat.format(loan.createdAt!)
                        : 'N/A',
                  ),
                ),
              ],
            ),
          ),

          // Repayment Progress (for in-progress loans)
          if (loan.status == LoanStatus.inProgress) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildRepaymentProgress(loan, totalRepayable),
            ),
          ],

          // Lender Info (for accepted/in-progress loans)
          if (loan.lender != null &&
              (loan.status == LoanStatus.accepted ||
                  loan.status == LoanStatus.inProgress ||
                  loan.status == LoanStatus.fulfilled)) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildLenderInfo(loan.lender!),
            ),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildActionButtons(loan),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(LoanStatus status) {
    Color bgColor;
    Color textColor;
    String text = _formatStatus(status);

    switch (status) {
      case LoanStatus.pending:
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case LoanStatus.accepted:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case LoanStatus.inProgress:
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      case LoanStatus.completed:
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case LoanStatus.rejected:
      case LoanStatus.defaulted:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default:
        bgColor = AppColors.gray100;
        textColor = AppColors.gray600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == LoanStatus.accepted)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.check, color: textColor, size: 14),
            ),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray400,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.gray900,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRepaymentProgress(Loan loan, double totalRepayable) {
    final paidAmount = loan.amountPaid ?? 0.0;
    final progress = totalRepayable > 0
        ? (paidAmount / totalRepayable).clamp(0.0, 1.0)
        : 0.0;
    final daysRemaining = loan.dueDate != null
        ? loan.dueDate!.difference(DateTime.now()).inDays
        : 0;

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
              '₹${_formatAmount(paidAmount)} / ₹${_formatAmount(totalRepayable)}',
              style: TextStyle(
                color: AppColors.gray700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
        const SizedBox(height: 6),
        Text(
          '${daysRemaining > 0 ? daysRemaining : 0} days remaining',
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLenderInfo(dynamic lender) {
    final firstName = lender.firstName ?? '';
    final lastName = lender.lastName ?? '';
    final initials =
        '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
            .toUpperCase();

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$firstName $lastName'.toLowerCase(),
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Lender',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(Loan loan) {
    // For accepted loans - show confirm money received button
    if (loan.status == LoanStatus.accepted) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _confirmMoneyReceived(loan),
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirm Money Received'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _viewLoanDetails(loan),
              child: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For pending loans - show cancel and view buttons
    if (loan.status == LoanStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _cancelLoan(loan),
              child: const Text('Cancel Request'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray700,
                side: BorderSide(color: AppColors.gray300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _viewLoanDetails(loan),
              child: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // For other statuses - just view details
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _viewLoanDetails(loan),
        child: const Text('View Details'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(2)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return NumberFormat('#,##,###').format(amount.toInt());
    }
    return amount.toStringAsFixed(0);
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

  void _viewLoanDetails(Loan loan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLoanDetailsSheet(loan),
    );
  }

  Widget _buildLoanDetailsSheet(Loan loan) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final totalRepayable = loan.totalRepayable ??
        (loan.amount + (loan.amount * loan.interestRate / 100));

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
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
                      _buildStatusBadge(loan.status),
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
                          '₹${_formatAmount(loan.amount)}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total Repayable: ₹${_formatAmount(totalRepayable)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details Grid
                  _buildDetailRow('Purpose', loan.purpose ?? 'N/A'),
                  _buildDetailRow('Duration', '${loan.durationDays} days'),
                  _buildDetailRow('Interest Rate',
                      '${loan.interestRate.toStringAsFixed(2)}%'),
                  _buildDetailRow(
                      'Created',
                      loan.createdAt != null
                          ? dateFormat.format(loan.createdAt!)
                          : 'N/A'),
                  if (loan.acceptedAt != null)
                    _buildDetailRow(
                        'Accepted', dateFormat.format(loan.acceptedAt!)),
                  if (loan.dueDate != null)
                    _buildDetailRow(
                        'Due Date', dateFormat.format(loan.dueDate!)),
                  if (loan.lender != null)
                    _buildDetailRow('Lender',
                        '${loan.lender!.firstName} ${loan.lender!.lastName}'),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (loan.status == LoanStatus.pending) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _cancelLoan(loan);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel Request'),
                      ),
                    ),
                  ],
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
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
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

  Future<void> _confirmMoneyReceived(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Money Received'),
        content: Text(
            'Have you received ₹${_formatAmount(loan.amount)} from the lender?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Received'),
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
              content: Text('Money received confirmed!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadAllLoans();
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

  Future<void> _cancelLoan(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Loan Request'),
        content:
            const Text('Are you sure you want to cancel this loan request?'),
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
          _loadAllLoans();
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
