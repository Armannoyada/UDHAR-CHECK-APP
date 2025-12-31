import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../bloc/onboarding/onboarding_bloc.dart';

class SelfieStepPage extends StatefulWidget {
  const SelfieStepPage({super.key});

  @override
  State<SelfieStepPage> createState() => _SelfieStepPageState();
}

class _SelfieStepPageState extends State<SelfieStepPage> {
  String? _selfiePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Initialize with existing data if available
    final state = context.read<OnboardingBloc>().state;
    _selfiePath = state.selfiePath;
  }

  Future<void> _takeSelfie() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selfiePath = image.path;
        });

        if (mounted) {
          context.read<OnboardingBloc>().add(OnboardingSelfieUpdated(
                selfiePath: image.path,
              ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing selfie: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _retakeSelfie() {
    setState(() {
      _selfiePath = null;
    });
    context.read<OnboardingBloc>().add(const OnboardingSelfieUpdated(
          selfiePath: '',
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Take a Selfie',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'We need a selfie to verify your identity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.gray500,
                ),
          ),
          const SizedBox(height: 48),

          // Selfie Preview / Capture Area
          Center(
            child: _selfiePath != null && _selfiePath!.isNotEmpty
                ? _buildSelfiePreview()
                : _buildCaptureArea(),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureArea() {
    return Column(
      children: [
        // Camera icon placeholder - square with rounded corners
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gray300,
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 40,
            color: AppColors.gray400,
          ),
        ),
        const SizedBox(height: 20),

        // Instructions
        const Text(
          'Position your face in the frame',
          style: TextStyle(
            color: AppColors.gray600,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 20),

        // Open Camera Button
        ElevatedButton.icon(
          onPressed: _takeSelfie,
          icon: const Icon(Icons.camera_alt, color: AppColors.white, size: 18),
          label: const Text(
            'Open Camera',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSelfiePreview() {
    return Column(
      children: [
        // Selfie Preview
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.success,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(
              File(_selfiePath!),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Success message
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Selfie captured successfully!',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Retake button
        OutlinedButton.icon(
          onPressed: _retakeSelfie,
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          label: const Text(
            'Retake Selfie',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
