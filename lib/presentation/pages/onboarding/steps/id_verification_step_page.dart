import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';

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
    {'value': 'pan', 'label': 'PAN Card'},
    {'value': 'voter_id', 'label': 'Voter ID'},
    {'value': 'driving_license', 'label': 'Driving License'},
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
              SnackBar(
                content: const Text('File size must be less than 5MB'),
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
    switch (_selectedIdType) {
      case 'aadhar':
        return '12-digit Aadhar number';
      case 'pan':
        return 'PAN number (e.g., ABCDE1234F)';
      case 'voter_id':
        return 'Voter ID number';
      case 'driving_license':
        return 'Driving License number';
      default:
        return 'Enter ID number';
    }
  }

  String _getIdNumberHelperText() {
    switch (_selectedIdType) {
      case 'aadhar':
        return 'Enter 12-digit Aadhar number (numbers only)';
      case 'pan':
        return 'Enter 10-character PAN number';
      case 'voter_id':
        return 'Enter your Voter ID number';
      case 'driving_license':
        return 'Enter your Driving License number';
      default:
        return '';
    }
  }

  int _getMaxLength() {
    switch (_selectedIdType) {
      case 'aadhar':
        return 12;
      case 'pan':
        return 10;
      default:
        return 20;
    }
  }

  String? _validateIdNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter ID number';
    }

    switch (_selectedIdType) {
      case 'aadhar':
        if (value.length != 12 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Enter valid 12-digit Aadhar number';
        }
        break;
      case 'pan':
        if (value.length != 10 ||
            !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                .hasMatch(value.toUpperCase())) {
          return 'Enter valid PAN number (e.g., ABCDE1234F)';
        }
        break;
      case 'voter_id':
      case 'driving_license':
        if (value.length < 10) {
          return 'Enter valid ID number';
        }
        break;
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
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedIdType,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                ),
                items: _idTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(type['label']!),
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
              textCapitalization: _selectedIdType == 'pan'
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              keyboardType: _selectedIdType == 'aadhar'
                  ? TextInputType.number
                  : TextInputType.text,
              inputFormatters: _selectedIdType == 'aadhar'
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              decoration: _inputDecoration(_getIdNumberHint()).copyWith(
                counterText: '',
                helperText: _getIdNumberHelperText(),
                helperStyle: TextStyle(
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
            Text(
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
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _documentPath != null
                        ? AppColors.success
                        : AppColors.gray300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _documentPath != null
                          ? Icons.check_circle
                          : Icons.cloud_upload_outlined,
                      size: 48,
                      color: _documentPath != null
                          ? AppColors.success
                          : AppColors.gray400,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _documentName ?? 'Click to upload document',
                      style: TextStyle(
                        color: _documentPath != null
                            ? AppColors.gray900
                            : AppColors.gray500,
                        fontSize: 14,
                        fontWeight: _documentPath != null
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_documentPath != null) ...[
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickDocument,
                        child: Text(
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
