class Room {
  final String id;
  final String roomNumber;
  final String floor;
  final double monthlyRate;
  final double size; // in sqm
  final List<String> amenities;
  final String status; // Available, Occupied, Under Maintenance
  final List<String>? imageUrls;

  Room({
    required this.id,
    required this.roomNumber,
    required this.floor,
    required this.monthlyRate,
    required this.size,
    required this.amenities,
    required this.status,
    this.imageUrls,
  });

  String get formattedRate => '₱${monthlyRate.toStringAsFixed(2)}';
  
  bool get isAvailable => status == 'Available';
  bool get isOccupied => status == 'Occupied';

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      roomNumber: json['room_number'],
      floor: json['floor'],
      monthlyRate: json['monthly_rate'].toDouble(),
      size: json['size'].toDouble(),
      amenities: List<String>.from(json['amenities']),
      status: json['status'],
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_number': roomNumber,
      'floor': floor,
      'monthly_rate': monthlyRate,
      'size': size,
      'amenities': amenities,
      'status': status,
      'image_urls': imageUrls,
    };
  }
}