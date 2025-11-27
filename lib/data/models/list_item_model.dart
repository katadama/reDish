import 'package:equatable/equatable.dart';

class ListItemModel extends Equatable {
  final String id;
  final String userId;
  final String profileId;
  final String name;
  final String? categoryId;
  final String? categoryName;
  final double price;
  final int weight;
  final int db;
  final int psdays;
  final int listType;
  final DateTime? lastMovedAt;
  final String? profileName;
  final int? profileColorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListItemModel({
    required this.id,
    required this.userId,
    required this.profileId,
    required this.name,
    this.categoryId,
    this.categoryName,
    required this.price,
    required this.weight,
    required this.db,
    required this.psdays,
    required this.listType,
    this.lastMovedAt,
    this.profileName,
    this.profileColorIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ListItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? lastMovedAt;
    if (json['last_moved_at'] != null) {
      lastMovedAt = DateTime.parse(json['last_moved_at'] as String);
    }

    String? categoryName;
    if (json.containsKey('categories')) {
      final categoryData = json['categories'] as Map<String, dynamic>?;
      categoryName = categoryData?['name'] as String?;
    } else if (json.containsKey('category_name')) {
      categoryName = json['category_name'] as String?;
    }

    String? profileName;
    int? profileColorIndex;
    if (json.containsKey('profiles')) {
      final profileData = json['profiles'] as Map<String, dynamic>?;
      profileName = profileData?['name'] as String?;
      profileColorIndex = profileData?['color'] as int?;
    } else {
      profileName = json['profile_name'] as String?;
      profileColorIndex = json['profile_color'] as int?;
    }

    return ListItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      profileId: json['profile_id'] as String,
      name: json['name'] as String,
      categoryId: json['category_id'] as String?,
      categoryName: categoryName,
      price: (json['price'] as num).toDouble(),
      weight: json['weight'] as int,
      db: json['db'] as int,
      psdays: json['psdays'] as int,
      listType: json['list_type'] as int,
      lastMovedAt: lastMovedAt,
      profileName: profileName,
      profileColorIndex: profileColorIndex,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'profile_id': profileId,
      'name': name,
      'category_id': categoryId,
      'price': price,
      'weight': weight,
      'db': db,
      'psdays': psdays,
      'list_type': listType,
      if (lastMovedAt != null) 'last_moved_at': lastMovedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ListItemModel copyWith({
    String? id,
    String? userId,
    String? profileId,
    String? name,
    String? categoryId,
    String? categoryName,
    double? price,
    int? weight,
    int? db,
    int? psdays,
    int? listType,
    DateTime? lastMovedAt,
    String? profileName,
    int? profileColorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      db: db ?? this.db,
      psdays: psdays ?? this.psdays,
      listType: listType ?? this.listType,
      lastMovedAt: lastMovedAt ?? this.lastMovedAt,
      profileName: profileName ?? this.profileName,
      profileColorIndex: profileColorIndex ?? this.profileColorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        profileId,
        name,
        categoryId,
        categoryName,
        price,
        weight,
        db,
        psdays,
        listType,
        lastMovedAt,
        profileName,
        profileColorIndex,
        createdAt,
        updatedAt,
      ];
}
