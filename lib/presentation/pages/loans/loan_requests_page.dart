import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LoanRequestsPage extends StatefulWidget {
  const LoanRequestsPage({super.key});

  @override
  State<LoanRequestsPage> createState() => _LoanRequestsPageState();
}

class _LoanRequestsPageState extends State<LoanRequestsPage> {
  final _minAmountController = TextEditingController(text: '500');
  final _maxAmountController = TextEditingController(text: '100000');
  String _sortBy = 'Date';
  String _order = 'Newest First';
  bool _isLoading = false;
  List<dynamic> _loanRequests = [];

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
    setState(() => _isLoading = true);
    
    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isLoading = false;
      _loanRequests = []; // Empty for now
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              color: AppColors.primary,
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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
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
                  items: ['Date', 'Amount', 'Duration'],
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
                  value: _order,
                  items: ['Newest First', 'Oldest First'],
                  onChanged: (value) {
                    setState(() => _order = value!);
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
          else if (_loanRequests.isEmpty)
            _buildEmptyState()
          else
            _buildLoanList(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? prefix,
  }) {
    return Container(
      decoration: BoxDecoration(
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
        onChanged: (_) => _loadLoanRequests(),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
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
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                color: AppColors.gray900,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search,
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
              color: AppColors.primary,
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
      children: _loanRequests.map((loan) {
        return _buildLoanCard(loan);
      }).toList(),
    );
  }

  Widget _buildLoanCard(dynamic loan) {
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
                '₹${loan['amount'] ?? 0}',
                style: const TextStyle(
                  color: AppColors.gray900,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Purpose: ${loan['purpose'] ?? 'N/A'}',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Duration: ${loan['durationDays'] ?? 0} days',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // View details
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Accept loan
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
