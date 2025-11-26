import 'package:hive/hive.dart';

part 'review_model.g.dart';

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String orderId;
  
  @HiveField(2)
  final String clientId;
  
  @HiveField(3)
  final String specialistId;
  
  @HiveField(4)
  final int rating;
  
  @HiveField(5)
  final String comment;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.specialistId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      orderId: json['order_id'],
      clientId: json['client_id'],
      specialistId: json['specialist_id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'client_id': clientId,
      'specialist_id': specialistId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Review copyWith({
    String? id,
    String? orderId,
    String? clientId,
    String? specialistId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      specialistId: specialistId ?? this.specialistId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}