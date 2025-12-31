import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bloc/onboarding/onboarding_bloc.dart';

class IdVerificationStepPage extends StatefulWidget {
  const IdVerificationStepPage({super.key});

  @override
  State<IdVerificationStepPage> createState() => _IdVerificationStepPageState();
}

class _IdVerificationStepPageState extends State<IdVerificationStepPage> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  String _selectedIdType = 'aadhar';
  String? _documentPath;
  String? _documentName;

  final List<Map<String, String>> _idTypes = [
    {'value': 'aadhar', 'label': 'Aadhar Card'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    final state = context.read<OnboardingBloc>().state;
    _selectedIdType = state.idType;
    _idNumberController.text = state.idNumber;
    _documentPath = state.documentPath;
    _documentName = state.documentName;
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    super.dispose();
  }

  void _updateIdInfo() {
    context.read<OnboardingBloc>().add(OnboardingIdUpdated(
          idType: _selectedIdType,
          idNumber: _idNumberController.text.trim(),
          documentPath: _documentPath,
          documentName: _documentName,
        ));
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 5MB'),
                backgroundColor: AppColors.danger,
              ),
            );
          }
          return;
        }

        setState(() {
          _documentPath = file.path;
          _documentName = file.name;
        });
        _updateIdInfo();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  String _getIdNumberHint() {
    return '12-digit Aadhar number';
  }

  String _getIdNumberHelperText() {
    return 'Enter 12-digit Aadhar number (numbers only)';
  }

  int _getMaxLength() {
    return 12;
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ID number';
    }
    if (value.length != 12 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Enter valid 12-digit Aadhar number';
    }
    return null;
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
              'Identity Verification',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gray900,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your government ID for verification',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.gray500,
                  ),
            ),
            const SizedBox(height: 32),

            // ID Type Dropdown
            _buildLabel('ID TYPE'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray300),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedIdType,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                ),
                dropdownColor: AppColors.white,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.gray500),
                items: _idTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(
                      type['label']!,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedIdType = value!;
                    _idNumberController.clear();
                  });
                  _updateIdInfo();
                },
              ),
            ),
            const SizedBox(height: 24),

            // ID Number
            _buildLabel('ID NUMBER'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idNumberController,
              maxLength: _getMaxLength(),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: _inputDecoration(_getIdNumberHint()).copyWith(
                counterText: '',
                helperText: _getIdNumberHelperText(),
                helperStyle: const TextStyle(
                  color: AppColors.gray500,
                  fontSize: 12,
                ),
              ),
              onChanged: (_) => _updateIdInfo(),
              validator: _validateIdNumber,
            ),
            const SizedBox(height: 24),

            // Upload Document
            _buildLabel('UPLOAD ID DOCUMENT'),
            const SizedBox(height: 8),
            const Text(
              'Accepted formats: JPG, PNG, PDF (Max 5MB)',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),

            // Upload Area
            InkWell(
              onTap: _pickDocument,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _documentPath != null
                        ? AppColors.success
                        : AppColors.gray300,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentPath != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 40,
                      color: _documentPath != null
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _documentPath != null
                          ? _documentName ?? 'Document uploaded'
                          : 'Click to upload document',
                      style: TextStyle(
                        color: _documentPath != null
                            ? AppColors.gray900
                            : AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_documentPath != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickDocument,
                        child: const Text(
                          'Change document',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
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
