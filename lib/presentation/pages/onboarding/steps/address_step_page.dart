import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bloc/onboarding/onboarding_bloc.dart';

class AddressStepPage extends StatefulWidget {
  const AddressStepPage({super.key});

  @override
  State<AddressStepPage> createState() => _AddressStepPageState();
}

class _AddressStepPageState extends State<AddressStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    final state = context.read<OnboardingBloc>().state;
    _streetAddressController.text = state.streetAddress;
    _cityController.text = state.city;
    _stateController.text = state.state;
    _pincodeController.text = state.pincode;
  }

  @override
  void dispose() {
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _updateAddress() {
    context.read<OnboardingBloc>().add(OnboardingAddressUpdated(
          streetAddress: _streetAddressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
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
              'Address Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your current address',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
            const SizedBox(height: 32),

            // Street Address
            _buildLabel('STREET ADDRESS'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _streetAddressController,
              maxLines: 3,
              decoration: _inputDecoration('Enter your full address'),
              onChanged: (_) => _updateAddress(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your street address';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // City and State Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('CITY'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        decoration: _inputDecoration('City'),
                        onChanged: (_) => _updateAddress(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter city';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('STATE'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stateController,
                        decoration: _inputDecoration('State'),
                        onChanged: (_) => _updateAddress(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter state';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pincode
            _buildLabel('PINCODE'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration('6-digit pincode').copyWith(
                counterText: '',
                helperText: 'Enter 6-digit pincode',
                helperStyle: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 12,
                ),
              ),
              onChanged: (_) => _updateAddress(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter pincode';
                }
                if (value.length != 6) {
                  return 'Pincode must be 6 digits';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
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
      hintStyle: const TextStyle(
        color: AppColors.gray400,
        fontSize: 15,
      ),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    );
  }
}
