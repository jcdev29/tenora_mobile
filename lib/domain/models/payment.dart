class Payment {
  final String id;
  final String tenantId;
  final String contractId;
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // Pending, Under Review, Verified, Rejected, Overdue
  final String? proofImageUrl;
  final String? referenceNumber;
  final String? notes;
  final String? rejectionReason;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.tenantId,
    required this.contractId,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    required this.status,
    this.proofImageUrl,
    this.referenceNumber,
    this.notes,
    this.rejectionReason,
    required this.createdAt,
  });

  bool get isPending => status == 'Pending';
  bool get isUnderReview => status == 'Under Review';
  bool get isVerified => status == 'Verified';
  bool get isRejected => status == 'Rejected';
  bool get isOverdue => status == 'Overdue' || 
      (isPending && dueDate.isBefore(DateTime.now()));

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  String get formattedAmount => '₱${amount.toStringAsFixed(2)}';

  String get statusColor {
    switch (status) {
      case 'Verified':
        return 'success';
      case 'Under Review':
        return 'warning';
      case 'Rejected':
      case 'Overdue':
        return 'error';
      default:
        return 'pending';
    }
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      tenantId: json['tenant_id'],
      contractId: json['contract_id'],
      amount: json['amount'].toDouble(),
      dueDate: DateTime.parse(json['due_date']),
      paidDate: json['paid_date'] != null 
          ? DateTime.parse(json['paid_date']) 
          : null,
      status: json['status'],
      proofImageUrl: json['proof_image_url'],
      referenceNumber: json['reference_number'],
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'contract_id': contractId,
      'amount': amount,
      'due_date': dueDate.toIso8601String(),
      'paid_date': paidDate?.toIso8601String(),
      'status': status,
      'proof_image_url': proofImageUrl,
      'reference_number': referenceNumber,
      'notes': notes,
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
    };
  }
}