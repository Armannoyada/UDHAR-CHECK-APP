import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';

class LendingSetupStepPage extends StatefulWidget {
  const LendingSetupStepPage({super.key});

  @override
  State<LendingSetupStepPage> createState() => _LendingSetupStepPageState();
}

class _LendingSetupStepPageState extends State<LendingSetupStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _lendingAmountController = TextEditingController();
  bool _termsAccepted = false;

  final List<String> _termsAndConditions = [
    'Follow all platform guidelines and policies',
    'Only lend money you can afford to lose',
    'Treat all borrowers with respect and dignity',
    'Report any suspicious activity immediately',
    'Maintain accurate and honest lending records',
    'Comply with all applicable laws and regulations',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    final state = context.read<OnboardingBloc>().state;
    if (state.maxLendingAmount != null) {
      _lendingAmountController.text = state.maxLendingAmount!.toStringAsFixed(0);
    }
    _termsAccepted = state.termsAccepted;
  }

  @override
  void dispose() {
    _lendingAmountController.dispose();
    super.dispose();
  }

  void _updateLendingPreferences() {
    final amount = double.tryParse(_lendingAmountController.text.replaceAll(',', '')) ?? 0;
    context.read<OnboardingBloc>().add(OnboardingLendingPreferencesUpdated(
          maxLendingAmount: amount,
          termsAccepted: _termsAccepted,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Lending Setup',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your lending preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
            const SizedBox(height: 32),

            // Maximum Lending Amount
            _buildLabel('MAXIMUM LENDING AMOUNT (₹)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _lendingAmountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('e.g., 50000').copyWith(
                prefixText: '₹ ',
                prefixStyle: TextStyle(
                  color: AppColors.gray700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                helperText: 'This is the maximum amount you\'re willing to lend at any time',
                helperStyle: TextStyle(
                  color: AppColors.gray500,
                  fontSize: 12,
                ),
              ),
              onChanged: (_) => _updateLendingPreferences(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum lending amount';
                }
                final amount = double.tryParse(value.replaceAll(',', ''));
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount < 1000) {
                  return 'Minimum lending limit is ₹1,000';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Terms and Conditions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms and Conditions',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By becoming a lender on this platform, you agree to:',
                    style: TextStyle(
                      color: AppColors.gray600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Scrollable terms list
                  Container(
                    height: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.gray200),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _termsAndConditions.map((term) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(
                                    color: AppColors.gray700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    term,
                                    style: TextStyle(
                                      color: AppColors.gray700,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Accept Terms Checkbox
            InkWell(
              onTap: () {
                setState(() {
                  _termsAccepted = !_termsAccepted;
                });
                _updateLendingPreferences();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _termsAccepted
                            ? AppColors.primary
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _termsAccepted
                              ? AppColors.primary
                              : AppColors.gray300,
                          width: 2,
                        ),
                      ),
                      child: _termsAccepted
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'I accept the terms and conditions',
                        style: TextStyle(
                          color: AppColors.gray700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.gray700,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.gray400,
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
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
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.danger),
      ),
    );
  }
}
