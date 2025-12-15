class Contract {
  final String id;
  final String tenantId;
  final String roomId;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRate;
  final double securityDeposit;
  final String status; // Draft, Active, Expiring, Expired, Renewed
  final String? terms;
  final DateTime createdAt;
  final DateTime? signedAt;

  Contract({
    required this.id,
    required this.tenantId,
    required this.roomId,
    required this.startDate,
    required this.endDate,
    required this.monthlyRate,
    required this.securityDeposit,
    required this.status,
    this.terms,
    required this.createdAt,
    this.signedAt,
  });

  int get durationInMonths {
    return endDate.month - startDate.month + 
           (endDate.year - startDate.year) * 12;
  }

  int get daysUntilExpiry {
    return endDate.difference(DateTime.now()).inDays;
  }

  bool get isActive => status == 'Active';
  bool get isExpiring => status == 'Expiring' || (isActive && daysUntilExpiry <= 30);
  bool get isExpired => status == 'Expired' || endDate.isBefore(DateTime.now());

  String get formattedMonthlyRate => '₱${monthlyRate.toStringAsFixed(2)}';
  String get formattedSecurityDeposit => '₱${securityDeposit.toStringAsFixed(2)}';

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      monthlyRate: json['monthly_rate'].toDouble(),
      securityDeposit: json['security_deposit'].toDouble(),
      status: json['status'],
      terms: json['terms'],
      createdAt: DateTime.parse(json['created_at']),
      signedAt: json['signed_at'] != null 
          ? DateTime.parse(json['signed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'room_id': roomId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'monthly_rate': monthlyRate,
      'security_deposit': securityDeposit,
      'status': status,
      'terms': terms,
      'created_at': createdAt.toIso8601String(),
      'signed_at': signedAt?.toIso8601String(),
    };
  }
}