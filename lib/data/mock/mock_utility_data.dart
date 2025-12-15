import '../../domain/models/utility_reading.dart';

class MockUtilityData {
  // Mock configuration per room
  static Map<String, dynamic> getRoomUtilityConfig() {
    return {
      'electricity': {
        'meter_type': 'own_meter', // or 'submeter'
        'can_number': '1234-5678-9012',
        'rate': 12.50, // ₱ per kWh
      },
      'water': {
        'meter_type': 'submeter',
        'can_number': null,
        'rate': 50.00, // ₱ per m³
      },
    };
  }

  static List<UtilityReading> getElectricityReadings() {
    final now = DateTime.now();
    
    return [
      // Current month (pending - tenant needs to submit)
      UtilityReading(
        id: 'elec_003',
        roomId: 'room_201',
        utilityType: 'electricity',
        meterType: 'own_meter',
        readingDate: DateTime(now.year, now.month, 1),
        previousReading: 1523,
        currentReading: 1623,
        consumption: 100,
        rate: 12.50,
        amount: 1250.00,
        canNumber: '1234-5678-9012',
        billImageUrl: null,
        inputBy: 'tenant',
        status: 'pending',
        notes: null,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      
      // Last month (verified)
      UtilityReading(
        id: 'elec_002',
        roomId: 'room_201',
        utilityType: 'electricity',
        meterType: 'own_meter',
        readingDate: DateTime(now.year, now.month - 1, 1),
        previousReading: 1423,
        currentReading: 1523,
        consumption: 100,
        rate: 12.50,
        amount: 1250.00,
        canNumber: '1234-5678-9012',
        billImageUrl: 'bill_elec_002.jpg',
        inputBy: 'tenant',
        status: 'verified',
        notes: 'Verified and added to monthly bill',
        createdAt: now.subtract(const Duration(days: 33)),
      ),
      
      // 2 months ago
      UtilityReading(
        id: 'elec_001',
        roomId: 'room_201',
        utilityType: 'electricity',
        meterType: 'own_meter',
        readingDate: DateTime(now.year, now.month - 2, 1),
        previousReading: 1328,
        currentReading: 1423,
        consumption: 95,
        rate: 12.50,
        amount: 1187.50,
        canNumber: '1234-5678-9012',
        billImageUrl: 'bill_elec_001.jpg',
        inputBy: 'tenant',
        status: 'verified',
        notes: null,
        createdAt: now.subtract(const Duration(days: 63)),
      ),
    ];
  }

  static List<UtilityReading> getWaterReadings() {
    final now = DateTime.now();
    
    return [
      // Current month (admin will input)
      UtilityReading(
        id: 'water_003',
        roomId: 'room_201',
        utilityType: 'water',
        meterType: 'submeter',
        readingDate: DateTime(now.year, now.month, 1),
        previousReading: 40,
        currentReading: 45,
        consumption: 5,
        rate: 50.00,
        amount: 250.00,
        canNumber: null,
        billImageUrl: null,
        inputBy: 'admin',
        status: 'verified',
        notes: 'Monthly reading by admin',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      
      // Last month
      UtilityReading(
        id: 'water_002',
        roomId: 'room_201',
        utilityType: 'water',
        meterType: 'submeter',
        readingDate: DateTime(now.year, now.month - 1, 1),
        previousReading: 35,
        currentReading: 40,
        consumption: 5,
        rate: 50.00,
        amount: 250.00,
        canNumber: null,
        billImageUrl: null,
        inputBy: 'admin',
        status: 'verified',
        notes: 'Monthly reading by admin',
        createdAt: now.subtract(const Duration(days: 32)),
      ),
      
      // 2 months ago
      UtilityReading(
        id: 'water_001',
        roomId: 'room_201',
        utilityType: 'water',
        meterType: 'submeter',
        readingDate: DateTime(now.year, now.month - 2, 1),
        previousReading: 29,
        currentReading: 35,
        consumption: 6,
        rate: 50.00,
        amount: 300.00,
        canNumber: null,
        billImageUrl: null,
        inputBy: 'admin',
        status: 'verified',
        notes: 'Monthly reading by admin',
        createdAt: now.subtract(const Duration(days: 62)),
      ),
    ];
  }

  static Future<List<UtilityReading>> fetchElectricityReadings() async {
    await Future.delayed(const Duration(seconds: 1));
    return getElectricityReadings();
  }

  static Future<List<UtilityReading>> fetchWaterReadings() async {
    await Future.delayed(const Duration(seconds: 1));
    return getWaterReadings();
  }

  static Future<Map<String, dynamic>> submitReading({
    required String utilityType,
    required String canNumber,
    required double previousReading,
    required double currentReading,
    required DateTime readingDate,
    String? notes,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'data': {
        'message': 'Reading submitted successfully. Waiting for admin verification.',
        'reading_id': 'reading_${DateTime.now().millisecondsSinceEpoch}',
      },
    };
  }
}