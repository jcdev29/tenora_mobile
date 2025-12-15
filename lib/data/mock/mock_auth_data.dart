import '../../core/constants/app_constants.dart';

class MockAuthData {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    if (email == AppConstants.mockEmail && password == AppConstants.mockPassword) {
      return {
        'success': true,
        'data': {
          'token': 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 'tenant_001',
            'email': email,
            'first_name': 'Juan',
            'last_name': 'Dela Cruz',
            'phone': '+63 917 123 4567',
            'profile_image_url': null,
            'created_at': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
          },
        },
      };
    } else {
      return {
        'success': false,
        'error': 'Invalid email or password',
      };
    }
  }
  
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String emergencyContactRelation,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'data': {
        'message': 'Registration successful. Please wait for admin verification.',
        'tenant_id': 'tenant_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }
  
  static Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}