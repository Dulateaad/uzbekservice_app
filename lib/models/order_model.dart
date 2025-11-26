import 'package:hive/hive.dart';

part 'order_model.g.dart';

@HiveType(typeId: 2)
class Order extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String clientId;
  
  @HiveField(2)
  final String specialistId;
  
  @HiveField(3)
  final String title;
  
  @HiveField(4)
  final String description;
  
  @HiveField(5)
  final String address;
  
  @HiveField(6)
  final double latitude;
  
  @HiveField(7)
  final double longitude;
  
  @HiveField(8)
  final DateTime scheduledDate;
  
  @HiveField(9)
  final int estimatedHours;
  
  @HiveField(10)
  final double totalPrice;
  
  @HiveField(11)
  final String status;
  
  @HiveField(12)
  final String? clientNotes;
  
  @HiveField(13)
  final String? specialistNotes;
  
  @HiveField(14)
  final DateTime createdAt;
  
  @HiveField(15)
  final DateTime updatedAt;
  
  @HiveField(16)
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.clientId,
    required this.specialistId,
    required this.title,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledDate,
    required this.estimatedHours,
    required this.totalPrice,
    required this.status,
    this.clientNotes,
    this.specialistNotes,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      clientId: json['client_id'],
      specialistId: json['specialist_id'],
      title: json['title'],
      description: json['description'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      scheduledDate: DateTime.parse(json['scheduled_date']),
      estimatedHours: json['estimated_hours'],
      totalPrice: (json['total_price'] as num).toDouble(),
      status: json['status'],
      clientNotes: json['client_notes'],
      specialistNotes: json['specialist_notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'specialist_id': specialistId,
      'title': title,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduled_date': scheduledDate.toIso8601String(),
      'estimated_hours': estimatedHours,
      'total_price': totalPrice,
      'status': status,
      'client_notes': clientNotes,
      'specialist_notes': specialistNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  Order copyWith({
    String? id,
    String? clientId,
    String? specialistId,
    String? title,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledDate,
    int? estimatedHours,
    double? totalPrice,
    String? status,
    String? clientNotes,
    String? specialistNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Order(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      specialistId: specialistId ?? this.specialistId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      clientNotes: clientNotes ?? this.clientNotes,
      specialistNotes: specialistNotes ?? this.specialistNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}