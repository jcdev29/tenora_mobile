class AppNotification {
  final String id;
  final String tenantId;
  final String title;
  final String message;
  final String type; // Payment, Contract, Complaint, General
  final String? relatedId; // ID of related payment, contract, etc.
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.tenantId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      tenantId: json['tenant_id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      relatedId: json['related_id'],
      isRead: json['is_read'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'title': title,
      'message': message,
      'type': type,
      'related_id': relatedId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}