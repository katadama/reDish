import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? itemCount;
  final double? percentage;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount,
    this.percentage,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      itemCount: json['item_count'] as int?,
      percentage: json['percentage'] as double?,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? itemCount,
    double? percentage,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      itemCount: itemCount ?? this.itemCount,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, createdAt, updatedAt, itemCount, percentage];
}
