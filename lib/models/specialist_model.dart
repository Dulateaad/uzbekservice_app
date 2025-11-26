import 'package:hive/hive.dart';

part 'specialist_model.g.dart';

@HiveType(typeId: 1)
class Specialist extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final String description;
  
  @HiveField(5)
  final double pricePerHour;
  
  @HiveField(6)
  final List<String> photos;
  
  @HiveField(7)
  final double rating;
  
  @HiveField(8)
  final int reviewCount;
  
  @HiveField(9)
  final String location;
  
  @HiveField(10)
  final double latitude;
  
  @HiveField(11)
  final double longitude;
  
  @HiveField(12)
  final bool isAvailable;
  
  @HiveField(13)
  final DateTime createdAt;
  
  @HiveField(14)
  final DateTime updatedAt;

  Specialist({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.description,
    required this.pricePerHour,
    this.photos = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Specialist.fromJson(Map<String, dynamic> json) {
    return Specialist(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      pricePerHour: (json['price_per_hour'] as num).toDouble(),
      photos: List<String>.from(json['photos'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] ?? 0,
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isAvailable: json['is_available'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'category': category,
      'description': description,
      'price_per_hour': pricePerHour,
      'photos': photos,
      'rating': rating,
      'review_count': reviewCount,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'is_available': isAvailable,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Specialist copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? description,
    double? pricePerHour,
    List<String>? photos,
    double? rating,
    int? reviewCount,
    String? location,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Specialist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}