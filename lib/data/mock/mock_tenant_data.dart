import '../../domain/models/tenant.dart';
import '../../domain/models/user.dart';
import '../../domain/models/room.dart';

class MockTenantData {
  static Tenant getCurrentTenant() {
    return Tenant(
      id: 'tenant_001',
      user: User(
        id: 'user_001',
        email: 'juan@email.com',
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        phone: '+63 917 123 4567',
        profileImageUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      currentRoom: Room(
        id: 'room_201',
        roomNumber: '201',
        floor: '2nd Floor',
        monthlyRate: 8500.00,
        size: 18.5,
        amenities: [
          'Air Conditioning',
          'Private Bathroom',
          'WiFi',
          'Bed Frame',
          'Study Table',
          'Cabinet',
        ],
        status: 'Occupied',
        imageUrls: null,
      ),
      emergencyContactName: 'Maria Dela Cruz',
      emergencyContactPhone: '+63 918 765 4321',
      emergencyContactRelation: 'Mother',
      status: 'Active',
      moveInDate: DateTime.now().subtract(const Duration(days: 150)),
      moveOutDate: null,
      idDocumentUrls: ['id_front.jpg', 'id_back.jpg'],
    );
  }
  
  static Future<Tenant> fetchTenantProfile() async {
    await Future.delayed(const Duration(seconds: 1));
    return getCurrentTenant();
  }
  
  static Future<Map<String, dynamic>> updateProfile({
    required String phone,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String emergencyContactRelation,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'data': {
        'message': 'Profile updated successfully',
      },
    };
  }
}