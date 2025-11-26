import '../utils/timestamp_stub.dart';

// Модель пользователя для Firestore
class FirestoreUser {
  final String id;
  final String phoneNumber;
  final String name;
  final String userType; // 'client' или 'specialist'
  final String? email;
  final String? oneIdSub; // связка с OneID
  final String? category; // для специалистов
  final String? description; // для специалистов
  final double? pricePerHour; // для специалистов
  final String? avatarUrl;
  final List<String>? deviceTokens;
  final Map<String, bool>? notificationPreferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final Map<String, dynamic>? location; // {lat: double, lng: double}
  final List<String>? skills; // для специалистов
  final double? rating; // средний рейтинг
  final int? totalOrders; // количество заказов

  FirestoreUser({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.userType,
    this.email,
    this.oneIdSub,
    this.category,
    this.description,
    this.pricePerHour,
    this.avatarUrl,
    this.deviceTokens,
    this.notificationPreferences,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.location,
    this.skills,
    this.rating,
    this.totalOrders,
  });

  // Конвертация в Map для Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'userType': userType,
      'email': email,
      'oneIdSub': oneIdSub,
      'category': category,
      'description': description,
      'pricePerHour': pricePerHour,
      'avatarUrl': avatarUrl,
      if (deviceTokens != null) 'deviceTokens': deviceTokens,
      if (notificationPreferences != null) 'notificationPreferences': notificationPreferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isVerified': isVerified,
      'location': location,
      'skills': skills,
      'rating': rating,
      'totalOrders': totalOrders,
    };
  }

  // Создание из Map из Firestore
  factory FirestoreUser.fromMap(Map<String, dynamic> map) {
    return FirestoreUser(
      id: map['id'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      userType: map['userType'] ?? 'client',
      email: map['email'],
      oneIdSub: map['oneIdSub'],
      category: map['category'],
      description: map['description'],
      pricePerHour: map['pricePerHour']?.toDouble(),
      avatarUrl: map['avatarUrl'],
      deviceTokens: map['deviceTokens'] != null
          ? List<String>.from(map['deviceTokens'])
          : const <String>[],
      notificationPreferences: map['notificationPreferences'] != null
          ? Map<String, bool>.from(map['notificationPreferences'])
          : const {
              'push': true,
              'sms': true,
              'email': true,
            },
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isVerified: map['isVerified'] ?? false,
      location: map['location'] != null ? Map<String, dynamic>.from(map['location']) : null,
      skills: map['skills'] != null ? List<String>.from(map['skills']) : null,
      rating: map['rating']?.toDouble(),
      totalOrders: map['totalOrders'],
    );
  }

  // Копирование с изменениями
  FirestoreUser copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? userType,
    String? email,
    String? oneIdSub,
    String? category,
    String? description,
    double? pricePerHour,
    String? avatarUrl,
    List<String>? deviceTokens,
    Map<String, bool>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    Map<String, dynamic>? location,
    List<String>? skills,
    double? rating,
    int? totalOrders,
  }) {
    return FirestoreUser(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      oneIdSub: oneIdSub ?? this.oneIdSub,
      category: category ?? this.category,
      description: description ?? this.description,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      deviceTokens: deviceTokens ?? this.deviceTokens,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      skills: skills ?? this.skills,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
    );
  }
}

