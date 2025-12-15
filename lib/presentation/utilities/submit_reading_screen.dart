import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_utility_data.dart';

class SubmitReadingScreen extends StatefulWidget {
  final String utilityType; // electricity or water
  final String meterType; // own_meter or submeter

  const SubmitReadingScreen({
    super.key,
    required this.utilityType,
    required this.meterType,
  });

  @override
  State<SubmitReadingScreen> createState() => _SubmitReadingScreenState();
}

class _SubmitReadingScreenState extends State<SubmitReadingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _canController = TextEditingController();
  final _previousReadingController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  XFile? _billImage;
  bool _isSubmitting = false;

  bool get _isElectricity => widget.utilityType == 'electricity';
  String get _unit => _isElectricity ? 'kWh' : 'm³';
  IconData get _icon => _isElectricity ? Icons.bolt : Icons.water_drop;
  Color get _color => _isElectricity ? Colors.amber : Colors.blue;

  @override
  void initState() {
    super.initState();
    _loadPreviousReading();
  }

  @override
  void dispose() {
    _canController.dispose();
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousReading() async {
    // Load the last reading to auto-fill previous reading
    final readings = _isElectricity
        ? await MockUtilityData.fetchElectricityReadings()
        : await MockUtilityData.fetchWaterReadings();
    
    if (readings.isNotEmpty && mounted) {
      setState(() {
        _previousReadingController.text = 
            readings.first.currentReading.toStringAsFixed(_isElectricity ? 0 : 1);
        if (readings.first.canNumber != null) {
          _canController.text = readings.first.canNumber!;
        }
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() => _billImage = image);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  double get _consumption {
    final previous = double.tryParse(_previousReadingController.text) ?? 0;
    final current = double.tryParse(_currentReadingController.text) ?? 0;
    return current - previous;
  }

  Future<void> _submitReading() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_billImage == null) {
      _showError('Please upload a photo of your bill');
      return;
    }

    if (_consumption <= 0) {
      _showError('Current reading must be greater than previous reading');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await MockUtilityData.submitReading(
        utilityType: widget.utilityType,
        canNumber: _canController.text.trim(),
        previousReading: double.parse(_previousReadingController.text),
        currentReading: double.parse(_currentReadingController.text),
        readingDate: _selectedDate,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showError(result['error'] ?? 'Failed to submit reading');
      }
    } catch (e) {
      if (mounted) {
        _showError('An error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 12),
            Text('Reading Submitted'),
          ],
        ),
        content: const Text(
          'Your utility reading has been submitted successfully. The admin will verify it and update your billing.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit ${_isElectricity ? 'Electricity' : 'Water'} Reading'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildCANField(),
              const SizedBox(height: 24),
              _buildDateField(),
              const SizedBox(height: 24),
              _buildReadingsSection(),
              const SizedBox(height: 24),
              _buildConsumptionCard(),
              const SizedBox(height: 24),
              _buildBillUploadSection(),
              const SizedBox(height: 24),
              _buildNotesField(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to Submit',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: _color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Check your utility bill\n'
                  '2. Enter the reading from your meter\n'
                  '3. Take a clear photo of the bill\n'
                  '4. Submit for admin verification',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _color,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCANField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Account Number (CAN)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _canController,
          decoration: const InputDecoration(
            hintText: 'Enter your CAN',
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your CAN';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing Date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                const SizedBox(width: 16),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meter Readings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _previousReadingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Previous Reading',
                  hintText: '0',
                  suffixText: _unit,
                  prefixIcon: const Icon(Icons.arrow_back),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _currentReadingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Current Reading',
                  hintText: '0',
                  suffixText: _unit,
                  prefixIcon: const Icon(Icons.arrow_forward),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsumptionCard() {
    if (_consumption <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_color.withOpacity(0.1), _color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(_icon, color: _color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consumption',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_consumption.toStringAsFixed(_isElectricity ? 0 : 1)} $_unit',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: _color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bill Photo',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_billImage == null)
          Column(
            children: [
              _buildUploadButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(height: 12),
              _buildUploadButton(
                icon: Icons.photo_library,
                label: 'Choose from Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.successColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Bill Photo Uploaded',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _billImage!.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _billImage = null);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Remove'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Any additional information...',
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReading,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Submit Reading'),
      ),
    );
  }
}