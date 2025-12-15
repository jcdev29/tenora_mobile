import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_contract_data.dart';
import '../../domain/models/contract.dart';

class ContractDetailScreen extends StatefulWidget {
  const ContractDetailScreen({super.key});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  late Contract _contract;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContract();
  }

  Future<void> _loadContract() async {
    setState(() => _isLoading = true);
    _contract = await MockContractData.fetchActiveContract();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contract Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildDetailsCard(),
                  const SizedBox(height: 16),
                  _buildTermsCard(),
                  const SizedBox(height: 24),
                  _buildRenewalButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _contract.isExpiring
                        ? AppTheme.warningColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _contract.status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _contract.isExpiring
                          ? AppTheme.warningColor
                          : AppTheme.successColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (_contract.isExpiring)
                  Icon(Icons.warning_amber, color: AppTheme.warningColor),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Contract Duration',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    'Start Date',
                    DateFormatter.formatDate(_contract.startDate),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateInfo(
                    'End Date',
                    DateFormatter.formatDate(_contract.endDate),
                  ),
                ),
              ],
            ),
            if (_contract.isExpiring) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your contract expires in ${_contract.daysUntilExpiry} days. Consider renewing soon!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.warningColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Monthly Rent', _contract.formattedMonthlyRate),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Security Deposit',
              _contract.formattedSecurityDeposit,
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Contract Duration',
              '${_contract.durationInMonths} months',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('Contract ID', _contract.id, isSmall: true),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Signed On',
              _contract.signedAt != null
                  ? DateFormatter.formatDate(_contract.signedAt!)
                  : 'Not signed',
              isSmall: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _contract.terms ?? 'No terms available',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRenewalButton() {
    if (!_contract.isExpiring) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _showRenewalDialog,
        icon: const Icon(Icons.autorenew),
        label: const Text('Request Renewal'),
      ),
    );
  }

  Widget _buildDateInfo(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(
          date,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isSmall
              ? Theme.of(context).textTheme.bodySmall
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isSmall
              ? Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)
              : Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _showRenewalDialog() {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Contract Renewal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a renewal request to the admin. They will contact you to discuss the terms.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Any special requests or concerns?',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final result = await MockContractData.requestRenewal(
                messageController.text,
              );

              if (mounted && result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['data']['message']),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
