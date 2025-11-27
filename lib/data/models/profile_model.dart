import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:coo_list/utils/profile_colors.dart';

class ProfileModel extends Equatable {
  final String id;
  final String userId;
  final String name;
  final int colorIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  Color get color => ProfileColors.getColorByIndex(colorIndex);

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      colorIndex: json['color'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': colorIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? name,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, name, colorIndex, createdAt, updatedAt];
}



