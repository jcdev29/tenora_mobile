import 'user.dart';
import 'room.dart';

class Tenant {
  final String id;
  final User user;
  final Room? currentRoom;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final String status; // Pending, Verified, Active, Inactive
  final DateTime? moveInDate;
  final DateTime? moveOutDate;
  final List<String> idDocumentUrls;

  Tenant({
    required this.id,
    required this.user,
    this.currentRoom,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    required this.status,
    this.moveInDate,
    this.moveOutDate,
    required this.idDocumentUrls,
  });

  bool get isActive => status == 'Active';
  bool get isPending => status == 'Pending';
  bool get hasRoom => currentRoom != null;

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      user: User.fromJson(json['user']),
      currentRoom: json['current_room'] != null 
          ? Room.fromJson(json['current_room']) 
          : null,
      emergencyContactName: json['emergency_contact_name'],
      emergencyContactPhone: json['emergency_contact_phone'],
      emergencyContactRelation: json['emergency_contact_relation'],
      status: json['status'],
      moveInDate: json['move_in_date'] != null 
          ? DateTime.parse(json['move_in_date']) 
          : null,
      moveOutDate: json['move_out_date'] != null 
          ? DateTime.parse(json['move_out_date']) 
          : null,
      idDocumentUrls: List<String>.from(json['id_document_urls']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'current_room': currentRoom?.toJson(),
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relation': emergencyContactRelation,
      'status': status,
      'move_in_date': moveInDate?.toIso8601String(),
      'move_out_date': moveOutDate?.toIso8601String(),
      'id_document_urls': idDocumentUrls,
    };
  }
}