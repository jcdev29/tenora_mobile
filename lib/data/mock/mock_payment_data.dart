import '../../domain/models/payment.dart';
import '../../domain/models/payment_method.dart';

class MockPaymentData {
  static List<Payment> getPaymentHistory() {
    final now = DateTime.now();
    
    return [
      // Next payment (upcoming)
      Payment(
        id: 'payment_006',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month + 1, 5),
        paidDate: null,
        status: 'Pending',
        proofImageUrl: null,
        referenceNumber: null,
        notes: null,
        rejectionReason: null,
        createdAt: now,
      ),
      
      // Current month (under review)
      Payment(
        id: 'payment_005',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month, 5),
        paidDate: DateTime(now.year, now.month, 4),
        status: 'Under Review',
        proofImageUrl: 'payment_proof_005.jpg',
        referenceNumber: 'GCASH123456789',
        notes: 'Paid via GCash',
        rejectionReason: null,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      
      // Previous payments (verified)
      Payment(
        id: 'payment_004',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month - 1, 5),
        paidDate: DateTime(now.year, now.month - 1, 3),
        status: 'Verified',
        proofImageUrl: 'payment_proof_004.jpg',
        referenceNumber: 'GCASH987654321',
        notes: 'Paid via GCash',
        rejectionReason: null,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      
      Payment(
        id: 'payment_003',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month - 2, 5),
        paidDate: DateTime(now.year, now.month - 2, 4),
        status: 'Verified',
        proofImageUrl: 'payment_proof_003.jpg',
        referenceNumber: 'BDO20231201001',
        notes: 'Paid via BDO Bank Transfer',
        rejectionReason: null,
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      
      Payment(
        id: 'payment_002',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month - 3, 5),
        paidDate: DateTime(now.year, now.month - 3, 5),
        status: 'Verified',
        proofImageUrl: 'payment_proof_002.jpg',
        referenceNumber: 'GCASH555444333',
        notes: 'Paid via GCash',
        rejectionReason: null,
        createdAt: now.subtract(const Duration(days: 120)),
      ),
      
      Payment(
        id: 'payment_001',
        tenantId: 'tenant_001',
        contractId: 'contract_001',
        amount: 8500.00,
        dueDate: DateTime(now.year, now.month - 4, 5),
        paidDate: DateTime(now.year, now.month - 4, 2),
        status: 'Verified',
        proofImageUrl: 'payment_proof_001.jpg',
        referenceNumber: 'GCASH111222333',
        notes: 'Paid via GCash',
        rejectionReason: null,
        createdAt: now.subtract(const Duration(days: 150)),
      ),
    ];
  }
  
  static List<PaymentMethod> getPaymentMethods() {
    return [
      PaymentMethod(
        id: 'method_001',
        type: 'GCash',
        name: 'GCash Payment',
        accountNumber: '0917 123 4567',
        accountName: 'Maria Santos',
        qrCodeUrl: 'gcash_qr.png', // This would be a real QR code URL
        bankName: null,
        isActive: true,
      ),
      PaymentMethod(
        id: 'method_002',
        type: 'Bank Transfer',
        name: 'BDO Bank Transfer',
        accountNumber: '1234 5678 9012',
        accountName: 'Tenora Property Management',
        qrCodeUrl: null,
        bankName: 'BDO',
        isActive: true,
      ),
    ];
  }
  
  static Future<List<Payment>> fetchPaymentHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return getPaymentHistory();
  }
  
  static Future<Payment?> getNextPayment() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final payments = getPaymentHistory();
    return payments.firstWhere(
      (p) => p.isPending && p.dueDate.isAfter(DateTime.now()),
      orElse: () => payments.first,
    );
  }
  
  static Future<List<PaymentMethod>> fetchPaymentMethods() async {
    await Future.delayed(const Duration(seconds: 1));
    return getPaymentMethods();
  }
  
  static Future<Map<String, dynamic>> submitPaymentProof({
    required String paymentId,
    required String referenceNumber,
    required String paymentMethodId,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'data': {
        'message': 'Payment proof submitted successfully. Waiting for admin verification.',
        'payment_id': paymentId,
      },
    };
  }
}