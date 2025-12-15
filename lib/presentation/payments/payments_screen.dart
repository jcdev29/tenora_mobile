import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_payment_data.dart';
import '../../domain/models/payment.dart';
import '../../routes/app_router.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Payment> _allPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    _allPayments = await MockPaymentData.fetchPaymentHistory();
    setState(() => _isLoading = false);
  }

  List<Payment> get _upcomingPayments {
    return _allPayments.where((p) => p.isPending || p.isUnderReview).toList();
  }

  List<Payment> get _paymentHistory {
    return _allPayments.where((p) => p.isVerified || p.isRejected).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildUpcomingTab(), _buildHistoryTab()],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, AppRouter.paymentMethods);
        },
        icon: const Icon(Icons.payment),
        label: const Text('Payment Methods'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildUpcomingTab() {
    if (_upcomingPayments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'All Caught Up!',
        message: 'You have no upcoming payments.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _upcomingPayments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildPaymentCard(_upcomingPayments[index]);
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_paymentHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Payment History',
        message: 'Your payment history will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPayments,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _paymentHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildPaymentCard(_paymentHistory[index]);
        },
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    Color statusColor;
    IconData statusIcon;

    switch (payment.status) {
      case 'Verified':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        break;
      case 'Under Review':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Rejected':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.cancel;
        break;
      case 'Overdue':
        statusColor = AppTheme.errorColor;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.schedule;
    }

    return Card(
      child: InkWell(
        onTap: payment.isPending
            ? () {
                Navigator.pushNamed(
                  context,
                  AppRouter.paymentProof,
                  arguments: payment.id,
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.formattedAmount,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Due: ${DateFormatter.formatDate(payment.dueDate)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      payment.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (payment.isOverdue) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        color: AppTheme.errorColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This payment is overdue. Please pay as soon as possible.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (payment.isUnderReview) ...[
                const SizedBox(height: 12),
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
                          'Payment proof is being reviewed by admin.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.warningColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (payment.isRejected) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Payment proof was rejected',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.errorColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (payment.rejectionReason != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reason: ${payment.rejectionReason}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.errorColor),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              if (payment.referenceNumber != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.confirmation_number,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ref: ${payment.referenceNumber}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
              if (payment.isPending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.paymentProof,
                        arguments: payment.id,
                      );
                    },
                    child: const Text('Upload Payment Proof'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
