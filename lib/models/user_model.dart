class UserModel {
  final String id;
  final String phoneNumber;
  final String name;
  final String? email;
  final String userType; // 'client' или 'specialist'
  final String? category;
  final String? description;
  final double? pricePerHour;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.email,
    required this.userType,
    this.category,
    this.description,
    this.pricePerHour,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'userType': userType,
      'category': category,
      'description': description,
      'pricePerHour': pricePerHour,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      email: map['email'],
      userType: map['userType'],
      category: map['category'],
      description: map['description'],
      pricePerHour: map['pricePerHour']?.toDouble(),
      avatar: map['avatar'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isVerified: map['isVerified'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? email,
    String? userType,
    String? category,
    String? description,
    double? pricePerHour,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      category: category ?? this.category,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}