import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/loan_service.dart';
import '../../../data/models/loan_model.dart';
import '../../../core/di/injection_container.dart';

class LoanRequestsPage extends StatefulWidget {
  const LoanRequestsPage({super.key});

  @override
  State<LoanRequestsPage> createState() => _LoanRequestsPageState();
}

class _LoanRequestsPageState extends State<LoanRequestsPage> {
  final _minAmountController = TextEditingController(text: '500');
  final _maxAmountController = TextEditingController(text: '100000');
  String _sortBy = 'createdAt';
  String _sortOrder = 'DESC';
  bool _isLoading = false;
  List<Loan> _loanRequests = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoanRequests();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadLoanRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loanService = getIt<LoanService>();

      final minAmount = double.tryParse(_minAmountController.text);
      final maxAmount = double.tryParse(_maxAmountController.text);

      final response = await loanService.getPendingLoanRequests(
        minAmount: minAmount,
        maxAmount: maxAmount,
        sortBy: _sortBy,
        order: _sortOrder,
      );

      setState(() {
        _isLoading = false;
        _loanRequests = response.data ?? [];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _loanRequests = [];
      });
    }
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return AppColors.success;
    if (score >= 40) return const Color(0xFFFF9800);
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadLoanRequests,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Loan Requests',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse and review loan requests from borrowers',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Filter Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Min Amount
                  const Text(
                    'Min Amount',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _minAmountController,
                    prefix: '₹',
                  ),
                  const SizedBox(height: 16),

                  // Max Amount
                  const Text(
                    'Max Amount',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _maxAmountController,
                    prefix: '₹',
                  ),
                  const SizedBox(height: 16),

                  // Sort By
                  const Text(
                    'Sort By',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _sortBy,
                    items: const {
                      'createdAt': 'Date',
                      'amount': 'Amount',
                    },
                    onChanged: (value) {
                      setState(() => _sortBy = value!);
                      _loadLoanRequests();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Order
                  const Text(
                    'Order',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _sortOrder,
                    items: const {
                      'DESC': 'Newest First',
                      'ASC': 'Oldest First',
                    },
                    onChanged: (value) {
                      setState(() => _sortOrder = value!);
                      _loadLoanRequests();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_loanRequests.isEmpty)
              _buildEmptyState()
            else
              _buildLoanList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? prefix,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: prefix,
            prefixStyle: const TextStyle(
              color: AppColors.gray600,
              fontSize: 16,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onSubmitted: (_) => _loadLoanRequests(),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray500),
          items: items.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(
                entry.value,
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontSize: 14,
                ),
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
            'Error Loading Requests',
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
            onPressed: _loadLoanRequests,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Loan Requests Found',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no pending loan requests at the moment.\nCheck back later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanList() {
    return Column(
      children: _loanRequests.map((loan) => _buildLoanCard(loan)).toList(),
    );
  }

  Widget _buildLoanCard(Loan loan) {
    final borrower = loan.borrower;
    final borrowerName = borrower != null
        ? '${borrower.firstName ?? ''} ${borrower.lastName ?? ''}'.trim()
        : 'Unknown';
    final borrowerInitials = borrower != null
        ? '${borrower.firstName?.isNotEmpty == true ? borrower.firstName![0] : ''}${borrower.lastName?.isNotEmpty == true ? borrower.lastName![0] : ''}'
            .toUpperCase()
        : 'U';
    final location = borrower != null
        ? '${borrower.city ?? ''}, ${borrower.state ?? ''}'.trim()
        : '';
    final trustScore = borrower?.trustScore ?? 50;
    final repaymentScore = borrower?.repaymentScore ?? 50;
    final rating = borrower?.averageRating ?? 0.0;

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
          // Header - Avatar, Name, Amount
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
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
                                  fontSize: 16,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                // Name and Location
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
                      if (location.isNotEmpty && location != ', ')
                        Text(
                          location,
                          style: TextStyle(
                            color: AppColors.gray500,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                // Amount Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatCurrency(loan.amount),
                    style: const TextStyle(
                      color: Color(0xFFE65100),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Purpose
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14),
                children: [
                  TextSpan(
                    text: 'Purpose: ',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: loan.purpose ?? 'Not specified',
                    style: TextStyle(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Loan Details Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDetailItem('DURATION', '${loan.durationDays} days'),
                _buildDetailItem(
                    'INTEREST', '${loan.interestRate.toStringAsFixed(2)}%'),
                _buildDetailItem('RATING', '⭐ ${rating.toStringAsFixed(1)}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trust and Repayment Scores
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildScoreBox(
                    'TRUST',
                    trustScore,
                    _getScoreColor(trustScore),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildScoreBox(
                    'REPAYMENT',
                    repaymentScore,
                    _getScoreColor(repaymentScore),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Review Request Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _reviewRequest(loan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Review Request',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Expanded(
      child: Column(
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox(String label, double score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toInt().toString(),
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _reviewRequest(Loan loan) {
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
                  const Text(
                    'Loan Request Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
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
                          'Requested Amount',
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
                        const SizedBox(height: 8),
                        Text(
                          'Total Repayable: ${_formatCurrency(totalRepayable)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Borrower Info
                  _buildDetailRow('Borrower', borrowerName),
                  _buildDetailRow('Purpose', loan.purpose ?? 'N/A'),
                  _buildDetailRow('Duration', '${loan.durationDays} days'),
                  _buildDetailRow('Interest Rate',
                      '${loan.interestRate.toStringAsFixed(2)}%'),
                  if (loan.description != null && loan.description!.isNotEmpty)
                    _buildDetailRow('Description', loan.description!),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _rejectRequest(loan);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Reject'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _acceptRequest(loan);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Accept'),
                        ),
                      ),
                    ],
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

  Future<void> _acceptRequest(Loan loan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Loan Request'),
        content: Text(
          'Are you sure you want to accept this loan request of ${_formatCurrency(loan.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final loanService = getIt<LoanService>();
        await loanService.acceptLoan(loan.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan request accepted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadLoanRequests();
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

  Future<void> _rejectRequest(Loan loan) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Loan Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejecting this request:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
            child: Text(
              'Reject',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final loanService = getIt<LoanService>();
        await loanService.rejectLoan(
          loan.id,
          reasonController.text.isNotEmpty
              ? reasonController.text
              : 'Request rejected by lender',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan request rejected'),
              backgroundColor: AppColors.warning,
            ),
          );
          _loadLoanRequests();
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
