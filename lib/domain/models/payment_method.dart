class PaymentMethod {
  final String id;
  final String type; // GCash, Bank Transfer
  final String name;
  final String accountNumber;
  final String? accountName;
  final String? qrCodeUrl;
  final String? bankName;
  final bool isActive;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.accountNumber,
    this.accountName,
    this.qrCodeUrl,
    this.bankName,
    required this.isActive,
  });

  bool get isGCash => type == 'GCash';
  bool get isBankTransfer => type == 'Bank Transfer';

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      accountNumber: json['account_number'],
      accountName: json['account_name'],
      qrCodeUrl: json['qr_code_url'],
      bankName: json['bank_name'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'account_number': accountNumber,
      'account_name': accountName,
      'qr_code_url': qrCodeUrl,
      'bank_name': bankName,
      'is_active': isActive,
    };
  }
}