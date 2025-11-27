import 'package:equatable/equatable.dart';
import 'package:coo_list/utils/date_utils.dart';

class ProductModel extends Equatable {
  final String name;
  final String category;
  final int price;
  final int weight;
  final int db;
  final int spoilage;
  final DateTime? lastMovedAt;
  final String? error;
  final String? profileName;
  final int? profileColorIndex;

  const ProductModel({
    required this.name,
    required this.category,
    required this.price,
    required this.weight,
    required this.db,
    required this.spoilage,
    this.lastMovedAt,
    this.error,
    this.profileName,
    this.profileColorIndex,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      return ProductModel(
        name: '',
        category: '',
        price: 0,
        weight: 0,
        db: 0,
        spoilage: 0,
        error: json['error'] as String,
      );
    }

    return ProductModel(
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      weight: json['weight'] as int,
      db: json['db'] as int,
      spoilage: json['spoilage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    if (error != null) {
      return {'error': error};
    }

    return {
      'name': name,
      'category': category,
      'price': price,
      'weight': weight,
      'db': db,
      'spoilage': spoilage,
      if (lastMovedAt != null) 'last_moved_at': lastMovedAt!.toIso8601String(),
      if (profileName != null) 'profile_name': profileName,
      if (profileColorIndex != null) 'profile_color': profileColorIndex,
    };
  }

  Map<String, dynamic> toListItemJson({
    required String userId,
    required String profileId,
    required int listType,
    String? categoryId,
  }) {
    return {
      'user_id': userId,
      'profile_id': profileId,
      'name': name,
      'db': db,
      'price': price.toDouble(),
      'category_id': categoryId,
      'list_type': listType,
      'weight': weight,
      'psdays': spoilage,
      if (lastMovedAt != null) 'last_moved_at': lastMovedAt!.toIso8601String(),
    };
  }

  DateTime? getSpoilDate() {
    if (lastMovedAt == null || spoilage <= 0) return null;
    return ProductDateUtils.calculateSpoilDate(lastMovedAt!, spoilage);
  }

  int? getDaysUntilSpoiled() {
    if (lastMovedAt == null || spoilage <= 0) return null;
    return ProductDateUtils.calculateDaysUntilSpoiled(lastMovedAt!, spoilage);
  }

  String? getSpoilageStatusMessage() {
    final daysUntilSpoiled = getDaysUntilSpoiled();
    if (daysUntilSpoiled == null) return null;
    return ProductDateUtils.getSpoilageStatusMessage(daysUntilSpoiled);
  }

  ProductModel copyWith({
    String? name,
    String? category,
    int? price,
    int? weight,
    int? db,
    int? spoilage,
    DateTime? lastMovedAt,
    String? error,
    String? profileName,
    int? profileColorIndex,
  }) {
    return ProductModel(
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      db: db ?? this.db,
      spoilage: spoilage ?? this.spoilage,
      lastMovedAt: lastMovedAt ?? this.lastMovedAt,
      error: error ?? this.error,
      profileName: profileName ?? this.profileName,
      profileColorIndex: profileColorIndex ?? this.profileColorIndex,
    );
  }

  @override
  List<Object?> get props => [
        name,
        category,
        price,
        weight,
        db,
        spoilage,
        lastMovedAt,
        error,
        profileName,
        profileColorIndex,
      ];
}
