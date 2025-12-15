class MaintenanceRequest {
  final String id;
  final String tenantId;
  final String roomId;
  final String category;
  final String title;
  final String description;
  final String priority; // Low, Medium, High, Urgent
  final String status; // Open, In Progress, Resolved, Closed
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminNotes;

  MaintenanceRequest({
    required this.id,
    required this.tenantId,
    required this.roomId,
    required this.category,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.imageUrls,
    required this.createdAt,
    this.resolvedAt,
    this.adminNotes,
  });

  bool get isOpen => status == 'Open';
  bool get isInProgress => status == 'In Progress';
  bool get isResolved => status == 'Resolved';
  bool get isClosed => status == 'Closed';

  String get statusColor {
    switch (status) {
      case 'Resolved':
      case 'Closed':
        return 'success';
      case 'In Progress':
        return 'warning';
      case 'Open':
        return 'error';
      default:
        return 'pending';
    }
  }

  String get priorityColor {
    switch (priority) {
      case 'Urgent':
        return 'error';
      case 'High':
        return 'warning';
      case 'Medium':
        return 'info';
      case 'Low':
        return 'success';
      default:
        return 'pending';
    }
  }

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'],
      tenantId: json['tenant_id'],
      roomId: json['room_id'],
      category: json['category'],
      title: json['title'],
      description: json['description'],
      priority: json['priority'],
      status: json['status'],
      imageUrls: List<String>.from(json['image_urls']),
      createdAt: DateTime.parse(json['created_at']),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      adminNotes: json['admin_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'room_id': roomId,
      'category': category,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'admin_notes': adminNotes,
    };
  }
}
