class UtilityReading {
  final String id;
  final String roomId;
  final String utilityType; // electricity, water
  final String meterType; // own_meter, submeter
  final DateTime readingDate;
  final double previousReading;
  final double currentReading;
  final double consumption; // currentReading - previousReading
  final double rate; // per kWh or m³
  final double amount; // consumption * rate
  final String? canNumber; // Customer Account Number (for own_meter only)
  final String? billImageUrl; // Bill photo (for own_meter only)
  final String inputBy; // tenant, admin
  final String status; // pending, verified, rejected
  final String? notes;
  final DateTime createdAt;

  UtilityReading({
    required this.id,
    required this.roomId,
    required this.utilityType,
    required this.meterType,
    required this.readingDate,
    required this.previousReading,
    required this.currentReading,
    required this.consumption,
    required this.rate,
    required this.amount,
    this.canNumber,
    this.billImageUrl,
    required this.inputBy,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';
  bool get isRejected => status == 'rejected';
  
  bool get isOwnMeter => meterType == 'own_meter';
  bool get isSubmeter => meterType == 'submeter';
  
  bool get isElectricity => utilityType == 'electricity';
  bool get isWater => utilityType == 'water';

  String get formattedAmount => '₱${amount.toStringAsFixed(2)}';
  String get formattedConsumption {
    if (isElectricity) {
      return '${consumption.toStringAsFixed(0)} kWh';
    } else {
      return '${consumption.toStringAsFixed(1)} m³';
    }
  }

  factory UtilityReading.fromJson(Map<String, dynamic> json) {
    return UtilityReading(
      id: json['id'],
      roomId: json['room_id'],
      utilityType: json['utility_type'],
      meterType: json['meter_type'],
      readingDate: DateTime.parse(json['reading_date']),
      previousReading: json['previous_reading'].toDouble(),
      currentReading: json['current_reading'].toDouble(),
      consumption: json['consumption'].toDouble(),
      rate: json['rate'].toDouble(),
      amount: json['amount'].toDouble(),
      canNumber: json['can_number'],
      billImageUrl: json['bill_image_url'],
      inputBy: json['input_by'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'utility_type': utilityType,
      'meter_type': meterType,
      'reading_date': readingDate.toIso8601String(),
      'previous_reading': previousReading,
      'current_reading': currentReading,
      'consumption': consumption,
      'rate': rate,
      'amount': amount,
      'can_number': canNumber,
      'bill_image_url': billImageUrl,
      'input_by': inputBy,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}