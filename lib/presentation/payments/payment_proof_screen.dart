import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_payment_data.dart';
import '../../domain/models/payment_method.dart';

class PaymentProofScreen extends StatefulWidget {
  final String paymentId;

  const PaymentProofScreen({super.key, required this.paymentId});

  @override
  State<PaymentProofScreen> createState() => _PaymentProofScreenState();
}

class _PaymentProofScreenState extends State<PaymentProofScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  List<PaymentMethod> _paymentMethods = [];
  PaymentMethod? _selectedMethod;
  XFile? _proofImage;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() => _isLoading = true);
    _paymentMethods = await MockPaymentData.fetchPaymentMethods();
    if (_paymentMethods.isNotEmpty) {
      _selectedMethod = _paymentMethods.first;
    }
    setState(() => _isLoading = false);
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
      setState(() => _proofImage = image);
    }
  }

  Future<void> _submitProof() async {
    if (!_formKey.currentState!.validate()) return;
    if (_proofImage == null) {
      _showError('Please upload payment proof');
      return;
    }
    if (_selectedMethod == null) {
      _showError('Please select a payment method');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await MockPaymentData.submitPaymentProof(
        paymentId: widget.paymentId,
        referenceNumber: _referenceController.text.trim(),
        paymentMethodId: _selectedMethod!.id,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showError(result['error'] ?? 'Failed to submit payment proof');
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
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
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
            Text('Payment Proof Submitted'),
          ],
        ),
        content: const Text(
          'Your payment proof has been submitted successfully. The admin will review it and update the status soon.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to payments
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
      appBar: AppBar(title: const Text('Upload Payment Proof')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSelector(),
                    const SizedBox(height: 24),
                    _buildReferenceNumberField(),
                    const SizedBox(height: 24),
                    _buildProofUploadSection(),
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
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Instructions',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '1. Pay using one of the available payment methods\n'
            '2. Take a screenshot or photo of the receipt\n'
            '3. Enter the reference/transaction number\n'
            '4. Upload the proof and submit',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method Used',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...List.generate(_paymentMethods.length, (index) {
          final method = _paymentMethods[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedMethod = method);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _selectedMethod?.id == method.id
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedMethod?.id == method.id
                        ? AppTheme.primaryColor
                        : AppTheme.borderColor,
                    width: _selectedMethod?.id == method.id ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      method.isGCash
                          ? Icons.phone_android
                          : Icons.account_balance,
                      color: _selectedMethod?.id == method.id
                          ? AppTheme.primaryColor
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.name,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _selectedMethod?.id == method.id
                                      ? AppTheme.primaryColor
                                      : AppTheme.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.accountNumber,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (_selectedMethod?.id == method.id)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReferenceNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reference Number',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _referenceController,
          decoration: const InputDecoration(
            hintText: 'Enter transaction/reference number',
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the reference number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildProofUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Proof', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_proofImage == null)
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
            padding: const EdgeInsets.all(16),
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
                  'Proof Uploaded',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _proofImage!.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    setState(() => _proofImage = null);
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
          border: Border.all(
            color: AppTheme.borderColor,
            style: BorderStyle.solid,
          ),
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
        onPressed: _isSubmitting ? null : _submitProof,
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Submit Payment Proof'),
      ),
    );
  }
}
