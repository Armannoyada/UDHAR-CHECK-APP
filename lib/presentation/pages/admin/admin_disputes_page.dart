import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/services/admin_service.dart';

class AdminDisputesPage extends StatefulWidget {
  const AdminDisputesPage({super.key});

  @override
  State<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends State<AdminDisputesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = '';
  bool _isLoading = true;
  List<AdminDispute> _disputes = [];
  String? _errorMessage;

  final List<String> _tabs = ['All Disputes', 'Open'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadDisputes();
      }
    });
    _loadDisputes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? get _currentTabFilter {
    if (_tabController.index == 1) return 'open';
    return null;
  }

  Future<void> _loadDisputes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final adminService = getIt<AdminService>();
      String? statusFilter = _currentTabFilter;
      if (_selectedStatus.isNotEmpty) {
        statusFilter = _selectedStatus;
      }

      final data = await adminService.getAllDisputes(
        status: statusFilter,
      );

      setState(() {
        _disputes = data['disputes'] as List<AdminDispute>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDisputes,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Dispute Management',
              style: TextStyle(
                color: AppColors.gray900,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Handle and resolve disputes between lenders and borrowers',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                labelColor: AppColors.white,
                unselectedLabelColor: AppColors.gray600,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 18),
                        const SizedBox(width: 8),
                        const Text('All Disputes'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 18),
                        const SizedBox(width: 8),
                        const Text('Open'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gray200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedStatus.isEmpty ? null : _selectedStatus,
                  hint: Text(
                    'All Status',
                    style: TextStyle(color: AppColors.gray600, fontSize: 14),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.gray500),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All Status')),
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(
                        value: 'under_review', child: Text('Under Review')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value ?? '');
                    _loadDisputes();
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Disputes List
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              _buildErrorState()
            else if (_disputes.isEmpty)
              _buildEmptyState()
            else
              _buildDisputesList(),
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
            'Error Loading Disputes',
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
            onPressed: _loadDisputes,
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
            Icons.description_outlined,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No disputes found',
            style: TextStyle(
              color: AppColors.gray900,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no disputes at this time.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputesList() {
    return Column(
      children: _disputes.map((dispute) => _buildDisputeCard(dispute)).toList(),
    );
  }

  Widget _buildDisputeCard(AdminDispute dispute) {
    final statusColor = _getStatusColor(dispute.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispute #${dispute.id}',
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(dispute.createdAt),
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatStatus(dispute.status),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Reason
          Text(
            'Reason: ${dispute.reason}',
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (dispute.description != null && dispute.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dispute.description!,
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Parties
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raised By',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dispute.raisedBy?.fullName ?? 'Unknown',
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Against',
                      style: TextStyle(
                        color: AppColors.gray500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dispute.againstUser?.fullName ?? 'Unknown',
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewDisputeDetails(dispute),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _resolveDispute(dispute),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Resolve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.warning;
      case 'under_review':
        return AppColors.info;
      case 'resolved':
        return AppColors.success;
      case 'closed':
        return AppColors.gray500;
      default:
        return AppColors.gray500;
    }
  }

  String _formatStatus(String status) {
    return status.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  void _viewDisputeDetails(AdminDispute dispute) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dispute #${dispute.id}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(dispute.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatStatus(dispute.status),
                            style: TextStyle(
                              color: _getStatusColor(dispute.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildDetailSection('Reason', dispute.reason),
                    if (dispute.description != null)
                      _buildDetailSection('Description', dispute.description!),
                    _buildDetailSection(
                      'Raised By',
                      dispute.raisedBy?.fullName ?? 'Unknown',
                    ),
                    _buildDetailSection(
                      'Against',
                      dispute.againstUser?.fullName ?? 'Unknown',
                    ),
                    _buildDetailSection('Date', _formatDate(dispute.createdAt)),
                    if (dispute.loan != null)
                      _buildDetailSection(
                        'Loan Amount',
                        '₹${dispute.loan!.amount.toStringAsFixed(0)}',
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

  Widget _buildDetailSection(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.gray500,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _resolveDispute(AdminDispute dispute) async {
    final status = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Dispute'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select the resolution status:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Under Review'),
              leading: Radio<String>(
                value: 'under_review',
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'under_review'),
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: Radio<String>(
                value: 'resolved',
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'resolved'),
            ),
            ListTile(
              title: const Text('Closed'),
              leading: Radio<String>(
                value: 'closed',
                groupValue: null,
                onChanged: (value) => Navigator.pop(context, value),
              ),
              onTap: () => Navigator.pop(context, 'closed'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (status != null) {
      try {
        final adminService = getIt<AdminService>();
        await adminService.resolveDispute(dispute.id, status);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dispute marked as ${_formatStatus(status)}'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadDisputes();
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
}
