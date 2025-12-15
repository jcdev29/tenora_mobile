import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/mock/mock_utility_data.dart';
import '../../domain/models/utility_reading.dart';
import '../../routes/app_router.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  List<UtilityReading> _electricityReadings = [];
  List<UtilityReading> _waterReadings = [];
  Map<String, dynamic> _config = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUtilities();
  }

  Future<void> _loadUtilities() async {
    setState(() => _isLoading = true);
    
    _config = MockUtilityData.getRoomUtilityConfig();
    _electricityReadings = await MockUtilityData.fetchElectricityReadings();
    _waterReadings = await MockUtilityData.fetchWaterReadings();
    
    setState(() => _isLoading = false);
  }

  UtilityReading? get _latestElectricity {
    return _electricityReadings.isNotEmpty ? _electricityReadings.first : null;
  }

  UtilityReading? get _latestWater {
    return _waterReadings.isNotEmpty ? _waterReadings.first : null;
  }

  double get _totalUtilityCost {
    double total = 0;
    if (_latestElectricity != null && _latestElectricity!.isVerified) {
      total += _latestElectricity!.amount;
    }
    if (_latestWater != null && _latestWater!.isVerified) {
      total += _latestWater!.amount;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUtilities,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildTotalCard(),
                    const SizedBox(height: 24),
                    _buildElectricityCard(),
                    const SizedBox(height: 16),
                    _buildWaterCard(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Utilities',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your electricity and water readings',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total This Month',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₱${_totalUtilityCost.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTotalBreakdown(
                    'Electricity',
                    _latestElectricity?.amount ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTotalBreakdown(
                    'Water',
                    _latestWater?.amount ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBreakdown(String label, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₱${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildElectricityCard() {
    final config = _config['electricity'];
    final meterType = config['meter_type'];
    final isOwnMeter = meterType == 'own_meter';
    final latest = _latestElectricity;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.readingHistory,
            arguments: 'electricity',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bolt,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Electricity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOwnMeter
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOwnMeter ? 'Own Meter' : 'Submeter',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOwnMeter
                                  ? AppTheme.primaryColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              
              if (isOwnMeter && config['can_number'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CAN: ${config['can_number']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              
              if (latest != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadingInfo(
                        'Current',
                        '${latest.currentReading.toStringAsFixed(0)} kWh',
                      ),
                    ),
                    Expanded(
                      child: _buildReadingInfo(
                        'Previous',
                        '${latest.previousReading.toStringAsFixed(0)} kWh',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadingInfo(
                        'Consumption',
                        latest.formattedConsumption,
                      ),
                    ),
                    Expanded(
                      child: _buildReadingInfo(
                        'Amount',
                        latest.formattedAmount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(latest.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(latest.status),
                        size: 16,
                        color: _getStatusColor(latest.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(latest.status, isOwnMeter),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(latest.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (isOwnMeter && latest != null && latest.isPending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.submitReading,
                        arguments: {
                          'utilityType': 'electricity',
                          'meterType': meterType,
                        },
                      ).then((_) => _loadUtilities());
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Submit Reading'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterCard() {
    final config = _config['water'];
    final meterType = config['meter_type'];
    final isOwnMeter = meterType == 'own_meter';
    final latest = _latestWater;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRouter.readingHistory,
            arguments: 'water',
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water_drop,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOwnMeter
                                ? AppTheme.primaryColor.withOpacity(0.1)
                                : AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOwnMeter ? 'Own Meter' : 'Submeter',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isOwnMeter
                                  ? AppTheme.primaryColor
                                  : AppTheme.successColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              
              if (isOwnMeter && config['can_number'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CAN: ${config['can_number']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
              
              if (latest != null) ...[
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadingInfo(
                        'Current',
                        '${latest.currentReading.toStringAsFixed(1)} m³',
                      ),
                    ),
                    Expanded(
                      child: _buildReadingInfo(
                        'Previous',
                        '${latest.previousReading.toStringAsFixed(1)} m³',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildReadingInfo(
                        'Consumption',
                        latest.formattedConsumption,
                      ),
                    ),
                    Expanded(
                      child: _buildReadingInfo(
                        'Amount',
                        latest.formattedAmount,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(latest.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(latest.status),
                        size: 16,
                        color: _getStatusColor(latest.status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusText(latest.status, isOwnMeter),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(latest.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              if (isOwnMeter && latest != null && latest.isPending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.submitReading,
                        arguments: {
                          'utilityType': 'water',
                          'meterType': meterType,
                        },
                      ).then((_) => _loadUtilities());
                    },
                    icon: const Icon(Icons.upload),
                    label: const Text('Submit Reading'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rates',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRateRow(
                  'Electricity',
                  '₱${_config['electricity']['rate'].toStringAsFixed(2)} per kWh',
                  Icons.bolt,
                  Colors.amber,
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildRateRow(
                  'Water',
                  '₱${_config['water']['rate'].toStringAsFixed(2)} per m³',
                  Icons.water_drop,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRateRow(String label, String rate, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          rate,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'verified':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'verified':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusText(String status, bool isOwnMeter) {
    if (status == 'verified') {
      return 'Verified';
    } else if (status == 'pending') {
      if (isOwnMeter) {
        return 'Waiting for your reading submission';
      } else {
        return 'Admin will update reading';
      }
    } else if (status == 'rejected') {
      return 'Reading rejected - please resubmit';
    }
    return 'Unknown status';
  }
}