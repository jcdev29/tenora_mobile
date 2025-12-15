import '../../domain/models/contract.dart';

class MockContractData {
  static Contract getCurrentContract() {
    final startDate = DateTime.now().subtract(const Duration(days: 150));
    final endDate = startDate.add(const Duration(days: 365));
    
    return Contract(
      id: 'contract_001',
      tenantId: 'tenant_001',
      roomId: 'room_201',
      startDate: startDate,
      endDate: endDate,
      monthlyRate: 8500.00,
      securityDeposit: 17000.00,
      status: 'Active',
      terms: '''
RENTAL AGREEMENT TERMS AND CONDITIONS

1. RENT PAYMENT
   - Monthly rent of ₱8,500.00 is due on the 5th of each month
   - Late payment fee of ₱200.00 per day applies after the 5th
   - Payment can be made via GCash or Bank Transfer

2. SECURITY DEPOSIT
   - One-time security deposit of ₱17,000.00 (2 months rent)
   - Refundable upon move-out if no damages
   - Will be used to cover any unpaid bills or damages

3. UTILITIES
   - Electricity and water are metered separately
   - Internet is included in the monthly rent
   - Tenant responsible for own electricity and water bills

4. HOUSE RULES
   - No pets allowed
   - No smoking inside the room
   - Quiet hours from 10:00 PM to 6:00 AM
   - Visitors allowed until 9:00 PM only
   - No subleasing without owner's permission

5. MAINTENANCE
   - Tenant must report any damages immediately
   - Owner responsible for major repairs
   - Tenant responsible for damages caused by misuse

6. TERMINATION
   - Tenant must give 1 month advance notice
   - Owner must give 2 months advance notice
   - Early termination forfeits security deposit

7. RENEWAL
   - Contract can be renewed 30 days before expiration
   - Rent increase may apply upon renewal
   - New contract terms may be negotiated

I have read and understood all terms and conditions stated above.
      ''',
      createdAt: startDate,
      signedAt: startDate,
    );
  }
  
  static Future<Contract> fetchActiveContract() async {
    await Future.delayed(const Duration(seconds: 1));
    return getCurrentContract();
  }
  
  static Future<Map<String, dynamic>> requestRenewal(String message) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'success': true,
      'data': {
        'message': 'Renewal request submitted successfully. Admin will contact you soon.',
      },
    };
  }
}