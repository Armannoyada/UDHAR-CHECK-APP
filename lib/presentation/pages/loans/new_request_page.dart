import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/loan_service.dart';
import '../../../data/models/loan_model.dart';
import '../../../core/di/injection_container.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedDuration = '30 Days';
  String _selectedPurpose = 'Select purpose';
  bool _isLoading = false;

  final List<String> _durations = [
    '7 Days',
    '14 Days',
    '30 Days',
    '45 Days',
    '60 Days',
    '90 Days',
  ];

  final List<String> _purposes = [
    'Select purpose',
    'Medical Emergency',
    'Education',
    'Business',
    'Personal',
    'Home Repair',
    'Vehicle',
    'Wedding',
    'Travel',
    'Other',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPurpose == 'Select purpose') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a purpose')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final loanService = getIt<LoanService>();
      final durationDays = int.parse(_selectedDuration.split(' ')[0]);
      
      final request = CreateLoanRequest(
        amount: double.parse(_amountController.text),
        purpose: _selectedPurpose,
        durationDays: durationDays,
        interestRate: 10.0, // Default interest rate of 10%
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : null,
      );

      await loanService.createLoanRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan request submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.gray700),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.gray700),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back to Dashboard
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Dashboard',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Request Money',
                      style: TextStyle(
                        color: AppColors.gray900,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Fill in the details to create a new loan request',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Loan Request Guidelines Card
                    _buildGuidelinesCard(),
                    const SizedBox(height: 16),

                    // Quick Tips Card
                    _buildQuickTipsCard(),
                    const SizedBox(height: 24),

                    // Loan Details Section
                    _buildLoanDetailsSection(),
                    const SizedBox(height: 24),

                    // Purpose & Description Section
                    _buildPurposeSection(),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: AppColors.gray300,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text(
                                'Submit Request',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.gray600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelinesCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Loan Request Guidelines',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildGuidelineItem('Minimum loan amount: ₹1,000'),
          _buildGuidelineItem('Maximum loan amount: ₹1,00,000'),
          _buildGuidelineItem('Loan duration: 7 to 90 days'),
          _buildGuidelineItem('Your trust score affects approval chances'),
          _buildGuidelineItem('Be clear and honest in your description'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTipsCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: AppColors.warning, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quick Tips',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTipItem('Higher trust scores get faster approvals'),
          _buildTipItem('Complete your profile verification'),
          _buildTipItem('Provide accurate information'),
          _buildTipItem('Respond promptly to lender queries'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: AppColors.success, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanDetailsSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Loan Details',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loan Amount
          const Text(
            'LOAN AMOUNT *',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '₹',
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 18,
                  ),
                ),
              ),
              hintText: 'Enter amount (₹1,000 - ₹1,00,000)',
              hintStyle: TextStyle(color: AppColors.gray400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter loan amount';
              }
              final amount = double.tryParse(value);
              if (amount == null) {
                return 'Please enter a valid amount';
              }
              if (amount < 1000) {
                return 'Minimum amount is ₹1,000';
              }
              if (amount > 100000) {
                return 'Maximum amount is ₹1,00,000';
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Enter the amount you need to borrow',
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Loan Duration
          const Text(
            'LOAN DURATION *',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDuration,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray500),
                items: _durations.map((duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: AppColors.gray500, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedDuration = value!);
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how long you need the loan',
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeSection() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Purpose & Description',
                style: TextStyle(
                  color: AppColors.gray900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Purpose
          const Text(
            'PURPOSE *',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPurpose,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gray500),
                items: _purposes.map((purpose) {
                  return DropdownMenuItem<String>(
                    value: purpose,
                    child: Text(
                      purpose,
                      style: TextStyle(
                        color: purpose == 'Select purpose' 
                            ? AppColors.gray400 
                            : AppColors.gray900,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPurpose = value!);
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the reason for this loan',
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          const Text(
            'DESCRIPTION (OPTIONAL)',
            style: TextStyle(
              color: AppColors.gray600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Provide additional details about your loan request...',
              hintStyle: TextStyle(color: AppColors.gray400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add any additional information that might help lenders understand your request',
            style: TextStyle(
              color: AppColors.gray400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
