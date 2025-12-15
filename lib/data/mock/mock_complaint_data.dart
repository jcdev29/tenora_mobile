import '../../domain/models/complaint.dart';

class MockComplaintData {
  static List<Complaint> getComplaints() {
    final now = DateTime.now();
    
    return [
      Complaint(
        id: 'complaint_003',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Aircon',
        title: 'Aircon not cooling properly',
        description: 'The aircon is running but not cooling the room. It has been like this for 2 days already.',
        priority: 'High',
        status: 'In Progress',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 2)),
        resolvedAt: null,
        adminNotes: 'Technician scheduled for tomorrow at 2PM',
      ),
      
      Complaint(
        id: 'complaint_002',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Plumbing',
        title: 'Slow water drainage in shower',
        description: 'Water in the shower drains very slowly. Might be clogged.',
        priority: 'Medium',
        status: 'Resolved',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 15)),
        resolvedAt: now.subtract(const Duration(days: 14)),
        adminNotes: 'Plumber fixed the drainage. Should be working fine now.',
      ),
      
      Complaint(
        id: 'complaint_001',
        tenantId: 'tenant_001',
        roomId: 'room_201',
        category: 'Electrical',
        title: 'Flickering lights in bathroom',
        description: 'The bathroom lights keep flickering, especially at night.',
        priority: 'Medium',
        status: 'Closed',
        imageUrls: [],
        createdAt: now.subtract(const Duration(days: 30)),
        resolvedAt: now.subtract(const Duration(days: 28)),
        adminNotes: 'Replaced faulty light bulb and checked wiring. All good.',
      ),
    ];
  }
  
  static Future<List<Complaint>> fetchComplaints() async {
    await Future.delayed(const Duration(seconds: 1));
    return getComplaints();
  }
  
  static Future<Map<String, dynamic>> fileComplaint({
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
        'message': 'Complaint filed successfully. Admin will review it soon.',
        'complaint_id': 'complaint_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }
}