// Модель услуги специалиста
class FirestoreSpecialistService {
  final String id;
  final String specialistId;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? category;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreSpecialistService({
    required this.id,
    required this.specialistId,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.category,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'specialistId': specialistId,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory FirestoreSpecialistService.fromMap(Map<String, dynamic> map) {
    return FirestoreSpecialistService(
      id: map['id'] ?? '',
      specialistId: map['specialistId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      price: map['price']?.toDouble() ?? 0.0,
      durationMinutes: map['durationMinutes'] ?? 0,
      category: map['category'],
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  FirestoreSpecialistService copyWith({
    String? id,
    String? specialistId,
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? category,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FirestoreSpecialistService(
      id: id ?? this.id,
      specialistId: specialistId ?? this.specialistId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Услуга, выбранная в заказе
class OrderServiceItem {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String? description;
  final String? category;

  const OrderServiceItem({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'category': category,
    };
  }

  factory OrderServiceItem.fromMap(Map<String, dynamic> map) {
    return OrderServiceItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      durationMinutes: map['durationMinutes'] ?? 0,
      description: map['description'],
      category: map['category'],
    );
  }
}

// Модель заказа
class FirestoreOrder {
  final String id;
  final String clientId;
  final String specialistId;
  final String category;
  final String title;
  final String description;
  final String status; // 'pending', 'accepted', 'in_progress', 'completed', 'cancelled'
  final double price;
  final String? address;
  final Map<String, dynamic>? location;
  final DateTime scheduledDate;
  final String? timeSlot;
  final int totalDurationMinutes;
  final List<OrderServiceItem> services;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? images;
  final String? notes;
  final double? rating;
  final String? review;

  FirestoreOrder({
    required this.id,
    required this.clientId,
    required this.specialistId,
    required this.category,
    required this.title,
    required this.description,
    required this.status,
    required this.price,
    this.address,
    this.location,
    required this.scheduledDate,
    this.timeSlot,
    this.totalDurationMinutes = 0,
    this.services = const [],
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.images,
    this.notes,
    this.rating,
    this.review,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'specialistId': specialistId,
      'category': category,
      'title': title,
      'description': description,
      'status': status,
      'price': price,
      'address': address,
      'location': location,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'timeSlot': timeSlot,
      'totalDurationMinutes': totalDurationMinutes,
      'services': services.map((service) => service.toMap()).toList(),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'images': images,
      'notes': notes,
      'rating': rating,
      'review': review,
    };
  }

  factory FirestoreOrder.fromMap(Map<String, dynamic> map) {
    return FirestoreOrder(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      specialistId: map['specialistId'] ?? '',
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      price: map['price']?.toDouble() ?? 0.0,
      address: map['address'],
      location: map['location'] != null ? Map<String, dynamic>.from(map['location']) : null,
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'],
      totalDurationMinutes: map['totalDurationMinutes'] ?? 0,
      services: map['services'] != null
          ? List<Map<String, dynamic>>.from(map['services'])
              .map(OrderServiceItem.fromMap)
              .toList()
          : const [],
      completedAt: map['completedAt'] != null ? (map['completedAt'] as Timestamp).toDate() : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      images: map['images'] != null ? List<String>.from(map['images']) : null,
      notes: map['notes'],
      rating: map['rating']?.toDouble(),
      review: map['review'],
    );
  }

  FirestoreOrder copyWith({
    String? id,
    String? clientId,
    String? specialistId,
    String? category,
    String? title,
    String? description,
    String? status,
    double? price,
    String? address,
    Map<String, dynamic>? location,
    DateTime? scheduledDate,
    String? timeSlot,
    int? totalDurationMinutes,
    List<OrderServiceItem>? services,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    List<String>? images,
    String? notes,
    double? rating,
    String? review,
  }) {
    return FirestoreOrder(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      specialistId: specialistId ?? this.specialistId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      price: price ?? this.price,
      address: address ?? this.address,
      location: location ?? this.location,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      services: services ?? this.services,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      review: review ?? this.review,
    );
  }
}

// Модель отзыва
class FirestoreReview {
  final String id;
  final String orderId;
  final String clientId;
  final String specialistId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  FirestoreReview({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.specialistId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'clientId': clientId,
      'specialistId': specialistId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FirestoreReview.fromMap(Map<String, dynamic> map) {
    return FirestoreReview(
      id: map['id'] ?? '',
      orderId: map['orderId'] ?? '',
      clientId: map['clientId'] ?? '',
      specialistId: map['specialistId'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
