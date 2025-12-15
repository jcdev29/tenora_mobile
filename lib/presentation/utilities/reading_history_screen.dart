import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_utility_data.dart';
import '../../domain/models/utility_reading.dart';

class ReadingHistoryScreen extends StatefulWidget {
  final String utilityType; // electricity or water

  const ReadingHistoryScreen({super.key, required this.utilityType});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  List<UtilityReading> _readings = [];
  bool _isLoading = true;

  bool get _isElectricity => widget.utilityType == 'electricity';
  String get _unit => _isElectricity ? 'kWh' : 'm³';
  IconData get _icon => _isElectricity ? Icons.bolt : Icons.water_drop;
  Color get _color => _isElectricity ? Colors.amber : Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    setState(() => _isLoading = true);

    _readings = _isElectricity
        ? await MockUtilityData.fetchElectricityReadings()
        : await MockUtilityData.fetchWaterReadings();

    setState(() => _isLoading = false);
  }

  double get _averageConsumption {
    if (_readings.isEmpty) return 0;
    final total = _readings.fold<double>(
      0,
      (sum, reading) => sum + reading.consumption,
    );
    return total / _readings.length;
  }

  double get _totalAmount {
    return _readings.fold<double>(0, (sum, reading) => sum + reading.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_isElectricity ? 'Electricity' : 'Water'} History'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReadings,
              child: _readings.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 24),
                          Text(
                            'Reading History',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          ..._readings.map(
                            (reading) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildReadingCard(reading),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Average',
            '${_averageConsumption.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
            Icons.trending_flat,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total Paid',
            '₱${_totalAmount.toStringAsFixed(2)}',
            Icons.payments,
            AppTheme.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(UtilityReading reading) {
    Color statusColor;
    switch (reading.status) {
      case 'verified':
        statusColor = AppTheme.successColor;
        break;
      case 'pending':
        statusColor = AppTheme.warningColor;
        break;
      case 'rejected':
        statusColor = AppTheme.errorColor;
        break;
      default:
        statusColor = AppTheme.textSecondary;
    }

    return Card(
      child: InkWell(
        onTap: () => _showReadingDetails(reading),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(_icon, color: _color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatter.formatDate(reading.readingDate),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reading.formattedAmount,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      reading.status.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildReadingDetail(
                      'Previous',
                      '${reading.previousReading.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
                    ),
                  ),
                  Expanded(
                    child: _buildReadingDetail(
                      'Current',
                      '${reading.currentReading.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
                    ),
                  ),
                  Expanded(
                    child: _buildReadingDetail(
                      'Used',
                      reading.formattedConsumption,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, size: 80, color: _color.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'No Reading History',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${_isElectricity ? 'electricity' : 'water'} reading history will appear here.',
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

  void _showReadingDetails(UtilityReading reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(_icon, color: _color, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      DateFormatter.formatDate(reading.readingDate),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                'Previous Reading',
                '${reading.previousReading.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Current Reading',
                '${reading.currentReading.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Consumption', reading.formattedConsumption),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Rate',
                '₱${reading.rate.toStringAsFixed(2)} per $_unit',
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('Amount', reading.formattedAmount, isBold: true),
              if (reading.canNumber != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildDetailRow('CAN', reading.canNumber!),
              ],
              if (reading.notes != null) ...[
                const SizedBox(height: 16),
                Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reading.notes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
