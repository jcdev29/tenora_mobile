import '../../domain/models/request.dart';

class MockRequestData {
  static List<MaintenanceRequest> getRequests() {
    final now = DateTime.now();

    return [
      MaintenanceRequest(
        id: 'request_003',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Aircon',
        title: 'Aircon not cooling properly',
        description:
            'The aircon is running but not cooling the room. It has been like this for 2 days already.',
        priority: 'High',
        status: 'In Progress',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: null,
        adminNotes: 'Technician scheduled for tomorrow at 2PM',
      ),

      MaintenanceRequest(
        id: 'request_002',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Plumbing',
        title: 'Slow water drainage in shower',
        description:
            'Water in the shower drains very slowly. Might be clogged.',
        priority: 'Medium',
        status: 'Resolved',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 15)),
        resolvedAt: now.subtract(const Duration(days: 14)),
        adminNotes: 'Plumber fixed the drainage. Should be working fine now.',
      ),

      MaintenanceRequest(
        id: 'request_001',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Electrical',
        title: 'Flickering lights in bathroom',
        description:
            'The bathroom lights keep flickering, especially at night.',
        priority: 'Medium',
        status: 'Closed',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 30)),
        resolvedAt: now.subtract(const Duration(days: 28)),
        adminNotes: 'Replaced faulty light bulb and checked wiring. All good.',
      ),
    ];
  }

  static Future<List<MaintenanceRequest>> fetchRequests() async {
    await Future.delayed(const Duration(seconds: 1));
    return getRequests();
  }

  static Future<Map<String, dynamic>> fileRequest({
    required String category,
    required String title,
    required String description,
    required String priority,
    List<String>? imageUrls,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    return {
      'success': true,
      'data': {
        'message': 'Request submitted successfully. Admin will review it soon.',
        'request_id': 'request_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }
}
