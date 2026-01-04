import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/services/admin_service.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _isLoading = true;
  List<PlatformSetting> _settings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminService = getIt<AdminService>();
      final settings = await adminService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadSettings,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Platform Settings',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Configure platform-wide settings',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorState()
            else
              _buildSettingsList(),
          ],
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
            'Error Loading Settings',
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
            style: TextStyle(color: AppColors.gray500),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSettings,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    // Group settings by category
    final Map<String, List<PlatformSetting>> groupedSettings = {};
    for (var setting in _settings) {
      final category = setting.category.isNotEmpty ? setting.category : 'General';
      if (!groupedSettings.containsKey(category)) {
        groupedSettings[category] = [];
      }
      groupedSettings[category]!.add(setting);
    }

    if (groupedSettings.isEmpty) {
      return _buildDefaultSettings();
    }

    return Column(
      children: groupedSettings.entries.map((entry) {
        return _buildSettingsSection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildDefaultSettings() {
    return Column(
      children: [
        // Loan Settings
        _buildSettingsCard(
          'Loan Settings',
          Icons.attach_money,
          [
            _buildSettingItem(
              'Minimum Loan Amount',
              '₹500',
              'The minimum amount users can borrow',
              () => _editSetting('min_loan_amount', '500', 'number'),
            ),
            _buildSettingItem(
              'Maximum Loan Amount',
              '₹50,000',
              'The maximum amount users can borrow',
              () => _editSetting('max_loan_amount', '50000', 'number'),
            ),
            _buildSettingItem(
              'Default Interest Rate',
              '10%',
              'Default interest rate for loans',
              () => _editSetting('default_interest_rate', '10', 'number'),
            ),
            _buildSettingItem(
              'Maximum Loan Duration',
              '365 days',
              'Maximum duration for loan repayment',
              () => _editSetting('max_loan_duration', '365', 'number'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // User Settings
        _buildSettingsCard(
          'User Settings',
          Icons.person,
          [
            _buildToggleSetting(
              'Require Verification',
              true,
              'Require users to verify their identity',
              (value) => _updateSetting('require_verification', value.toString()),
            ),
            _buildToggleSetting(
              'Allow New Registrations',
              true,
              'Allow new users to register',
              (value) => _updateSetting('allow_registrations', value.toString()),
            ),
            _buildSettingItem(
              'Minimum Trust Score',
              '30',
              'Minimum trust score required to borrow',
              () => _editSetting('min_trust_score', '30', 'number'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Notification Settings
        _buildSettingsCard(
          'Notification Settings',
          Icons.notifications,
          [
            _buildToggleSetting(
              'Email Notifications',
              true,
              'Send email notifications to users',
              (value) => _updateSetting('email_notifications', value.toString()),
            ),
            _buildToggleSetting(
              'Push Notifications',
              true,
              'Send push notifications to users',
              (value) => _updateSetting('push_notifications', value.toString()),
            ),
            _buildToggleSetting(
              'SMS Notifications',
              false,
              'Send SMS notifications to users',
              (value) => _updateSetting('sms_notifications', value.toString()),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Platform Settings
        _buildSettingsCard(
          'Platform Settings',
          Icons.settings,
          [
            _buildToggleSetting(
              'Maintenance Mode',
              false,
              'Put the platform in maintenance mode',
              (value) => _updateSetting('maintenance_mode', value.toString()),
            ),
            _buildSettingItem(
              'Platform Name',
              'Udhar',
              'The name of the platform',
              () => _editSetting('platform_name', 'Udhar', 'text'),
            ),
            _buildSettingItem(
              'Support Email',
              'support@udhar.com',
              'Support email address',
              () => _editSetting('support_email', 'support@udhar.com', 'text'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(String category, List<PlatformSetting> settings) {
    IconData icon;
    switch (category.toLowerCase()) {
      case 'loan':
        icon = Icons.attach_money;
        break;
      case 'user':
        icon = Icons.person;
        break;
      case 'notification':
        icon = Icons.notifications;
        break;
      default:
        icon = Icons.settings;
    }

    return Column(
      children: [
        _buildSettingsCard(
          category,
          icon,
          settings.map((setting) {
            if (setting.type == 'boolean') {
              return _buildToggleSetting(
                setting.name,
                setting.value.toLowerCase() == 'true',
                setting.description ?? '',
                (value) => _updateSetting(setting.key, value.toString()),
              );
            } else {
              return _buildSettingItem(
                setting.name,
                setting.value,
                setting.description ?? '',
                () => _editSetting(setting.key, setting.value, setting.type),
              );
            }
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsCard(String title, IconData icon, List<Widget> items) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String label,
    String value,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.gray900,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.gray500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting(
    String label,
    bool value,
    String description,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.gray900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _editSetting(String key, String currentValue, String type) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ')}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateSetting(key, controller.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSetting(String key, String value) async {
    try {
      final adminService = getIt<AdminService>();
      await adminService.updateSetting(key, value);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Setting updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadSettings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}
